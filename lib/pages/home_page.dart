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
                  style: const TextStyle(
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
                  style: const TextStyle(
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
          title: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Text(
                    'NL',
                    style: TextStyle(
                      height: 2.0,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color.fromARGB(255, 99, 7, 7),
                    ),
                  ),
              ), 
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide.none, 
                    ),
                    prefixIcon: const Icon(Icons.search)
                ),
              ),
              ),
            ],
          ),
          /*
        title: const Text(
          "NiteLife",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        */
        backgroundColor: const Color.fromARGB(255, 99, 7, 7),
        //backgroundColor: const Color.fromARGB(255, 1, 4, 20),
        //backgroundColor: Color.fromARGB(255, 20, 4, 4),
        /*
        actions: [
          // logout button
          
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          ),
          
        ],
        */
        bottom: TabBar(
          controller: TabController(
              length: 3, vsync: this, initialIndex: _appBarCurrentIndex),
          onTap: (index) {
            setState(() {
              _appBarCurrentIndex = index;
            });
          },
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'Popular'),
            Tab(text: 'New'),
          ],
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.white,
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
        //backgroundColor: Colors.black87,
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
