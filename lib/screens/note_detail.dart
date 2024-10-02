import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task2/models/note.dart';
import 'package:task2/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Medium', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium!;

    titleController.text = note.title ?? '';
    descriptionController.text = note.description ?? '';

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return Future.value(true); // Return true to allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: Form( // Wrap the ListView in a Form widget
            key: _formKey, // Assign form key
            child: ListView(
              children: <Widget>[
                // First element
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser!); // Added null check
                      });
                    },
                  ),
                ),
                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField( // Changed to TextFormField
                    controller: titleController,
                    style: textStyle,
                    validator: (value) { // Validation for title
                      if (value!.isEmpty) {
                        return 'Please enter the title'; // Error message
                      }
                      return null;
                    },
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField( // Changed to TextFormField
                    controller: descriptionController,
                    style: textStyle,
                    validator: (value) { // Validation for description
                      if (value!.isEmpty) {
                        return 'Please enter the description'; // Error message
                      }
                      return null;
                    },
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                // Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton( // Changed to ElevatedButton
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColorLight,
                            backgroundColor: Theme.of(context).primaryColorDark,
                          ),
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) { // Check if form is valid
                              setState(() {
                                debugPrint("Save button clicked");
                                _save();
                              });
                            } else {
                              _showAlertDialog('Error', 'Please fill the required fields'); // Show alert if invalid
                            }
                          },
                        ),
                      ),
                      Container(width: 5.0),
                      Expanded(
                        child: ElevatedButton( // Changed to ElevatedButton
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColorLight,
                            backgroundColor: Theme.of(context).primaryColorDark,
                          ),
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Medium':
        note.priority = 2;
        break;
      case 'Low':
        note.priority = 3;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority = _priorities[0]; // Default to High
    switch (value) {
      case 1:
        priority = _priorities[0];  // 'High'
        break;
      case 2:
        priority = _priorities[1];  // 'Medium'
        break;
      case 3:
        priority = _priorities[2];  // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id!); // Added null check
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }
}
