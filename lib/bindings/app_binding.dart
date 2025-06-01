import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/order_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(ProductController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(OrderController(), permanent: true);
  }
}
