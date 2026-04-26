import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/planet_data.dart';
import '../models/planet_quiz_question.dart';

class ApolloQuizService {
  static const String baseUrl =
      'https://optima-livekit-token-server.onrender.com';

  static Future<PlanetQuizQuestion?> generateQuiz(PlanetData planet) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apollo-quiz'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'planet': {
          'name': planet.name,
          'subtitle': planet.subtitle,
          'description': planet.description,
          'diameter': planet.diameter,
          'mass': planet.mass,
          'dayLength': planet.dayLength,
        },
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);
    return PlanetQuizQuestion.fromJson(data);
  }
}