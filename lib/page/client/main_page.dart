import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'home_page.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class MainPage extends StatelessWidget {
  final RxInt currentIndex = 0.obs;
  final List<Widget> pages = [
    const HomePage(),
    FavoritesPage(),
    CartPage(),
    const ProfilePage(),
  ];

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex.value,
            onTap: (index) => currentIndex.value = index,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryBrown,
            unselectedItemColor: AppTheme.primaryBrown.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.home, color: AppTheme.primaryBrown),
                ),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: AppTheme.primaryBrown),
                ),
                label: 'Favoris',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.shopping_cart, color: AppTheme.primaryBrown),
                ),
                label: 'Panier',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: AppTheme.primaryBrown),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
