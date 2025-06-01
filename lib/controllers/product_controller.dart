import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiddart/controllers/auth_controller.dart';
import '../models/product.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({String? categoryId}) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      final artisanId = authController.userId;

      if (artisanId == null) {
        Get.snackbar('Erreur', 'Artisan ID not available');
        return;
      }

      Query query = _firestore
          .collection('products')
          .where('artisanId', isEqualTo: artisanId);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final QuerySnapshot snapshot = await query.get();
      products.value =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Product.fromJson({'id': doc.id, ...data});
          }).toList();
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      Get.snackbar('Erreur', 'Impossible de charger les produits');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> imageUrls,
    bool isOnPromotion = false,
    double? promotionPercentage,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final artisanId = authController.userId;

      if (artisanId == null) {
        throw 'Artisan ID not available';
      }

      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
        'createdAt': DateTime.now().toIso8601String(),
        'isAvailable': true,
        'artisanId': artisanId,
        'isOnPromotion': isOnPromotion,
        'promotionPercentage': promotionPercentage,
      };

      await _firestore.collection('products').add(productData);
      await fetchProducts();
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
      rethrow;
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> imageUrls,
    bool isOnPromotion = false,
    double? promotionPercentage,
  }) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
        'isOnPromotion': isOnPromotion,
        'promotionPercentage': promotionPercentage,
      });

      // Mettre à jour le produit dans la liste locale
      final index = products.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updatedProduct = Product(
          id: id,
          name: name,
          description: description,
          price: price,
          categoryId: categoryId,
          imageUrls: imageUrls,
          createdAt: products[index].createdAt,
          isAvailable: products[index].isAvailable,
          artisanId: products[index].artisanId,
          isOnPromotion: isOnPromotion,
          promotionPercentage: promotionPercentage,
        );
        products[index] = updatedProduct;
      }

      // Rafraîchir la liste complète
      await fetchProducts();
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((p) => p.id == productId);
      Get.snackbar('Succès', 'Produit supprimé avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le produit');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    try {
      isLoading.value = true;
      await _firestore.collection('products').doc(productId).update({
        'isAvailable': isAvailable,
      });
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = Product(
          id: products[index].id,
          name: products[index].name,
          description: products[index].description,
          price: products[index].price,
          categoryId: products[index].categoryId,
          imageUrls: products[index].imageUrls,
          createdAt: products[index].createdAt,
          isAvailable: isAvailable,
          artisanId: products[index].artisanId,
        );
        products[index] = updatedProduct;
      }
      Get.snackbar('Succès', 'Disponibilité du produit mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour la disponibilité');
    } finally {
      isLoading.value = false;
    }
  }
}
