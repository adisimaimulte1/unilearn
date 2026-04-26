class ApolloIntentProcessor {
  static bool isOpenPlanetCommand(String input) {
    return _isOpenPlanetCommand(input);
  }

  static bool isPlanetScrollCommand(String input) {
    final text = input.toLowerCase();

    final scrollWords = [
      "go to",
      "show",
      "open",
      "take me to",
      "scroll to",
      "move to",
    ];

    final planets = [
      "mercury",
      "venus",
      "earth",
      "mars",
      "jupiter",
      "saturn",
      "uranus",
      "neptune",
      "pluto",
      "sun",
    ];

    return scrollWords.any(text.contains) && planets.any(text.contains);
  }

  static bool isShutdownCommand(String input) {
    final text = input.toLowerCase();

    return text.contains("turn off") ||
        text.contains("shut down") ||
        text.contains("shutdown") ||
        text.contains("stop apollo") ||
        text.contains("go to sleep") ||
        text.contains("disable apollo") ||
        text.contains("shut yourself down");
  }

  static bool _isOpenPlanetCommand(String input) {
    final text = input.toLowerCase();

    return text.contains("open planet") ||
        text.contains("show planet") ||
        text.contains("open this planet") ||
        text.contains("show this planet") ||
        text.contains("open card") ||
        text.contains("show card") ||
        text.contains("open planet card") ||
        text.contains("show planet card") ||
        text.contains("open this card") ||
        text.contains("show this card") ||
        text.contains("open it") ||
        text.contains("show it") ||
        text.contains("open this") ||
        text.contains("show this") ||
        text.contains("open the planet") ||
        text.contains("show the planet") ||
        text.contains("open the card");
  }

  static bool isClosePlanetCommand(String input) {
    final text = input.toLowerCase();

    return text.contains('close planet') ||
        text.contains('close this') ||
        text.contains('close card') ||
        text.contains('hide this') ||
        text.contains('go back') ||
        text.contains('exit planet') ||
        text.contains('close it') ||
        text.contains('close the planet') ||
        text.contains('close the card') ||
        text.contains('go back') ||
        text.contains('exit the planet');
  }

  static bool isMorePlanetInfoCommand(String input) {
    final text = input.toLowerCase();

    return text.contains("tell me more") ||
        text.contains("more details") ||
        text.contains("more information") ||
        text.contains("explain this planet") ||
        text.contains("what about this planet") ||
        text.contains("details about this planet") ||
        text.contains("tell me about this planet");
  }

  static String cleanWakeWord(String input) {
    return input
        .replaceAll(RegExp(r"(hey|ok|okay)\s+apollo", caseSensitive: false), "")
        .trim();
  }
}