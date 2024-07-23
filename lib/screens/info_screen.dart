import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'login_screen.dart';  // Make sure to import your login screen here

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _purposeText = 'Loading purpose...';
  int _totalCandidates = 0;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _updateCurrentTime();
  }

  Future<void> _fetchData() async {
    try {
      var purposeDoc = await _db.collection('settings').doc('purpose').get();
      var candidatesSnapshot = await _db.collection('candidates').get();
      var votingSessionDoc = await _db.collection('voting').doc('voting_session').get();

      setState(() {
        if (purposeDoc.exists) {
          _purposeText = (purposeDoc.data() as Map<String, dynamic>)['text'] ?? 'Purpose not set.';
        }

        if (votingSessionDoc.exists) {
          var sessionData = votingSessionDoc.data() as Map<String, dynamic>;
          _startTime = (sessionData['start_time'] as Timestamp).toDate();
          _endTime = (sessionData['end_time'] as Timestamp).toDate();
        }

        _totalCandidates = candidatesSnapshot.docs.length;
      });
    } catch (e) {
      setState(() {
        _purposeText = 'Error fetching purpose.';
      });
    }
  }

  void _updateCurrentTime() {
    setState(() {
      _currentTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    });

    Future.delayed(const Duration(seconds: 1), _updateCurrentTime);
  }

  String _timeLeft() {
    DateTime now = DateTime.now();

    if (now.isBefore(_startTime)) {
      Duration untilStart = _startTime.difference(now);
      return 'Voting has not started yet. Starts in ${untilStart.inHours}h ${untilStart.inMinutes % 60}m ${untilStart.inSeconds % 60}s';
    } else if (now.isAfter(_endTime)) {
      return 'Voting session ended.';
    } else {
      Duration difference = _endTime.difference(now);
      return '${difference.inHours}h ${difference.inMinutes % 60}m ${difference.inSeconds % 60}s left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade400,
          title: const Text('Voting Information', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purpose of the Vote:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(_purposeText, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8.0),
                const Text(
                  'Total Number of Candidates:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('$_totalCandidates', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8.0),
                const Text(
                  'Current Date and Time:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(_currentTime, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8.0),
                const Text(
                  'Voting Session:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('Start Time : ${DateFormat('dd-MM-yyyy HH:mm:ss').format(_startTime)}', style: const TextStyle(fontSize: 18)),
                Text('End Time : ${DateFormat('dd-MM-yyyy HH:mm:ss').format(_endTime)}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8.0),
                const Text(
                  'Time Left for Voting:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(_timeLeft(), style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 45),
                        backgroundColor: Colors.blueGrey.shade300
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: const Text('Go to Ballot', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
