import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../controllers/artisan/category_products_controller.dart';
import '../../controllers/auth_controller.dart';
import 'artisan_conversations_list.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryId;
  final String artisanId;

  const CategoryProductsPage({
    Key? key,
    required this.categoryId,
    required this.artisanId,
  }) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final CategoryProductsController controller = Get.put(
    CategoryProductsController(),
  );

  @override
  void initState() {
    super.initState();
    controller.fetchProductsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Mes Produits',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryBrown),
          onPressed: () {
            Navigator.of(context).pop();
            Get.back();
          },
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            padding: const EdgeInsets.all(12),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () {
              final artisanId = Get.find<AuthController>().userId;
              if (artisanId != null) {
                Get.to(() => ArtisanConversationsList(artisanId: artisanId));
              } else {
                _showMessage(
                  'Impossible de trouver l\'identifiant de l\'artisan',
                  true,
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppTheme.primaryBrown),
            onPressed: () async {
              await Get.find<AuthController>().logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Catégories horizontales
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected =
                      category['id'] == controller.selectedCategoryId.value;

                  return GestureDetector(
                    onTap:
                        () =>
                            controller.fetchProductsByCategory(category['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.primaryBrown
                                : AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.primaryBrown.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (category['id'] == 'all' && isSelected) ...[
                            Icon(Icons.check, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            category['name'] ?? '',
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppTheme.primaryBrown,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Liste des produits
            Expanded(
              child:
                  controller.products.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun produit dans cette catégorie',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
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
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          final product = controller.products[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: Image(
                                          image:
                                              (product.imageUrls.isNotEmpty)
                                                  ? NetworkImage(
                                                    product.imageUrls.first,
                                                  )
                                                  : const AssetImage(
                                                        'assets/icons/placeholder.png',
                                                      )
                                                      as ImageProvider,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      if (product.isOnPromotion &&
                                          product.promotionPercentage != null)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '-${product.promotionPercentage!.toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (product.isOnPromotion &&
                                                product.promotionPercentage !=
                                                    null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(
                                                    0.8,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${product.price.toStringAsFixed(2)} TND',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.7,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${product.discountedPrice.toStringAsFixed(2)} TND',
                                                style: TextStyle(
                                                  color:
                                                      product.isOnPromotion
                                                          ? Colors.green
                                                          : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (product.description?.isNotEmpty ??
                                          false) ...[
                                        Text(
                                          product.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBrown
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          controller.categories.firstWhere(
                                            (cat) =>
                                                cat['id'] == product.categoryId,
                                            orElse:
                                                () => {
                                                  'name': 'Non catégorisé',
                                                },
                                          )['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryBrown,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      }),
    );
  }

  void _showMessage(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
