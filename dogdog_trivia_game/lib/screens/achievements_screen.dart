import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_progress.dart';
import '../models/achievement.dart';
import '../models/enums.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/enum_extensions.dart';
import '../widgets/modern_card.dart';
import '../design_system/modern_colors.dart';

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
  Timer? _celebrationTimer;

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
    // Capture messenger to avoid using context after async gap
    final messenger = ScaffoldMessenger.of(context);
    try {
      final progressService = context.read<ProgressService>();
      final progress = await progressService.getPlayerProgress();

      if (!mounted) return;
      setState(() {
        _playerProgress = progress;
        _isLoading = false;
      });

      // Start animations
      _mainAnimationController.forward();

      // Play celebration animation for newly unlocked achievements
      if (progress.unlockedAchievements.isNotEmpty && mounted) {
        _celebrationTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            _celebrationController.forward();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error loading achievements: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    _mainAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  /// Returns the dog breed image path for a given rank
  String _getDogBreedImagePath(Rank rank) {
    switch (rank) {
      case Rank.chihuahua:
        return 'assets/images/chihuahua.png';
      case Rank.pug:
        return 'assets/images/mops.png';
      case Rank.cockerSpaniel:
        return 'assets/images/cocker.png';
      case Rank.germanShepherd:
        return 'assets/images/schaeferhund.png';
      case Rank.greatDane:
        return 'assets/images/dogge.png';
    }
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
            // Capture navigator to avoid BuildContext across async gap
            final navigator = Navigator.of(context);
            await _audioService.playButtonSound();
            if (!mounted) return;
            navigator.pop();
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
          Text(
            AppLocalizations.of(context).achievementsScreen_pleaseRetryLater,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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

    return ModernCard.gradient(
      gradientColors: ModernColors.purpleGradient,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).achievementsScreen_yourStatistics,
            style: const TextStyle(
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
                  AppLocalizations.of(
                    context,
                  ).achievementsScreen_correctAnswers,
                  progress.totalCorrectAnswers.toString(),
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context).achievementsScreen_accuracy,
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
                  AppLocalizations.of(context).achievementsScreen_gamesPlayed,
                  progress.totalGamesPlayed.toString(),
                  Icons.sports_esports,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context).achievementsScreen_totalScore,
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
          child: ModernCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context).achievementsScreen_currentRank,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 20),

                // Dog Breed Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isRankUnlocked
                            ? ModernColors.primaryPurple.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: ColorFiltered(
                      colorFilter: isRankUnlocked
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : ColorFilter.mode(
                              Colors.grey.withValues(alpha: 0.7),
                              BlendMode.saturation,
                            ),
                      child: Image.asset(
                        _getDogBreedImagePath(currentRank),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRankUnlocked
                                  ? ModernColors.primaryPurple
                                  : ModernColors.surfaceMedium,
                            ),
                            child: Icon(
                              Icons.pets,
                              size: 50,
                              color: isRankUnlocked
                                  ? Colors.white
                                  : ModernColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  currentRank.displayName(context),
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
                  currentRank.description(context),
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
                      AppLocalizations.of(
                        context,
                      ).achievementsScreen_moreAnswersToUnlock(
                        currentRank.requiredCorrectAnswers -
                            progress.totalCorrectAnswers,
                      ),
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
      return ModernCard.gradient(
        gradientColors: ModernColors.greenGradient,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).achievementsScreen_allRanksAchieved,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              ).achievementsScreen_allRanksAchievedDescription,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final progressToNext = progress.progressToNextRank;
    final remainingAnswers =
        nextRank.requiredCorrectAnswers - progress.totalCorrectAnswers;

    return ModernCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Dog breed image for next rank
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primaryPurple.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    _getDogBreedImagePath(nextRank),
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ModernColors.primaryPurple,
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 16,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).achievementsScreen_nextRank,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      nextRank.displayName(context),
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
            AppLocalizations.of(
              context,
            ).achievementsScreen_moreAnswersToNextRank(remainingAnswers),
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
        Text(
          AppLocalizations.of(context).achievementsScreen_allAchievements,
          style: const TextStyle(
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

    return ModernCard.interactive(
      onTap: () async {
        await _audioService.playButtonSound();
        _showAchievementDetails(achievement, progress);
      },
      margin: EdgeInsets.zero,
      hasBorder: isUnlocked,
      borderColor: ModernColors.primaryPurple,
      borderWidth: 2.0,
      child: Row(
        children: [
          // Dog Breed Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? ModernColors.primaryPurple.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: ColorFiltered(
                colorFilter: isUnlocked
                    ? const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      )
                    : ColorFilter.mode(
                        Colors.grey.withValues(alpha: 0.7),
                        BlendMode.saturation,
                      ),
                child: Image.asset(
                  _getDogBreedImagePath(achievement.rank),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked
                            ? ModernColors.primaryPurple
                            : ModernColors.surfaceMedium,
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 30,
                        color: isUnlocked
                            ? Colors.white
                            : ModernColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
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
                        achievement.rank.displayName(context),
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
                  AppLocalizations.of(
                    context,
                  ).achievementsScreen_correctAnswersRequired(
                    achievement.requiredCorrectAnswers,
                  ),
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
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dog Breed Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isUnlocked
                          ? ModernColors.primaryPurple.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: ColorFiltered(
                    colorFilter: isUnlocked
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          )
                        : ColorFilter.mode(
                            Colors.grey.withValues(alpha: 0.7),
                            BlendMode.saturation,
                          ),
                    child: Image.asset(
                      _getDogBreedImagePath(achievement.rank),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUnlocked
                                ? ModernColors.primaryPurple
                                : ModernColors.surfaceMedium,
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 40,
                            color: isUnlocked
                                ? Colors.white
                                : ModernColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                achievement.rank.displayName(context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                achievement.rank.description(context),
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
                        Text(
                          AppLocalizations.of(
                            context,
                          ).achievementsScreen_requiredAnswers,
                          style: const TextStyle(
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
                        Text(
                          AppLocalizations.of(
                            context,
                          ).achievementsScreen_yourAnswers,
                          style: const TextStyle(
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
                          Text(
                            AppLocalizations.of(
                              context,
                            ).achievementsScreen_unlocked,
                            style: const TextStyle(
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
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
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
}
