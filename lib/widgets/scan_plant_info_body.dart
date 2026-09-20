import 'package:flutter/material.dart';

import '../data/scan_info_plan.dart';
import '../data/scan_report_modules.dart';
import '../theme/tuinier_colors.dart';

const _infoAccent = Color(0xFF0369A1);
const _infoBg = Color(0xFFF0F9FF);
const _infoBorder = Color(0xFFBAE6FD);
const _cardRadius = 16.0;

/// Volledige plantinfo-pagina: swipe tussen items met samenvatting + stappenplan.
class ScanPlantInfoBody extends StatefulWidget {
  const ScanPlantInfoBody({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  final List<ScanInfoItem> items;
  final int initialIndex;

  @override
  State<ScanPlantInfoBody> createState() => _ScanPlantInfoBodyState();
}

class _ScanPlantInfoBodyState extends State<ScanPlantInfoBody> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final start = widget.initialIndex.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    _currentIndex = start;
    _pageController = PageController(initialPage: start);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const _EmptyPlantInfoMessage();
    }

    final total = widget.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 18, color: _infoAccent),
                  SizedBox(width: 8),
                  Text(
                    'Plantinfo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TuinierColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                total == 1
                    ? 'Tips en let-op punten voor deze plant op basis van je scan.'
                    : 'Swipe voor de volgende tip · $total onderwerpen',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: TuinierColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (total > 1) ...[
          const SizedBox(height: 12),
          _PlantInfoPageIndicator(
            count: total,
            currentIndex: _currentIndex,
            items: widget.items,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ],
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return _PlantInfoPageCard(item: widget.items[index]);
            },
          ),
        ),
        if (total > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '${_currentIndex + 1} van $total',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TuinierColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlantInfoPageCard extends StatelessWidget {
  const _PlantInfoPageCard({required this.item});

  final ScanInfoItem item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ScanPlantInfoDetailContent(item: item),
      ],
    );
  }
}

/// Gedeelde inhoud voor plantinfo (volledige pagina of detail-sheet).
class ScanPlantInfoDetailContent extends StatelessWidget {
  const ScanPlantInfoDetailContent({super.key, required this.item});

  final ScanInfoItem item;

  @override
  Widget build(BuildContext context) {
    final steps = resolveScanInfoSteps(item);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _infoBg,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: _infoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFE0F2FE),
                ),
                child: Icon(item.icon, color: _infoAccent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Handige info voor deze plant',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _infoAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Waarom dit belangrijk is',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.bodyText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: TuinierColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Zo pak je het aan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key + 1;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TuinierColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TuinierColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: _infoAccent,
                      child: Text(
                        '$i',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (step.detail?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.detail!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: TuinierColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PlantInfoPageIndicator extends StatelessWidget {
  const _PlantInfoPageIndicator({
    required this.count,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int count;
  final int currentIndex;
  final List<ScanInfoItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == currentIndex;
          final item = items[index];
          return Material(
            color: selected ? _infoAccent : TuinierColors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? _infoAccent : _infoBorder,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _infoAccent,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyPlantInfoMessage extends StatelessWidget {
  const _EmptyPlantInfoMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 40, color: TuinierColors.iconMuted),
            const SizedBox(height: 12),
            const Text(
              'Geen extra plantinfo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TuinierColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'De AI heeft geen let-op punten voor deze scan. Swipe terug naar Taken voor acties.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: TuinierColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
