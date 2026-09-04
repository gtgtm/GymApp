<?php

declare(strict_types=1);

namespace App\Services\Reports;

use Symfony\Component\HttpFoundation\StreamedResponse;

class CsvExporter
{
    /**
     * Formula-injection trigger characters recognised by Excel/Sheets/LibreOffice.
     * A cell starting with any of these can execute as a formula when opened.
     */
    private const FORMULA_TRIGGER_CHARS = ['=', '+', '-', '@', "\t", "\r"];

    /**
     * @param  array<int, array<string, mixed>>  $rows
     */
    public function stream(string $filename, array $rows): StreamedResponse
    {
        return response()->streamDownload(function () use ($rows) {
            $handle = fopen('php://output', 'w');

            if ($rows === []) {
                fclose($handle);

                return;
            }

            fputcsv($handle, array_keys($rows[0]));

            foreach ($rows as $row) {
                fputcsv($handle, array_map($this->escapeCell(...), $row));
            }

            fclose($handle);
        }, $filename, ['Content-Type' => 'text/csv']);
    }

    private function escapeCell(mixed $value): mixed
    {
        if (! is_string($value) || $value === '') {
            return $value;
        }

        if (in_array($value[0], self::FORMULA_TRIGGER_CHARS, true)) {
            return "'".$value;
        }

        return $value;
    }
}
