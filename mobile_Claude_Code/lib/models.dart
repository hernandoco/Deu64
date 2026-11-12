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


/// Versículo del día (`/api/v1/versiculo_del_dia`).
class VerseResponse {
  final String topicId;
  final String title;
  final String description;
  final String verse;

  VerseResponse({
    required this.topicId,
    required this.title,
    required this.description,
    required this.verse,
  });

  factory VerseResponse.fromJson(Map<String, dynamic> json) {
    return VerseResponse(
      topicId: json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      verse: json['verse'] as String? ?? '',
    );
  }
}

/// Oración modelo (`/api/v1/oracion_modelo`).
class PrayerResponse {
  final String topicId;
  final String title;
  final String prayer;
  final List<String> verses;

  PrayerResponse({
    required this.topicId,
    required this.title,
    required this.prayer,
    required this.verses,
  });

  factory PrayerResponse.fromJson(Map<String, dynamic> json) {
    return PrayerResponse(
      topicId: json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      prayer: json['prayer'] as String? ?? '',
      verses: ((json['verses'] as List?) ?? const [])
          .map((e) => (e as Map<String, dynamic>)['verse'] as String? ?? '')
          .where((v) => v.isNotEmpty)
          .toList(),
    );
  }
}

/// Reto del día (`/api/v1/reto_del_dia`).
class ChallengeResponse {
  final String topicId;
  final String title;
  final String description;
  final List<ChallengeItem> challenges;

  ChallengeResponse({
    required this.topicId,
    required this.title,
    required this.description,
    required this.challenges,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeResponse(
      topicId: json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      challenges: ((json['listChallenge'] as List?) ?? const [])
          .map((e) => ChallengeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChallengeItem {
  final String challenge;
  final String tips;

  ChallengeItem({required this.challenge, required this.tips});

  factory ChallengeItem.fromJson(Map<String, dynamic> json) {
    return ChallengeItem(
      challenge: json['challenge'] as String? ?? '',
      tips: json['tips'] as String? ?? '',
    );
  }
}

/// Mensaje de hoy en audio (`/api/v1/Mensaje_audible`).
class AudioMessageResponse {
  final String topicId;
  final String title;
  final String audioUrl;

  AudioMessageResponse({
    required this.topicId,
    required this.title,
    required this.audioUrl,
  });

  factory AudioMessageResponse.fromJson(Map<String, dynamic> json) {
    return AudioMessageResponse(
      topicId: json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      audioUrl: json['audio_url'] as String? ?? '',
    );
  }
}
