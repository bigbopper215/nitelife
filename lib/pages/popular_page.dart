import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/pages/profile_page.dart';
import 'package:nite_life/services/firestore.dart';
import 'calendar_page.dart';
import 'new_events_page.dart';

class PopularPage extends StatelessWidget {
  const PopularPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> notesList = snapshot.data!.docs;

          // sort notes by timestamp in descending order
          notesList.sort((a, b) {
            int aNetVotes = _calculateNetVotes(a);
            int bNetVotes = _calculateNetVotes(b);
            return bNetVotes.compareTo(aNetVotes);
          });

          return ListView.builder(
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

              int upvotes = data['upvotes'] ?? 0;
              int downvotes = data['downvotes'] ?? 0;
              int netVotes = upvotes - downvotes;

              bool isCreator =
                  data['creatorID'] == FirebaseAuth.instance.currentUser?.uid;

              DateTime eventDate = DateTime.parse(data['date']);
              String day = DateFormat('d').format(eventDate);
              String month = DateFormat('MMM').format(eventDate);
              String dayOfWeek = DateFormat('E').format(eventDate);

              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            //SizedBox(height: 0),
                            Text(month, style: TextStyle(fontSize: 14)),
                            //SizedBox(height: 0),
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
                              onPressed: () =>
                                  firestoreService.upvoteEvent(docID),
                              icon: const Icon(Icons.keyboard_arrow_up),
                            ),
                            Text('$netVotes'),
                            IconButton(
                              onPressed: () =>
                                  firestoreService.downvoteEvent(docID),
                              icon: Icon(Icons.keyboard_arrow_down),
                            )
                          ],
                        ),
                      ],
                    ),
                    /*
                    if (isCreator)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => editEvent(
                                docID,
                                title,
                                description,
                                location,
                                date,
                                time,
                              ),
                              icon: const Icon(Icons.settings),
                              iconSize: 15,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            IconButton(
                              onPressed: () =>
                                  firestoreService.deleteNote(docID),
                              icon: const Icon(Icons.delete),
                              iconSize: 15,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      */
                  ],
                ),
              );
            },
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

int _calculateNetVotes(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  int upvotes = data['upvotes'] ?? 0;
  int downvotes = data['downvotes'] ?? 0;
  return upvotes - downvotes;
}

