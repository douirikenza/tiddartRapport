import 'package:Tiddart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/message_controller.dart';
import '../../models/message_model.dart';
import 'client_chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final AuthController _authController = Get.find<AuthController>();
  final MessageController _messageController = Get.find<MessageController>(); 
  List<Map<String, dynamic>> _filteredArtisans = [];
  List<Map<String, dynamic>> _allArtisans = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadArtisans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadArtisans() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'artisan')
              .where('isApproved', isEqualTo: true)
              .get();
      _allArtisans =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'Artisan',
              'image': data['image'],
              'isOnline': data['isOnline'] ?? false,
              'lastMessage': null,
              'unread': 0,
            };
          }).toList();
      setState(() {
        _filteredArtisans = List.from(_allArtisans);
      });
    } catch (e) {
      _showMessage('Erreur lors du chargement des artisans', true);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArtisans =
          _allArtisans.where((artisan) {
            final name = artisan['name'].toString().toLowerCase();
            return name.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un artisan...',
                    hintStyle: TextStyle(
                      color: AppTheme.primaryBrown.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: AppTheme.primaryBrown, fontSize: 16),
                  autofocus: true,
                )
                : Text(
                  'Messages',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredArtisans = List.from(_allArtisans);
                } else {
                  _searchFocusNode.requestFocus();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pour votre sécurité, veuillez utiliser uniquement la messagerie de Tiddart pour communiquer avec les artisans.',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _filteredArtisans.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredArtisans.length,
                      itemBuilder: (context, index) {
                        final artisan = _filteredArtisans[index];
                        return _buildArtisanCard(artisan, context);
                      },
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSearching ? Icons.search_off : Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.primaryBrown.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSearching ? 'Aucun artisan trouvé' : 'Aucun artisan disponible',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryBrown.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Essayez avec d\'autres mots-clés'
                : 'Les artisans apparaîtront ici',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryBrown.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(Map<String, dynamic> artisan, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.primaryBrown.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            final currentUser = _authController.firebaseUser.value;
            if (currentUser != null) {
              Get.to(
                () => ClientChatPage(
                  clientId: currentUser.uid,
                  artisanId: artisan['id'],
                  artisanName: artisan['name'],
                ),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            } else {
              _showMessage(
                'Vous devez être connecté pour accéder aux messages',
                true,
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                      child:
                          artisan['image'] != null
                              ? ClipOval(
                                child: Image.network(
                                  artisan['image'],
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Text(
                                artisan['name'][0].toUpperCase(),
                                style: TextStyle(
                                  color: AppTheme.primaryBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                    ),
                    if (artisan['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            artisan['name'],
                            style: AppTheme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (artisan['lastMessage'] != null)
                            Text(
                              _formatTimestamp(
                                artisan['lastMessage']['timestamp'],
                              ),
                              style: AppTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryBrown.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (artisan['lastMessage'] != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                artisan['lastMessage']['content'],
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryBrown.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (artisan['unread'] > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBrown,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  artisan['unread'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          'Cliquez pour démarrer une conversation',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryBrown.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
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
}
