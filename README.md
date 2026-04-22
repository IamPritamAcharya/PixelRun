![Banner](assets/banner.png)

<h1 align="center">Pixel Runner</h1>

<p align="center">
  Endless runner built with Flutter + Flame, focused on modular game architecture and real-time systems.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Flame-Game%20Engine-orange" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" />
  <img src="https://img.shields.io/badge/License-MIT-black" />
</p>

---

## 📖 Overview

Pixel Runner is a lane-based endless runner implemented using Flutter and Flame.
The project emphasizes **clean separation of concerns**, with gameplay logic split across components, managers, and core systems.

---

## 🗂️ Project Structure

```text
lib/
├── game/
│   ├── components/
│   │   ├── coin.dart
│   │   ├── obstacle.dart
│   │   ├── particle_effect.dart
│   │   ├── player.dart
│   │   ├── power_up.dart
│   │   └── road.dart
│   │
│   ├── managers/
│   │   ├── audio_manager.dart
│   │   ├── coin_manager.dart
│   │   ├── obstacle_manager.dart
│   │   └── power_up_manager.dart
│   │
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── game_state.dart
│   │   └── runner_game.dart
│
├── screens/
│   ├── game_screen.dart
│   ├── info_screen.dart
│   ├── main_menu_screen.dart
│   └── settings_screen.dart
│
├── widgets/
│   ├── glass_card.dart
│   └── neon_button.dart
│
└── main.dart
```

---

## 🏗️ Architecture

The project follows a **layered game architecture**:

* **Game Layer (`RunnerGame`)**

  * Central game loop
  * State updates
  * Collision handling

* **Component Layer**

  * Player, obstacles, coins, power-ups, particles
  * Each is an isolated `PositionComponent`

* **Manager Layer**

  * Handles spawning and lifecycle
  * Keeps logic out of components

* **UI Layer**

  * Flutter screens and overlays
  * Completely separated from game loop

---

## ⚙️ Core Systems

### Game Loop (`RunnerGame`)

Responsible for:

* Score + distance updates
* Dynamic speed scaling
* Collision detection
* Camera effects (screen shake)

Difficulty increases over time via:

```dart
speed = initialSpeed + (score / interval) * increment
```

---

### Player System

* Lane-based movement (3 lanes)
* Smooth interpolation between lanes
* Jump system using normalized time curve:

```math
y = h × 4t(1 - t)
```

* Collision filtering when airborne (prevents unfair hits)

---

### Collision System

* Custom rectangular hitboxes
* Per-entity collision tuning
* Context-aware handling:

  * Shield overrides
  * Airborne immunity
  * Magnet attraction

---

### Procedural Generation

#### ObstacleManager

* Pattern-based spawning
* Multi-lane blocking logic
* Adaptive spawn interval

#### CoinManager

* Lane-aware spawning (avoids obstacles)
* Multiple spawn patterns

#### PowerUpManager

* Controlled spawn probability
* Balanced distribution across lanes

---

### Particle System

* Lightweight custom particle engine
* Used for:

  * Explosions
  * Coin collection
  * Power-up feedback

---

### Game State

Centralized state management:

* Score, coins, distance
* Power-up timers
* Speed tracking
* Persistent storage (high score, settings)

---

### Audio System

Singleton-based `AudioManager`:

* Background music
* SFX (jump, coin, crash)
* Volume + mute control

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (>= 3.x)
* Dart SDK

---

### Installation

```bash
git clone https://github.com/your-username/pixel-runner.git
cd pixel-runner
flutter pub get
flutter run
```

---

## 🎮 Controls

| Action     | Input                    |
| ---------- | ------------------------ |
| Move Left  | ← / A / Swipe Left       |
| Move Right | → / D / Swipe Right      |
| Jump       | ↑ / W / Space / Swipe Up |
| Slide Back | ↓ / S / Swipe Down       |
| Pause      | Esc / P                  |

---

## 🔧 Configuration

All core parameters are defined in:

```dart
GameConfig
```

Includes:

* Jump physics (`jumpHeight`, `jumpDuration`)
* Speed scaling
* Spawn intervals
* Power-up durations

---

## ⚡ Performance Considerations

* Minimal widget usage (Flame-first rendering)
* Decoupled systems (managers vs components)
* Optimized collision rectangles
* Lightweight particle system

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

Guidelines:

* Keep logic modular
* Avoid coupling between systems
* Maintain performance efficiency

---

## 📄 License

MIT License

---

## ⭐ Support

If you find this project useful, consider starring the repository.
