import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total {
    if (product.isOnPromotion && product.promotionPercentage != null) {
      return product.discountedPrice * quantity;
    }
    return product.getPriceAsDouble() * quantity;
  }

  // Helper method to format total with currency
  String getFormattedTotal() {
    return '${total.toStringAsFixed(2)} TND';
  }
}
