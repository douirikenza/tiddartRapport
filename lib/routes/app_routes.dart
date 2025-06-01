import 'package:get/get.dart';
import '../page/artisan/add_product_page.dart';
import '../page/client/cart_page.dart';
import '../page/client/favorites_page.dart';
import '../page/client/home_page.dart';
import '../page/auth/login_page.dart';
import '../page/client/main_page.dart';
import '../page/client/payment_page.dart';
import '../page/auth/pswd_oublie_page.dart';
import '../page/auth/signup_page.dart';
import '../page/auth/valid_code_page.dart';
import '../page/client/profile_page.dart';
import '../page/client/product_details_page.dart';
import '../page/client/Product_categories_Page.dart';
import '../page/client/category_selector_page.dart';



import '../page/client/textile_page.dart';
import '../page/auth/welcome_page.dart';
import '../page/artisan/category_management_page.dart';
import '../page/artisan/artisan_dashboard_page.dart';
import '../page/artisan/artisan_profile_page.dart';
import '../page/artisan/order_statistics_page.dart';
import '../page/artisan/category_products_page.dart';
import '../page/admin/admin_dashboard_page.dart';
import '../page/admin/category_management_page.dart';
import '../page/admin/artisan_management_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String register = '/register';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String promotions = '/promotions';
  static const String mainPage = '/main';
  static const String paymentPage = '/paymentPage';
  static const String pswdOubliePage = '/pswdOubliePage';
  static const String validCodePage = '/validCodePage';
  static const String categories = '/categories';
  static const String cosmetics = '/cosmetics';
  static const String food = '/food';
  static const String decoration = '/decoration';
  static const String textile = '/textile';
  static const String categorySelector = '/select-category';
  static const String welcome = '/welcome';
  static const String productDetails = '/product-details';
  static const String artisanDashboard = '/artisan/dashboard';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCategoryManagement = '/admin/categories';
  static const String adminArtisanManagement = '/admin/artisans';
  static const String categoryManagement = '/artisan/categories';
  static const String productManagement = '/artisan/products';
  static const String artisanProfile = '/artisan/profile';
  static const String orderStatistics = '/artisan/statistics';
  static const String forgotPassword = '/forgot-password';
  static const String artisanCategoryProducts = '/artisan/category/products';
  static const String addProduct = '/artisan/products/add';

  static final routes = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: signup, page: () => const SignUpPage()),
    GetPage(name: mainPage, page: () => MainPage()),
    GetPage(name: cart, page: () => CartPage()),
    GetPage(name: favorites, page: () => FavoritesPage()),
    GetPage(name: profile, page: () => const ProfilePage()),

    GetPage(name: pswdOubliePage, page: () => PswdOubliePage()),
    GetPage(name: validCodePage, page: () => ValidCodePage()),
    GetPage(name: categories, page: () => ProductCategoriesPage()),


    GetPage(name: textile, page: () => TextilePage()),
    GetPage(name: categorySelector, page: () => const CategorySelectorPage()),
    GetPage(name: welcome, page: () => const WelcomePage()),
    GetPage(
      name: productDetails,
      page:
          () => ProductDetailsPage(
            product: Get.arguments['product'],
            artisanId: Get.arguments['artisanId'],
          ),
    ),
    GetPage(
      name: artisanDashboard,
      page: () => ArtisanDashboardPage(artisanId: Get.arguments),
    ),
    GetPage(
      name: adminDashboard,
      page: () => AdminDashboardPage(adminId: Get.arguments),
    ),
    GetPage(
      name: adminCategoryManagement,
      page: () => AdminCategoryManagementPage(),
    ),
    GetPage(
      name: adminArtisanManagement,
      page: () => AdminArtisanManagementPage(),
    ),
    GetPage(name: categoryManagement, page: () => CategoryManagementPage()),

    GetPage(
      name: artisanProfile,
      page: () => ArtisanProfilePage(artisanId: Get.arguments),
    ),
    GetPage(name: orderStatistics, page: () => OrderStatisticsPage()),
    GetPage(
      name: artisanCategoryProducts,
      page:
          () => CategoryProductsPage(
            categoryId: Get.arguments['categoryId'],
            artisanId: Get.arguments['artisanId'],
          ),
    ),
    GetPage(name: addProduct, page: () => const AddProductPage()),
  ];
}
