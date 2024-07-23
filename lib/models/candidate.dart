import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  final String id;
  final String name;
  final int votes;

  Candidate({required this.id, required this.name, required this.votes});

  factory Candidate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Candidate(
      id: doc.id,
      name: data['name'] ?? '',
      votes: data['votes'] ?? 0,
    );
  }
}
