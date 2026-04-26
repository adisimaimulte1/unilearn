class PlanetQuizQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String explanation;

  const PlanetQuizQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.explanation,
  });

  factory PlanetQuizQuestion.fromJson(Map<String, dynamic> json) {
    return PlanetQuizQuestion(
      question: json['question'] ?? '',
      answers: List<String>.from(json['answers'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}