import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_voting/services/auth_service.dart'; // Import AuthService
import '../models/candidate.dart';
import 'results_screen.dart';

class BallotScreen extends StatefulWidget {
  @override
  _BallotScreenState createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  String? _selectedCandidateId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  bool _hasVoted = false;
  DateTime _endTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkIfVoted();
    _fetchVotingEndTime();
  }

  Future<void> _checkIfVoted() async {
    User? user = _authService.getCurrentUser();
    if (user != null) {
      DocumentSnapshot voteDoc = await _db.collection('user_votes').doc(user.uid).get();
      if (voteDoc.exists) {
        bool voted = (voteDoc.data() as Map<String, dynamic>)['voted'] ?? false;
        setState(() {
          _hasVoted = voted;
        });
      }
    }
  }

  Future<void> _fetchVotingEndTime() async {
    DocumentSnapshot votingSessionDoc = await _db.collection('voting').doc('voting_session').get();
    if (votingSessionDoc.exists) {
      var sessionData = votingSessionDoc.data() as Map<String, dynamic>;
      _endTime = (sessionData['end_time'] as Timestamp).toDate();
    }
  }

  Future<void> _resetUserVotes() async {
    await _authService.resetAllUserVotes();
    // Refresh the vote status
    _checkIfVoted();
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate to vote for.')),
      );
      return;
    }

    User? user = _authService.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to vote.')),
      );
      return;
    }

    try {
      // Check if the user has already voted
      DocumentSnapshot voteDoc = await _db.collection('user_votes').doc(user.uid).get();
      if (voteDoc.exists && (voteDoc.data() as Map<String, dynamic>)['voted'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already voted.')),
        );
        return;
      }

      // Increment vote count in Firestore
      DocumentReference candidateRef = _db.collection('candidates').doc(_selectedCandidateId);
      await candidateRef.update({
        'votes': FieldValue.increment(1),
      });

      // Record the user's vote
      await _db.collection('user_votes').doc(user.uid).set({
        'voted': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Check if voting session has ended
      if (DateTime.now().isAfter(_endTime)) {
        await _resetUserVotes(); // Reset all user votes
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vote submitted successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting vote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade400,
          title: const Text('Cast Your Vote',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w700),),
        ),
        body: _hasVoted
            ? const Center(child: Text('You have already voted.'))
            : _buildVotingOptions(),
        floatingActionButton: _hasVoted
            ? null
            : FloatingActionButton(
          child: const Icon(Icons.done),
          onPressed: _submitVote,
        ),
      ),
    );
  }

  Widget _buildVotingOptions() {
    return StreamBuilder<List<Candidate>>(
      stream: _db.collection('candidates').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList();
      }),
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
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var candidate = snapshot.data![index];
            return RadioListTile<String>(
              title: Text(candidate.name),
              value: candidate.id,
              groupValue: _selectedCandidateId,
              onChanged: (value) {
                setState(() {
                  _selectedCandidateId = value;
                });
              },
            );
          },
        );
      },
    );
  }
}
