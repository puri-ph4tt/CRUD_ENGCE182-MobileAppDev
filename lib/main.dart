// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sql_helper.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Event Task',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    if (_selectedIndex == 0) {
      final data = await SQLHelper.getItems();
      setState(() {
        _journals = data;
        _isLoading = false;
      });
    } else if (_selectedIndex == 1) {
      final data = await SQLHelper.getItemFav();
      setState(() {
        _journals = data;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    //_timeController.text = "";
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  int _selectedIndex = 0;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _favStatusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _refreshJournals();
    });
  }

  void _showDetailPopup(Map<String, dynamic> journal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(journal['event_name']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${journal['description']}'),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 15,
                  ),
                  Text(
                      ' ${DateFormat('dd MMM y').format(DateTime.parse(journal['date']))}  '),
                  const Icon(
                    Icons.access_time,
                    size: 15,
                  ),
                  Text(
                      ' ${DateFormat('HH:mm').format(DateTime.parse(journal['date']))}'),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                  ),
                  Text(
                    ' ${journal['location']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              // Add other details you want to display here
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['event_name'];
      _descriptionController.text = existingJournal['description'];
      _locationController.text = existingJournal['location'];
      _dateController.text = DateFormat('y-MM-dd').format(
        DateTime.parse(existingJournal['date']),
      );
      _timeController.text = DateFormat('HH:mm').format(
        DateTime.parse(existingJournal['date']),
      );
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //Event tiltle form
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.event),
                        hintText: 'Event title',
                        suffixIcon: IconButton(
                          onPressed: _titleController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //Description form
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.description_rounded),
                        hintText: 'Description',
                        suffixIcon: IconButton(
                          onPressed: _descriptionController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //Location form
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.location_on),
                        hintText: 'Location',
                        suffixIcon: IconButton(
                          onPressed: _locationController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //Date form
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        hintText: 'Date',
                        suffixIcon: IconButton(
                          onPressed: _dateController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), //get today's date
                            firstDate: DateTime(
                                2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));
                        if (pickedDate != null) {
                          print(
                              pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                          String formattedDate = DateFormat('yyyy-MM-dd').format(
                              pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                          print(
                              formattedDate); //formatted date output using intl package =>  2022-07-04
                          //You can format date as per your need

                          setState(() {
                            _dateController.text =
                                formattedDate; //set foratted date to TextField value.
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Date is not selected';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //Time form
                    TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.access_time),
                        hintText: "Time",
                        suffixIcon: IconButton(
                          onPressed: _timeController.clear,
                          icon: const Icon(Icons.clear),
                        ), //label text of field
                      ),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                        );
                        if (pickedTime != null) {
                          print(pickedTime.format(context)); //output 10:51 PM
                          int hour = pickedTime.hour;
                          int minute = pickedTime.minute;
                          String formattedTime =
                              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

                          print(formattedTime); //output 14:59:00
                          //DateFormat() is from intl package, you can format the time on any pattern you need.

                          setState(() {
                            _timeController.text = formattedTime;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Time is not selected';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //Button
                    ElevatedButton(
                      onPressed: () async {
                        // Save new journal

                        if (_formKey.currentState!.validate()) {
                          if (id == null) {
                            await _addItem();
                          }

                          if (id != null) {
                            await _updateItem(id);
                          }
                          // Clear the text fields
                          _titleController.text = '';
                          _descriptionController.text = '';
                          _locationController.text = '';
                          _dateController.text = '';
                          _timeController.text = '';

                          // Close the bottom sheet
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

  // Insert a new journal to the database
  Future<void> _addItem() async {
    String datetime = '${_dateController.text} ${_timeController.text}';
    await SQLHelper.createItem(_titleController.text, datetime,
        _locationController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    String datetime = '${_dateController.text} ${_timeController.text}';
    await SQLHelper.updateItem(id, _titleController.text, datetime,
        _locationController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Update an existing fav journal
  Future<void> updateItemFav(int id) async {
    await SQLHelper.updateItemFav(id, _favStatusController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a event!'),
    ));
    _refreshJournals();
  }

  void _deleteEndedEvents() async {
    final now = DateTime.now();
    final endedEvents = <Map<String, dynamic>>[];

    for (final event in _journals) {
      final eventDate = DateTime.parse(event['date']);

      if (now.isAfter(eventDate) && event['fav_status'] != "T") {
        endedEvents.add(event);
      }
    }

    if (endedEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No unfavorite ended events to delete!'),
      ));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Do you want to delete all unfavorite ended events?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (final event in endedEvents) {
        await SQLHelper.deleteItem(event['id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unfavorite ended events have been deleted!'),
      ));

      _refreshJournals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Task'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.auto_delete),
            onPressed: () {
              // Implement the logic to delete ended events here
              _deleteEndedEvents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Implement the logic to refresh here
              _refreshJournals();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue[200],
                margin: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    _showDetailPopup(_journals[index]);
                  },
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(width: 5, color: Colors.blue),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('dd').format(
                              DateTime.parse(_journals[index]['date']),
                            ),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMM').format(
                              DateTime.parse(_journals[index]['date']),
                            ),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          _journals[index]['event_name'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                            width: 5), // Add some spacing between text and icon
                        Opacity(
                            opacity: 0.65, // Set the opacity value here
                            child: Row(
                              children: [
                                const Text("( "),
                                Text(_journals[index]['location']),
                                const Text(" )"),
                              ],
                            )),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        //Text('${_journals[index]['description']} at '),
                        // count down time
                        Text(
                          calculateDaysLeft(_journals[index]
                              ['date']), // Use the countdown function here
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: calculateDaysLeft(
                                        _journals[index]['date']) ==
                                    'Event ended'
                                ? Colors.red
                                : calculateDaysLeft(_journals[index]['date']) ==
                                        'Today'
                                    ? Color.fromARGB(255, 15, 150, 19)
                                    : (calculateDaysLeft(
                                                _journals[index]['date']) ==
                                            'Tomorrow'
                                        ? Color.fromARGB(255, 194, 161, 13)
                                        : Color.fromARGB(255, 104, 98, 98)),
                          ),
                        ), // Use the countdown function here
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.access_time,
                          size: 15,
                        ),
                        Text(
                            ' ${DateFormat('HH:mm').format(DateTime.parse(_journals[index]['date']))}'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            icon: _journals[index]['fav_status'] == "F"
                                ? Icon(Icons.star_border)
                                : Icon(Icons.star),
                            onPressed: () {
                              if (_journals[index]['fav_status'] == "F") {
                                _favStatusController.text = "T";
                              } else {
                                _favStatusController.text = "F";
                              }
                              updateItemFav(_journals[index]['id']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_journals[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

String calculateDaysLeft(String targetDate) {
  DateTime targetDateTime = DateTime.parse(targetDate);
  DateTime now = DateTime.now();

  if (targetDateTime.isBefore(now)) {
    return 'Event ended';
  }

  now = DateTime(now.year, now.month, now.day);

  Duration difference = targetDateTime.difference(now);
  int daysLeft = difference.inDays;

  if (daysLeft == 0) {
    return 'Today';
  } else if (daysLeft == 1) {
    return 'Tomorrow';
  } else if (daysLeft < 0) {
    return 'Event ended';
  } else {
    return '$daysLeft days left';
  }
}
