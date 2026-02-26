# 3D Dog Skeleton System — Implementation Plan

## Goal

Create moving 3D dogs controllable by the user, with a **decoupled architecture** separating **Model** (art/mesh) from **Controller** (animation/logic). A standard **Skeleton** acts as the contract — every breed provides the animation engine with the same bone structure, so the animation code doesn't care if it's animating a Corgi, Poodle, or Pug.

## Technology

- **Rendering**: Flame game engine (added to `pubspec.yaml` as `flame: ^1.22.0`)
- **Breeds**: All 13 from `CompanionBreed` enum (labrador, goldenRetriever, beagle, poodle, bulldog, boxer, corgi, germanShepherd, husky, dalmatian, shibaInu, akita, basenji)

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Layer 4: Flutter Widget  (DogGameWidget)        │
│  Wraps Flame game into a normal Flutter widget   │
├─────────────────────────────────────────────────┤
│  Layer 3: Flame Game  (DogGame + DogController)  │
│  Game loop, user input (touch/keyboard)          │
├─────────────────────────────────────────────────┤
│  Layer 2: Animation  (DogAnimationEngine)        │
│  Procedural math on bones. Breed-agnostic.       │
│  State machine: idle, walk, run, sit, bark...    │
├─────────────────────────────────────────────────┤
│  Layer 1: Model  (DogSkeleton + BreedProfile)    │
│  Bone hierarchy = the CONTRACT                   │
│  BreedProfile = proportions per breed            │
└─────────────────────────────────────────────────┘
```

**The key decoupling**: The Animation Engine only touches `DogSkeleton` (bones). It never knows what breed it's animating. The `BreedProfile` only feeds initial proportions and visual properties. The renderer reads both skeleton poses + breed visuals to draw the dog.

---

## Bone Hierarchy (27 bones)

```
root (hip/pelvis)
├── spine_base
│   └── spine_mid
│       └── chest
│           ├── neck
│           │   └── head
│           │       ├── jaw
│           │       ├── ear_left
│           │       └── ear_right
│           ├── shoulder_left
│           │   └── upper_arm_left
│           │       └── lower_arm_left
│           │           └── paw_front_left
│           └── shoulder_right
│               └── upper_arm_right
│                   └── lower_arm_right
│                       └── paw_front_right
├── hip_left
│   └── upper_leg_left
│       └── lower_leg_left
│           └── paw_rear_left
├── hip_right
│   └── upper_leg_right
│       └── lower_leg_right
│           └── paw_rear_right
└── tail_base
    └── tail_mid
        └── tail_tip
```

Each `Bone` has:
- `name` — unique identifier (e.g. `'spine_base'`)
- `parentName` — reference to parent bone (null for root)
- `length` — rest length of this bone segment
- `localX`, `localY` — offset from parent's tip in parent's local space
- `localRotation` — rotation in radians relative to parent
- `localScale` — uniform scale factor
- `worldX`, `worldY`, `worldRotation`, `worldScale` — computed by forward kinematics

---

## Files to Create

### Step 1: Layer 1 — Models (`lib/models/skeleton/`)

#### 1a. `bone.dart` (DONE)
- `Bone` class with local/world transforms
- `tipX`/`tipY` computed properties for bone end point
- `copy()` for deep cloning
- `resetLocal()` to zero out animation transforms

#### 1b. `dog_skeleton.dart`
- `DogSkeleton` class
- `Map<String, Bone> bones` — all 27 bones keyed by name
- `static DogSkeleton create()` — factory that builds the full hierarchy with default proportions
- `void applyBreedProfile(BreedProfile profile)` — adjusts bone lengths/positions to match a breed
- `void solve()` — forward kinematics: walks parent→child computing world transforms
- `Bone getBone(String name)` — safe accessor
- `void resetPose()` — reset all bones to rest pose
- Bone name constants (e.g. `static const String root = 'root'`)

#### 1c. `breed_profile.dart`
- `BreedProfile` class containing:
  - `String name` — breed display name
  - `double bodyLength` — multiplier (1.0 = standard)
  - `double bodyWidth` — multiplier
  - `double legLength` — multiplier
  - `double headSize` — multiplier
  - `double earLength` — multiplier
  - `double earDroop` — 0.0 (erect) to 1.0 (fully floppy)
  - `double tailLength` — multiplier
  - `double tailCurl` — 0.0 (straight) to 1.0 (tight curl)
  - `double neckLength` — multiplier
  - `double chestWidth` — multiplier
  - `Color primaryColor` — main body color
  - `Color secondaryColor` — belly/accent color
  - `Color noseColor` — nose/paw pad color
- `static BreedProfile fromCompanionBreed(CompanionBreed breed)` — factory with a `switch` over all 13 breeds
- Proportions table:

| Breed            | bodyLength | bodyWidth | legLength | headSize | earLength | earDroop | tailLength | tailCurl |
|------------------|-----------|-----------|-----------|----------|-----------|----------|------------|----------|
| Labrador         | 1.0       | 1.0       | 1.0       | 1.0      | 0.8       | 0.6      | 1.0        | 0.1      |
| Golden Retriever | 1.05      | 1.05      | 1.0       | 1.0      | 0.85      | 0.7      | 1.1        | 0.15     |
| Beagle           | 0.9       | 0.9       | 0.8       | 0.95     | 1.0       | 0.9      | 0.8        | 0.3      |
| Poodle           | 0.95      | 0.8       | 1.3       | 0.9      | 1.1       | 0.8      | 0.6        | 0.2      |
| Bulldog          | 0.85      | 1.4       | 0.6       | 1.2      | 0.6       | 0.3      | 0.4        | 0.1      |
| Boxer            | 1.0       | 1.2       | 1.0       | 1.1      | 0.7       | 0.5      | 0.3        | 0.1      |
| Corgi            | 1.3       | 1.0       | 0.5       | 0.9      | 1.1       | 0.1      | 0.3        | 0.0      |
| German Shepherd  | 1.1       | 1.05      | 1.1       | 1.05     | 1.0       | 0.0      | 1.1        | 0.2      |
| Husky            | 1.05      | 1.1       | 1.0       | 1.0      | 0.85      | 0.0      | 1.0        | 0.6      |
| Dalmatian        | 1.0       | 0.9       | 1.1       | 0.95     | 0.9       | 0.6      | 1.0        | 0.15     |
| Shiba Inu        | 0.9       | 0.95      | 0.95      | 0.95     | 0.8       | 0.0      | 0.9        | 0.8      |
| Akita            | 1.15      | 1.2       | 1.1       | 1.1      | 0.8       | 0.0      | 1.0        | 0.7      |
| Basenji          | 0.95      | 0.85      | 1.15      | 0.9      | 0.7       | 0.0      | 0.7        | 0.9      |

---

### Step 2: Layer 2 — Animation (`lib/services/skeleton/`)

#### 2a. `animation_state.dart`
- `enum DogAnimationState { idle, walk, run, sit, bark, sleep, wagTail }`
- `class AnimationStateManager`:
  - `DogAnimationState currentState`
  - `DogAnimationState? previousState` — for crossfade blending
  - `double blendFactor` — 0.0 (fully previous) to 1.0 (fully current)
  - `double blendSpeed` — how fast to transition (default 3.0 = ~0.3s)
  - `void transitionTo(DogAnimationState newState)` — initiates a crossfade
  - `void update(double dt)` — advances blend factor
  - `bool canTransitionTo(DogAnimationState target)` — rules (e.g. can't run while sitting without going through idle first)

#### 2b. `dog_animation_engine.dart`
- `class DogAnimationEngine`:
  - `AnimationStateManager stateManager`
  - `double _time` — accumulated animation time
  - `double _walkCycleSpeed`, `_runCycleSpeed` — tuning constants
  - `void update(double dt, DogSkeleton skeleton)` — main entry point:
    1. Advance `_time += dt`
    2. Update state manager blend
    3. Reset skeleton to rest pose
    4. Apply current animation to bones
    5. If blending, also apply previous animation and lerp
  - Private methods for each animation:
    - `_applyIdle(skeleton, time)` — sine wave breathing on chest scale, gentle head bob, slow tail sway
    - `_applyWalk(skeleton, time)` — 4-beat diagonal gait: front-left+rear-right, then front-right+rear-left. Legs swing with sine wave, spine flexes laterally, head bobs
    - `_applyRun(skeleton, time)` — faster gait with gallop pattern, greater spine flex, ears flatten back, all paws briefly airborne
    - `_applySit(skeleton, time)` — rear legs fold (large negative rotation on lower_leg), spine tilts upward, front legs straight, tail rests on ground
    - `_applyBark(skeleton, time)` — jaw oscillates open/closed, head tilts up, body bounces, plays for ~1s then returns to idle
    - `_applySleep(skeleton, time)` — curl-up pose: spine curves, head rests on front paws, slow breathing sine wave
    - `_applyWagTail(skeleton, time)` — additive: sinusoidal tail swing with spring physics overshoot. Can layer on top of other states.
  - `static double _lerp(double a, double b, double t)` — linear interpolation
  - `static double _lerpAngle(double a, double b, double t)` — angle-aware lerp

---

### Step 3: Layer 3 — Flame Game (`lib/game/`)

#### 3a. `components/dog_body_painter.dart`
- `class DogBodyPainter`:
  - `void paint(Canvas canvas, DogSkeleton skeleton, BreedProfile profile)`:
    1. For each body segment, draw an ellipse/rounded rect between bone base and tip
    2. Size/width determined by breed profile proportions
    3. Colors from breed profile
    4. Drawing order: tail → rear legs → body → front legs → neck → head → ears (back to front)
  - Private helpers:
    - `_drawBodySegment(canvas, bone, width, color)` — draws an ellipse along the bone
    - `_drawLeg(canvas, upperBone, lowerBone, pawBone, width, color)` — draws connected leg segments
    - `_drawHead(canvas, headBone, jawBone, profile)` — draws head with eyes, nose, mouth
    - `_drawEar(canvas, earBone, profile)` — draws ear shape based on droop
    - `_drawTail(canvas, bones, profile)` — draws curved tail through tail bones
    - `_drawPaw(canvas, pawBone, color)` — draws small circle for paw

#### 3b. `components/dog_component.dart`
- `class DogComponent extends PositionComponent`:
  - `final DogSkeleton skeleton`
  - `final BreedProfile breedProfile`
  - `final DogAnimationEngine animationEngine`
  - `final DogBodyPainter painter`
  - `double facingDirection` — 1.0 (right) or -1.0 (left)
  - `Vector2 velocity` — current movement velocity
  - `@override void update(double dt)`:
    1. Update animation engine with dt and skeleton
    2. Solve skeleton forward kinematics
    3. Update position based on velocity
    4. Flip facingDirection based on velocity.x
  - `@override void render(Canvas canvas)`:
    1. Save canvas state
    2. Scale by facingDirection for horizontal flip
    3. Call `painter.paint(canvas, skeleton, breedProfile)`
    4. Restore canvas
  - `void setAnimationState(DogAnimationState state)` — delegate to engine
  - `void move(Vector2 direction)` — set velocity and trigger walk/run

#### 3c. `dog_controller.dart`
- `class DogController`:
  - `DogComponent? dog` — reference to controlled dog
  - `Vector2 _inputDirection` — accumulated input direction
  - `double walkThreshold` — input magnitude below this = walk
  - `double runThreshold` — input magnitude above this = run
  - `void onKeyEvent(KeyEvent event)`:
    - W/Up → _inputDirection.y -= 1
    - S/Down → _inputDirection.y += 1
    - A/Left → _inputDirection.x -= 1
    - D/Right → _inputDirection.x += 1
    - Space → bark
    - E → toggle sit/stand
    - R → toggle sleep/wake
  - `void onJoystickMove(Vector2 delta)` — for touch input
  - `void onActionButton(DogAnimationState action)` — for touch action buttons
  - `void update(double dt)`:
    1. Normalize input direction
    2. If magnitude > 0: move dog, set walk/run based on magnitude
    3. If magnitude == 0 and was moving: transition to idle
    4. Reset input each frame (for keyboard, accumulate; for joystick, direct set)

#### 3d. `dog_game.dart`
- `class DogGame extends FlameGame with KeyboardEvents`:
  - `late DogComponent dog`
  - `late DogController controller`
  - `final CompanionBreed breed` — constructor parameter
  - `Color backgroundColor` — light grass green
  - `@override Future<void> onLoad()`:
    1. Create `DogSkeleton.create()`
    2. Create `BreedProfile.fromCompanionBreed(breed)`
    3. Apply profile to skeleton
    4. Create `DogAnimationEngine()`
    5. Create `DogComponent` with all the above
    6. Create `DogController` linked to dog
    7. Add dog component to game, center it
  - `@override void update(double dt)`: update controller
  - `@override KeyEventResult onKeyEvent(event, keysPressed)`: delegate to controller
  - `void changeBreed(CompanionBreed newBreed)` — hot-swap breed at runtime (proves decoupling!)

---

### Step 4: Layer 4 — Widget (`lib/widgets/skeleton/`)

#### 4a. `dog_game_widget.dart`
- `class DogGameWidget extends StatefulWidget`:
  - `final CompanionBreed breed`
  - `final double width, height`
  - `final bool showControls` — whether to overlay touch controls
- `class _DogGameWidgetState extends State<DogGameWidget>`:
  - `late DogGame _game`
  - `@override void initState()`: create `DogGame(breed: widget.breed)`
  - `@override Widget build(BuildContext context)`:
    - `Stack` containing:
      1. `GameWidget(game: _game)` — the Flame game
      2. If `showControls`: overlay with action buttons (Sit, Bark, Sleep) positioned at bottom
  - `@override void didUpdateWidget()`: if breed changed, call `_game.changeBreed(newBreed)`

---

### Step 5: Tests (`test/skeleton/`)

#### 5a. `bone_test.dart`
- Bone creation with defaults
- Bone copy independence
- Tip position calculation
- Reset local transforms

#### 5b. `dog_skeleton_test.dart`
- Creates 27 bones
- Parent-child relationships are correct
- Forward kinematics: child world position depends on parent
- Apply breed profile changes bone lengths
- Reset pose restores defaults

#### 5c. `breed_profile_test.dart`
- All 13 CompanionBreeds produce valid profiles
- All multipliers are positive
- Colors are non-null
- Labrador is the reference (all multipliers ~1.0)

#### 5d. `dog_animation_engine_test.dart`
- Default state is idle
- State transitions update current state
- Blend factor progresses over time
- Walk animation modifies leg bone rotations
- Idle animation modifies chest scale
- Bones are different from rest pose after animation

---

### Step 6: Integration & Commit

- Verify all tests pass
- Commit all files with descriptive message
- Push to `claude/3d-dogs-skeleton-system-WDfxV`

---

## How the Decoupling Works in Practice

```dart
// The animation engine ONLY knows about bones:
engine.update(dt, skeleton);  // Just math on bone transforms

// The breed profile ONLY defines proportions:
skeleton.applyBreedProfile(corgiProfile);  // Short legs, long body
skeleton.applyBreedProfile(poodleProfile); // Tall legs, small body

// The renderer reads BOTH, but they don't know about each other:
painter.paint(canvas, skeleton, profile);  // Draws shapes at bone positions

// Swapping breeds at runtime is trivial:
game.changeBreed(CompanionBreed.corgi);    // Same animation, different dog!
```

The skeleton is the **contract**. As long as every breed maps to the same 27 bones, any animation works with any breed. Add a new breed? Just define a new `BreedProfile`. Add a new animation? Just add a new method in `DogAnimationEngine`. Neither change affects the other.
