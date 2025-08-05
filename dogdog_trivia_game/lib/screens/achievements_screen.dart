import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_progress.dart';
import '../models/achievement.dart';
import '../models/enums.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../l10n/generated/app_localizations.dart';

/// Screen displaying all achievements and player progress
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _celebrationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _celebrationAnimation;
  late AudioService _audioService;

  PlayerProgress? _playerProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _setupAnimations();
    _loadPlayerProgress();
  }

  /// Setup animations for the screen
  void _setupAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  /// Load player progress from the progress service
  Future<void> _loadPlayerProgress() async {
    try {
      final progressService = context.read<ProgressService>();
      final progress = await progressService.getPlayerProgress();

      setState(() {
        _playerProgress = progress;
        _isLoading = false;
      });

      // Start animations
      _mainAnimationController.forward();

      // Play celebration animation for newly unlocked achievements
      if (progress.unlockedAchievements.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _celebrationController.forward();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading achievements: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).achievementsScreen_title,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _audioService.playButtonSound();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            )
          : _playerProgress == null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  /// Builds the error state when progress couldn't be loaded
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            ).errorScreen_loadingError('achievements'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again later',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _audioService.playButtonSound();
              setState(() {
                _isLoading = true;
              });
              await _loadPlayerProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).achievementsScreen_tryAgain,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content of the screen
  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _mainAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Progress Section
                  _buildOverallProgressSection(),

                  const SizedBox(height: 32),

                  // Current Rank Section
                  _buildCurrentRankSection(),

                  const SizedBox(height: 32),

                  // Next Rank Progress Section
                  _buildNextRankProgressSection(),

                  const SizedBox(height: 32),

                  // All Achievements Section
                  _buildAllAchievementsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the overall progress statistics section
  Widget _buildOverallProgressSection() {
    final progress = _playerProgress!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Correct Answers',
                  progress.totalCorrectAnswers.toString(),
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Accuracy',
                  '${(progress.accuracy * 100).toStringAsFixed(1)}%',
                  Icons.track_changes,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Games Played',
                  progress.totalGamesPlayed.toString(),
                  Icons.sports_esports,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Score',
                  progress.totalScore.toString(),
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a statistics card
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the current rank section
  Widget _buildCurrentRankSection() {
    final progress = _playerProgress!;
    final currentRank = progress.currentRank;
    final isRankUnlocked = progress.isRankUnlocked(currentRank);

    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_celebrationAnimation.value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Current Rank',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 20),

                // Rank Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isRankUnlocked
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isRankUnlocked
                            ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRankIcon(currentRank),
                    size: 50,
                    color: isRankUnlocked
                        ? Colors.white
                        : const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  currentRank.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isRankUnlocked
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  currentRank.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),

                if (!isRankUnlocked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentRank.requiredCorrectAnswers - progress.totalCorrectAnswers} more correct answers to unlock',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the next rank progress section
  Widget _buildNextRankProgressSection() {
    final progress = _playerProgress!;
    final nextRank = progress.nextRank;

    if (nextRank == null) {
      // All ranks achieved
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.emoji_events, size: 48, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'All Ranks Achieved!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You have unlocked all available ranks. Great job!',
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final progressToNext = progress.progressToNextRank;
    final remainingAnswers =
        nextRank.requiredCorrectAnswers - progress.totalCorrectAnswers;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRankIcon(nextRank),
                size: 32,
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Rank',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      nextRank.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progressToNext * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressToNext,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '$remainingAnswers more correct answers to next rank',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  /// Builds the all achievements section
  Widget _buildAllAchievementsSection() {
    final progress = _playerProgress!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 16),

        // Achievement Cards
        ...Rank.values.map((rank) {
          final achievement = progress.achievements.firstWhere(
            (a) => a.rank == rank,
            orElse: () => Achievement.fromRank(rank),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAchievementCard(achievement, progress),
          );
        }),
      ],
    );
  }

  /// Builds an individual achievement card
  Widget _buildAchievementCard(
    Achievement achievement,
    PlayerProgress progress,
  ) {
    final isUnlocked = progress.isRankUnlocked(achievement.rank);
    final progressValue = achievement.getProgress(progress.totalCorrectAnswers);

    return GestureDetector(
      onTap: () async {
        await _audioService.playButtonSound();
        _showAchievementDetails(achievement, progress);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked
              ? Border.all(color: const Color(0xFFFFD700), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Achievement Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
                      ),
              ),
              child: Icon(
                _getRankIcon(achievement.rank),
                size: 30,
                color: isUnlocked ? Colors.white : const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(width: 16),

            // Achievement Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${achievement.requiredCorrectAnswers} correct answers',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),

                    // Progress Bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressValue,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${progress.totalCorrectAnswers}/${achievement.requiredCorrectAnswers}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  /// Shows detailed information about an achievement
  void _showAchievementDetails(
    Achievement achievement,
    PlayerProgress progress,
  ) {
    final isUnlocked = progress.isRankUnlocked(achievement.rank);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
                        ),
                ),
                child: Icon(
                  _getRankIcon(achievement.rank),
                  size: 40,
                  color: isUnlocked ? Colors.white : const Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                achievement.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                achievement.description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Required answers:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          achievement.requiredCorrectAnswers.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your answers:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          progress.totalCorrectAnswers.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),

                    if (isUnlocked && achievement.unlockedDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Unlocked:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${achievement.unlockedDate!.day}.${achievement.unlockedDate!.month}.${achievement.unlockedDate!.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  await _audioService.playButtonSound();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).achievementsScreen_close,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the appropriate icon for a rank
  IconData _getRankIcon(Rank rank) {
    switch (rank) {
      case Rank.chihuahua:
        return Icons.pets;
      case Rank.pug:
        return Icons.favorite;
      case Rank.cockerSpaniel:
        return Icons.star;
      case Rank.germanShepherd:
        return Icons.military_tech;
      case Rank.greatDane:
        return Icons.diamond;
    }
  }
}
