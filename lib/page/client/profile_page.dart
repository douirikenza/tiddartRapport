import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../theme/app_theme.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product_model.dart';
import '../../routes/app_routes.dart';

import 'chat_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.find<AuthController>();
  final FavoritesController favoritesController = Get.find();
  bool isEditingName = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (authController.firebaseUser.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
    } else {
      profileController.loadUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: 160,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.brown),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.brown),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
      profileController.setProfileImage(_profileImageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.firebaseUser.value;

      if (user == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 100,
                  color: AppTheme.primaryBrown.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'Connectez-vous pour voir votre profil',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppTheme.primaryBrown),
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.accentGold,
                AppTheme.primaryBrown.withOpacity(0.8),
                AppTheme.accentGold,
              ],
            ).createShader(bounds),
            child: Text(
              'Mon Profil',
              style: AppTheme.textTheme.displayMedium?.copyWith(
                fontFamily: 'Playfair Display',
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: AppTheme.primaryBrown),
              onPressed: () async {
                await authController.logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        body: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
              ),
            );
          }

          final userData = profileController.userData.value;
          if (userData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.primaryBrown.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger les données',
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileController.loadUserData(),
                    style: AppTheme.primaryButtonStyle,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _addressController.text = userData['address'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Photo de profil
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceLight,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _profileImageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : userData['profileImage'] != null
                              ? ClipOval(
                                  child: Image.network(
                                    userData['profileImage'],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppTheme.primaryBrown
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.primaryBrown.withOpacity(0.5),
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _showImageSourceActionSheet,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Informations de l'utilisateur
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoField(
                        icon: Icons.person_outline,
                        label: 'Nom',
                        value: userData['name'] ?? 'Non défini',
                        controller: _nameController,
                        onEdit: () async {
                          await profileController.updateUserData(
                              name: _nameController.text);
                        },
                      ),
                      const Divider(height: 32),
                      _buildInfoField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: userData['email'] ?? 'Non défini',
                        controller: _emailController,
                        enabled: false,
                      ),
                      const Divider(height: 32),
                      _buildInfoField(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        value: userData['phone'] ?? 'Non défini',
                        controller: _phoneController,
                        onEdit: () async {
                          await profileController.updateUserData(
                              phone: _phoneController.text);
                        },
                      ),
                      const Divider(height: 32),
                      _buildInfoField(
                        icon: Icons.location_on_outlined,
                        label: 'Adresse',
                        value: userData['address'] ?? 'Non défini',
                        controller: _addressController,
                        onEdit: () async {
                          await profileController.updateUserData(
                              address: _addressController.text);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section des actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.favorite_border,
                        label: 'Mes favoris',
                        onTap: () => Get.toNamed(AppRoutes.favorites),
                      ),
                      const Divider(height: 24),
                      _buildActionButton(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Mes commandes',
                        onTap: () {
                          // TODO: Implémenter la navigation vers les commandes
                        },
                      ),
                      const Divider(height: 24),
                      _buildActionButton(
                        icon: Icons.chat_outlined,
                        label: 'Messages',
                        onTap: () => Get.to(() => const ChatListPage()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    bool enabled = true,
    Function()? onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryBrown, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryBrown.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: enabled && onEdit != null
                    ? () {
                        controller.text = value;
                        _showEditDialog(label, controller, onEdit);
                      }
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: enabled
                              ? AppTheme.textDark
                              : AppTheme.textDark.withOpacity(0.7),
                        ),
                      ),
                    ),
                    if (enabled && onEdit != null)
                      Icon(
                        Icons.edit,
                        size: 18,
                        color: AppTheme.primaryBrown.withOpacity(0.5),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBrown, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.primaryBrown.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    String label,
    TextEditingController controller,
    Function() onEdit,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Entrez votre $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.primaryBrown.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onEdit();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
