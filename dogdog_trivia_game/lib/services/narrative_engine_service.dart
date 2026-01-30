import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/story_arc.dart';
import '../models/companion_enums.dart';
import '../models/memory.dart';

/// Service that manages narrative story arcs
/// 
/// Handles loading stories, managing progress, and creating
/// memories from completed adventures.
class NarrativeEngineService extends ChangeNotifier {
  static final NarrativeEngineService _instance = NarrativeEngineService._internal();
  factory NarrativeEngineService() => _instance;
  NarrativeEngineService._internal();

  /// All available story arcs
  List<StoryArc> _stories = [];
  List<StoryArc> get stories => List.unmodifiable(_stories);

  /// Current story progress (if playing)
  StoryProgress? _currentProgress;
  StoryProgress? get currentProgress => _currentProgress;

  /// Currently active story
  StoryArc? _currentStory;
  StoryArc? get currentStory => _currentStory;

  /// Whether the service is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize with story data
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load built-in stories
    _stories = _generateDefaultStories();
    
    // In the future, load from assets or network
    // await _loadStoriesFromAssets();
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Get stories available for a given world area
  List<StoryArc> getStoriesForArea(WorldArea area) {
    return _stories.where((s) => s.area == area).toList();
  }

  /// Get stories available for a given growth stage
  List<StoryArc> getStoriesForStage(GrowthStage stage) {
    return _stories.where((s) => s.isAvailableFor(stage)).toList();
  }

  /// Get a random story for the given area and stage
  StoryArc? getRandomStory(WorldArea area, GrowthStage stage) {
    final available = _stories
        .where((s) => s.area == area && s.isAvailableFor(stage))
        .toList();
    
    if (available.isEmpty) return null;
    
    available.shuffle();
    return available.first;
  }

  /// Start a new story
  Future<void> startStory(StoryArc story) async {
    _currentStory = story;
    _currentProgress = StoryProgress.start(story);
    notifyListeners();
  }

  /// Record answering a question correctly
  void recordCorrectAnswer({String? funFact}) {
    if (_currentProgress == null) return;

    final newFacts = funFact != null
        ? [..._currentProgress!.factsLearned, funFact]
        : _currentProgress!.factsLearned;

    _currentProgress = _currentProgress!.copyWith(
      correctAnswers: _currentProgress!.correctAnswers + 1,
      totalAnswered: _currentProgress!.totalAnswered + 1,
      bondAccumulated: _currentProgress!.bondAccumulated + 0.02,
      factsLearned: newFacts,
    );
    notifyListeners();
  }

  /// Record answering a question incorrectly
  void recordIncorrectAnswer() {
    if (_currentProgress == null) return;

    _currentProgress = _currentProgress!.copyWith(
      totalAnswered: _currentProgress!.totalAnswered + 1,
    );
    notifyListeners();
  }

  /// Advance to the next scene
  void advanceScene() {
    if (_currentProgress == null) return;

    final nextIndex = _currentProgress!.currentSceneIndex + 1;
    final isComplete = nextIndex >= _currentProgress!.totalScenes;

    _currentProgress = _currentProgress!.copyWith(
      currentSceneIndex: nextIndex,
      isComplete: isComplete,
      completedAt: isComplete ? DateTime.now() : null,
    );
    notifyListeners();
  }

  /// Complete the current story and create a memory
  Memory? completeStory() {
    if (_currentStory == null || _currentProgress == null) return null;

    final memory = Memory(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      storyTitle: _currentStory!.title,
      description: 'Explored ${_currentStory!.area.displayName} with your companion!',
      factsLearned: _currentProgress!.factsLearned,
      worldArea: _currentStory!.area.name,
      correctAnswers: _currentProgress!.correctAnswers,
      bondGained: _currentProgress!.bondAccumulated + _currentStory!.bondReward,
    );

    // Clear current story
    _currentStory = null;
    _currentProgress = null;
    notifyListeners();

    return memory;
  }

  /// Cancel the current story without saving
  void cancelStory() {
    _currentStory = null;
    _currentProgress = null;
    notifyListeners();
  }

  /// Generate default stories for initial release
  List<StoryArc> _generateDefaultStories() {
    return [
      // Home stories
      _createHomeFirstMeetingStory(),
      _createHomeBedtimeStory(),
      
      // Bark Park stories
      _createBarkParkExplorationStory(),
      _createBarkParkFrisbeeStory(),
      
      // Vet Clinic stories
      _createVetClinicCheckupStory(),
      
      // Dog Show stories
      _createDogShowPracticeStory(),
    ];
  }

  StoryArc _createHomeFirstMeetingStory() {
    return StoryArc(
      id: 'home_first_meeting',
      title: 'Welcome Home!',
      description: 'Your new companion is exploring their new home. Help them learn about being a great dog!',
      area: WorldArea.home,
      startingMood: CompanionMood.curious,
      requiredStage: GrowthStage.puppy,
      bondReward: 0.05,
      estimatedMinutes: 3,
      segments: [
        const StorySegment(
          id: 'home_intro',
          type: SegmentType.intro,
          narration: 'Your new puppy is sniffing around the living room, tail wagging with curiosity!',
          companionMood: CompanionMood.curious,
        ),
        const StorySegment(
          id: 'home_discovery',
          type: SegmentType.discovery,
          narration: 'They found their new bed and jumped in! Time to learn some fun facts about dogs.',
          companionMood: CompanionMood.happy,
        ),
      ],
      questions: [
        const StoryQuestion(
          id: 'home_q1',
          context: 'Your puppy is sniffing around, using their amazing nose...',
          question: 'How many times better is a dog\'s sense of smell compared to humans?',
          options: ['10 times', '100 times', '10,000 to 100,000 times', '1 million times'],
          correctIndex: 2,
          correctReaction: 'Woof! Your puppy wags their tail proudly! 🐕',
          incorrectReaction: 'Your puppy tilts their head. Let\'s learn together!',
          funFact: 'Dogs have up to 300 million smell receptors, while humans only have about 6 million!',
          bondPoints: 0.02,
        ),
        const StoryQuestion(
          id: 'home_q2',
          context: 'Your puppy yawns and stretches out on their comfy bed...',
          question: 'How many hours a day do puppies typically sleep?',
          options: ['4-6 hours', '8-10 hours', '12-14 hours', '18-20 hours'],
          correctIndex: 3,
          correctReaction: 'Your sleepy puppy curls up happily! 😴',
          incorrectReaction: 'Your puppy is already dreaming...',
          funFact: 'Puppies need lots of sleep to grow and develop their brains. They sleep almost as much as newborn babies!',
          bondPoints: 0.02,
        ),
      ],
      funFacts: [
        'Dogs dream just like humans do!',
        'A dog\'s wet nose helps them absorb scent chemicals.',
      ],
    );
  }

  StoryArc _createHomeBedtimeStory() {
    return StoryArc(
      id: 'home_bedtime',
      title: 'Sleepy Time',
      description: 'It\'s bedtime! Learn about how dogs rest and dream.',
      area: WorldArea.home,
      startingMood: CompanionMood.sleepy,
      requiredStage: GrowthStage.puppy,
      bondReward: 0.04,
      estimatedMinutes: 2,
      segments: [
        const StorySegment(
          id: 'bed_intro',
          type: SegmentType.intro,
          narration: 'The sun is setting and your companion is yawning...',
          companionMood: CompanionMood.sleepy,
        ),
      ],
      questions: [
        const StoryQuestion(
          id: 'bed_q1',
          context: 'Your puppy is circling before lying down...',
          question: 'Why do dogs circle before lying down?',
          options: [
            'They\'re dizzy',
            'They\'re checking for danger and making a comfy spot',
            'They forgot where they were going',
            'They\'re playing a game'
          ],
          correctIndex: 1,
          correctReaction: 'Your puppy settles down perfectly! 🌙',
          incorrectReaction: 'Your puppy finds the perfect spot anyway!',
          funFact: 'This circling behavior comes from wild ancestors who would pat down grass to make a safe sleeping spot!',
          bondPoints: 0.02,
        ),
      ],
      funFacts: [
        'Dogs experience REM sleep and dream about dog activities!',
      ],
    );
  }

  StoryArc _createBarkParkExplorationStory() {
    return StoryArc(
      id: 'bark_park_explore',
      title: 'Park Explorer',
      description: 'First trip to the park! So many new smells and friends to meet.',
      area: WorldArea.barkPark,
      startingMood: CompanionMood.excited,
      requiredStage: GrowthStage.puppy,
      bondReward: 0.06,
      estimatedMinutes: 4,
      segments: [
        const StorySegment(
          id: 'park_arrive',
          type: SegmentType.intro,
          narration: 'You arrive at Bark Park! Your companion can barely contain their excitement!',
          companionMood: CompanionMood.excited,
        ),
        const StorySegment(
          id: 'park_meet',
          type: SegmentType.discovery,
          narration: 'A friendly Golden Retriever comes over to say hello!',
          companionMood: CompanionMood.curious,
        ),
      ],
      questions: [
        const StoryQuestion(
          id: 'park_q1',
          context: 'Two dogs are sniffing each other\'s noses...',
          question: 'How do dogs greet each other?',
          options: [
            'They shake paws',
            'They bark loudly',
            'They sniff each other',
            'They do a little dance'
          ],
          correctIndex: 2,
          correctReaction: 'Your pup makes a new friend! 🐾',
          incorrectReaction: 'Your pup shows you how dogs really say hello!',
          funFact: 'Dogs can learn a lot about each other by sniffing, including what they ate, how they feel, and if they want to be friends!',
          bondPoints: 0.02,
        ),
        const StoryQuestion(
          id: 'park_q2',
          context: 'You see a dog\'s tail wagging really fast...',
          question: 'Does a wagging tail always mean a dog is happy?',
          options: [
            'Yes, always',
            'No, it can mean different things',
            'Only if it\'s a big dog',
            'Only on sunny days'
          ],
          correctIndex: 1,
          correctReaction: 'You\'re learning to read dog body language! 📚',
          incorrectReaction: 'Let\'s watch the dogs more closely!',
          funFact: 'A tail wag can show excitement, nervousness, or even fear. The position and speed of the wag tells the whole story!',
          bondPoints: 0.02,
        ),
      ],
      funFacts: [
        'Dogs can make friends with other dogs within seconds!',
        'Playing with other dogs helps puppies learn social skills.',
      ],
    );
  }

  StoryArc _createBarkParkFrisbeeStory() {
    return StoryArc(
      id: 'bark_park_frisbee',
      title: 'Frisbee Fun',
      description: 'Time to play fetch! Learn about dogs and exercise.',
      area: WorldArea.barkPark,
      startingMood: CompanionMood.excited,
      requiredStage: GrowthStage.adolescent,
      bondReward: 0.05,
      estimatedMinutes: 3,
      segments: [
        const StorySegment(
          id: 'frisbee_start',
          type: SegmentType.intro,
          narration: 'You pull out a frisbee and your companion\'s eyes light up!',
          companionMood: CompanionMood.excited,
        ),
      ],
      questions: [
        const StoryQuestion(
          id: 'frisbee_q1',
          context: 'Your dog is running super fast to catch the frisbee...',
          question: 'How fast can some dogs run?',
          options: [
            'Up to 15 mph',
            'Up to 25 mph',
            'Up to 45 mph',
            'Up to 70 mph'
          ],
          correctIndex: 2,
          correctReaction: 'Your speedy companion catches it mid-air! 🏆',
          incorrectReaction: 'That was close! Let\'s try again!',
          funFact: 'Greyhounds are the fastest dogs and can reach speeds of 45 mph, almost as fast as a car on a highway!',
          bondPoints: 0.02,
        ),
      ],
      funFacts: [
        'Dogs need regular exercise to stay healthy and happy!',
      ],
    );
  }

  StoryArc _createVetClinicCheckupStory() {
    return StoryArc(
      id: 'vet_checkup',
      title: 'Health Checkup',
      description: 'Visiting the vet to make sure your companion is healthy and strong!',
      area: WorldArea.vetClinic,
      startingMood: CompanionMood.curious,
      requiredStage: GrowthStage.adolescent,
      bondReward: 0.05,
      estimatedMinutes: 3,
      segments: [
        const StorySegment(
          id: 'vet_arrive',
          type: SegmentType.intro,
          narration: 'You walk into the vet clinic. Your companion sniffs the air nervously.',
          companionMood: CompanionMood.curious,
        ),
        const StorySegment(
          id: 'vet_comfort',
          type: SegmentType.transition,
          narration: 'You pet your companion gently, and they start to relax.',
          companionMood: CompanionMood.happy,
        ),
      ],
      questions: [
        const StoryQuestion(
          id: 'vet_q1',
          context: 'The vet is checking your dog\'s temperature...',
          question: 'What is a healthy body temperature for a dog?',
          options: [
            'Same as humans (98.6°F)',
            'Slightly higher (101-102.5°F)',
            'Much lower (95°F)',
            'Much higher (110°F)'
          ],
          correctIndex: 1,
          correctReaction: 'Your companion is perfectly healthy! 🏥',
          incorrectReaction: 'Good thing the vet knows! Your pup is healthy.',
          funFact: 'Dogs naturally run warmer than humans, which is why they might feel warm when you pet them!',
          bondPoints: 0.02,
        ),
      ],
      funFacts: [
        'Regular vet visits help keep dogs healthy for a long, happy life!',
      ],
    );
  }

  StoryArc _createDogShowPracticeStory() {
    return StoryArc(
      id: 'dog_show_practice',
      title: 'Show Practice',
      description: 'Practice your routines for the big dog show!',
      area: WorldArea.dogShowArena,
      startingMood: CompanionMood.excited,
      requiredStage: GrowthStage.adult,
      bondReward: 0.07,
      estimatedMinutes: 4,
      segments: [
        const StorySegment(
          id: 'show_arrive',
          type: SegmentType.intro,
          narration: 'The Dog Show Arena is buzzing with excitement! Your companion prances proudly.',
          companionMood: CompanionMood.excited,
        ),
      ],
      questions: [
        const StoryQuestion(
          id: 'show_q1',
          context: 'The judges are looking at how the dogs stand and walk...',
          question: 'What do judges look for in a dog show?',
          options: [
            'How cute the dog looks',
            'How the dog matches breed standards',
            'How loud the dog can bark',
            'How many tricks the dog knows'
          ],
          correctIndex: 1,
          correctReaction: 'Your companion strikes a perfect pose! ⭐',
          incorrectReaction: 'Your companion looks great anyway!',
          funFact: 'Dog shows evaluate dogs based on how well they match the ideal characteristics for their breed, including body shape, coat, and movement.',
          bondPoints: 0.02,
        ),
      ],
      funFacts: [
        'The most famous dog show is the Westminster Kennel Club Dog Show, held since 1877!',
      ],
    );
  }
}
