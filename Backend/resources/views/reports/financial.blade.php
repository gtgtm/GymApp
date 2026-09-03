<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: DejaVu Sans, sans-serif; color: #1a1a1a; font-size: 12px; }
        h1 { font-size: 18px; margin-bottom: 0; }
        p.subtitle { color: #666; margin-top: 4px; }
        table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        th, td { text-align: left; padding: 6px 8px; border-bottom: 1px solid #ddd; }
        th { background: #f5f5f5; }
        .totals { margin-top: 16px; }
        .totals td { font-weight: bold; }
    </style>
</head>
<body>
    <h1>{{ $gym->name }} — Financial Report</h1>
    <p class="subtitle">{{ $summary['from'] }} to {{ $summary['to'] }}</p>

    <table class="totals">
        <tr><td>Revenue</td><td>₹{{ number_format($summary['revenue'], 2) }}</td></tr>
        <tr><td>Expenses</td><td>₹{{ number_format($summary['expenses'], 2) }}</td></tr>
        <tr><td>Profit</td><td>₹{{ number_format($summary['profit'], 2) }}</td></tr>
    </table>

    <h3>Payment Method Breakdown</h3>
    <table>
        <thead><tr><th>Method</th><th>Amount</th></tr></thead>
        <tbody>
            @foreach($summary['payment_method_breakdown'] as $method => $total)
                <tr><td>{{ ucfirst(str_replace('_', ' ', $method)) }}</td><td>₹{{ number_format($total, 2) }}</td></tr>
            @endforeach
        </tbody>
    </table>

    <h3>Expense Category Breakdown</h3>
    <table>
        <thead><tr><th>Category</th><th>Amount</th></tr></thead>
        <tbody>
            @foreach($summary['expense_category_breakdown'] as $category => $total)
                <tr><td>{{ ucfirst($category) }}</td><td>₹{{ number_format($total, 2) }}</td></tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
