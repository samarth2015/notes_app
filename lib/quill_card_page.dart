import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:JustNotes/appstyle.dart';
import 'package:JustNotes/settings.dart';

class QuillCardPage extends StatefulWidget {
  /// Input: Key key, QueryDocumentSnapshot doc
  /// Output: State<QuillCardPage>
  /// This class is a StatefulWidget that displays the Quill Editor for the selected note.
  /// The Quill Editor is used to edit the content of the note in a rich text format.
  /// The title of the note is displayed in a TextField widget.
  /// The content of the note is displayed using QuillEditor widget.
  /// The QuillEditor widget is wrapped with QuillToolbar.simple widget to provide text formatting options.
  const QuillCardPage({super.key, required this.doc});
  final QueryDocumentSnapshot doc;

  @override
  State<QuillCardPage> createState() => _QuillCardPageState();
}

class _QuillCardPageState extends State<QuillCardPage> {
  // Defining quillController for the Quill Editor
  final quill.QuillController controller = quill.QuillController.basic();
  Color textColor = Colors.black; // Default text color
  String tag = "";
  TextEditingController? titleController;

  @override
  void initState() {
    super.initState();
    tag = widget.doc['tag']; // Initial tag value from the document
    titleController = TextEditingController(text: widget.doc["title"]); // Initial title value
    // Listening to changes in the Quill Editor and updating on the server in json format.
    // This json format is easier to store data with formatting
    var myJSON = jsonDecode(widget.doc["content"]); // Decoding intial content value
    controller.document = quill.Document.fromJson(myJSON); // Setting initial content value loaded from json
  }

  @override
  Widget build(BuildContext context) {
    controller.document.changes.listen((event) {
      var json = jsonEncode(controller.document
          .toDelta()
          .toJson()); // Converting QuillDocument to json
      FirebaseFirestore.instance.collection("notes").doc(widget.doc.id).update({
        "content": json,
        "date": Appstyle.getCurrentDateTime()
      }); // Updating the content on the server
    });

    // WillPopScope to handle back button press on mobile phone
    // It is used to produce same effect as back button on the app bar
    return WillPopScope(
      onWillPop: () async {
        if (controller.document.toDelta().toJson().toString() ==
                "[{insert: \n}]" &&
            titleController!.text.isEmpty) {
          FirebaseFirestore.instance
              .collection("notes")
              .doc(widget.doc.id)
              .delete();
        } // Deleting the note if it is empty
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 233, 208, 1),
          actions: [
            // IconButton to navigate to Tags Settings
            IconButton(
              icon: const Icon(Icons.new_label, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppSettings()),
                );
              },
            ),
          ],
          elevation: 0.0,
          title: GestureDetector(
            // GestureDetector box to change the tag of the note.
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.yellow[100]!),
                  elevation: WidgetStateProperty.all<double>(0.0),
                ),
                onPressed: () async {
                  // Fetching the tags from the server
                  // Displaying the tags in a dialog box and updating the tag of the note
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('tags')
                      .orderBy("creation_time", descending: true)
                      .get();

                  // Displaying the tags in a dialog box
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Choose New Tag"),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                // Making a ListView.builder to display the tags comming in form of Stream form server.
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: querySnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        // Updating the tag of the note and also on the server
                                        Navigator.of(context).pop();
                                        await FirebaseFirestore.instance
                                            .collection("notes")
                                            .doc(widget.doc.id)
                                            .update(
                                          {
                                            "tag": querySnapshot.docs[index]
                                                ["tag_name"],
                                            "color_id": querySnapshot
                                                .docs[index]["color_id"],
                                          },
                                        );
                                        setState(() {
                                          // Setting the state with new tag
                                          tag = querySnapshot.docs[index]
                                              ["tag_name"];
                                        });
                                      },
                                      child: ListTile(
                                        title: Text(querySnapshot.docs[index]
                                            ["tag_name"]),
                                        trailing: Icon(
                                          // Color of the tag to be shown with tag name
                                          Icons.circle_outlined,
                                          color: Appstyle.cardsColor[
                                              querySnapshot.docs[index]
                                                  ["color_id"]],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              ElevatedButton(
                                // Button to navigate to Tags Settings
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AppSettings()),
                                  );
                                },
                                child: const Text("Edit Tags"),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(
                  // Icon to show with the tag just for designing
                  Icons.label,
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(
                  // Text to show with the tag, also controlling the overflow of the Tag name
                  tag,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 27, 27, 27),
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          centerTitle: true,
        ),
        // Quill Editor
        body: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: Column(
              // Column to display the title and Quill Editor and Text Editing options at the bottom
              children: [
                TextField(
                  // TextField to edit the title of the note
                  onChanged: (value) {
                    // Updating the title of the note on the server as soon as the value changes
                    FirebaseFirestore.instance
                        .collection("notes")
                        .doc(widget.doc.id)
                        .update({
                      "title": value,
                      "date": Appstyle.getCurrentDateTime()
                    });
                  },
                  maxLines:
                      null, // title can be extended to more than 1 lines so set this property to null
                  minLines: 1,
                  keyboardType: TextInputType
                      .multiline, // multiline input to be supported
                  controller: titleController,
                  decoration: const InputDecoration(
                    // Decoration for the TextField
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        fontSize: 43,
                        letterSpacing: 2,
                        fontFamily: 'Nunito',
                        color: Color.fromRGBO(154, 154, 154, 1)),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    // Styling of the title
                    fontSize: 43,
                    letterSpacing: 2,
                    color: Color.fromARGB(255, 40, 40, 40),
                    fontFamily: 'Nunito',
                  ),
                ),
                Expanded(
                  // Expanded widget to take the remaining space which contains the Quill Editor
                  child: quill.QuillEditor.basic(
                    configurations: quill.QuillEditorConfigurations(
                      // Configurations for the Quill Editor
                      placeholder:
                          'Start writing something...', // placeholder same as hintText property
                      controller: controller,
                      sharedConfigurations:
                          const quill.QuillSharedConfigurations(
                        dialogBarrierColor: Colors.white,
                        locale: Locale('en'),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  // SingleChildScrollView to make the Text Editing options scrollable
                  scrollDirection:
                      Axis.horizontal, // giving horizontal scrolling
                  child: quill.QuillToolbar.simple(
                    // QuillToolbar.simple to provide text formatting options
                    configurations: quill.QuillSimpleToolbarConfigurations(
                      controller: controller,
                      buttonOptions:
                          // ButtonOptions to provide the styling of the text editing options
                          const quill.QuillSimpleToolbarButtonOptions(
                        base: quill.QuillToolbarBaseButtonOptions(
                          // Styling of the base button
                          iconTheme: quill.QuillIconTheme(
                            iconButtonSelectedData: quill.IconButtonData(
                              iconSize: 18,
                              color: Colors.black,
                            ),
                            iconButtonUnselectedData: quill.IconButtonData(
                              iconSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        color: quill.QuillToolbarColorButtonOptions(
                            iconData: Icons.color_lens),
                        undoHistory: quill.QuillToolbarHistoryButtonOptions(
                          // Styling of the undo button
                          iconTheme: quill.QuillIconTheme(
                            iconButtonUnselectedData:
                                quill.IconButtonData(color: Colors.black),
                          ),
                          iconSize: 18,
                        ),
                        fontFamily: quill.QuillToolbarFontFamilyButtonOptions(
                          // Styling of the font family button and giving black color to text
                          style: TextStyle(color: Colors.black),
                        ),
                        fontSize: quill.QuillToolbarFontSizeButtonOptions(
                          // Styling of the font size button and giving black color to text
                          style: TextStyle(color: Colors.black),
                        ),
                        selectHeaderStyleDropdownButton: quill
                            .QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                          // Styling of the header style button and giving black color to text
                          textStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      sharedConfigurations:
                          const quill.QuillSharedConfigurations(
                        locale: Locale('en'),
                      ),
                      showClipboardCut: false,
                      showClipboardCopy: false,
                      showClipboardPaste: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
