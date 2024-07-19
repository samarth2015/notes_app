import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JustNotes/appstyle.dart';
import 'dart:math';

class AppSettings extends StatefulWidget {
  /// This class is create for setting the color as well as the name of the tag.
  /// A new tag can be created/added by using the floating action button.
  /// Long press shows dialogue box, asking to delete the tag.
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _SettingsState();
}

class _SettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
      appBar: AppBar(
        title: const Text(
          "Edit Labels",
          style: TextStyle(
            fontFamily: "Nunito",
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Widget for displaying the list of tags with their colors
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("tags")
                    .orderBy("creation_time", descending: true)
                    .snapshots(), // Stream to get the list of tags
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display a loading indicator while waiting for data
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    // Display the list of tags using ListView builder
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot doc =
                              snapshot.data!.docs[index]; // Get the document
                          return GestureDetector(
                            // Long press gesture to remove a tag
                            onLongPress: () {
                              showDialog(
                                // Shows the dialog box for the confirmation of the deletion of the the note
                                context: context,
                                builder: (BuildContext context) {
                                  // AlertDialog to confirm deletion of the tag
                                  return AlertDialog(
                                    title: const Text("Remove Tag"),
                                    content:
                                        const Text("Do you want to remove this tag?"),
                                    actions: <Widget>[
                                      // Cancel button
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      // Remove button
                                      TextButton(
                                        child: const Text(
                                          "Remove",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          // Delete the tag document
                                          FirebaseFirestore.instance
                                              .collection("tags")
                                              .doc(doc.id)
                                              .delete();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: ListTile(
                              title: GestureDetector(
                                // Tap gesture to edit the tag name
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // AlertDialog to edit the tag name
                                      return AlertDialog(
                                        title: const Text("Edit Tag"),
                                        content: TextField(
                                          controller: TextEditingController(
                                              text: doc["tag_name"]),
                                          onChanged: (value) {
                                            FirebaseFirestore.instance
                                                .collection("tags")
                                                .doc(doc.id)
                                                .update(
                                              {"tag_name": value},
                                            );// Update the tag name on the Firebase server
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  doc["tag_name"],
                                ),
                              ),
                              trailing: IconButton(
                                // Icon button to change tag color
                                icon: Icon(
                                  Icons.circle_outlined,
                                  color: Appstyle.cardsColor[doc["color_id"]],
                                ),
                                onPressed: () {
                                  showDialog(
                                    // Shows dialog box to choose the color of the tag
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Choose a color"),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                // Flexible widget to make the list scrollable
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: Appstyle
                                                      .cardsColor.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      // ListTile to select color
                                                      title: Text(Appstyle
                                                              .cardsColorName[
                                                          index]),
                                                      trailing: IconButton(
                                                        // Icon button to confirm color selection
                                                        icon: Icon(
                                                          Icons.circle_outlined,
                                                          color: Appstyle
                                                                  .cardsColor[
                                                              index],
                                                        ),
                                                        onPressed: () {
                                                          // Update colorid
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "tags")
                                                              .doc(doc.id)
                                                              .update(
                                                            {"color_id": index},
                                                          ); // Update the colorid on the Firebase server
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  // Default return in case of unexpected state
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Floating action button to add a new tag
        onPressed: () {
          int colorid = Random().nextInt(Appstyle.cardsColor.length); // Generates random colorid
          FirebaseFirestore.instance.collection("tags").add({
            "tag_name": "New Tag", // Default tag name
            "color_id": colorid, // Setting randomly generated tag name
            "creation_time": Appstyle.getCurrentDateTime(), // Current date time to sort tags according to the creation time
          });
        },
        backgroundColor: Colors.yellow,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
