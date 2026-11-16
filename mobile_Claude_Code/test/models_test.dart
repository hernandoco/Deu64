import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models.dart';

void main() {
  test('TopicResponse lee el tema y sus escenas', () {
    final topic = TopicResponse.fromJson({
      'topicId': 't1',
      'title': 'Detrás del corazón de Dios',
      'scenes': [
        {
          'index': 1,
          'title': 'Escena 1',
          'description': 'Descripción',
          'imageUrl': 'http://example.com/1.png',
        },
      ],
    });

    expect(topic.topicId, 't1');
    expect(topic.title, 'Detrás del corazón de Dios');
    expect(topic.scenes, hasLength(1));
    expect(topic.scenes.first.imageUrl, 'http://example.com/1.png');
  });

  test('QuestionsResponse lee preguntas y cuál opción es correcta', () {
    final resp = QuestionsResponse.fromJson({
      'topicId': 't1',
      'questions': [
        {
          'index': 1,
          'question': '¿Pregunta?',
          'recommendation': 'Pista',
          'options': [
            {'text': 'Sí', 'isCorrect': true},
            {'text': 'No', 'isCorrect': false},
          ],
        },
      ],
    });

    final q = resp.questions.single;
    expect(q.question, '¿Pregunta?');
    expect(q.recommendation, 'Pista');
    expect(q.options.map((o) => o.isCorrect), [true, false]);
  });

  test('PrayerResponse usa valores vacíos y omite versículos vacíos', () {
    final prayer = PrayerResponse.fromJson({
      'title': 'Oración',
      'verses': [
        {'verse': 'Juan 3:16'},
        {'verse': ''},
        <String, dynamic>{},
      ],
    });

    expect(prayer.topicId, '');
    expect(prayer.prayer, '');
    expect(prayer.verses, ['Juan 3:16']);
  });

  test('ChallengeResponse lee los retos desde listChallenge', () {
    final reto = ChallengeResponse.fromJson({
      'title': 'Reto',
      'listChallenge': [
        {'challenge': 'Ayuda en casa', 'tips': 'Pregunta qué falta'},
      ],
    });

    expect(reto.challenges.single.challenge, 'Ayuda en casa');
    expect(reto.challenges.single.tips, 'Pregunta qué falta');
  });

  test('ChallengeResponse sin listChallenge queda sin retos', () {
    expect(ChallengeResponse.fromJson({}).challenges, isEmpty);
  });

  test('AudioMessageResponse lee la URL desde audio_url', () {
    final audio = AudioMessageResponse.fromJson({
      'title': 'Mensaje',
      'audio_url': 'http://example.com/a.mp3',
    });

    expect(audio.audioUrl, 'http://example.com/a.mp3');
  });
}
