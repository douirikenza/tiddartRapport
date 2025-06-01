import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import 'product_details_page.dart';

class TextilePage extends StatelessWidget {
  TextilePage({super.key});

  final List<ProductModel> textileItems = [
    ProductModel(
      id: '1',
      name: "Écharpe en soie",
      price: "65,00 TND",
      image: 'assets/products/echarpe.png',
      description: "Écharpe en soie tissée à la main",
      artisanId: "artisan_amina_id",
      category: "Textile",
    ),
    ProductModel(
      id: '2',
      name: "Burnous traditionnel",
      price: "180,00 TND",
      image: 'assets/products/burnous.png',
      description: "Burnous en laine pure fait main",
      artisanId: "artisan_khaled_id",
      category: "Textile",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildCategoryPage('Textile', textileItems);
  }

  Widget _buildCategoryPage(String title, List<ProductModel> products) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D9B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0D9B5),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
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
                color: const Color(0xFFE2BF91),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(product.image, height: 80),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.price,
                    style: const TextStyle(color: Colors.brown),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
