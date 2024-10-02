import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task2/models/note.dart';
import 'package:task2/utils/database_helper.dart';
import 'package:task2/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note>? noteList; // Changed to nullable type
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = <Note>[]; // Corrected initialization of noteList
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        backgroundColor: Colors.blue,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.bodyLarge!; // Use bodyLarge

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.cyan,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList![position].priority),
              child: getPriorityIcon(this.noteList![position].priority),
            ),
            title: Text(
              this.noteList![position].title ?? 'Untitled', // Use the public getter
              style: titleStyle,
            ),

            subtitle: Text(this.noteList![position].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                _delete(context, noteList![position]);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.noteList![position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      default:
        return Colors.red;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
      case 2:
        return Icon(Icons.keyboard_arrow_right);
      case 3:
        return Icon(Icons.text_rotation_angledown);
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!); // Ensure note.id is non-null
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar); // Use ScaffoldMessenger
  }

  void navigateToDetail(Note note, String title) async {
    bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      }).catchError((error) {
        debugPrint('Error fetching notes: $error'); // Handle error
      });
    }).catchError((error) {
      debugPrint('Error initializing database: $error'); // Handle error
    });
  }
}
