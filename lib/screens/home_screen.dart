//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/data_service.dart';
import '../models/candidate.dart';
import '../models/issue.dart';
import '../widgets/candidate_card.dart';
import '../widgets/issue_card.dart';
import 'ballot_screen.dart';
import 'results_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _purposeText = 'Loading purpose...';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _fetchPurpose();
    _fetchVotingSessionTimes();
  }

  Future<void> _fetchPurpose() async {
    try {
      DocumentSnapshot doc = await _db.collection('settings').doc('purpose').get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        setState(() {
          _purposeText = data?['text'] ?? 'Purpose not set.';
        });
      } else {
        setState(() {
          _purposeText = 'Purpose not set.';
        });
      }
    } catch (e) {
      //print('Error fetching purpose: $e');
      setState(() {
        _purposeText = 'Error fetching purpose.';
      });
    }
  }

  Future<void> _fetchVotingSessionTimes() async {
    try {
      DocumentSnapshot votingSessionDoc = await _db.collection('voting').doc('voting_session').get();
      if (votingSessionDoc.exists) {
        Map<String, dynamic>? sessionData = votingSessionDoc.data() as Map<String, dynamic>?;
        if (sessionData != null) {
          Timestamp startTimestamp = sessionData['start_time'] as Timestamp;
          Timestamp endTimestamp = sessionData['end_time'] as Timestamp;
          setState(() {
            _startTime = startTimestamp.toDate();
            _endTime = endTimestamp.toDate();
          });
        }
      }
    } catch (e) {
      //print('Error fetching voting session times: $e');
    }
  }

  bool _isVotingActive() {
    DateTime now = DateTime.now();
    return now.isAfter(_startTime) && now.isBefore(_endTime);
  }

  bool _isVotingEnded() {
    DateTime now = DateTime.now();
    return now.isAfter(_endTime);
  }

  @override
  Widget build(BuildContext context) {
    bool isVotingActive = _isVotingActive();
    bool isVotingEnded = _isVotingEnded();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade400,
          title: const Text('Ballot',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w700),),
          leading: IconButton( // Add this line
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => InfoScreen()),
              );
            },
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Vote',style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,),),
              onPressed: isVotingActive
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BallotScreen()),
                );
              }
                  : null,
            ),
            TextButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('Results',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
              onPressed: isVotingEnded
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResultsScreen()),
                );
              }
                  : null,
            ),
          ],
        ),
        body: Column(
          children: [
            Card(
              color: Colors.grey.shade500,
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _purposeText,
                  style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "List of Candidates",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Candidate>>(
                stream: _dataService.getCandidates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No candidates available.'));
                  }
                  List<Candidate> candidates = snapshot.data!;
                  return ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      return CandidateCard(
                        candidate: candidates[index],
                        allCandidates: candidates,
                      );
                    },
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Issues",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
            ),
            SizedBox(
              height: 100.0,  // Set a fixed height for the issues section
              child: StreamBuilder<List<Issue>>(
                stream: _dataService.getIssues(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No issues.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return IssueCard(issue: snapshot.data![index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
