import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Demander la permission pour les notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Initialiser les notifications locales
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Configurer le gestionnaire de messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Configurer le gestionnaire de messages en premier plan
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Forcer la mise à jour du token FCM
      await _messaging.deleteToken();
      String? token = await _messaging.getToken();
      debugPrint('New FCM Token: $token');

      // Mettre à jour le token FCM pour l'utilisateur actuel
      if (token != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await saveTokenToDatabase(user.uid);
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _showErrorMessage('Erreur lors de l\'initialisation des notifications');
    }
  }

  Future<void> saveTokenToDatabase(String userId) async {
    try {
      String? token = await _messaging.getToken();
      debugPrint('Saving FCM token for user $userId: $token');

      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('FCM token saved successfully for user $userId');
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
      _showErrorMessage(
        'Erreur lors de l\'enregistrement du token de notification',
      );
    }
  }

  Future<void> notifyAdminForNewArtisan(String artisanName) async {
    try {
      debugPrint('Notifying admins about new artisan: $artisanName');

      // Récupérer tous les tokens FCM des admins
      QuerySnapshot adminSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'admin')
              .get();

      debugPrint('Found ${adminSnapshot.docs.length} admin users');

      for (var doc in adminSnapshot.docs) {
        Map<String, dynamic> adminData = doc.data() as Map<String, dynamic>;
        String? adminToken = adminData['fcmToken'];
        String adminId = doc.id;

        debugPrint('Processing admin $adminId with token: $adminToken');

        if (adminToken != null && adminToken.isNotEmpty) {
          // Envoyer la notification via Cloud Functions
          await _firestore.collection('notifications').add({
            'token': adminToken,
            'title': 'Nouvel artisan en attente',
            'body': '$artisanName a demandé à devenir artisan',
            'type': 'new_artisan',
            'adminId': adminId,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'pending',
          });
          debugPrint('Notification sent to admin $adminId');
        } else {
          // Si l'admin n'a pas de token FCM, stocker la notification
          await _firestore.collection('pending_notifications').add({
            'adminId': adminId,
            'title': 'Nouvel artisan en attente',
            'body': '$artisanName a demandé à devenir artisan',
            'type': 'new_artisan',
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
          });
          debugPrint('Pending notification stored for admin $adminId');
        }
      }
    } catch (e) {
      debugPrint('Error notifying admin: $e');
      _showErrorMessage(
        'Erreur lors de l\'envoi de la notification à l\'admin',
      );
    }
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erreur',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      shouldIconPulse: true,
      barBlur: 10,
      overlayBlur: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

// Gestionnaire de messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Message reçu en arrière-plan: ${message.notification?.title}');
  debugPrint('Message data: ${message.data}');
}

// Gestionnaire de messages en premier plan
void _handleForegroundMessage(RemoteMessage message) {
  debugPrint('Message reçu en premier plan: ${message.notification?.title}');
  debugPrint('Message data: ${message.data}');
}
