import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'product_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesController favoritesController = Get.find();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (authController.firebaseUser.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.firebaseUser.value;

      if (user == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 100,
                  color: AppTheme.primaryBrown.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'Connectez-vous pour voir vos favoris',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Mes Favoris',
            style: AppTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Obx(
          () =>
              favoritesController.favorites.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: AppTheme.primaryBrown.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Aucun produit dans les favoris",
                          style: AppTheme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryBrown.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: favoritesController.favorites.length,
                    itemBuilder: (context, index) {
                      final product = favoritesController.favorites[index];
                      return GestureDetector(
                        onTap:
                            () => Get.to(
                              () => ProductDetailsPage(
                                product: product,
                                artisanId: product.artisanId,
                              ),
                            ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBrown.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      product.image,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 150,
                                                color: AppTheme.surfaceLight,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: AppTheme.primaryBrown
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        favoritesController.removeFromFavorites(
                                          product,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: AppTheme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: AppTheme.primaryBrown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (product.isOnPromotion &&
                                        product.promotionPercentage !=
                                            null) ...[
                                      Text(
                                        product.price,
                                        style: TextStyle(
                                          color: AppTheme.textDark.withOpacity(
                                            0.5,
                                          ),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        '${product.discountedPrice.toStringAsFixed(2)} TND',
                                        style: AppTheme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ] else
                                      Text(
                                        '${product.discountedPrice.toStringAsFixed(2)} TND',
                                        style: AppTheme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: AppTheme.primaryBrown,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      );
    });
  }
}
