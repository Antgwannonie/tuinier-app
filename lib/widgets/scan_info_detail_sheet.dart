import 'package:flutter/material.dart';

import '../data/scan_report_modules.dart';
import '../theme/tuinier_colors.dart';
import 'scan_plant_info_body.dart';

Future<void> showScanInfoDetailSheet({
  required BuildContext context,
  required ScanInfoItem item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ScanInfoDetailSheet(item: item),
  );
}

class _ScanInfoDetailSheet extends StatelessWidget {
  const _ScanInfoDetailSheet({required this.item});

  final ScanInfoItem item;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TuinierColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                ScanPlantInfoDetailContent(item: item),
              ],
            ),
          ),
        );
      },
    );
  }
}
