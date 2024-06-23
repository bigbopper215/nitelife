import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/services/firestore.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});

  @override
  _PopularPageState createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<DocumentSnapshot> notesList = [];
  Map<String, int> netVotesMap = {};
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    QuerySnapshot snapshot = await firestoreService.getNotesStream().first;
    setState(() {
      notesList = snapshot.docs;
      netVotesMap.clear();
      for (var doc in notesList) {
        netVotesMap[doc.id] = _calculateNetVotes(doc);
      }
      _orderEvents();
    });
  }

  Future<void> _refreshEvents() async {
    await _fetchEvents();
  }

  void _updateNetVotes(String docID, int change) {
    setState(() {
      netVotesMap[docID] = (netVotesMap[docID] ?? 0) + change;
    });
  }

  int _calculateNetVotes(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    int upvotes = data['upvotes'] ?? 0;
    int downvotes = data['downvotes'] ?? 0;
    return upvotes - downvotes;
  }

  void _upvoteEvent(String docID) async {
    DocumentSnapshot document = await firestoreService.getDocument(docID);
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Map<String, dynamic> votes = Map<String, dynamic>.from(data['votes'] ?? {});

    if (votes[currentUser!.uid] == 1) {
      // User is trying to cancel their upvote
      votes.remove(currentUser!.uid);
      data['upvotes'] = (data['upvotes'] ?? 0) - 1;
      _updateNetVotes(docID, -1);
    } else if (votes[currentUser!.uid] == -1) {
      // User is changing their vote from downvote to upvote
      votes[currentUser!.uid] = 1;
      data['upvotes'] = (data['upvotes'] ?? 0) + 1;
      data['downvotes'] = (data['downvotes'] ?? 0) - 1;
      _updateNetVotes(docID, 2);
    } else {
      // User is upvoting for the first time
      votes[currentUser!.uid] = 1;
      data['upvotes'] = (data['upvotes'] ?? 0) + 1;
      _updateNetVotes(docID, 1);
    }

    data['votes'] = votes;
    await firestoreService.updateDocument(docID, data);
  }

  void _downvoteEvent(String docID) async {
    DocumentSnapshot document = await firestoreService.getDocument(docID);
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Map<String, dynamic> votes = Map<String, dynamic>.from(data['votes'] ?? {});

    if (votes[currentUser!.uid] == -1) {
      // User is trying to cancel their downvote
      votes.remove(currentUser!.uid);
      data['downvotes'] = (data['downvotes'] ?? 0) - 1;
      _updateNetVotes(docID, 1);
    } else if (votes[currentUser!.uid] == 1) {
      // User is changing their vote from upvote to downvote
      votes[currentUser!.uid] = -1;
      data['upvotes'] = (data['upvotes'] ?? 0) - 1;
      data['downvotes'] = (data['downvotes'] ?? 0) + 1;
      _updateNetVotes(docID, -2);
    } else {
      // User is downvoting for the first time
      votes[currentUser!.uid] = -1;
      data['downvotes'] = (data['downvotes'] ?? 0) + 1;
      _updateNetVotes(docID, -1);
    }

    data['votes'] = votes;
    await firestoreService.updateDocument(docID, data);
  }

  void _orderEvents() {
    setState(() {
      notesList.sort((a, b) {
        int aNetVotes = netVotesMap[a.id] ?? _calculateNetVotes(a);
        int bNetVotes = netVotesMap[b.id] ?? _calculateNetVotes(b);
        return bNetVotes.compareTo(aNetVotes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (notesList.isEmpty) {
            notesList = snapshot.data!.docs;
            for (var doc in notesList) {
              netVotesMap[doc.id] = _calculateNetVotes(doc);
            }
          }

          return RefreshIndicator(
            onRefresh: _refreshEvents,
            child: ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String title = data['title'] ?? 'No Title';
                String description = data['description'] ?? 'No Description';
                String location = data['location'] ?? 'No Location';
                String date = data['date'] != null
                    ? DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(data['date']))
                    : 'No Date';
                String time = data['time'] ?? 'No Time';

                int netVotes = netVotesMap[docID] ?? 0;

                bool isCreator =
                    data['creatorID'] == FirebaseAuth.instance.currentUser?.uid;

                DateTime eventDate = DateTime.parse(data['date']);
                String day = DateFormat('d').format(eventDate);
                String month = DateFormat('MMM').format(eventDate);
                String dayOfWeek = DateFormat('E').format(eventDate);

                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          // Date and Time Column
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(day,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(month, style: TextStyle(fontSize: 14)),
                              Text('$dayOfWeek @$time',
                                  style: TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('Description: $description',
                                    style: TextStyle(fontSize: 14)),
                                Text('Location: $location',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => _upvoteEvent(docID),
                                icon: const Icon(Icons.keyboard_arrow_up),
                              ),
                              Text('$netVotes'),
                              IconButton(
                                onPressed: () => _downvoteEvent(docID),
                                icon: Icon(Icons.keyboard_arrow_down),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading events"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
