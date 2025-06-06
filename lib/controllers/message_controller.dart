import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Message> messages = <Message>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('MessageController initialisé');
  }

  // Méthode pour ajouter un message de test
  Future<void> addTestMessage(String artisanId) async {
    try {
      print('Ajout d\'un message de test pour artisanId: $artisanId');
      final message = {
        'senderId': 'client_test_1',
        'receiverId': artisanId,
        'content': 'Bonjour, je suis intéressé par vos produits.',
        'timestamp': Timestamp.now(),
        'isRead': false,
        'senderName': 'Client Test',
        'senderImage': null,
      };

      final docRef = await _firestore.collection('messages').add(message);
      print('Message de test ajouté avec succès. ID: ${docRef.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout du message de test: $e');
      rethrow;
    }
  }

  // Envoyer un nouveau message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    required String senderName,
    String? senderImage,
  }) async {
    try {
      final message = {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'senderName': senderName,
        'senderImage': senderImage,
      };

      await _firestore.collection('messages').add(message);
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }

  // Obtenir les messages entre deux utilisateurs
  Stream<List<Message>> getMessagesBetweenUsers(
    String userId1,
    String userId2,
  ) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList();
        });
  }

  // Obtenir les conversations uniques pour un utilisateur
  Stream<List<Message>> getConversations(String userId, bool isArtisan) {
    return _firestore
        .collection('messages')
        .where(isArtisan ? 'receiverId' : 'senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final allMessages =
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();

          // Grouper par expéditeur/destinataire et prendre le dernier message
          final Map<String, Message> latestMessages = {};
          for (var message in allMessages) {
            final otherUserId =
                isArtisan ? message.senderId : message.receiverId;
            if (!latestMessages.containsKey(otherUserId) ||
                message.timestamp.isAfter(
                  latestMessages[otherUserId]!.timestamp,
                )) {
              latestMessages[otherUserId] = message;
            }
          }

          return latestMessages.values.toList();
        });
  }

  // Obtenir le nombre de messages non lus
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Marquer tous les messages comme lus
  Future<void> markMessagesAsRead(
    String currentUserId,
    String otherUserId,
  ) async {
    final messages =
        await _firestore
            .collection('messages')
            .where('senderId', isEqualTo: otherUserId)
            .where('receiverId', isEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Supprimer un message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      rethrow;
    }
  }
}
