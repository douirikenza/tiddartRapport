import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../controllers/admin_settings_controller.dart';
import '../../routes/app_routes.dart';

class AdminSettingsPage extends StatelessWidget {
  final AdminSettingsController controller = Get.put(AdminSettingsController());

  AdminSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(
          AppRoutes.adminDashboard,
          arguments: controller.getUserId(),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Paramètres',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () {
              Get.offAllNamed(
                AppRoutes.adminDashboard,
                arguments: controller.getUserId(),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Paramètres généraux'),
              const SizedBox(height: 20),
              _buildSettingsCard([
                Obx(
                  () => _buildSettingItem(
                    'Notifications',
                    'Gérer les paramètres de notification',
                    Icons.notifications,
                    Colors.blue,
                    () => controller.toggleNotifications(),
                    trailing: Switch(
                      value: controller.notificationsEnabled.value,
                      onChanged: (value) => controller.toggleNotifications(),
                      activeColor: Colors.blue,
                    ),
                  ),
                ),
                _buildSettingItem(
                  'Langue',
                  'Changer la langue de l\'application',
                  Icons.language,
                  Colors.green,
                  () => _showLanguageDialog(context),
                ),
                Obx(
                  () => _buildSettingItem(
                    'Thème',
                    'Personnaliser l\'apparence',
                    Icons.palette,
                    Colors.purple,
                    () => controller.toggleTheme(),
                    trailing: Switch(
                      value: controller.isDarkMode.value,
                      onChanged: (value) => controller.toggleTheme(),
                      activeColor: Colors.purple,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 30),
              _buildSectionTitle('Sécurité'),
              const SizedBox(height: 20),
              _buildSettingsCard([
                _buildSettingItem(
                  'Mot de passe',
                  'Modifier le mot de passe',
                  Icons.lock,
                  Colors.orange,
                  () => _showChangePasswordDialog(context),
                ),
                Obx(
                  () => _buildSettingItem(
                    'Authentification à deux facteurs',
                    'Activer/Désactiver l\'A2F',
                    Icons.security,
                    Colors.red,
                    () => controller.toggleTwoFactor(),
                    trailing: Switch(
                      value: controller.twoFactorEnabled.value,
                      onChanged: (value) => controller.toggleTwoFactor(),
                      activeColor: Colors.red,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 30),
              _buildSectionTitle('Système'),
              const SizedBox(height: 20),
              _buildSettingsCard([
                _buildSettingItem(
                  'Sauvegarde',
                  'Gérer les sauvegardes de données',
                  Icons.backup,
                  Colors.teal,
                  () => _showBackupDialog(context),
                ),
                Obx(
                  () => _buildSettingItem(
                    'Maintenance',
                    'Mode maintenance et nettoyage',
                    Icons.build,
                    Colors.brown,
                    () => controller.toggleMaintenanceMode(),
                    trailing: Switch(
                      value: controller.maintenanceMode.value,
                      onChanged: (value) => controller.toggleMaintenanceMode(),
                      activeColor: Colors.brown,
                    ),
                  ),
                ),
                _buildSettingItem(
                  'Logs système',
                  'Consulter les journaux système',
                  Icons.description,
                  Colors.indigo,
                  () => _showSystemLogsDialog(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choisir la langue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  controller.availableLanguages
                      .map(
                        (language) => ListTile(
                          title: Text(language),
                          onTap: () {
                            controller.changeLanguage(language);
                            Navigator.pop(context);
                          },
                          trailing: Obx(
                            () =>
                                controller.currentLanguage.value == language
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                    : Container(width: 24),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.orange,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Changer le mot de passe',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: currentPasswordController,
                            obscureText: _obscureCurrentPassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe actuel',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.orange,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrentPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscureCurrentPassword =
                                              !_obscureCurrentPassword,
                                    ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: newPasswordController,
                            obscureText: _obscureNewPassword,
                            decoration: InputDecoration(
                              labelText: 'Nouveau mot de passe',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.orange,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscureNewPassword =
                                              !_obscureNewPassword,
                                    ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmer le mot de passe',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.orange,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword,
                                    ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (newPasswordController.text ==
                                    confirmPasswordController.text) {
                                  controller.changePassword(
                                    currentPasswordController.text,
                                    newPasswordController.text,
                                  );
                                  Navigator.pop(context);
                                } else {
                                  Get.snackbar(
                                    'Erreur',
                                    'Les mots de passe ne correspondent pas',
                                    backgroundColor: Colors.red.shade50,
                                    colorText: Colors.red,
                                    snackPosition: SnackPosition.TOP,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 10,
                                    icon: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Confirmer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sauvegarde des données'),
            content: const Text(
              'Voulez-vous créer une sauvegarde de toutes les données ? '
              'Cette opération peut prendre quelques minutes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.backupData();
                  Navigator.pop(context);
                },
                child: const Text('Sauvegarder'),
              ),
            ],
          ),
    );
  }

  void _showSystemLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logs système'),
            content: FutureBuilder<List<Map<String, dynamic>>>(
              future: controller.getSystemLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Aucun log disponible');
                }

                return SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final log = snapshot.data![index];
                      return ListTile(
                        title: Text(log['message'] ?? ''),
                        subtitle: Text(
                          log['timestamp']?.toDate()?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        leading: Icon(
                          _getLogIcon(log['type'] ?? ''),
                          color: _getLogColor(log['type'] ?? ''),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  IconData _getLogIcon(String type) {
    switch (type.toLowerCase()) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }

  Color _getLogColor(String type) {
    switch (type.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
