import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/pages/popular_page.dart';
import 'package:nite_life/pages/profile_page.dart';
import 'package:nite_life/services/firestore.dart';
import 'calendar_page.dart';
import 'new_events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  int _appBarCurrentIndex = 1;
  int _bottomNavCurrentIndex = 0;

  String _errorMessage = "Fill in all fields";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _errorMessage = "";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
        _errorMessage = "";
      });
    }
  }

  final tabs = [
    const HomePage(),
    const Placeholder(),
    const ProfilePage(),
  ];

  //opens a box to add an event
  void openNoteBox({String? docID}) {
    setState(() {
      _errorMessage = ""; //clears the error message when opening the dialogue
    });

    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    dateController.clear();
    timeController.clear();
    selectedDate = null;
    selectedTime = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'Select Date',
                ),
                onTap: () => _selectDate(context),
              ),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'Select Time',
                ),
                onTap: () => _selectTime(context),
              ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //check if any fields are empty
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null) {
                setState(() {
                  _errorMessage = "Please fill in all fields";
                });
                return;
              }

              final noteData = {
                'title': titleController.text,
                'description': descriptionController.text,
                'location': locationController.text,
                'date': selectedDate?.toIso8601String(),
                'time': selectedTime?.format(context),

                //Store the creator's ID
                'creatorID': FirebaseAuth.instance.currentUser?.uid,

                //Keep track of when event was added
                'timestamp': FieldValue.serverTimestamp(),
              };

              if (docID == null) {
                firestoreService.addNote(noteData);
              } else {
                firestoreService.updateNote(docID, noteData);
              }

              titleController.clear();
              descriptionController.clear();
              locationController.clear();
              dateController.clear();
              timeController.clear();
              selectedDate = null;
              selectedTime = null;

              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void editEvent(
    String docID,
    String title,
    String description,
    String location,
    String date,
    String time,
  ) {
    setState(() {
      _errorMessage = "";
    });

    titleController.text = title;
    descriptionController.text = description;
    locationController.text = location;
    selectedDate = DateTime.parse(date);
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    selectedTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(time));
    timeController.text = time;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'Select Date',
                ),
                onTap: () => _selectDate(context),
              ),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'Select Time',
                ),
                onTap: () => _selectTime(context),
              ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  locationController.text.isEmpty ||
                  selectedDate == null ||
                  selectedTime == null) {
                setState(() {
                  _errorMessage = "Please fill in all fields";
                });
                return;
              }

              final noteData = {
                'title': titleController.text,
                'description': descriptionController.text,
                'location': locationController.text,
                'date': selectedDate?.toIso8601String(),
                'time': selectedTime?.format(context),

                // Store the creator's ID
                'creatorID': FirebaseAuth.instance.currentUser?.uid,

                // Keep track of when event was added
                'timestamp': FieldValue.serverTimestamp(),
              };

              firestoreService.updateNote(docID, noteData);

              titleController.clear();
              descriptionController.clear();
              locationController.clear();
              dateController.clear();
              timeController.clear();
              selectedDate = null;
              selectedTime = null;

              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }
/*
  Widget _buildPopularPage() {
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
  */

  Widget _buildCalendarPage() {
    return const CalendarPage();
  }

  Widget _buildNewEventsPage() {
    return const NewEventsPage();
  }

  Widget _buildPopularPage() {
    return const PopularPage();
  }

  Widget _buildProfilePage() {
    return const ProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _bottomNavCurrentIndex == 0
        ? AppBar(
        title: const Text(
          "N i t e L i f e",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 99, 7, 7),
        actions: [
          // logout button
          
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          ),
          
        ],
        bottom: TabBar(
          controller: TabController(
              length: 3, vsync: this, initialIndex: _appBarCurrentIndex),
          onTap: (index) {
            setState(() {
              _appBarCurrentIndex = index;
            });
          },
          tabs: [
            Tab(text: 'Calendar'),
            Tab(text: 'Popular'),
            Tab(text: 'New'),
          ],
        ),
      )
      : null,
      body: _bottomNavCurrentIndex == 0
        ? IndexedStack(
        index: _appBarCurrentIndex,
        children: [
          _buildCalendarPage(),
          _buildPopularPage(),
          _buildNewEventsPage(),
        ],
      )
      : _bottomNavCurrentIndex == 2
        ? _buildProfilePage()
        : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavCurrentIndex,
        onTap: (int newIndex) {
          if (newIndex == 1) {
            openNoteBox();
          } else {
            setState(() {
              _bottomNavCurrentIndex = newIndex;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

int _calculateNetVotes(DocumentSnapshot document) {
  int upvotes = document['upvotes'] ?? 0;
  int downvotes = document['downvotes'] ?? 0;
  return upvotes - downvotes;
}
