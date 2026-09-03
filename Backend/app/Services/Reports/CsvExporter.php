<?php

declare(strict_types=1);

namespace App\Services\Reports;

use Symfony\Component\HttpFoundation\StreamedResponse;

class CsvExporter
{
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
                fputcsv($handle, $row);
            }

            fclose($handle);
        }, $filename, ['Content-Type' => 'text/csv']);
    }
}
