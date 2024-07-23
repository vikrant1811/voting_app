import 'package:flutter/material.dart';
import '../models/candidate.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final List<Candidate> allCandidates;

  CandidateCard({required this.candidate, required this.allCandidates});

  @override
  Widget build(BuildContext context) {
    // Determine the maximum number of votes
    int maxVotes = allCandidates.fold(0, (max, c) => c.votes > max ? c.votes : max);

    // Determine if the current candidate has the maximum votes
    bool isWinner = candidate.votes == maxVotes;

    return Card(
      color: Colors.grey.shade400,
      margin: EdgeInsets.all(8.0,),
      child: ListTile(
        title: Text(candidate.name,style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
        subtitle: Text('Votes: ${candidate.votes}'),
        trailing: isWinner ? Text('Leading!') : SizedBox.shrink(),
      ),
    );
  }
}
