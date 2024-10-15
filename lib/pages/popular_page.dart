
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/services/firestore.dart';

class PopularPage extends StatelessWidget {
  const PopularPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    User? currentUser = FirebaseAuth.instance.currentUser;

    void showCommentSection(String docID) {
      final FocusNode focusNode = FocusNode(); //
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusScope.of(context).requestFocus(focusNode);
            });
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
            child:Container(
              padding: const EdgeInsets.all(16.0),
              height: 700,
              child: Column(
                children: [
                  const Text('Comments',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey, thickness: 1),
                  // add a light grey line across to separate Comments and the comment section
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getCommentsStream(docID),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<DocumentSnapshot> comments = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> commentData = comments[index]
                                  .data() as Map<String, dynamic>;
                              Timestamp? createdAt = commentData['timestamp'];
                              return ListTile(
                                title: Text(
                                  commentData['userName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commentData['comment'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16
                                      ),
                                      ),
                                    Text(
                                      createdAt != null ? formatTimestamp(createdAt) : 'just now',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error loading comments"));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              firestoreService.addComment(docID, value);
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
            );
          });
    }

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> notesList = snapshot.data!.docs;

          // displays event details
          void showEventDetails(String docID) {
            DocumentSnapshot document =
                notesList.firstWhere((note) => note.id == docID);
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            String title = data['title'] ?? 'No Title';
            String description = data['description'] ?? 'No Description';
            String location = data['location'] ?? 'No Location';

            String dateString = data['date'] ?? '';
            DateTime? dateParsed =
                DateTime.tryParse(dateString); // Parse your date string

            String time = data['time'] ?? '';

            // Display your event details or open a dialog with the details
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(title),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Description: $description'),
                        Text('Location: $location'),
                        if (dateParsed != null)
                          Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(dateParsed)}'),
                        Text('Time: $time'),
                        const SizedBox(height: 16),
                        //Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
                        //buildCommentSection(docID),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          }

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

              int userVote = (data['votes'] != null &&
                      data['votes'][currentUser?.uid] != null)
                  ? data['votes'][currentUser!.uid]
                  : 0;

              return GestureDetector(
                  onTap: () => showEventDetails(docID),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 9.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
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
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                //SizedBox(height: 0),
                                Text(month,
                                    style: const TextStyle(fontSize: 14)),
                                //SizedBox(height: 0),
                                Text(time,
                                    style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20.0),
                                  Text(title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text('Description: $description',
                                      style: const TextStyle(fontSize: 14)),
                                  Text(location,
                                      style: const TextStyle(fontSize: 14)),
                                  Row(
                                    verticalDirection: VerticalDirection.down,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        iconSize: 15,
                                        onPressed: () => showCommentSection(docID),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  iconSize: 35,
                                  onPressed: () =>
                                      firestoreService.upvoteEvent(docID),
                                  icon: Icon(
                                    Icons.keyboard_arrow_up,
                                    color: userVote == 1
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                Text('$netVotes'),
                                IconButton(
                                  iconSize: 35,
                                  onPressed: () =>
                                      firestoreService.downvoteEvent(docID),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: userVote == -1
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
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
                  ));
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

DateTime _getEventDateTime(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  String date = data['date'];
  String time = data['time'] ?? '00:00';

  // Clean up the time string
  time = time.trim().toUpperCase();

  // Handle both 24-hour and 12-hour (with AM/PM) time formats
  DateFormat dateFormat;
  if (time.contains('AM') || time.contains('PM')) {
    dateFormat = DateFormat('yyyy-MM-dd hh:mm a');
  } else {
    dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  }

  try {
    return dateFormat.parse('$date $time');
  } catch (e) {
    // Fallback to date only parsing if time parsing fails
    return DateTime.parse(date);
  }
}

int _calculateNetVotes(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  int upvotes = data['upvotes'] ?? 0;
  int downvotes = data['downvotes'] ?? 0;
  return upvotes - downvotes;
}

// Helper function to format the timestamp
String formatTimestamp(Timestamp timestamp) {
  DateTime commentTime = timestamp.toDate();
  Duration difference = DateTime.now().difference(commentTime);

  if (difference.inDays > 0) {
    return '${difference.inDays}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'just now'; // or use 'a moment ago' etc.
  }
}
