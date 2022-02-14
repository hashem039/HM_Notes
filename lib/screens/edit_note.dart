import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hm_notes/models/note.dart';
import 'package:hm_notes/utils/database_helper.dart';
import 'package:intl/intl.dart';

class EditNoteScreen extends StatefulWidget {
  //constructor to accept a String title and pass it to appBar title
  final String appBarTitle;
  final Note note;

  EditNoteScreen(this.note, this.appBarTitle);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState(note, appBarTitle);
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  //get the singleton instance of our database
  DatabaseHelper dbHelper = DatabaseHelper();

  //constructor to accept a String title and pass it to appBar title
  String appBarTitle;
  Note note;

  _EditNoteScreenState(this.note, this.appBarTitle);

  static var _priorities = ['High', 'Low'];
  final _noteTitleFNode = FocusNode();
  final _noteBodyFNode = FocusNode();

  final _noteTitleController = TextEditingController();
  final _noteBodyController = TextEditingController();

  final _unfocusedColor = Colors.grey[600];

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.subtitle1;

    //update files with note details
    _noteTitleController.text = note.title;
    _noteBodyController.text = note.description ??= 'NA';
    return WillPopScope(
      onWillPop: () async {
        backToLastScreen();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          // this is optional just for clarification how to control back action
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              backToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String e) {
                    return DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  style: textStyle,
                  value: updatePriorityAsString(note.priority),
                  onChanged: (value) {
                    setState(() {
                      debugPrint('User Selected $value ');
                      updatePriorityAsInt(value.toString());
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  style: textStyle,
                  decoration: InputDecoration(
                    //filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color: _noteTitleFNode.hasFocus
                          ? Theme.of(context).colorScheme.secondary
                          : _unfocusedColor,
                    ),
                  ),
                  onChanged: (value) {
                    debugPrint("Something changed in the Title field");
                    updateTitle();
                  },
                  controller: _noteTitleController,
                ),
              ),
              SizedBox(),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: _noteBodyController,
                  style: textStyle,
                  decoration: InputDecoration(
                    //filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: _noteTitleFNode.hasFocus
                          ? Theme.of(context).colorScheme.secondary
                          : _unfocusedColor,
                    ),
                  ),
                  onChanged: (value) {
                    debugPrint('Something changed in desc text filed');
                    updateDescription();
                  },
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _saveToDB();
                        },
                        child: Text(
                          "Save",
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _deleteNote();
                        },
                        child: Text(
                          "Delete",
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void backToLastScreen() {
    Navigator.pop(context,
        true); //here we return true to previous screen so that it will update it's content (there should be await to rescive the result
  }

  //convert the string priority of to int (in order to store it in the Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        {
          note.priority = 1;
          break;
        }
      case 'Low':
        {
          note.priority = 2;
          break;
        }
    }
  }

  //convert the int priority of String(in order to update dropdown menu)
  String updatePriorityAsString(int value) {
    String priority = 'Low';
    switch (value) {
      case 1:
        {
          priority = _priorities[0];
          break;
        }
      case 2:
        {
          priority = _priorities[1];
          break;
        }
    }
    return priority;
  }

  //update title of note
  void updateTitle() {
    note.title = _noteTitleController.text;
  }

  //update description
  void updateDescription() {
    note.description = _noteBodyController.text;
  }

  //save data to the database
  void _saveToDB() async {
    //after we add a note we have to back to our list view
    backToLastScreen();
    //we have to cases: 1 if we adding new note, 2 if we updating already exist one
    //set the date before save the note
    note.date = DateFormat().add_yMMM().format(DateTime.now());
    int result;
    if (note.id != null) {
      // update operation
      result = await dbHelper.updateNote(note);
    } else {
      //insert operation
      result = await dbHelper.insertNote(note);
    }
    result > 0
        ? _showAlertDialog('Status', 'Note Saved Successfully')
        : _showAlertDialog('Status', 'Problem saving the Note...');
  }

  //delete note
  void _deleteNote() async {
    //anyway we have to navigate back to our last screen(note list).
    backToLastScreen();
    //there are to cases: 1 if we delete already saved note, 2. if we delete just made note
    if (note.id == null) {
      //case 2
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }
    //case 1
    int result = await dbHelper.deleteNote(note.id!);
    result > 0
        ? _showAlertDialog('Status', 'Note Deleted Successfully')
        : _showAlertDialog('Statsu', 'Error while deleting note...');
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
