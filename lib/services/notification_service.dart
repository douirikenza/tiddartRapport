import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Demander la permission pour les notifications
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Initialiser les notifications locales
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);

    // Configurer le gestionnaire de messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configurer le gestionnaire de messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Enregistrer le token FCM d'un utilisateur
  Future<void> saveTokenToDatabase(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });

        // Vérifier s'il y a des notifications en attente pour cet utilisateur
        QuerySnapshot pendingNotifications =
            await _firestore
                .collection('pending_notifications')
                .where('adminId', isEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .get();

        // Envoyer les notifications en attente
        for (var doc in pendingNotifications.docs) {
          Map<String, dynamic> notification =
              doc.data() as Map<String, dynamic>;
          await _firestore.collection('notifications').add({
            'token': token,
            'title': notification['title'],
            'body': notification['body'],
            'type': notification['type'],
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Marquer la notification comme lue
          await doc.reference.update({'isRead': true});
        }
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement du token FCM: $e');
    }
  }

  // Envoyer une notification à l'admin pour un nouvel artisan
  Future<void> notifyAdminForNewArtisan(String artisanName) async {
    try {
      // Récupérer tous les tokens FCM des admins
      QuerySnapshot adminSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'admin')
              .get();

      for (var doc in adminSnapshot.docs) {
        Map<String, dynamic> adminData = doc.data() as Map<String, dynamic>;
        String? adminToken = adminData['fcmToken'];

        if (adminToken != null && adminToken.isNotEmpty) {
          // Envoyer la notification via Cloud Functions
          await _firestore.collection('notifications').add({
            'token': adminToken,
            'title': 'Nouvel artisan en attente',
            'body': '$artisanName a demandé à devenir artisan',
            'type': 'new_artisan',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Si l'admin n'a pas de token FCM, on peut stocker la notification dans une collection séparée
          await _firestore.collection('pending_notifications').add({
            'adminId': doc.id,
            'title': 'Nouvel artisan en attente',
            'body': '$artisanName a demandé à devenir artisan',
            'type': 'new_artisan',
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }
}

// Gestionnaire de messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message reçu en arrière-plan: ${message.notification?.title}');
}

// Gestionnaire de messages en premier plan
void _handleForegroundMessage(RemoteMessage message) {
  print('Message reçu en premier plan: ${message.notification?.title}');
}
