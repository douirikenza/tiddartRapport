import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import 'auth_controller.dart';

class FavoritesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find();
  var favorites = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
    // Écouter les changements d'authentification
    ever(_authController.firebaseUser, (_) => loadFavorites());
  }

  Future<void> loadFavorites() async {
    if (_authController.firebaseUser.value == null) {
      favorites.clear();
      return;
    }

    try {
      final userId = _authController.firebaseUser.value!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data()!.containsKey('favorites')) {
        final List<dynamic> favoriteIds = doc.data()!['favorites'] ?? [];
        final List<ProductModel> loadedFavorites = [];

        for (String productId in favoriteIds.cast<String>()) {
          final productDoc =
              await _firestore.collection('products').doc(productId).get();
          if (productDoc.exists) {
            loadedFavorites
                .add(ProductModel.fromMap(productDoc.data()!, productDoc.id));
          }
        }

        favorites.value = loadedFavorites;
      }
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    }
  }

  bool isFavorite(ProductModel product) {
    return favorites.any((p) => p.id == product.id);
  }

  Future<void> addToFavorites(ProductModel product) async {
    if (_authController.firebaseUser.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez vous connecter pour ajouter aux favoris',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final userId = _authController.firebaseUser.value!.uid;
      if (!favorites.any((p) => p.id == product.id)) {
        // Ajouter localement
        favorites.add(product);

        // Ajouter dans Firebase
        await _firestore.collection('users').doc(userId).set({
          'favorites': FieldValue.arrayUnion([product.id])
        }, SetOptions(merge: true));

        Get.snackbar(
          'Favoris',
          '${product.name} a été ajouté aux favoris.',
          backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
          colorText: AppTheme.primaryBrown,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          boxShadows: AppTheme.defaultShadow,
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter aux favoris',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFromFavorites(ProductModel product) async {
    if (_authController.firebaseUser.value == null) return;

    try {
      final userId = _authController.firebaseUser.value!.uid;

      // Supprimer localement
      favorites.removeWhere((p) => p.id == product.id);

      // Supprimer dans Firebase
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([product.id])
      });

      Get.snackbar(
        'Favoris',
        'Produit retiré des favoris.',
        backgroundColor: AppTheme.surfaceLight.withOpacity(0.95),
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 3),
        boxShadows: AppTheme.defaultShadow,
      );
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
    }
  }
}
