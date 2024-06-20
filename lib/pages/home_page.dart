import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/pages/profile_page.dart';
import 'package:nite_life/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  int _currentIndex = 0;

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
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
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
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
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

  Widget _buildHomePage() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          List<DocumentSnapshot> notesList = snapshot.data!.docs;

          // sort notes by timestamp in descending order
          notesList.sort((a, b){
            Timestamp aTimestamp = a['timestamp'] ?? Timestamp.now();
            Timestamp bTimestamp = b['timestamp'] ?? Timestamp.now();
            return bTimestamp.compareTo(aTimestamp);
          });

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = notesList[index];
              String docID = document.id;

              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              String title = data['title'] ?? 'No Title';
              String description = data['description'] ?? 'No Description';
              String location = data['location'] ?? 'No Location';
              String date = data['date'] != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['date']))
                  : 'No Date';
              String time = data['time'] ?? 'No Time';

              bool isCreator = data['creatorID'] == FirebaseAuth.instance.currentUser?.uid;

              return ListTile(
                title: Text(title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: $description'),
                    Text('Location: $location'),
                    Text('Date: $date'),
                    Text('Time: $time'),
                  ],
                ),
                trailing: isCreator
                ? Row(
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
                    ),
                    IconButton(
                      onPressed: () => firestoreService.deleteNote(docID),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                )
                : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vassar NiteLife"),
        backgroundColor: Color.fromARGB(148, 176, 17, 17),
        actions: [
          // logout button
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          const Placeholder(),
          const ProfilePage(),
        ],
      ),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          if (newIndex == 1) {
            openNoteBox();
          } else {
            setState(() {
              _currentIndex = newIndex;
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
