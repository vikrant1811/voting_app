import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/candidate.dart';

class ResultsScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade400,
          title: Text('Election Results',style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        body: StreamBuilder<List<Candidate>>(
          stream: _db.collection('candidates').snapshots().map((snapshot) {
            return snapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList()
              ..sort((a, b) => b.votes.compareTo(a.votes));
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
      
            List<Candidate> candidates = snapshot.data!;
            if (candidates.isEmpty) {
              return Center(child: Text('No candidates available.'));
            }
      
            // Determine the maximum votes and winners
            int maxVotes = candidates.first.votes;
            List<Candidate> winners = candidates.where((c) => c.votes == maxVotes).toList();
      
            return ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                var candidate = candidates[index];
                bool isWinner = winners.contains(candidate);
                int voteDifference = maxVotes - candidate.votes;
      
                return Card(
                  margin: EdgeInsets.all(8.0),
                  color: isWinner ? Colors.green.shade400 : Colors.grey.shade500,
                  child: ListTile(
                    title: Text(
                      candidate.name,
                      style: TextStyle(
                        fontSize: isWinner ? 24: 20,
                        fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                        color: isWinner ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${candidate.votes} Votes',
                          style: TextStyle(
                            fontSize: isWinner ? 18: 16,
                            color: isWinner ? Colors.white : Colors.black,
                          ),
                        ),
                        if (!isWinner)
                          Text(
                            'Difference: $voteDifference',
                            style: TextStyle(fontSize:14,fontWeight:FontWeight.bold,color: Colors.pink.shade400),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
