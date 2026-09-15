import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/progress/domain/progress_models.dart';
import 'package:gymapp_admin/features/progress/presentation/add_measurement_sheet.dart';
import 'package:gymapp_admin/features/progress/presentation/progress_providers.dart';

class ProgressTab extends ConsumerStatefulWidget {
  const ProgressTab({required this.memberId, super.key});

  final int memberId;

  @override
  ConsumerState<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends ConsumerState<ProgressTab> {
  bool _isUploading = false;

  Future<void> _uploadPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      await ref.read(progressRepositoryProvider).uploadPhoto(
            memberId: widget.memberId,
            filePath: file.path,
            takenOn: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            type: 'progress',
          );
      ref.invalidate(progressPhotoListProvider(widget.memberId));
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(bodyMeasurementListProvider(widget.memberId));
    final photosAsync = ref.watch(progressPhotoListProvider(widget.memberId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weight Trend', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => showAddMeasurementSheet(context, widget.memberId),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AsyncValueView(
          value: measurementsAsync,
          onRetry: () => ref.invalidate(bodyMeasurementListProvider(widget.memberId)),
          builder: (context, measurements) {
            final withWeight = measurements.where((m) => m.weightKg != null).toList();
            if (withWeight.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No weight measurements recorded yet.'),
              );
            }
            return SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      dotData: const FlDotData(show: true),
                      spots: [
                        for (var i = 0; i < withWeight.length; i++)
                          FlSpot(i.toDouble(), withWeight[i].weightKg!),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Progress Photos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _uploadPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _uploadPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AsyncValueView(
          value: photosAsync,
          onRetry: () => ref.invalidate(progressPhotoListProvider(widget.memberId)),
          builder: (context, photos) {
            if (photos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No progress photos yet.'),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final ProgressPhoto photo = photos[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(photo.url, fit: BoxFit.cover),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
