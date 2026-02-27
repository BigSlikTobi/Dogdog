import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/companion.dart';
import '../models/companion_enums.dart';
import '../models/memory.dart';

/// Controller managing the companion's state, mood, and progression
class CompanionController extends ChangeNotifier {
  static const String _companionKey = 'companion_data';
  static const String _memoriesKey = 'memories_data';

  Companion? _companion;
  List<Memory> _memories = [];
  bool _isLoading = true;
  
  /// Bond gained per correct answer (base value)
  static const double _bondPerCorrect = 0.005; // 0.5% per correct
  
  /// Bond bonus for streaks
  static const double _streakBonus = 0.002; // 0.2% extra per streak

  Companion? get companion => _companion;
  List<Memory> get memories => List.unmodifiable(_memories);
  bool get isLoading => _isLoading;
  bool get hasCompanion => _companion != null;

  /// Get highlighted memories
  List<Memory> get highlightedMemories =>
      _memories.where((m) => m.isHighlighted).toList();

  /// Get memories for a specific world area
  List<Memory> memoriesForArea(WorldArea area) =>
      _memories.where((m) => m.worldArea == area.name).toList();

  /// Available breeds for current stage
  List<CompanionBreed> get availableBreeds {
    final stage = _companion?.stage ?? GrowthStage.puppy;
    return CompanionBreed.availableAt(stage);
  }

  /// Unlocked world areas
  List<WorldArea> get unlockedAreas {
    final stage = _companion?.stage ?? GrowthStage.puppy;
    return WorldArea.values.where((a) => a.isUnlockedFor(stage)).toList();
  }

  /// Initialize the controller
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load companion
      final companionJson = prefs.getString(_companionKey);
      if (companionJson != null) {
        _companion = Companion.fromJson(
          jsonDecode(companionJson) as Map<String, dynamic>,
        );
        
        // Update mood if companion missed the player
        if (_companion!.missedPlayer) {
          _companion = _companion!.withMood(CompanionMood.excited);
        }
        
        // Calculate hunger decay on load
        _checkHunger();
      }

      // Load memories
      final memoriesJson = prefs.getString(_memoriesKey);
      if (memoriesJson != null) {
        final list = jsonDecode(memoriesJson) as List<dynamic>;
        _memories = list
            .map((e) => Memory.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('Error loading companion data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adopt a new companion
  Future<void> adoptCompanion({
    required String name,
    required CompanionBreed breed,
  }) async {
    _companion = Companion(
      id: _generateId(),
      name: name,
      breed: breed,
      adoptedAt: DateTime.now(),
      lastInteractionAt: DateTime.now(),
      mood: CompanionMood.excited,
      lastFedAt: DateTime.now(),
    );
    
    await _save();
    notifyListeners();
  }

  /// Rename the companion
  Future<void> renameDog(String newName) async {
    if (_companion == null || newName.isEmpty) return;
    
    _companion = _companion!.copyWith(name: newName);
    await _save();
    notifyListeners();
  }

  /// Add bond from correct answer
  Future<void> onCorrectAnswer({int streak = 0}) async {
    if (_companion == null) return;

    double bondAmount = _bondPerCorrect;
    if (streak >= 3) bondAmount += _streakBonus;
    if (streak >= 5) bondAmount += _streakBonus;

    final previousStage = _companion!.stage;
    _companion = _companion!.addBond(bondAmount);

    // Check for growth stage change
    if (_companion!.stage != previousStage) {
      _companion = _companion!.withMood(CompanionMood.excited);
    } else {
      _companion = _companion!.withMood(CompanionMood.happy);
    }

    await _save();
    notifyListeners();
  }

  /// Handle wrong answer (gentle, no punishment)
  Future<void> onWrongAnswer() async {
    if (_companion == null) return;

    _companion = _companion!.copyWith(
      mood: CompanionMood.curious,
      lastInteractionAt: DateTime.now(),
    );

    await _save();
    notifyListeners();

  }
  
  /// Check and update hunger based on time passed
  void _checkHunger() {
    if (_companion == null) return;
    
    final hoursSinceFed = DateTime.now().difference(_companion!.lastFedAt).inMinutes / 60.0;
    if (hoursSinceFed > 0.5) { // Only update if significant time passed
      // Decay rate: ~10% per hour
      final decay = hoursSinceFed * 0.1;
      final newHunger = (_companion!.hunger - decay).clamp(0.0, 1.0);
      
      if (newHunger != _companion!.hunger) {
        _companion = _companion!.copyWith(
          hunger: newHunger,
          // If very hungry, mood changes
          mood: newHunger < 0.3 ? CompanionMood.sleepy : _companion!.mood,
        );
        _save(); // Save background update
      }
    }
  }

  /// Feed the companion
  /// Returns true if successful, false if not enough treats or full
  Future<bool> feedCompanion() async {
    if (_companion == null) return false;
    
    // Check if full
    if (_companion!.hunger >= 1.0) return false;
    
    // Check treats
    if (_companion!.treats < 1) return false;
    
    _companion = _companion!.copyWith(
      hunger: (_companion!.hunger + 0.3).clamp(0.0, 1.0), // +30% hunger
      treats: _companion!.treats - 1, // Cost 1 treat
      lastFedAt: DateTime.now(),
      mood: CompanionMood.happy,
      lastInteractionAt: DateTime.now(),
    );
    
    // Small bond boost for care
    _companion = _companion!.addBond(0.002);
    
    await _save();
    notifyListeners();
    return true;
  }

  /// Add bond from casual interaction (cuddle, pet, feed)
  Future<void> addBondFromInteraction(double amount) async {
    if (_companion == null) return;

    _companion = _companion!.copyWith(
      bondLevel: _companion!.bondLevel + amount,
      mood: CompanionMood.happy,
      lastInteractionAt: DateTime.now(),
    );

    await _save();
    notifyListeners();
  }

  /// Update mood directly
  Future<void> setMood(CompanionMood mood) async {
    if (_companion == null) return;

    _companion = _companion!.withMood(mood);
    await _save();
    notifyListeners();
  }

  /// Create and save a new memory
  Future<Memory> createMemory({
    required String storyTitle,
    required String description,
    required WorldArea area,
    required List<String> factsLearned,
    required int correctAnswers,
    required double bondGained,
    String? screenshotPath,
  }) async {
    final memory = Memory(
      id: _generateId(),
      timestamp: DateTime.now(),
      storyTitle: storyTitle,
      description: description,
      factsLearned: factsLearned,
      worldArea: area.name,
      correctAnswers: correctAnswers,
      bondGained: bondGained,
      screenshotPath: screenshotPath,
    );

    _memories.insert(0, memory);
    await _save();
    notifyListeners();

    return memory;
  }

  /// Toggle memory highlight
  Future<void> toggleMemoryHighlight(String memoryId) async {
    final index = _memories.indexWhere((m) => m.id == memoryId);
    if (index == -1) return;

    _memories[index] = _memories[index].toggleHighlight();
    await _save();
    notifyListeners();
  }

  /// Record companion interaction (updates mood and last interaction)
  Future<void> recordInteraction() async {
    if (_companion == null) return;

    _companion = _companion!.copyWith(
      lastInteractionAt: DateTime.now(),
    );

    await _save();
    notifyListeners();
  }

  /// Check if a new growth stage was reached
  bool didReachNewStage(GrowthStage previousStage) {
    return _companion != null && _companion!.stage != previousStage;
  }

  /// Save data to storage
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_companion != null) {
        await prefs.setString(_companionKey, jsonEncode(_companion!.toJson()));
      }

      await prefs.setString(
        _memoriesKey,
        jsonEncode(_memories.map((m) => m.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving companion data: $e');
    }
  }

  /// Generate unique ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Reset companion (for testing/new game)
  Future<void> reset() async {
    _companion = null;
    _memories.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_companionKey);
    await prefs.remove(_memoriesKey);

    notifyListeners();
  }
}
