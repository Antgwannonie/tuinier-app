import 'package:flutter/material.dart';



import '../../data/mushroom_problems_guide.dart';

import '../../data/plant_encyclopedia_layout.dart';

import 'mushroom_guide_card.dart';

import 'mushroom_problems_illustrations.dart';



class MushroomProblemsGuideView extends StatelessWidget {

  const MushroomProblemsGuideView({super.key, required this.guide});



  final MushroomProblemsGuide guide;



  static const _twoColBreakpoint = 520.0;



  @override

  Widget build(BuildContext context) {

    final width = MediaQuery.sizeOf(context).width - 32;

    final twoCol = width >= _twoColBreakpoint;



    return Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        wrapMushroomGuideCard(
          context: context,
          title: 'Problemen vroeg herkennen',
          summary: guide.cardSummary('Problemen vroeg herkennen'),
          details: guide.cardDetail('Problemen vroeg herkennen'),
          child: _EarlyRecognitionCard(
            summary: guide.cardSummary('Problemen vroeg herkennen'),
          ),
        ),

        const SizedBox(height: 12),

        wrapMushroomGuideCard(
          context: context,
          title: 'Veelvoorkomende problemen',
          summary: guide.cardSummary('Veelvoorkomende problemen'),
          details: guide.cardDetail('Veelvoorkomende problemen'),
          child: _CommonProblemsSection(
            problems: guide.commonProblems,
            summary: guide.cardSummary('Veelvoorkomende problemen'),
            twoCol: twoCol,
          ),
        ),

        const SizedBox(height: 12),

        wrapMushroomGuideCard(
          context: context,
          title: 'Problemen snel herkennen',
          summary: guide.cardSummary('Problemen snel herkennen'),
          details: guide.cardDetail('Problemen snel herkennen'),
          child: _QuickRecognitionCard(
            items: guide.quickRecognition,
            summary: guide.cardSummary('Problemen snel herkennen'),
            twoCol: twoCol,
          ),
        ),

        const SizedBox(height: 12),

        wrapMushroomGuideCard(
          context: context,
          title: 'Algemene checklist bij problemen',
          summary: guide.cardSummary('Algemene checklist bij problemen'),
          details: guide.cardDetail('Algemene checklist bij problemen'),
          child: _ChecklistCard(
            summary: guide.cardSummary('Algemene checklist bij problemen'),
            twoCol: twoCol,
          ),
        ),

        const SizedBox(height: 12),

        wrapMushroomGuideCard(
          context: context,
          title: 'Wanneer een blok weggooien?',
          summary: guide.cardSummary('Wanneer een blok weggooien?'),
          details: guide.cardDetail('Wanneer een blok weggooien?'),
          child: _DiscardCard(
            summary: guide.cardSummary('Wanneer een blok weggooien?'),
            twoCol: twoCol,
          ),
        ),

        const SizedBox(height: 12),

        wrapMushroomGuideCard(
          context: context,
          title: 'Extra hulp nodig?',
          summary: guide.cardSummary('Extra hulp nodig?'),
          details: guide.cardDetail('Extra hulp nodig?'),
          child: _ExtraHelpCard(
            summary: guide.cardSummary('Extra hulp nodig?'),
          ),
        ),

      ],

    );

  }

}



class _GreenSectionTitle extends StatelessWidget {

  const _GreenSectionTitle(this.title);



  final String title;



  @override

  Widget build(BuildContext context) {

    return Text(

      title,

      style: Theme.of(context).textTheme.titleSmall?.copyWith(

            fontWeight: FontWeight.w800,

            color: const Color(PlantDetailDesign.primaryGreen),

          ),

    );

  }

}



class _EarlyRecognitionCard extends StatelessWidget {

  const _EarlyRecognitionCard({required this.summary});



  final String summary;



  @override

  Widget build(BuildContext context) {

    final t = Theme.of(context).textTheme;

    final stack = MediaQuery.sizeOf(context).width < 400;



    final textBlock = Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const _GreenSectionTitle('Problemen vroeg herkennen'),

        const SizedBox(height: 8),

        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),

      ],

    );



    const hero = MushroomProblemsIllustration(

      assetPath: MushroomProblemsAssets.hero,

      aspectRatio: 4 / 3,

    );



    return stack

          ? Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [textBlock, const SizedBox(height: 12), hero],

            )

          : Row(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Expanded(child: textBlock),

                const SizedBox(width: 12),

                const SizedBox(width: 130, child: hero),

              ],

            );

  }
}



class _CommonProblemsSection extends StatelessWidget {

  const _CommonProblemsSection({

    required this.problems,

    required this.summary,

    required this.twoCol,

  });



  final List<MushroomProblemCard> problems;

  final String summary;

  final bool twoCol;



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        const _GreenSectionTitle('Veelvoorkomende problemen'),

        const SizedBox(height: 8),

        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),

        const SizedBox(height: 10),

        if (twoCol)

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: [

              for (final problem in problems)

                SizedBox(

                  width: (MediaQuery.sizeOf(context).width - 32 - 20) / 2,

                  child: _ProblemCard(problem: problem),

                ),

            ],

          )

        else

          SizedBox(

            height: 320,

            child: ListView.separated(

              scrollDirection: Axis.horizontal,

              itemCount: problems.length,

              separatorBuilder: (_, __) => const SizedBox(width: 10),

              itemBuilder: (context, index) {

                return SizedBox(

                  width: 260,

                  child: _ProblemCard(problem: problems[index]),

                );

              },

            ),

          ),

      ],

    );

  }

}



class _ProblemCard extends StatelessWidget {

  const _ProblemCard({required this.problem});



  final MushroomProblemCard problem;

  @override

  Widget build(BuildContext context) {

    final t = Theme.of(context).textTheme;



    return Container(

      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),

      decoration: BoxDecoration(

        color: const Color(PlantDetailDesign.card),

        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),

        border: Border.all(color: const Color(PlantDetailDesign.border)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          Stack(

            children: [

              MushroomProblemsIllustration(

                assetPath: problem.assetPath,

                aspectRatio: 16 / 10,

                compact: true,

              ),

              Positioned(

                top: 6,

                right: 6,

                child: Container(

                  padding: const EdgeInsets.all(4),

                  decoration: const BoxDecoration(

                    color: Color(0xFFB71C1C),

                    shape: BoxShape.circle,

                  ),

                  child: const Icon(

                    Icons.priority_high_rounded,

                    size: 14,

                    color: Colors.white,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 10),

          Text(

            problem.title,

            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),

          ),

        ],

      ),

    );

  }

}

class _QuickRecognitionCard extends StatelessWidget {

  const _QuickRecognitionCard({

    required this.items,

    required this.summary,

    required this.twoCol,

  });



  final List<QuickRecognitionItem> items;

  final String summary;

  final bool twoCol;



  @override

  Widget build(BuildContext context) {

    final t = Theme.of(context).textTheme;



    Widget itemTile(QuickRecognitionItem item) {

      return Column(

        children: [

          SizedBox(

            width: 56,

            height: 56,

            child: MushroomProblemsIllustration(

              assetPath: item.assetPath,

              compact: true,

              circular: true,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            item.label,

            textAlign: TextAlign.center,

            style: t.labelSmall?.copyWith(

              fontWeight: FontWeight.w700,

              fontSize: 10,

            ),

          ),

        ],

      );

    }



    return Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          const _GreenSectionTitle('Problemen snel herkennen'),

          const SizedBox(height: 8),

          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),

          const SizedBox(height: 12),

          if (twoCol)

            Row(

              children: [

                for (var i = 0; i < items.length; i++) ...[

                  if (i > 0) const SizedBox(width: 8),

                  Expanded(child: itemTile(items[i])),

                ],

              ],

            )

          else

            SingleChildScrollView(

              scrollDirection: Axis.horizontal,

              child: Row(

                children: [

                  for (var i = 0; i < items.length; i++) ...[

                    if (i > 0) const SizedBox(width: 12),

                    SizedBox(width: 72, child: itemTile(items[i])),

                  ],

                ],

              ),

            ),

        ],

      );

  }

}



class _ChecklistCard extends StatelessWidget {

  const _ChecklistCard({

    required this.summary,

    required this.twoCol,

  });



  final String summary;

  final bool twoCol;



  @override

  Widget build(BuildContext context) {

    final t = Theme.of(context).textTheme;

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),

      decoration: BoxDecoration(

        color: const Color(0xFFE8F5E9),

        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),

        border: Border.all(color: const Color(0xFFC8E6C9)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const _GreenSectionTitle('Algemene checklist bij problemen'),

          const SizedBox(height: 8),

          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),

        ],

      ),

    );

  }

}



class _DiscardCard extends StatelessWidget {

  const _DiscardCard({required this.summary, required this.twoCol});



  final String summary;

  final bool twoCol;



  @override

  Widget build(BuildContext context) {

    final t = Theme.of(context).textTheme;



    final list = Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Wanneer een blok weggooien?',

          style: t.titleSmall?.copyWith(

            fontWeight: FontWeight.w800,

            color: const Color(0xFFB71C1C),

          ),

        ),

        const SizedBox(height: 10),

        Text(summary, style: t.bodySmall?.copyWith(height: 1.35)),

      ],

    );



    const trashImage = MushroomProblemsIllustration(

      assetPath: MushroomProblemsAssets.discardTrash,

      aspectRatio: 4 / 3,

    );



    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),

      decoration: BoxDecoration(

        color: const Color(0xFFFFF5F5),

        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),

        border: Border.all(color: const Color(0xFFFFCDD2)),

      ),

      child: twoCol

          ? Row(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Expanded(child: list),

                const SizedBox(width: 12),

                const SizedBox(width: 120, child: trashImage),

              ],

            )

          : Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [list, const SizedBox(height: 12), trashImage],

            ),

    );

  }

}



class _ExtraHelpCard extends StatelessWidget {

  const _ExtraHelpCard({required this.summary});



  final String summary;



  @override

  Widget build(BuildContext context) {

    final t = Theme.of(context).textTheme;



    return Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          const _GreenSectionTitle('Extra hulp nodig?'),

          const SizedBox(height: 8),

          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),

          const SizedBox(height: 12),

          OutlinedButton.icon(

            onPressed: null,

            icon: const Icon(Icons.edit_note_rounded, size: 18),

            label: const Text('Notities maken'),

            style: OutlinedButton.styleFrom(

              foregroundColor: const Color(PlantDetailDesign.primaryGreen),

              side: const BorderSide(color: Color(PlantDetailDesign.primaryGreen)),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            ),

          ),

        ],

    );

  }

}

