import 'package:cloud_firestore/cloud_firestore.dart';

class ArtisanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getArtisanById(String artisanId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(artisanId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }
      return null;
    } catch (e) {
      print('Error getting artisan: $e');
      return null;
    }
  }
}
