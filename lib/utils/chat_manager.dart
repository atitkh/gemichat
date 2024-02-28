import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatManager {
  bool isLoading = false;
  List<types.Message> messages = [];
  final user = const types.User(
    id: 'user',
  );
  final bot = const types.User(
    id: 'model',
    firstName: 'Gemi Bot',
  );

  generateResponse(String message) async {
    isLoading = true; // Indicate that a response is being generated

    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: dotenv.env['API_KEY']!,
    );

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);
      isLoading = false;
      return response.text; // Adjust if response format is different
    } catch (e) {
      isLoading = false;
      // Add an error message to the chat UI
      messages.insert(
          0,
          types.TextMessage(
            author: bot,
            id: const Uuid().v4(),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            text: "Sorry, I couldn't process your request. Please try again.",
          ));
    }
  }

  addMessages(types.Message message) async {
    if (message.author.id == bot.id && messages.isNotEmpty) {
      messages.removeAt(0); // Remove the '...' message
    }
    messages.insert(0, message);
    if (message is types.TextMessage && message.author.id == user.id) {
      messages.insert(
          0,
          types.TextMessage(
            author: bot,
            id: const Uuid().v4(),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            text: '...',
          ));
    }
  }
}
