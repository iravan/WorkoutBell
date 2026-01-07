# Workout Timer

A Flutter workout timer app that alternates between workout and rest periods.

## Features

- Configurable workout time (1, 2, 3, 4, 5, 10, 15, 30 minutes)
- Configurable rest time (0.5, 1, 2, 3, 4, 5, 10 minutes)
- Visual circular progress indicator
- Round counter
- Tap to start/pause timer
- Long press to reset timer
- Sound notification when timer reaches zero
- Persists workout/rest time preferences

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Add sound file:
   - Place a `boxingbell.mp3` file in the `assets/sounds/` directory
   - The app will use haptic feedback as a fallback if the sound file is not found

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

- **Tap the circle** to start/pause the timer
- **Long press the circle** to reset the timer
- **Tap workout/rest time labels** to cycle through available durations
- **Long press the time display** at the top to show seconds
