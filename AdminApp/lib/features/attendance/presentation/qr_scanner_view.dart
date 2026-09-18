import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Native camera QR scanner. Debounces repeated detections of the same
/// code (or any code) for [cooldown] so a single scan doesn't fire twice
/// while the code is still in frame.
class QrScannerView extends StatefulWidget {
  const QrScannerView({
    required this.onDetected,
    this.cooldown = const Duration(seconds: 2),
    super.key,
  });

  final ValueChanged<String> onDetected;
  final Duration cooldown;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _isPaused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_isPaused) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _isPaused = true);
    widget.onDetected(value);
    Future.delayed(widget.cooldown, () {
      if (mounted) setState(() => _isPaused = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _handleDetection,
              errorBuilder: (context, error, child) =>
                  _ScannerError(error: error),
            ),
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.primary, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => 'Camera permission denied. Enable it in system settings to scan QR codes.',
      _ => 'Could not start the camera.',
    };

    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined, color: scheme.error, size: 32),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
