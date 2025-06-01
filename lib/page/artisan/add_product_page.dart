import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/product_controller.dart';
import '../../theme/app_theme.dart';
import '../../services/image_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final promotionPercentageController = TextEditingController();
  String? selectedCategoryId;
  final RxList<dynamic> selectedImages = <dynamic>[].obs;
  final RxBool isOnPromotion = false.obs;

  final CategoryController categoryController = Get.find<CategoryController>();
  final ProductController productController = Get.find<ProductController>();
  final ImageService imageService = ImageService();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    promotionPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_box_rounded,
                      color: AppTheme.primaryBrown,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nouveau produit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBrown,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du produit*',
                        labelStyle: TextStyle(color: AppTheme.primaryBrown),
                        hintText: 'Entrez le nom du produit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryBrown),
                        ),
                        prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: AppTheme.primaryBrown),
                        hintText: 'Décrivez votre produit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryBrown),
                        ),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Prix (TND)*',
                        labelStyle: TextStyle(color: AppTheme.primaryBrown),
                        hintText: 'Entrez le prix',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBrown.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryBrown),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Catégorie*',
                          labelStyle: TextStyle(color: AppTheme.primaryBrown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryBrown.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryBrown.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items:
                            categoryController.categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(
                                      category.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => selectedCategoryId = value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Images du produit*',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...selectedImages.map(
                            (image) => Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => selectedImages.remove(image),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.close, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await imageService.showImagePickerDialog(
                                context,
                                (dynamic image) {
                                  selectedImages.add(image);
                                },
                              );
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Promotion Switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBrown.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                color: AppTheme.primaryBrown,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Mettre en promotion',
                                style: TextStyle(
                                  color: AppTheme.primaryBrown,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Switch(
                              value: isOnPromotion.value,
                              onChanged: (value) {
                                isOnPromotion.value = value;
                                if (!value) {
                                  promotionPercentageController.clear();
                                }
                              },
                              activeColor: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Promotion Percentage Field
                    Obx(
                      () =>
                          isOnPromotion.value
                              ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: promotionPercentageController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Pourcentage de réduction*',
                                      labelStyle: TextStyle(
                                        color: AppTheme.primaryBrown,
                                      ),
                                      hintText:
                                          'Entrez le pourcentage (ex: 20)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppTheme.primaryBrown
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppTheme.primaryBrown
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppTheme.primaryBrown,
                                        ),
                                      ),
                                      prefixIcon: const Icon(Icons.percent),
                                      suffixText: '%',
                                    ),
                                  ),
                                ],
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        selectedCategoryId != null &&
                        selectedImages.isNotEmpty &&
                        (!isOnPromotion.value ||
                            (isOnPromotion.value &&
                                promotionPercentageController
                                    .text
                                    .isNotEmpty))) {
                      try {
                        final imageUrls = await Future.wait(
                          selectedImages.map((image) async {
                            final url = await imageService.uploadImage(
                              image,
                              'products',
                            );
                            return url;
                          }),
                        );

                        productController.addProduct(
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          categoryId: selectedCategoryId!,
                          imageUrls: imageUrls.cast<String>(),
                          isOnPromotion: isOnPromotion.value,
                          promotionPercentage:
                              isOnPromotion.value
                                  ? double.parse(
                                    promotionPercentageController.text,
                                  )
                                  : null,
                        );

                        await productController.fetchProducts();
                        Navigator.of(context).pop();

                        Get.snackbar(
                          'Succès',
                          'Produit ajouté avec succès',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          snackPosition: SnackPosition.TOP,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Erreur',
                          'Une erreur est survenue lors de l\'ajout du produit',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } else {
                      Get.snackbar(
                        'Erreur',
                        'Veuillez remplir tous les champs obligatoires',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Ajouter le produit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
