class PomodoroMusic {
  final String name;
  final String assetPath;

  PomodoroMusic(this.name, this.assetPath);
}

final List<PomodoroMusic> availableMusics = [
  PomodoroMusic('None', ''),
  PomodoroMusic('Tic-tac', 'assets/sounds/tic-tac.mp3'),
  PomodoroMusic('Night Rain', 'assets/sounds/nightRainForest.mp3'),
  PomodoroMusic('Campfire', 'assets/sounds/Campfire.mp3'),
];
