import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:JustNotes/appstyle.dart';
import 'package:JustNotes/quill_card_page.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

Widget noteCard(QueryDocumentSnapshot doc, BuildContext context) {
  /// Input: QueryDocumentSnapshot doc, BuildContext context
  /// Output: Widget
  /// This function returns a card widget that displays the notes details in short.
  /// This card is wrapped with GestureDetector and InkWell to navigate to the QuillCardPage on tap.
  /// On long press, a dialog box appears asking for confirmation to delete the note.
  /// The card displays the tag, date, title and content of the note.
  /// The content is displayed using QuillController and QuillDocument.
  final quill.QuillController controller = quill.QuillController.basic();
  var myJSON = jsonDecode(doc["content"]);
  controller.document = quill.Document.fromJson(myJSON);
  return GestureDetector(
    child: InkWell(
      onTap: () {
        // Navigate to QuillCardPage
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => QuillCardPage(doc: doc)));
      },
      onLongPress: () {
        // Show dialog box to confirm deletion of note
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return AlertDialog which has buttons to confirm or cancel deletion
            return AlertDialog(
              title: const Text("Remove Note",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text("Do you want to remove this note?",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              actions: <Widget>[
                // Cancel button
                TextButton(
                  child: const Text("Cancel",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                // Remove button
                TextButton(
                  child: const Text("Remove",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red,),),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection("notes")
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
      child: Container(
        // Designing of card
        width: double.infinity,
        height: 135,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Appstyle.cardsColor[doc['color_id']],
        ),
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                // showing tag and date of note at top-left and top-right side of card
                children: [
                  Expanded(
                    child: Text(
                      doc['tag'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      doc['date'].toString().substring(0, 10),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            //Sized box for spacing
            const SizedBox(height: 4),
            SizedBox(
              // showing title of note in larger and bold font style.
              width: double.infinity,
              child: Text(
                doc["title"] == "" ? "Untitled" : doc["title"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              // showing content of note in normal font style (without quill styling).
              width: double.infinity,
              child: Text(
                controller.document.toPlainText().toString() == "[{insert: \n}]"
                    ? "No content"
                    : controller.document.toPlainText().toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
