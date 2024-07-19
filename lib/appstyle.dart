import 'package:flutter/material.dart';

class Appstyle {
///This is the Page where the Color Styling of the NotesCard is being done.
///Also here the Date and Time format plus the way color_id and Tag_name are mapped is done here
  const Appstyle();

  static List<Color> cardsColor = [
    //Defining the colors for NotesCard shown in HomeScreen
    const Color(0xFFF06292),
    const Color(0xFFCE93D8),
    const Color(0xFFA5D6A7),
    const Color(0xFFFFEE58),
    const Color(0xFFA7FFEB),
    const Color(0xFFFFA726)
  ];

  static List<String> cardsColorName = [
    // The name of cardscolor which are shown to the user.
    // Colors are shown for the convinience of the user to select the color of the tag.
    "Pink",
    "Purple",
    "Green",
    "Yellow",
    "Blue",
    "Orange"
  ];

  static String getCurrentDateTime() {
    //Output: Date and Time in String format
    //We are taking the date and time when the note is created/edited
    //This is used to display the Date of creation/editing on the NotesCard in HomeScreen
    DateTime now = DateTime.now();
    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return formattedDate;
  }

}
