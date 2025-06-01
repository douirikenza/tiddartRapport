import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import 'payment_page.dart';

class CartPaymentChoicePage extends StatefulWidget {
  final double totalAmount;
  final List<CartItem> cartItems;

  const CartPaymentChoicePage({
    Key? key,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<CartPaymentChoicePage> createState() => _CartPaymentChoicePageState();
}

class _CartPaymentChoicePageState extends State<CartPaymentChoicePage> {
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotal();
  }

  void calculateTotal() {
    total = widget.cartItems.fold(0.0, (sum, item) {
      double itemPrice;
      if (item.product.isOnPromotion &&
          item.product.promotionPercentage != null) {
        itemPrice = item.product.discountedPrice;
      } else {
        itemPrice = item.product.getPriceAsDouble();
      }
      return sum + (itemPrice * item.quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paymentMethods = [
      {
        'label': 'PayPal',
        'icon': Icons.paypal,
        'method': 'PayPal',
        'description': 'Paiement sécurisé et rapide',
        'color': const Color(0xFF0070BA),
        'bgColor': const Color(0xFFE5F2FF),
      },
      {
        'label': 'Carte Bancaire',
        'icon': Icons.credit_card,
        'method': 'Carte',
        'description': 'Visa, Mastercard, etc.',
        'color': const Color(0xFF1A1F71),
        'bgColor': const Color(0xFFF0F0FF),
      },
      {
        'label': 'Paiement à la Livraison',
        'icon': Icons.local_shipping,
        'method': 'Livraison',
        'description': 'Payez lors de la réception',
        'color': const Color(0xFF2E7D32),
        'bgColor': const Color(0xFFE8F5E9),
      },
    ];

    final combinedProduct = ProductModel(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Commande multiple',
      price: '${total.toStringAsFixed(2)} TND',
      image: widget.cartItems.first.product.image,
      description: 'Commande de ${widget.cartItems.length} articles',
      artisanId: 'multiple_artisans',
      category: 'Multiple',
    );

    String? selectedMethod;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B4513)),
          onPressed: () {
            Navigator.of(context).pop();
            Get.back();
          },
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            padding: const EdgeInsets.all(12),
          ),
        ),
        title: const Text(
          'Mode de paiement',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Choisissez votre méthode de paiement préférée',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      selectedMethod = method['method'];
                      Get.to(
                        () => PaymentPage(
                          product: combinedProduct,
                          paymentMethod: method['method'],
                          price: total,
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: method['bgColor'],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                method['icon'],
                                color: method['color'],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['label'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: method['color'],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: method['color'],
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B4513).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        if (selectedMethod != null) {
                          Get.to(
                            () => PaymentPage(
                              product: combinedProduct,
                              paymentMethod: selectedMethod!,
                              price: total,
                            ),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        } else {
                          Get.snackbar(
                            'Sélection requise',
                            'Veuillez choisir un mode de paiement',
                            backgroundColor: Colors.white,
                            colorText: const Color(0xFF8B4513),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Center(
                        child: Text(
                          'Continuer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.cartItems.length} article${widget.cartItems.length > 1 ? 's' : ''} • ${total.toStringAsFixed(2)} TND',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
