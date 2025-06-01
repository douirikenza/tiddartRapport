import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'auth_controller.dart';
import 'package:flutter/material.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find();
  var cartItems = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
    // Écouter les changements d'authentification
    ever(_authController.firebaseUser, (_) => loadCart());
  }

  Future<void> loadCart() async {
    if (_authController.firebaseUser.value == null) {
      cartItems.clear();
      return;
    }

    try {
      final userId = _authController.firebaseUser.value!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data()!.containsKey('cart')) {
        final List<dynamic> cartData = doc.data()!['cart'] ?? [];
        final List<CartItem> loadedItems = [];

        for (var item in cartData) {
          final productDoc = await _firestore
              .collection('products')
              .doc(item['productId'])
              .get();
          if (productDoc.exists) {
            final product =
                ProductModel.fromMap(productDoc.data()!, productDoc.id);
            loadedItems.add(CartItem(
              product: product,
              quantity: item['quantity'] ?? 1,
            ));
          }
        }

        cartItems.value = loadedItems;
      }
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
    }
  }

  Future<void> _updateFirebaseCart() async {
    if (_authController.firebaseUser.value == null) return;

    try {
      final userId = _authController.firebaseUser.value!.uid;
      final cartData = cartItems
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      await _firestore.collection('users').doc(userId).set({
        'cart': cartData,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la mise à jour du panier: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    if (_authController.firebaseUser.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez vous connecter pour ajouter au panier',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final index =
          cartItems.indexWhere((e) => e.product.id == item.product.id);
      if (index != -1) {
        cartItems[index].quantity += item.quantity;
      } else {
        cartItems.add(item);
      }
      await _updateFirebaseCart();
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    try {
      cartItems.removeWhere((e) => e.product.id == item.product.id);
      await _updateFirebaseCart();
    } catch (e) {
      print('Erreur lors de la suppression du panier: $e');
    }
  }

  Future<void> changeQuantity(int index, int delta) async {
    try {
      final current = cartItems[index];
      current.quantity += delta;
      if (current.quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index] = current;
      }
      await _updateFirebaseCart();
    } catch (e) {
      print('Erreur lors du changement de quantité: $e');
    }
  }

  double get total => cartItems.fold(0, (sum, item) => sum + item.total);

  Future<void> clearCart() async {
    try {
      cartItems.clear();
      await _updateFirebaseCart();
    } catch (e) {
      print('Erreur lors du vidage du panier: $e');
    }
  }
}
