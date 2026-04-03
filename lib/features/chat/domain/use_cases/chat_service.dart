import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../entities/chat_message.dart';

class ChatService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  final String _systemPrompt;

  ChatService({required String characterName, required String characterStory})
    : _systemPrompt =
          'Sei $characterName, un animale che vive nel Parco del Delta del Po. '
          'Ecco la tua storia e le tue caratteristiche: $characterStory. '
          'Rispondi sempre in prima persona, come se fossi davvero questo animale. '
          'Parla in italiano, con un tono amichevole e didattico. '
          'Puoi raccontare curiosità su di te, il tuo habitat, le tue abitudini. '
          'Non uscire mai dal personaggio.';

  Future<String> sendMessage(List<ChatMessage> history, String userMessage) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) throw Exception('OPENAI_API_KEY non configurata');

    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...history.map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({'model': _model, 'messages': messages, 'max_tokens': 500, 'temperature': 0.8}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? 'Errore API OpenAI');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }
}
