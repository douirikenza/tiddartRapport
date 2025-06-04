import 'package:Tiddart/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/app_routes.dart';
import './profile_controller.dart';
import '../services/notification_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  String? userId;
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      userId = user.uid;
      // Charger les données du profil après la connexion
      final ProfileController profileController = Get.find<ProfileController>();
      await profileController.loadUserData();

      // Vérifier le rôle de l'utilisateur
      var userData = await getCurrentUserData();
      String? userRole = userData?['role'];
      bool isApproved = userData?['isApproved'] ?? false;

      if (userRole == 'artisan') {
        if (isApproved) {
          Get.offAllNamed(AppRoutes.artisanDashboard, arguments: user.uid);
        } else {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Compte en attente, \nVotre compte artisan est en attente d'approbation par l'administrateur.",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 79, 39, 11),
                      ),
                    ),
                  ),
                ],
              ),

              backgroundColor: const Color.fromARGB(255, 194, 165, 145),

              duration: const Duration(seconds: 5),
            ),
          );
          Get.offAllNamed(AppRoutes.welcome);
        }
      } else if (userRole == 'admin') {
        Get.offAllNamed(AppRoutes.adminDashboard, arguments: user.uid);
      } else {
        // Client normal
        Get.offAllNamed(AppRoutes.mainPage);
      }
    }
  }

  // Obtenir les informations de l'utilisateur actuel depuis Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (firebaseUser.value != null) {
        final uid = firebaseUser.value!.uid;
        print('user UID: $uid');
        DocumentSnapshot doc =
            await _firestore
                .collection('users')
                .doc(firebaseUser.value!.uid)
                .get();
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur: $e");
      return null;
    }
  }

  // Vérifier si l'utilisateur est un artisan
  Future<bool> isArtisan() async {
    try {
      var userData = await getCurrentUserData();
      return userData?['role'] == 'artisan';
    } catch (e) {
      print("Erreur lors de la vérification du rôle: $e");
      return false;
    }
  }

  // Connexion avec email et mot de passe
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // La redirection sera gérée par _setInitialScreen
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(child: Text("Erreur de connexion$e")),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 241, 130, 96),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Get.snackbar(
      //   "Erreur de connexion",
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.shade100,
      //   colorText: Colors.brown,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  // Inscription avec email et mot de passe
  Future<void> signup(
    String name,
    String email,
    String password,
    bool isArtisan,
  ) async {
    try {
      isLoading.value = true;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Créer le profil utilisateur dans Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': isArtisan ? 'artisan' : 'client',
        'isApproved': !isArtisan, // Les artisans commencent non approuvés
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le nom d'affichage
      await result.user!.updateDisplayName(name);

      // Enregistrer le token FCM pour les notifications
      await _notificationService.saveTokenToDatabase(result.user!.uid);

      if (isArtisan) {
        // Notifier l'admin du nouvel artisan
        await _notificationService.notifyAdminForNewArtisan(name);

        // Déconnexion automatique uniquement pour les artisans
        await _auth.signOut();
        // Redirection vers la page de connexion avec un message
        Get.offAllNamed(AppRoutes.login);
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Inscription réussie, \nVotre compte artisan est en attente d'approbation par l'administrateur.",
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),

            backgroundColor: Colors.orange.shade100,

            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // Pour les clients, redirection directe vers la page principale
        Get.offAllNamed(AppRoutes.mainPage);
        Get.snackbar(
          "Inscription réussie",
          "Votre compte a été créé avec succès. Bienvenue !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      }
    } catch (e) {
      // Get.snackbar(
      //   "Erreur d'inscription",
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.shade100,
      //   colorText: Colors.brown,
      // );
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(child: Text("Erreur d'inscription$e")),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 241, 130, 96),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Réinitialiser les données du profil
      final ProfileController profileController = Get.find<ProfileController>();
      profileController.userData.value = null;
    } catch (e) {
      Get.snackbar(
        "Erreur de déconnexion",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        "Réinitialisation du mot de passe",
        "Un email a été envoyé à $email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.brown,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.brown,
      );
    }
  }
}
