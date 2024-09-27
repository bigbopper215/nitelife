import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/pages/settings_page.dart';
import 'package:nite_life/services/firestore.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // Set the height you want
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 99, 7, 7),
          title: const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              )
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                ),
              onPressed: () {
                // Navigate to the settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching user data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found'));
          }

          String username = snapshot.data!['username'] ?? 'No Username';

          return Stack(
            children: [
              Container(
                color: Colors.white,
                height: 175, // Adjust height to your preference
              ),
              Positioned(
                top: 10, // Adjust the top position as needed
                left: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 50, // Adjust radius to your preference
                  backgroundColor: Colors.grey[300], // Set background color for blank profile picture
                  child: Icon(
                    Icons.person,
                    size: 50, // Adjust icon size to your preference
                    color: Colors.white, // Icon color
                  ),
                ),
              ),
              Positioned(
                top: 120, // Adjust the top position as needed to position content below the profile picture
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      username,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    // Add more profile details or actions here
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}