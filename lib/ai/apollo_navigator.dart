import 'package:flutter/material.dart';

import '../models/planet_data.dart';

class ApolloNavigator {
  static PageController? planetPageController;
  static BuildContext? mainSelectorContext;

  static List<PlanetData> planets = [];

  static int currentPlanetIndex = 0;
  static PlanetData? activePlanet;
  static bool isPlanetPopupOpen = false;

  static void Function(PlanetData planet)? openPlanetPopup;

  static final List<String> planetOrder = [
    "mercury",
    "venus",
    "earth",
    "mars",
    "jupiter",
    "saturn",
    "uranus",
    "neptune",
    "pluto",
  ];

  static PlanetData? get currentPlanet {
    if (planets.isEmpty) return null;

    final safeIndex =
        ((currentPlanetIndex % planets.length) + planets.length) %
            planets.length;

    return planets[safeIndex];
  }

  static PlanetData? get focusedPlanet {
    return activePlanet ?? currentPlanet;
  }

  static void registerPlanets(List<PlanetData> newPlanets) {
    planets = newPlanets;
  }

  static void registerOpenPlanetPopup(
      void Function(PlanetData planet) callback,
      ) {
    openPlanetPopup = callback;
  }

  static void updateCurrentPlanet(int index) {
    if (planets.isEmpty) return;

    currentPlanetIndex =
        ((index % planets.length) + planets.length) % planets.length;

    if (!isPlanetPopupOpen) {
      activePlanet = currentPlanet;
    }
  }

  static void setActivePlanet(PlanetData planet) {
    activePlanet = planet;
    isPlanetPopupOpen = true;
  }

  static void clearActivePlanet() {
    isPlanetPopupOpen = false;
    activePlanet = currentPlanet;
  }

  static String? extractPlanetName(String input) {
    final text = input.toLowerCase();

    if (planets.isNotEmpty) {
      for (final planet in planets) {
        final name = planet.name.toLowerCase();

        if (text.contains(name)) {
          return name;
        }
      }
    }

    for (final planet in planetOrder) {
      if (text.contains(planet)) {
        return planet;
      }
    }

    return null;
  }

  static Future<bool> scrollToPlanet(String input) async {
    final controller = planetPageController;
    if (controller == null || !controller.hasClients) return false;

    final targetPlanet = extractPlanetName(input);
    if (targetPlanet == null) return false;

    final order = planets.isNotEmpty
        ? planets.map((planet) => planet.name.toLowerCase()).toList()
        : planetOrder;

    final targetBaseIndex = order.indexOf(targetPlanet);
    if (targetBaseIndex == -1) return false;

    final currentPage = controller.page?.round() ?? controller.initialPage;

    final currentBaseIndex =
        ((currentPage % order.length) + order.length) % order.length;

    int bestPage = currentPage;
    int bestDistance = 999999;

    for (int loop = -2; loop <= 2; loop++) {
      final candidatePage =
          currentPage -
              currentBaseIndex +
              targetBaseIndex +
              loop * order.length;

      final distance = (candidatePage - currentPage).abs();

      if (distance < bestDistance) {
        bestDistance = distance;
        bestPage = candidatePage;
      }
    }

    await controller.animateToPage(
      bestPage,
      duration: Duration(
        milliseconds: 350 + (bestDistance * 90).clamp(0, 600).toInt(),
      ),
      curve: Curves.easeInOutCubic,
    );

    updateCurrentPlanet(targetBaseIndex);

    return true;
  }

  static bool openCurrentPlanetPopup() {
    final planet = focusedPlanet;
    if (planet == null || openPlanetPopup == null) return false;

    openPlanetPopup!(planet);
    return true;
  }

  static Future<bool> scrollAndOpenPlanet(String input) async {
    final didScroll = await scrollToPlanet(input);
    if (!didScroll) return false;

    final planetName = extractPlanetName(input);
    if (planetName == null || planets.isEmpty || openPlanetPopup == null) {
      return false;
    }

    final planet = planets.firstWhere(
          (p) => p.name.toLowerCase() == planetName,
    );

    openPlanetPopup!(planet);
    return true;
  }

  static VoidCallback? closePlanetPopup;

  static void registerClosePlanetPopup(VoidCallback callback) {
    closePlanetPopup = callback;
  }

  static bool closeCurrentPlanetPopup() {
    if (!isPlanetPopupOpen || closePlanetPopup == null) return false;

    closePlanetPopup!();
    return true;
  }
}