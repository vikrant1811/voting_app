import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String id;
  final String title;
  final String description;

  Issue({required this.id, required this.title, required this.description});

  factory Issue.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Issue(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
