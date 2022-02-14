import 'package:flutter/material.dart';
import 'package:hm_notes/models/note.dart';
import 'package:hm_notes/screens/edit_note.dart';
import 'package:hm_notes/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
   List<Note>? notelist;
  late int count = 0;

  @override
  Widget build(BuildContext context) {
    if (notelist == null) {
      notelist = <Note>[];
      updateListView();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Notes"),
        ),
        body: getNoteListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint("Floating Action Button Pressed");
            navigateToEditNoteScreen(Note('', '', 2),"Add Note");
          },
          tooltip: "Add Note",
          child: Icon(Icons.add),
        ));
  }

  ListView getNoteListView() {
    TextStyle? titleStyle = Theme.of(context).textTheme.subtitle1;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int positon) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.notelist![positon].priority),
                child: getPriorityIcon(this.notelist![positon].priority),
              ),
              title: Text(
                this.notelist![positon].title,
                style: titleStyle,
              ),
              subtitle: Text(this.notelist![positon].date),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onTap: () {
                  _delete(context, this.notelist![positon]);
                },
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToEditNoteScreen(this.notelist![positon], "Note Details");
              },
            ),
          );
        });
  }

  //Returns color based on priority
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        {
          return Colors.red;
          break;
        }
      case 2:
        {
          return Colors.yellow;
          break;
        }
      default:
        return Colors.yellow;
    }
  }

  //Returns Icon based on priority
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        {
          return Icon(Icons.play_arrow);
          break;
        }
      case 2:
        {
          return Icon(Icons.keyboard_arrow_right);
          break;
        }
      default:
        return Icon(Icons.play_arrow);
    }
  }

  // delete a note when delete icon pressed
  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      //update list view
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snakBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snakBar);
  }

  //fetch data and update list view
  void updateListView() {
    final Future<Database> dbFuture  = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.notelist = noteList;
          count = noteList.length;
        });
      });

    });
  }

  void navigateToEditNoteScreen(Note note, String title) async {
    bool result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EditNoteScreen(note, title);
    }));
    result? updateListView() : null;
  }
}
