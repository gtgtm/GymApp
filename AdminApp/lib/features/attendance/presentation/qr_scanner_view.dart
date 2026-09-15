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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: MobileScanner(controller: _controller, onDetect: _handleDetection),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
