import 'package:cloud_firestore/cloud_firestore.dart';

class JobService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> getActiveJobs() async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'active')
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch active jobs: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserJobs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user jobs: $e');
    }
  }

  static Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update job status: $e');
    }
  }

  static Future<String> createJob(Map<String, dynamic> jobData) async {
    try {
      final doc = await _firestore.collection('jobs').add({
        ...jobData,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      return doc.id;
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }
}