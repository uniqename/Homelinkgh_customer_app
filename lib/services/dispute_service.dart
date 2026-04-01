// Firestore dependency removed - using simplified services

class DisputeService {
  static final _firestore // FirebaseFirestore _firestore = _firestore // FirebaseFirestore.instance;

  static Future<String> createDispute({
    required String orderId,
    required String userId,
    required String reason,
    required String description,
  }) async {
    try {
      final doc = await _firestore.collection('disputes').add({
        'orderId': orderId,
        'userId': userId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Failed to create dispute: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserDisputes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('disputes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user disputes: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllDisputes() async {
    try {
      final snapshot = await _firestore
          .collection('disputes')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch all disputes: $e');
    }
  }

  static Future<void> updateDisputeStatus(String disputeId, String status) async {
    try {
      await _firestore.collection('disputes').doc(disputeId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update dispute status: $e');
    }
  }

  static Future<void> addDisputeMessage({
    required String disputeId,
    required String senderId,
    required String message,
  }) async {
    try {
      await _firestore
          .collection('disputes')
          .doc(disputeId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add dispute message: $e');
    }
  }
}