import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../controllers/message_controller.dart';
import '../../models/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';

class ClientChatPage extends StatefulWidget {
  final String clientId;
  final String artisanId;
  final String artisanName;

  const ClientChatPage({
    Key? key,
    required this.clientId,
    required this.artisanId,
    required this.artisanName,
  }) : super(key: key);

  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  final MessageController _messageController = Get.find<MessageController>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  final ImagePicker _picker = ImagePicker();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Marquer les messages comme lus lors de l'ouverture de la conversation
    _messageController.markMessagesAsRead(widget.clientId, widget.artisanId);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userData = await _authController.getCurrentUserData();
      final clientName = userData?['name'] ?? 'Client';
      await _messageController.sendMessage(
        senderId: widget.clientId,
        receiverId: widget.artisanId,
        content: text.trim(),
        senderName: clientName,
        senderImage: null,
      );

      _textController.clear();
      setState(() {
        _isComposing = false;
      });
    } catch (e) {
      _showMessage('Erreur lors de l\'envoi du message', true);
    }
  }

  Future<void> _pickAndSendImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: await _showImageSourceDialog(),
      imageQuality: 70,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      final userData = await _authController.getCurrentUserData();
      final clientName = userData?['name'] ?? 'Client';
      await _messageController.sendMessage(
        senderId: widget.clientId,
        receiverId: widget.artisanId,
        content: imageUrl,
        senderName: clientName,
        senderImage: null,
      );
    }
  }

  Future<ImageSource> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppTheme.backgroundLight,
                title: Center(
                  child: Text(
                    'Envoyer une image',
                    style: TextStyle(
                      color: AppTheme.primaryBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: AppTheme.primaryBrown,
                            size: 36,
                          ),
                          onPressed:
                              () => Navigator.pop(context, ImageSource.camera),
                          tooltip: 'Caméra',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Caméra',
                          style: TextStyle(color: AppTheme.primaryBrown),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.photo_library,
                            color: AppTheme.primaryBrown,
                            size: 36,
                          ),
                          onPressed:
                              () => Navigator.pop(context, ImageSource.gallery),
                          tooltip: 'Galerie',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Galerie',
                          style: TextStyle(color: AppTheme.primaryBrown),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ) ??
        ImageSource.gallery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.primaryBrown.withOpacity(0.1),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.artisanName,
              style: TextStyle(
                color: AppTheme.primaryBrown,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'En ligne',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
          onPressed: () {
            Navigator.of(context).pop();
            Get.back();
          },
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageController.getMessagesBetweenUsers(
                widget.clientId,
                widget.artisanId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBrown,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de chargement des messages',
                      style: TextStyle(color: AppTheme.primaryBrown),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.primaryBrown.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message',
                          style: TextStyle(
                            color: AppTheme.primaryBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == widget.clientId;

                    return GestureDetector(
                      onLongPress:
                          isMe
                              ? () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        backgroundColor:
                                            AppTheme.backgroundLight,
                                        title: Text(
                                          'Supprimer le message ?',
                                          style: TextStyle(
                                            color: AppTheme.primaryBrown,
                                          ),
                                        ),
                                        content: Text(
                                          'Voulez-vous vraiment supprimer ce message ?',
                                          style: TextStyle(
                                            color: AppTheme.primaryBrown,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: Text(
                                              'Annuler',
                                              style: TextStyle(
                                                color: AppTheme.primaryBrown,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: Text(
                                              'Supprimer',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await _messageController.deleteMessage(
                                    message.id,
                                  );
                                }
                              }
                              : null,
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: 8,
                            left: isMe ? 64 : 0,
                            right: isMe ? 0 : 64,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMe ? AppTheme.primaryBrown : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    message.senderName,
                                    style: TextStyle(
                                      color: AppTheme.primaryBrown,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              message.content.startsWith('http')
                                  ? Image.network(
                                    message.content,
                                    width: 200,
                                    height: 200,
                                  )
                                  : Text(
                                    message.content,
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message.timestamp),
                                style: TextStyle(
                                  color:
                                      isMe
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add_photo_alternate,
                          color: AppTheme.primaryBrown,
                        ),
                        onPressed: _pickAndSendImage,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _textController,
                          onChanged: (text) {
                            final composing = text.trim().isNotEmpty;
                            if (composing != _isComposing) {
                              setState(() {
                                _isComposing = composing;
                              });
                            }
                          },
                          onSubmitted: _isComposing ? _handleSubmitted : null,
                          decoration: InputDecoration(
                            hintText: 'Écrivez votre message...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color:
                            _isComposing
                                ? AppTheme.primaryBrown
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed:
                            _isComposing
                                ? () => _handleSubmitted(_textController.text)
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  void _showMessage(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
