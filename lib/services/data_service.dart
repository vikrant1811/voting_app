import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/candidate.dart';
import '../models/issue.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Candidate>> getCandidates() {
    return _db.collection('candidates').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Issue>> getIssues() {
    return _db.collection('issues').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Issue.fromFirestore(doc)).toList();
    });
  }
}
