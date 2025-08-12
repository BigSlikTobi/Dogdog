import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';

/// A horizontal progress line widget showing dog breed checkpoints in a scrollable format
class HorizontalProgressLine extends StatelessWidget {
  final int currentQuestionCount;
  final List<Checkpoint> completedCheckpoints;
  final Checkpoint? currentCheckpoint;
  final QuestionCategory? category;

  const HorizontalProgressLine({
    super.key,
    required this.currentQuestionCount,
    required this.completedCheckpoints,
    this.currentCheckpoint,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final checkpoints = Checkpoint.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          _getProgressTitle(),
          style: ModernTypography.headingSmall.copyWith(
            color: ModernColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ModernSpacing.sm),

        // Progress info
        Text(
          'Questions answered: $currentQuestionCount',
          style: ModernTypography.bodyMedium.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
        SizedBox(height: ModernSpacing.lg),

        // Horizontal checkpoints
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: checkpoints.length,
            itemBuilder: (context, index) {
              final checkpoint = checkpoints[index];
              final isCompleted = completedCheckpoints.contains(checkpoint);
              final isNext = _isNextCheckpoint(checkpoint);

              return Container(
                width: 100,
                margin: EdgeInsets.only(
                  right: index < checkpoints.length - 1 ? ModernSpacing.md : 0,
                ),
                child: Column(
                  children: [
                    // Dog image with status
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: isCompleted
                              ? ModernColors.success
                              : isNext
                              ? ModernColors.primaryBlue
                              : ModernColors.surfaceLight,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Dog breed image
                          ClipOval(
                            child: Image.asset(
                              checkpoint.imagePath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ModernColors.surfaceLight,
                                  ),
                                  child: Icon(
                                    Icons.pets,
                                    color: ModernColors.textLight,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Completion check mark overlay
                          if (isCompleted)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ModernColors.success,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: ModernSpacing.xs),

                    // Checkpoint name
                    Text(
                      checkpoint.displayName,
                      style: ModernTypography.caption.copyWith(
                        fontWeight: isCompleted || isNext
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isCompleted
                            ? ModernColors.success
                            : isNext
                            ? ModernColors.primaryBlue
                            : ModernColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Questions required
                    Text(
                      '${checkpoint.questionsRequired}Q',
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textLight,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isNextCheckpoint(Checkpoint checkpoint) {
    return _getNextCheckpoint() == checkpoint;
  }

  Checkpoint? _getNextCheckpoint() {
    for (final checkpoint in Checkpoint.values) {
      if (currentQuestionCount < checkpoint.questionsRequired) {
        return checkpoint;
      }
    }
    return null; // All completed
  }

  String _getProgressTitle() {
    if (category != null) {
      switch (category!) {
        case QuestionCategory.dogTraining:
          return 'Dog Training Progress';
        case QuestionCategory.dogBreeds:
          return 'Dog Breed Progress';
        case QuestionCategory.dogBehavior:
          return 'Dog Behavior Progress';
        case QuestionCategory.dogHealth:
          return 'Dog Health Progress';
        case QuestionCategory.dogHistory:
          return 'Dog History Progress';
      }
    }
    return 'Progress'; // Fallback
  }
}
