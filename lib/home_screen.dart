import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:JustNotes/notes_card.dart';
import 'package:JustNotes/appstyle.dart';
import 'dart:math';
import 'package:JustNotes/about.dart';
import 'package:JustNotes/quill_card_page.dart';

class HomeScreen extends StatefulWidget {
  /// The main screen of the JustNotes application, displaying user notes.
  /// There's an App Bar with the name of the App written on it and a way for an About page.
  /// In the body of Home Screen we can see the list of notes in it's body, built using ListView Builder.
  /// The list is made up of the Notes Card with Date, Tag (Catagoryof Note), Title and some part of the content is shown.
  /// Notes without title are visible as Untitled.
  /// Floating Action button is used to add a new note in the database.
  /// For deleting the Notes we can long press the Cote Card (Details are in notes_card.dart)
  /// Also Notescard without content and title are automatically deleted
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Info button leading to the 'About' screen (about.dart)
          IconButton(
            icon: const Icon(Icons.info, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const About()),
              );
            },
          ),
        ],
        title: const Text(
          "JustNotes",
          style: TextStyle(color: Colors.black),
        ), // App name
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
        elevation: 0,
      ),
      backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notes")
                      .orderBy("date", descending: true)
                      .snapshots(), // Retrieving notes from Firestore in a descending order of date
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while waiting for data
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      // Display an error message if data retrieval fails
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      // Display a message to start taking notes and image when no notes are available
                      return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                  "https://firebasestorage.googleapis.com/v0/b/notes-project-6d296.appspot.com/o/home_2.png?alt=media&token=1183b371-0c6e-47a9-8bfd-1b0c12745b78"),
                              const Text(
                                'Start writting your notes',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                      );
                    }
                    if (snapshot.hasData) {
                      // Display the list of notes using ListView builder
                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot doc =
                                snapshot.data!.docs[index];
                            return noteCard(
                                doc, context); // Custom note card widget
                          },
                        ),
                      );
                    }
                    // Default return in case of unexpected state
                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Displaying the text and an image
                            Image.asset('lib/Images/home_2.png'),
                            const Text(
                              'Start writting your notes',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // A floating action button to create new note
        onPressed: () async {
          // Generate a random color ID for new notes
          int colorId = Random().nextInt(Appstyle.cardsColor.length);

          // Add a new note document to Firestore
          FirebaseFirestore.instance.collection("notes").add({
            "title": "", // Initiating the empty title
            "content":
                "[{\"insert\": \"\\n\"}]", // Initiating the empty content with format
            "color_id":
                colorId, // Randomly generated color id which can be changed later
            "date": Appstyle
                .getCurrentDateTime(), // Current datetime (at the time of creating new note)
            "tag": "No Tag", // default tag, if the note is not categorized
          });

          // Retrieve the latest added note for navigation to its detail view
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('notes')
              .orderBy("date", descending: true)
              .limit(1)
              .get();
          QueryDocumentSnapshot doc = querySnapshot.docs[0];

          // Navigate to the detail view of the newly added note
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => QuillCardPage(doc: doc)));
        },
        backgroundColor: Colors.yellow,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
