import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nite_life/services/firestore.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

    // Function to handle account deletion
  void _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        // Navigate back to login or onboarding screen after deletion
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Handle any errors (e.g., reauthentication might be needed)
      print('Error deleting account: $e');
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        // If the user needs to re-authenticate before deleting their account
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in again to delete your account.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title:  const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: logout,
                    icon: const Icon(Icons.logout),
                  ),
                  const Text(
                    'Logout',
                  )
                ],
              ),
            ),
            const SizedBox(height: 7.5),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      _deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.delete)),
                  const Text(
                    'Delete Account',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
