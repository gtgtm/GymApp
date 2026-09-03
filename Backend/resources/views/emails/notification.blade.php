<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
</head>
<body style="font-family: sans-serif; color: #1a1a1a;">
    <h2 style="margin-bottom: 4px;">{{ $message->title }}</h2>
    @if($message->body)
        <p style="color: #444;">{{ $message->body }}</p>
    @endif
</body>
</html>
