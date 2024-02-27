import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:gemichat/utils/chat_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatManager chatManager = ChatManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        messages: chatManager.messages,
        onAttachmentPressed: _handleImageSelection,
        onSendPressed: _handleSendPressed,
        showUserAvatars: false,
        showUserNames: true,
        user: chatManager.user,
        theme: const DefaultChatTheme(
          backgroundColor: Colors.black,
          inputBorderRadius: BorderRadius.zero,
          receivedMessageBodyTextStyle: TextStyle(color: Colors.white),
          secondaryColor: Colors.green,
          attachmentButtonIcon: Icon(
            Icons.camera_alt,
            color: Colors.white,
          ),
          inputBackgroundColor: Colors.black,
          seenIcon: Text(
            'read',
            style: TextStyle(
              fontSize: 10.0,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    if (!chatManager.isLoading) {
      final textMessage = types.TextMessage(
        author: chatManager.user,
        id: const Uuid().v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: message.text,
      );
      chatManager.addMessages(textMessage);
      setState(() {});

      chatManager.generateResponse(message.text).then((response) {
        if (response != null) {
          final botMessage = types.TextMessage(
            author: chatManager.bot,
            id: const Uuid().v4(),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            text: response,
          );
          chatManager.addMessages(botMessage);
          setState(() {});
        }
      });
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
        imageQuality: 80, maxWidth: 1440, source: ImageSource.gallery);

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: chatManager.user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
      chatManager.addMessages(message);
    }
  }
}
