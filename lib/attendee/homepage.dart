import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MessagingScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () {
              // Implement search functionality here
            },
            icon:const  Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon:const  Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const  Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs
              .map((doc) => doc['email'] as String)
              .where((email) => email != user?.email)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(users[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagingScreen(
                            currentUserEmail: user?.email ?? '',
                            recipientEmail: users[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // void _logout(BuildContext context) async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => SignInPage()),
  //     );
  //   } catch (e) {
  //     print('Failed to log out: $e');
  //   }
  // }
}
