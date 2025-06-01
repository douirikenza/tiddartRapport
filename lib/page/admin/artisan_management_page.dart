import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/artisan_management_controller.dart';
import '../../theme/app_theme.dart';

class AdminArtisanManagementPage extends StatelessWidget {
  final AdminArtisanController controller = Get.put(AdminArtisanController());

  AdminArtisanManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Gestion des artisans',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 20,
          ),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () =>
                      controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : controller.artisans.isEmpty
                          ? _buildEmptyState()
                          : _buildArtisansList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 212, 199, 195),
            const Color.fromARGB(255, 128, 90, 79),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Gérez vos artisans',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Approuvez et gérez les comptes artisans',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun artisan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun artisan n\'est inscrit pour le moment',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisansList() {
    return ListView.builder(
      itemCount: controller.artisans.length,
      itemBuilder: (context, index) {
        final artisan = controller.artisans[index];
        final bool isApproved = artisan['isApproved'] ?? false;
        final bool isSuspended = artisan['isSuspended'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatusAvatar(isApproved, isSuspended),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artisan['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artisan['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(isApproved, isSuspended),
                    ],
                  ),
                ),
                _buildActionButton(context, artisan, isApproved, isSuspended),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusAvatar(bool isApproved, bool isSuspended) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:
            isSuspended
                ? Colors.red.shade50
                : isApproved
                ? Colors.green.shade50
                : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        isSuspended
            ? Icons.block_outlined
            : isApproved
            ? Icons.check_circle_outline
            : Icons.pending_outlined,
        color:
            isSuspended
                ? Colors.red
                : isApproved
                ? Colors.green
                : Colors.orange,
        size: 30,
      ),
    );
  }

  Widget _buildStatusChip(bool isApproved, bool isSuspended) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isSuspended
                ? Colors.red.shade50
                : isApproved
                ? Colors.green.shade50
                : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isSuspended
            ? 'Compte suspendu'
            : isApproved
            ? 'Compte approuvé'
            : 'En attente d\'approbation',
        style: TextStyle(
          color:
              isSuspended
                  ? Colors.red
                  : isApproved
                  ? Colors.green
                  : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Map<String, dynamic> artisan,
    bool isApproved,
    bool isSuspended,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) {
        if (isSuspended) {
          return [
            _buildPopupMenuItem(
              'unsuspend',
              'Réactiver le compte',
              Icons.restore,
              Colors.green,
            ),
          ];
        } else if (isApproved) {
          return [
            _buildPopupMenuItem(
              'suspend',
              'Suspendre le compte',
              Icons.block,
              Colors.red,
            ),
          ];
        } else {
          return [
            _buildPopupMenuItem(
              'approve',
              'Approuver',
              Icons.check_circle,
              Colors.green,
            ),
            _buildPopupMenuItem('reject', 'Rejeter', Icons.cancel, Colors.red),
          ];
        }
      },
      onSelected: (value) {
        switch (value) {
          case 'approve':
            _showConfirmationDialog(
              context,
              'Approuver l\'artisan',
              'Voulez-vous vraiment approuver cet artisan ?',
              () => controller.approveArtisan(artisan['id']),
              Colors.green,
            );
            break;
          case 'reject':
            _showConfirmationDialog(
              context,
              'Rejeter l\'artisan',
              'Voulez-vous vraiment rejeter cet artisan ? Cette action est irréversible.',
              () => controller.rejectArtisan(artisan['id']),
              Colors.red,
            );
            break;
          case 'suspend':
            _showConfirmationDialog(
              context,
              'Suspendre l\'artisan',
              'Voulez-vous vraiment suspendre cet artisan ?',
              () => controller.suspendArtisan(artisan['id']),
              Colors.orange,
            );
            break;
          case 'unsuspend':
            _showConfirmationDialog(
              context,
              'Réactiver l\'artisan',
              'Voulez-vous vraiment réactiver cet artisan ?',
              () => controller.unsuspendArtisan(artisan['id']),
              Colors.green,
            );
            break;
        }
      },
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_rounded, color: color, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onConfirm();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Confirmer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
