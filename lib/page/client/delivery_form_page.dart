import 'package:Tiddart/controllers/order_controller.dart';
import 'package:Tiddart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../controllers/order_controller.dart';
import '../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryFormPage extends StatefulWidget {
  final ProductModel product;

  const DeliveryFormPage({super.key, required this.product});

  @override
  State<DeliveryFormPage> createState() => _DeliveryFormPageState();
}

class _DeliveryFormPageState extends State<DeliveryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  final double _deliveryFee = 7.0;
  bool _isLocationSelected = false;
  gmaps.LatLng? _selectedLocation;
  final gmaps.LatLng _initialPosition = const gmaps.LatLng(
    34.0209,
    -6.8416,
  ); // Rabat, Maroc

  final _orderController = Get.put(OrderController());

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    // Supprimer les espaces et le préfixe +216 s'il existe
    String cleanNumber = value.replaceAll(' ', '').replaceAll('+216', '');
    // Vérifier si le numéro commence par 0
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }
    // Vérifier si le numéro a 8 chiffres après le préfixe
    if (cleanNumber.length != 8) {
      return 'Le numéro doit contenir 8 chiffres après le préfixe';
    }
    // Vérifier si le numéro ne contient que des chiffres
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code postal requis';
    }
    if (value.length != 4) {
      return 'Le code postal doit contenir 4 chiffres';
    }
    return null;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si le service n'est pas activé, afficher un message et retourner une position par défaut
      Get.snackbar(
        'Service de localisation désactivé',
        'Veuillez activer la localisation pour sélectionner votre position',
        backgroundColor: Colors.white,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.BOTTOM,
      );
      return Position(
        latitude: _initialPosition.latitude,
        longitude: _initialPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    // Vérifier les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission refusée',
          'La permission de localisation est nécessaire pour sélectionner votre position',
          backgroundColor: Colors.white,
          colorText: AppTheme.primaryBrown,
          snackPosition: SnackPosition.BOTTOM,
        );
        return Position(
          latitude: _initialPosition.latitude,
          longitude: _initialPosition.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission permanente refusée',
        'Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres.',
        backgroundColor: Colors.white,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.BOTTOM,
      );
      return Position(
        latitude: _initialPosition.latitude,
        longitude: _initialPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    // Obtenir la position actuelle
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur de localisation',
        'Impossible d\'obtenir votre position actuelle',
        backgroundColor: Colors.white,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.BOTTOM,
      );
      return Position(
        latitude: _initialPosition.latitude,
        longitude: _initialPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  void _showLocationPicker() async {
    try {
      // Vérifier les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission refusée',
            'La permission de localisation est nécessaire pour sélectionner votre position',
            backgroundColor: Colors.white,
            colorText: AppTheme.primaryBrown,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission permanente refusée',
          'Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres.',
          backgroundColor: Colors.white,
          colorText: AppTheme.primaryBrown,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLocation = gmaps.LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez votre position',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      child: gmaps.GoogleMap(
                        initialCameraPosition: gmaps.CameraPosition(
                          target: currentLocation,
                          zoom: 15,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                        onTap: (latLng) async {
                          setState(() {
                            _selectedLocation = latLng;
                            _isLocationSelected = true;
                          });
                          await _updateAddressFromLatLng(
                            latLng.latitude,
                            latLng.longitude,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        markers:
                            _selectedLocation != null
                                ? {
                                  gmaps.Marker(
                                    markerId: const gmaps.MarkerId(
                                      'selected_location',
                                    ),
                                    position: _selectedLocation!,
                                    icon: gmaps
                                        .BitmapDescriptor.defaultMarkerWithHue(
                                      gmaps.BitmapDescriptor.hueRed,
                                    ),
                                  ),
                                }
                                : {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder à la carte. Veuillez vérifier vos permissions de localisation.',
        backgroundColor: Colors.white,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildWebMap(gmaps.LatLng currentLocation) {
    latlng.LatLng? webSelectedLocation =
        _selectedLocation != null
            ? latlng.LatLng(
              _selectedLocation!.latitude,
              _selectedLocation!.longitude,
            )
            : null;
    final mapController = fmap.MapController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            fmap.FlutterMap(
              mapController: mapController,
              options: fmap.MapOptions(
                initialCenter:
                    webSelectedLocation ??
                    latlng.LatLng(
                      currentLocation.latitude,
                      currentLocation.longitude,
                    ),
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    webSelectedLocation = point;
                    _selectedLocation = gmaps.LatLng(
                      point.latitude,
                      point.longitude,
                    );
                  });
                  _updateAddressFromLatLng(point.latitude, point.longitude);
                },
              ),
              children: [
                fmap.TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                if (webSelectedLocation != null)
                  fmap.MarkerLayer(
                    markers: [
                      fmap.Marker(
                        width: 40.0,
                        height: 40.0,
                        point: webSelectedLocation!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (webSelectedLocation != null) {
                    setState(() {
                      _isLocationSelected = true;
                    });
                    Navigator.pop(context);
                  } else {
                    Get.snackbar(
                      'Attention',
                      'Veuillez sélectionner un point sur la carte',
                      backgroundColor: AppTheme.surfaceLight,
                      colorText: AppTheme.primaryBrown,
                      snackPosition: SnackPosition.TOP,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 10,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    Text(
                      'Confirmer la localisation',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productPrice = widget.product.getPriceAsDouble();
    final discountedPrice =
        widget.product.isOnPromotion
            ? widget.product.discountedPrice
            : productPrice;
    final total = discountedPrice + _deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBrown),
          onPressed: () {
            Navigator.of(context).pop();
            Get.back();
          },
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            padding: const EdgeInsets.all(12),
          ),
        ),
        title: Text(
          'Informations de livraison',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé de la commande
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.primaryBrown,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Résumé de la commande',
                            style: AppTheme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        'Produit',
                        widget.product.isOnPromotion
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${productPrice.toStringAsFixed(2)} TND',
                                  style: AppTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                  ),
                                ),
                                Text(
                                  '${discountedPrice.toStringAsFixed(2)} TND',
                                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : '${productPrice.toStringAsFixed(2)} TND',
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Frais de livraison',
                        '${_deliveryFee.toStringAsFixed(2)} TND',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      _buildPriceRow(
                        'Total',
                        widget.product.isOnPromotion
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(productPrice + _deliveryFee).toStringAsFixed(2)} TND',
                                  style: AppTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                  ),
                                ),
                                Text(
                                  '${total.toStringAsFixed(2)} TND',
                                  style: AppTheme.textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            )
                            : '${total.toStringAsFixed(2)} TND',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sélection de la localisation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          _isLocationSelected
                              ? AppTheme.accentGold
                              : AppTheme.primaryBrown.withOpacity(0.1),
                      width: _isLocationSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  _isLocationSelected
                                      ? AppTheme.accentGold.withOpacity(0.1)
                                      : AppTheme.primaryBrown.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color:
                                  _isLocationSelected
                                      ? AppTheme.accentGold
                                      : AppTheme.primaryBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Votre localisation',
                                style: AppTheme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _isLocationSelected
                                    ? 'Localisation sélectionnée'
                                    : 'Sélectionnez votre position',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      _isLocationSelected
                                          ? AppTheme.accentGold
                                          : AppTheme.primaryBrown.withOpacity(
                                            0.6,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showLocationPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLocationSelected
                                  ? AppTheme.accentGold
                                  : AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(MaterialState.pressed)) {
                              return _isLocationSelected
                                  ? AppTheme.accentGold.withOpacity(0.9)
                                  : AppTheme.primaryBrown.withOpacity(0.9);
                            }
                            return _isLocationSelected
                                ? AppTheme.accentGold
                                : AppTheme.primaryBrown;
                          }),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isLocationSelected
                                  ? Icons.edit_location
                                  : Icons.add_location,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isLocationSelected
                                  ? 'Modifier la localisation'
                                  : 'Choisir sur la carte',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations personnelles
                _buildSectionTitle(
                  'Informations personnelles',
                  Icons.person_outline,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.length < 3) {
                      return 'Le nom doit contenir au moins 3 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Numéro de téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  prefixText: '+216 ',
                  onChanged: (value) {
                    // Supprimer automatiquement le préfixe +216 s'il est saisi manuellement
                    if (value.startsWith('+216')) {
                      _phoneController.text = value.substring(4).trim();
                      _phoneController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _phoneController.text.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(
                  'Adresse de livraison',
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  label: 'Adresse',
                  icon: Icons.home_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    if (value.length < 10) {
                      return 'Veuillez entrer une adresse plus détaillée';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'Ville',
                        icon: Icons.location_city_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ville requise';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Code postal',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                        validator: _validatePostalCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _additionalInfoController,
                  label: 'Instructions supplémentaires (optionnel)',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à payer',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${total.toStringAsFixed(2)} TND',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppTheme.primaryBrown.withOpacity(0.9);
                  }
                  return AppTheme.primaryBrown;
                }),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Text(
                    'Confirmer la commande',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBrown),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    String? prefixText,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryBrown),
          prefixText: prefixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.primaryBrown.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.primaryBrown.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppTheme.primaryBrown, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade300, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.surfaceLight,
          labelStyle: TextStyle(color: AppTheme.primaryBrown.withOpacity(0.7)),
        ),
        style: AppTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.primaryBrown,
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.primaryBrown : AppTheme.textDark,
          ),
        ),
        price is Widget
            ? price
            : Text(
              price,
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.primaryBrown : AppTheme.textDark,
              ),
            ),
      ],
    );
  }

  Future<void> _updateAddressFromLatLng(double lat, double lng) async {
    try {
      if (kIsWeb) {
        // Utilise Nominatim (OpenStreetMap) sur le web
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&accept-language=fr',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'FlutterApp/1.0 (your@email.com)'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] ?? {};
          setState(() {
            _addressController.text = [
              address['road'],
              address['suburb'],
              address['neighbourhood'],
              address['village'],
              address['town'],
              address['state_district'],
            ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
            _cityController.text =
                address['city'] ??
                address['town'] ??
                address['village'] ??
                address['state'] ??
                '';
          });
        } else {
          Get.snackbar(
            'Erreur',
            "Impossible de récupérer l'adresse (Nominatim)",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      } else {
        // Utilise geocoding sur mobile
        final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
        print('Placemarks: $placemarks');
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          setState(() {
            _addressController.text = [
              placemark.street,
              placemark.subLocality,
              placemark.subAdministrativeArea,
            ].where((e) => e != null && e.isNotEmpty).join(', ');
            _cityController.text =
                placemark.locality ?? placemark.administrativeArea ?? '';
          });
        } else {
          Get.snackbar(
            'Adresse introuvable',
            "Aucune adresse n'a été trouvée pour ce point.",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        "Impossible de récupérer l'adresse : $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      setState(() {
        _addressController.text = '';
        _cityController.text = '';
      });
    }
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

  Future<void> _createOrder() async {
    print('Début de la création de la commande');

    if (!_formKey.currentState!.validate()) {
      print('Validation du formulaire échouée');
      return;
    }

    if (!_isLocationSelected) {
      print('Localisation non sélectionnée');
      Get.snackbar(
        'Attention',
        'Veuillez sélectionner votre localisation sur la carte',
        backgroundColor: AppTheme.surfaceLight,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.warning_amber_rounded, color: AppTheme.accentGold),
      );
      return;
    }

    try {
      print('Création de la commande...');
      final orderId = await _orderController.createOrder(
        products: [widget.product],
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        deliveryAddress: _addressController.text,
        deliveryCity: _cityController.text,
        postalCode: _postalCodeController.text,
        additionalInfo: _additionalInfoController.text,
        deliveryLocation: GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        deliveryFee: _deliveryFee,
      );

      print('Commande créée avec succès: $orderId');

      Get.snackbar(
        'Succès',
        'Votre commande a été enregistrée avec succès',
        backgroundColor: AppTheme.surfaceLight,
        colorText: AppTheme.primaryBrown,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.check_circle_outline, color: AppTheme.primaryBrown),
      );

      Get.offAllNamed(AppRoutes.mainPage);
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer la commande: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}
