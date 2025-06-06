import 'package:Tiddart/page/admin/artisan_management_page.dart';
import 'package:Tiddart/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../page/artisan/artisan_profile_page.dart';

class AdminNotificationsPage extends StatelessWidget {
  final String adminId;
  const AdminNotificationsPage({Key? key, required this.adminId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.surfaceLight,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .where('adminId', isEqualTo: adminId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune notification'));
          }
          final notifications = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      notif['status'] == 'pending'
                          ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: Colors.brown,
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          )
                          : const Icon(
                            Icons.notifications,
                            color: Colors.brown,
                          ),
                  title: Text(
                    notif['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notif['body'] ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final docId = notifications[index].id;
                      if (value == 'read') {
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(docId)
                            .update({'status': 'read'});
                      } else if (value == 'delete') {
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(docId)
                            .delete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          if (notif['status'] == 'pending')
                            const PopupMenuItem(
                              value: 'read',
                              child: Text('Marquer comme lue'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
                  ),
                  onTap: () async {
                    if (notif['type'] == 'new_artisan') {
                      Get.to(() => AdminArtisanManagementPage());
                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(notifications[index].id)
                          .update({'status': 'read'});
                    }
                  },
                  selected: notif['status'] == 'pending',
                  selectedTileColor: Colors.orange.withOpacity(0.08),
                  isThreeLine: false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
