import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ApolloRecordings {
  static final Random _random = Random();

  static const int wakeCount = 15;
  static const int shutdownCount = 10;
  static const int openPlanetCount = 10;

  static final Map<String, int> actionCounts = {
    'mercury': 5,
    'venus': 5,
    'earth': 5,
    'mars': 5,
    'jupiter': 5,
    'saturn': 5,
    'uranus': 5,
    'neptune': 5,
    'pluto': 5,
  };

  static Future<Uint8List> getWakeResponse() async {
    final index = _random.nextInt(wakeCount) + 1;

    final data = await rootBundle.load(
      'assets/audio/apollo/wake/$index.mp3',
    );

    return data.buffer.asUint8List();
  }

  static Future<Uint8List?> getPlanetResponse(String planetName) async {
    final folder = planetName.toLowerCase();
    final count = actionCounts[folder];

    if (count == null) return null;

    final index = _random.nextInt(count) + 1;

    final data = await rootBundle.load(
      'assets/audio/apollo/$folder/$index.mp3',
    );

    return data.buffer.asUint8List();
  }

  static Future<Uint8List> getOpenPlanetResponse() async {
    final index = _random.nextInt(openPlanetCount) + 1;

    final data = await rootBundle.load(
      'assets/audio/apollo/open_planet/$index.mp3',
    );

    return data.buffer.asUint8List();
  }

  static const int closePlanetCount = 10;

  static Future<Uint8List> getClosePlanetResponse() async {
    final index = _random.nextInt(closePlanetCount) + 1;

    final data = await rootBundle.load(
      'assets/audio/apollo/close_planet/$index.mp3',
    );

    return data.buffer.asUint8List();
  }

  static Future<Uint8List> getShutdownResponse() async {
    final index = _random.nextInt(shutdownCount) + 1;

    final data = await rootBundle.load(
      'assets/audio/apollo/shutdown/$index.mp3',
    );

    return data.buffer.asUint8List();
  }}