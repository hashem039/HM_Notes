import 'package:flutter/material.dart';

import 'screens/note_list.dart';

void main() => runApp(HMNotes());

class HMNotes extends StatelessWidget {
  //const HMNotes({Key? key}) : super(key: key);

  final List<String> list = [
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item1",
    "Item2",
    "Item3"
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HM Notes",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home:NoteList(),
    ); }
}
