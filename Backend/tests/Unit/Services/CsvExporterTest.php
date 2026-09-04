<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Services\Reports\CsvExporter;
use Tests\TestCase;

class CsvExporterTest extends TestCase
{
    private function renderedCsv(array $rows): string
    {
        $response = (new CsvExporter)->stream('test.csv', $rows);

        ob_start();
        $response->sendContent();

        return ob_get_clean();
    }

    public function test_formula_prefixed_values_are_neutralized(): void
    {
        $csv = $this->renderedCsv([
            ['name' => '=cmd|"/c calc"!A0', 'amount' => 100],
        ]);

        $this->assertStringContainsString("'=cmd", $csv);
    }

    public function test_plus_and_minus_and_at_prefixes_are_neutralized(): void
    {
        $csv = $this->renderedCsv([
            ['a' => '+1+1', 'b' => '-1+1', 'c' => '@SUM(A1)'],
        ]);

        $this->assertStringContainsString("'+1+1", $csv);
        $this->assertStringContainsString("'-1+1", $csv);
        $this->assertStringContainsString("'@SUM", $csv);
    }

    public function test_normal_values_are_untouched(): void
    {
        $csv = $this->renderedCsv([
            ['name' => 'Vikas Kumar', 'amount' => 1500],
        ]);

        $this->assertStringContainsString('Vikas Kumar', $csv);
        $this->assertStringNotContainsString("'Vikas", $csv);
    }
}
