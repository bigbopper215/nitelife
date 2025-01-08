import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.person)),
                  const Text(
                    'Edit Profile',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                 // const EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
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
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
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
            const SizedBox(height: 4.0),
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),

            /*
            THEME
            be able to switch between light and dark theme
             */
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.toggle_off)),
                  const Text(
                    'Theme',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.notifications)),
                  const Text(
                    'Notifications',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.people)),
                  const Text(
                    'Privacy Policy',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.policy)),
                  const Text(
                    'Terms of Service',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.handyman)),
                  const Text(
                    'Community Guidelines',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.question_mark_rounded)),
                  const Text(
                    'FAQ',
                  )
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              //padding:
                  //const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      //_deleteAccount(context);
                      }, 
                    icon: const Icon(Icons.mail)),
                  const Text(
                    'Contact Us',
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
