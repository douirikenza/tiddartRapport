import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminSettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isDarkMode = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString currentLanguage = 'Français'.obs;
  final RxBool maintenanceMode = false.obs;
  final RxBool twoFactorEnabled = false.obs;

  // Liste des langues disponibles
  final List<String> availableLanguages = ['Français', 'English', 'العربية'];

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Récupérer l'ID de l'utilisateur actuel
  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  // Charger les paramètres depuis Firestore
  Future<void> loadSettings() async {
    try {
      final settings =
          await _firestore.collection('settings').doc('admin').get();
      if (settings.exists) {
        final data = settings.data()!;
        isDarkMode.value = data['darkMode'] ?? false;
        notificationsEnabled.value = data['notifications'] ?? true;
        currentLanguage.value = data['language'] ?? 'Français';
        maintenanceMode.value = data['maintenanceMode'] ?? false;
        twoFactorEnabled.value = data['twoFactorAuth'] ?? false;
      }
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  // Sauvegarder les paramètres dans Firestore
  Future<void> saveSettings() async {
    try {
      await _firestore.collection('settings').doc('admin').set({
        'darkMode': isDarkMode.value,
        'notifications': notificationsEnabled.value,
        'language': currentLanguage.value,
        'maintenanceMode': maintenanceMode.value,
        'twoFactorAuth': twoFactorEnabled.value,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        'Succès',
        'Paramètres sauvegardés avec succès',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde des paramètres',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  // Gérer les notifications
  Future<void> toggleNotifications() async {
    notificationsEnabled.value = !notificationsEnabled.value;
    await saveSettings();
  }

  // Changer la langue
  Future<void> changeLanguage(String language) async {
    currentLanguage.value = language;
    // Ici, vous pouvez ajouter la logique pour changer la langue de l'application
    await saveSettings();
  }

  // Changer le thème
  Future<void> toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;

      // Sauvegarder d'abord les paramètres
      await saveSettings();

      // Appliquer le thème après la sauvegarde
      // Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

      Get.snackbar(
        'Succès',
        'Thème modifié avec succès',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // En cas d'erreur, revenir à l'état précédent
      isDarkMode.value = !isDarkMode.value;
      Get.snackbar(
        'Erreur',
        'Erreur lors du changement de thème',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  // Changer le mot de passe
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Récupérer l'utilisateur actuel
      final user = _auth.currentUser;
      if (user == null) throw 'Utilisateur non connecté';

      // Vérifier le mot de passe actuel
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Mettre à jour le mot de passe
      await user.updatePassword(newPassword);

      Get.snackbar(
        'Succès',
        'Mot de passe modifié avec succès',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du changement de mot de passe: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  // Gérer l'authentification à deux facteurs
  Future<void> toggleTwoFactor() async {
    twoFactorEnabled.value = !twoFactorEnabled.value;
    await saveSettings();
  }

  // Gérer le mode maintenance
  Future<void> toggleMaintenanceMode() async {
    maintenanceMode.value = !maintenanceMode.value;
    await saveSettings();
  }

  // Sauvegarder les données
  Future<void> backupData() async {
    try {
      // Récupérer toutes les collections importantes
      final users = await _firestore.collection('users').get();
      final products = await _firestore.collection('products').get();
      final orders = await _firestore.collection('orders').get();

      // Créer un document de sauvegarde
      await _firestore.collection('backups').add({
        'timestamp': FieldValue.serverTimestamp(),
        'users': users.docs.map((doc) => doc.data()).toList(),
        'products': products.docs.map((doc) => doc.data()).toList(),
        'orders': orders.docs.map((doc) => doc.data()).toList(),
      });

      Get.snackbar(
        'Succès',
        'Sauvegarde effectuée avec succès',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
    }
  }

  // Récupérer les logs système
  Future<List<Map<String, dynamic>>> getSystemLogs() async {
    try {
      final logs =
          await _firestore
              .collection('logs')
              .orderBy('timestamp', descending: true)
              .limit(50)
              .get();

      return logs.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur lors de la récupération des logs: $e');
      return [];
    }
  }
}
