import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text("Veuillez entrer votre email et mot de passe"),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    ;

    try {
      await _authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      _showError('Une erreur est survenue lors de la connexion');
    }
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre email');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre mot de passe');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppTheme.backgroundLight,
      // resizeToAvoidBottomInset: true,
      body: Obx(
        () => Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                final isSmallScreen = maxHeight < 600;
                final viewInsets = MediaQuery.of(context).viewInsets.bottom;

                return SingleChildScrollView(
                  reverse: viewInsets > 0,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: viewInsets),
                    child: Container(
                      constraints: BoxConstraints(minHeight: maxHeight),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.backgroundLight,
                            AppTheme.surfaceLight,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: maxWidth * 0.06,
                                vertical: isSmallScreen ? 20 : 40,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: isSmallScreen ? 20 : 40),
                                  // Logo
                                  Container(
                                    height: isSmallScreen ? 80 : 120,
                                    width: isSmallScreen ? 80 : 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.surfaceLight,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryBrown
                                              .withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: isSmallScreen ? 40 : 60,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 20 : 40),
                                  // Titre
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => AppTheme.primaryGradient
                                            .createShader(bounds),
                                    child: Text(
                                      'Bienvenue',
                                      style: AppTheme.textTheme.displayLarge
                                          ?.copyWith(
                                            fontSize: isSmallScreen ? 24 : 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 4 : 8),
                                  Text(
                                    'Connectez-vous pour découvrir notre artisanat',
                                    style: AppTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppTheme.textDark.withOpacity(
                                            0.7,
                                          ),
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isSmallScreen ? 32 : 48),
                                  // Champs de formulaire
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceLight,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryBrown
                                              .withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(
                                      isSmallScreen ? 15 : 20,
                                    ),
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            labelStyle: TextStyle(
                                              color: AppTheme.primaryBrown,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.email,
                                              color: AppTheme.primaryBrown,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBrown
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBrown
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBrown,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical:
                                                      isSmallScreen ? 12 : 16,
                                                  horizontal:
                                                      isSmallScreen ? 12 : 16,
                                                ),
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                            labelText: 'Mot de passe',
                                            labelStyle: TextStyle(
                                              color: AppTheme.primaryBrown,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: AppTheme.primaryBrown,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: AppTheme.primaryBrown,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBrown
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBrown
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBrown,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          obscureText: _obscurePassword,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Bouton de connexion
                                  ElevatedButton(
                                    onPressed: _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryBrown,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 12 : 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        // fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Liens supplémentaires
                                  TextButton(
                                    onPressed:
                                        () => Get.toNamed(
                                          AppRoutes.pswdOubliePage,
                                        ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBrown,
                                    ),
                                    child: Text(
                                      'Mot de passe oublié ?',
                                      style: AppTheme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Pas encore de compte ?',
                                        style: AppTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: AppTheme.textDark
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Get.toNamed(AppRoutes.signup),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppTheme.primaryBrown,
                                        ),
                                        child: Text(
                                          'Créer un compte',
                                          style: AppTheme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_authController.isLoading.value)
              Container(
                color: Colors.black12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
