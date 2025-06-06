import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/image_service.dart';
import '../../routes/app_routes.dart';
import 'edit_product_page.dart';

class ArtisanProductManagementPage extends StatefulWidget {
  const ArtisanProductManagementPage({Key? key}) : super(key: key);

  @override
  State<ArtisanProductManagementPage> createState() =>
      _ArtisanProductManagementPageState();
}

class _ArtisanProductManagementPageState
    extends State<ArtisanProductManagementPage> {
  final CategoryController categoryController = Get.find<CategoryController>();
  final ProductController productController = Get.find<ProductController>();
  final ImageService imageService = ImageService();
  final searchController = TextEditingController();
  final RxString selectedCategoryId = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    productController.fetchProducts();
  }

  void filterProducts() {
    if (searchQuery.value.isEmpty && selectedCategoryId.value.isEmpty) {
      productController.fetchProducts();
    } else {
      if (selectedCategoryId.value.isNotEmpty) {
        productController.fetchProducts(categoryId: selectedCategoryId.value);
      } else {
        final filteredProducts =
            productController.products.where((product) {
              return product.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              );
            }).toList();
        productController.products.value = filteredProducts;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mes produits',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), // espace pour clavier
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(16),
                  color:
                      selectedCategoryId.value.isEmpty
                          ? Colors.white
                          : AppTheme.primaryBrown.withOpacity(0.1),
                  child: Column(
                    children: [
                      // Recherche
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un produit...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppTheme.primaryBrown,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            searchQuery.value = value;
                            if (selectedCategoryId.value.isEmpty) {
                              filterProducts();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filtres par catégorie
                      SizedBox(
                        height: 40,
                        child: Obx(
                          () => ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryController.categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: const Text('Tous'),
                                    selected: selectedCategoryId.value.isEmpty,
                                    onSelected: (selected) {
                                      selectedCategoryId.value = '';
                                      productController.fetchProducts();
                                    },
                                    backgroundColor: Colors.grey[100],
                                    selectedColor: AppTheme.primaryBrown
                                        .withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color:
                                          selectedCategoryId.value.isEmpty
                                              ? AppTheme.primaryBrown
                                              : Colors.grey[600],
                                    ),
                                  ),
                                );
                              }
                              final category =
                                  categoryController.categories[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category.name),
                                  selected:
                                      selectedCategoryId.value == category.id,
                                  onSelected: (selected) {
                                    selectedCategoryId.value =
                                        selected ? category.id : '';
                                    filterProducts();
                                  },
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: AppTheme.primaryBrown
                                      .withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color:
                                        selectedCategoryId.value == category.id
                                            ? AppTheme.primaryBrown
                                            : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Liste des produits
              Obx(() {
                if (productController.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  );
                }

                if (productController.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Aucun produit trouvé',
                            style: TextStyle(
                              color: AppTheme.primaryBrown,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Commencez à ajouter vos produits',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Responsive GridView dans boîte avec hauteur fixe
                final screenHeight = MediaQuery.of(context).size.height;
                return SizedBox(
                  height: screenHeight * 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        itemCount: productController.products.length,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final product = productController.products[index];
                          final category = categoryController.categories
                              .firstWhereOrNull(
                                (c) => c.id == product.categoryId,
                              );

                          return _buildProductCard(product, category);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addProduct),
        backgroundColor: AppTheme.primaryBrown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter un produit',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, category) {
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
                            ? NetworkImage(product.imageUrls.first)
                            : const AssetImage('assets/icons/placeholder.png')
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
                        borderRadius: BorderRadius.circular(8),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.isOnPromotion &&
                          product.promotionPercentage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.price.toStringAsFixed(2)} TND',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (product.description?.isNotEmpty ?? false) ...[
                  Text(
                    product.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category?.name ?? 'Non catégorisé',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryBrown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Modifier',
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 186, 246, 217),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EditProductPage(product: product),
                                  ),
                                ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: const Color.fromARGB(
                                      255,
                                      105,
                                      179,
                                      143,
                                    ),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Supprimer',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap:
                                () => _showDeleteConfirmation(context, product),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Confirmer la suppression',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voulez-vous vraiment supprimer le produit :',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      if (product.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            product.imageUrls.first,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${product.price.toStringAsFixed(2)} TND',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cette action est irréversible.',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    productController.deleteProduct(product.id);
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Succès',
                      'Produit supprimé avec succès',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Erreur',
                      'Erreur lors de la suppression du produit',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
