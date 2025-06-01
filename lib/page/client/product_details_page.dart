import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/artisan_service.dart';
import 'payment_choice_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  final String artisanId;

  const ProductDetailsPage({
    Key? key,
    required this.product,
    required this.artisanId,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final CartController cartController = Get.find();
  final FavoritesController favoritesController = Get.find();
  final ArtisanService artisanService = ArtisanService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Obx(
                  () => Icon(
                    favoritesController.isFavorite(widget.product)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        favoritesController.isFavorite(widget.product)
                            ? Colors.red
                            : AppTheme.primaryBrown,
                  ),
                ),
                onPressed: () {
                  if (favoritesController.isFavorite(widget.product)) {
                    favoritesController.removeFromFavorites(widget.product);
                  } else {
                    favoritesController.addToFavorites(widget.product);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image du produit en arrière-plan
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: Hero(
              tag: 'product_${widget.product.name}',
              child: Image.network(
                widget.product.image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBrown,
                      ),
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.surfaceLight,
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        color: AppTheme.accentGold,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Contenu détaillé
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indicateur de défilement
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style: AppTheme.textTheme.headlineMedium
                                            ?.copyWith(
                                              color: AppTheme.primaryBrown,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          if (widget.product.isOnPromotion &&
                                              widget
                                                      .product
                                                      .promotionPercentage !=
                                                  null) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                widget.product.price,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${widget.product.discountedPrice.toStringAsFixed(2)} TND',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ] else
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentGold
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                widget.product.price,
                                                style: AppTheme
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      color:
                                                          AppTheme.accentGold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryBrown.withOpacity(0.1),
                                    AppTheme.accentGold.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.accentGold.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: FutureBuilder<Map<String, dynamic>?>(
                                future: artisanService.getArtisanById(
                                  widget.artisanId,
                                ),
                                builder: (context, snapshot) {
                                  String artisanName = 'Chargement...';
                                  String artisanInitial = '?';

                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    artisanName =
                                        snapshot.data!['name'] ??
                                        'Artisan non spécifié';
                                    artisanInitial =
                                        artisanName.isNotEmpty
                                            ? artisanName[0].toUpperCase()
                                            : '?';
                                  } else if (snapshot.hasError) {
                                    artisanName = 'Artisan non disponible';
                                  }

                                  return Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.primaryBrown.withOpacity(
                                                0.2,
                                              ),
                                              AppTheme.accentGold.withOpacity(
                                                0.2,
                                              ),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.accentGold
                                                .withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          artisanInitial,
                                          style: TextStyle(
                                            color: AppTheme.primaryBrown,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Créé par',
                                              style: TextStyle(
                                                color: AppTheme.primaryBrown
                                                    .withOpacity(0.6),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              artisanName,
                                              style: TextStyle(
                                                color: AppTheme.primaryBrown,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.verified,
                                        color: AppTheme.accentGold,
                                        size: 24,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryBrown.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: AppTheme.textTheme.titleLarge
                                        ?.copyWith(
                                          color: AppTheme.primaryBrown,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.product.description,
                                    style: AppTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppTheme.textDark.withOpacity(
                                            0.8,
                                          ),
                                          height: 1.6,
                                          letterSpacing: 0.3,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Boutons d'action
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cartController.addToCart(
                                        CartItem(
                                          product: widget.product,
                                          quantity: 1,
                                        ),
                                      );
                                      _showMessage(
                                        'Produit ajouté au panier',
                                        false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        175,
                                        203,
                                        176,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ajouter au panier',
                                          style: AppTheme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final product = widget.product;
                                      final priceToPay =
                                          (product.isOnPromotion &&
                                                  product.promotionPercentage !=
                                                      null)
                                              ? product.discountedPrice
                                              : product.getPriceAsDouble();
                                      Get.to(
                                        () => PaymentChoicePage(
                                          product: product,
                                          price: priceToPay,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        222,
                                        196,
                                        111,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Acheter maintenant',
                                          style: AppTheme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }

  void _showMessage(String message, bool isError) {
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
