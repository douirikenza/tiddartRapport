import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/favorites_controller.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import 'product_details_page.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final FavoritesController favoritesController = Get.find();

  @override
  Widget build(BuildContext context) {
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: AppTheme.surfaceLight,
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: AppTheme.primaryBrown,
                                            size: 40,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 150,
                                        color: AppTheme.surfaceLight,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                            color: AppTheme.primaryBrown,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap:
                                        () => favoritesController
                                            .removeFromFavorites(product),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceLight,
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
                                      product.promotionPercentage != null) ...[
                                    Text(
                                      product.price,
                                      style: TextStyle(
                                        color: AppTheme.textDark.withOpacity(
                                          0.5,
                                        ),
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.discountedPrice.toStringAsFixed(2)} TND',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      product.price,
                                      style: TextStyle(
                                        color: AppTheme.textDark.withOpacity(
                                          0.5,
                                        ),

                                        fontSize: 14,
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
  }
}
