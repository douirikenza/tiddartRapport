import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'category_management_page.dart';
import 'artisan_management_page.dart';
import 'admin_statistics_page.dart';
import 'admin_settings_page.dart';
import 'admin_notifications_page.dart';
import '../../controllers/admin/admin_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../styles/app_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  final String adminId;

  const AdminDashboardPage({Key? key, required this.adminId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller = Get.put(
      AdminDashboardController(),
    );
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Dashboard Administrateur',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {
              Get.to(() => AdminNotificationsPage(adminId: adminId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await authController.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue sur votre tableau de bord',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildStatsCard(
                            'Total Artisans',
                            controller.totalArtisans.value.toString(),
                            Icons.people,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => _buildStatsCard(
                            'Catégories',
                            controller.totalCategories.value.toString(),
                            Icons.category,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => _buildStatsCard(
                            'Commandes',
                            controller.totalCommandes.value.toString(),
                            Icons.shopping_cart,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestion de la plateforme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        'Gestion des catégories',
                        Icons.category,
                        Colors.blue,
                        () => Get.to(() => AdminCategoryManagementPage()),
                      ),
                      _buildDashboardCard(
                        'Gestion des artisans',
                        Icons.people,
                        Colors.green,
                        () => Get.to(() => AdminArtisanManagementPage()),
                      ),
                      _buildDashboardCard(
                        'Statistiques',
                        Icons.bar_chart,
                        Colors.orange,
                        () => Get.to(() => AdminStatisticsPage()),
                      ),
                      _buildDashboardCard(
                        'Paramètres',
                        Icons.settings,
                        Colors.purple,
                        () => Get.to(() => AdminSettingsPage()),
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
  }

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
            color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
          Icon(icon, color: AppTheme.primaryBrown, size: 24),
            const SizedBox(height: 8),
            Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
              ),
          const SizedBox(height: 4),
            Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            ),
          ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
