import 'package:flutter/material.dart';

class StepProgress extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  final List<String>? labels;

  const StepProgress({super.key, required this.currentStep, required this.totalSteps, this.labels});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(height: 2, color: Colors.grey.shade300),
              );
            }
            final step = index ~/ 2 + 1;
            final isDone = step < currentStep;
            final isActive = step == currentStep;
            final bg = isDone || isActive ? theme.colorScheme.primary : Colors.grey.shade300;
            final fg = isDone || isActive ? Colors.white : Colors.black54;
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('$step', style: theme.textTheme.labelMedium?.copyWith(color: fg)),
            );
          }),
        ),
        if (labels != null && labels!.length == totalSteps) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (i) => Expanded(
              child: Text(
                labels![i],
                textAlign: i == 0 ? TextAlign.left : (i == totalSteps - 1 ? TextAlign.right : TextAlign.center),
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            )),
          )
        ]
      ],
    );
  }
}


