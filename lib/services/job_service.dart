// Firestore dependency removed - using simplified services
import '../models/job.dart';

class JobService {
  static final _firestore // FirebaseFirestore _firestore = _firestore // FirebaseFirestore.instance;

  static Stream<List<Job>> getProviderJobs(String providerId) {
    return _firestore
        .collection('jobs')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  static Stream<List<Job>> getAvailableJobs(List<String> serviceTypes) {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'pending')
        .where('serviceType', whereIn: serviceTypes)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  static Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> acceptJob(String jobId, String providerId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'providerId': providerId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}