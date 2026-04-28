class TopicResponse {
  final String topicId;
  final String title;
  final List<Scene> scenes;

  TopicResponse({required this.topicId, required this.title, required this.scenes});

  factory TopicResponse.fromJson(Map<String, dynamic> json) {
    return TopicResponse(
      topicId: json['topicId'] as String,
      title: json['title'] as String,
      scenes: (json['scenes'] as List).map((e) => Scene.fromJson(e)).toList(),
    );
  }
}

class Scene {
  final int index;
  final String title;
  final String description;
  final String imageUrl;

  Scene({required this.index, required this.title, required this.description, required this.imageUrl});

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      index: json['index'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class QuestionsResponse {
  final String topicId;
  final List<Question> questions;

  QuestionsResponse({required this.topicId, required this.questions});

  factory QuestionsResponse.fromJson(Map<String, dynamic> json) {
    return QuestionsResponse(
      topicId: json['topicId'] as String,
      questions: (json['questions'] as List).map((e) => Question.fromJson(e)).toList(),
    );
  }
}

class Question {
  final int index;
  final String question;
  final String recommendation;
  final List<Option> options;

  Question({
    required this.index,
    required this.question,
    required this.recommendation,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      index: json['index'] as int,
      question: json['question'] as String,
      recommendation: json['recommendation'] as String,
      options: (json['options'] as List).map((e) => Option.fromJson(e)).toList(),
    );
  }
}

class Option {
  final String text;
  final bool isCorrect;

  Option({required this.text, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}