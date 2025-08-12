import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';

/// A vertical progress line widget showing dog breed checkpoints
class VerticalProgressLine extends StatelessWidget {
  final int currentQuestionCount;
  final List<Checkpoint> completedCheckpoints;
  final Checkpoint? currentCheckpoint;

  const VerticalProgressLine({
    super.key,
    required this.currentQuestionCount,
    required this.completedCheckpoints,
    this.currentCheckpoint,
  });

  @override
  Widget build(BuildContext context) {
    final checkpoints = Checkpoint.values.reversed
        .toList(); // Reverse order: Deutsche Dogge on top, Chihuahua on bottom

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight > 0 ? constraints.maxHeight : 400,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Dog Breed Progress',
                style: ModernTypography.headingSmall.copyWith(
                  color: ModernColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ModernSpacing.md),

              // Progress info
              Text(
                'Questions answered: $currentQuestionCount',
                style: ModernTypography.bodyMedium.copyWith(
                  color: ModernColors.textSecondary,
                ),
              ),
              SizedBox(height: ModernSpacing.md),

              // Checkpoints list
              Expanded(
                child: ListView.builder(
                  itemCount: checkpoints.length,
                  itemBuilder: (context, index) {
                    final checkpoint = checkpoints[index];
                    final isCompleted = completedCheckpoints.contains(
                      checkpoint,
                    );
                    final isNext = _isNextCheckpoint(checkpoint);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: ModernSpacing.xs),
                      child: Row(
                        children: [
                          // Status indicator with dog image
                          Container(
                            width: 48,
                            height: 48,
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
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ModernColors.surfaceLight,
                                        ),
                                        child: Icon(
                                          Icons.pets,
                                          color: ModernColors.textLight,
                                          size: 24,
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
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ModernColors.success,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: ModernSpacing.sm),

                          // Checkpoint info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  checkpoint.displayName,
                                  style: ModernTypography.bodyMedium.copyWith(
                                    fontWeight: isCompleted || isNext
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isCompleted
                                        ? ModernColors.success
                                        : isNext
                                        ? ModernColors.primaryBlue
                                        : ModernColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${checkpoint.questionsRequired} questions required',
                                  style: ModernTypography.caption.copyWith(
                                    color: ModernColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
}
