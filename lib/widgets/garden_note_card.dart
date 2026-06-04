import 'dart:io';

import 'package:flutter/material.dart';

import '../data/plant_scan_photo_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_note.dart';

class GardenNoteCard extends StatelessWidget {
  const GardenNoteCard({
    super.key,
    required this.note,
    this.repository,
    this.onTap,
    this.onDelete,
  });

  final GardenNote note;
  final VegetableRepository? repository;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isAi = note.source == GardenNoteSource.ai;
    final photoPath = note.scanPhotoPath;

    final subtitle = isAi
        ? note.source.label
        : note.isGeneralGardenTask
            ? 'Algemene tuintaak'
            : _vegetableNames();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: isAi
            ? cs.secondaryContainer.withValues(alpha: 0.35)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoPath != null &&
                    PlantScanPhotoStore.exists(photoPath))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(photoPath),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  CircleAvatar(
                    backgroundColor: isAi
                        ? cs.secondaryContainer
                        : note.isGeneralGardenTask
                            ? cs.tertiaryContainer
                            : cs.primaryContainer,
                    child: Text(
                      note.isGeneralGardenTask && !isAi
                          ? '🌿'
                          : note.source.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (note.notify)
                            Icon(
                              Icons.notifications_active_outlined,
                              size: 18,
                              color: cs.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: t.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (!note.isGeneralGardenTask &&
                          note.vegetableIds.length > 1) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final id in note.vegetableIds)
                              Chip(
                                label: Text(
                                  repository?.byId(id)?.nameNl ?? id,
                                  style: t.textTheme.labelSmall,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (note.body.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          note.body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDelete != null && !isAi)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: 'Verwijderen',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _vegetableNames() {
    if (repository == null) {
      return '${note.vegetableIds.length} groente(n)';
    }
    final names = note.vegetableIds
        .map((id) => repository!.byId(id)?.nameNl ?? id)
        .toList();
    if (names.length == 1) return names.first;
    if (names.length <= 3) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2}';
  }
}
