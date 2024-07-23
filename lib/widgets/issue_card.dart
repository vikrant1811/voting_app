import 'package:flutter/material.dart';
import '../models/issue.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;

  IssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.grey.shade400,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              issue.title,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.0),
            Text(issue.description),
          ],
        ),
      ),
    );
  }
}
