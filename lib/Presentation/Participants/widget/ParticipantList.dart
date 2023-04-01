import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ParticipantList extends StatefulWidget {
  String? eventID, rollnumber;
  ParticipantList({super.key, required this.eventID, required this.rollnumber});

  @override
  _ParticipantListState createState() => _ParticipantListState();

  static getCSV() {}
}

class _ParticipantListState extends State<ParticipantList> {
  List<List<String>> items = [];

  @override
  void initState() {
    items = [
      <String>["participantID", "takenBy", "takenTime", "isPresent"]
    ];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> participants = FirebaseFirestore
        .instance
        .collection('Event')
        .doc(widget.eventID)
        .collection('Participants');
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: const EdgeInsets.only(left: 21.0, right: 21.0),
        child: StreamBuilder(
          stream: participants.orderBy('takenTime', descending: false).snapshots(),
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: snapshot.data!.docs.map((e) {
                    var time = (e["takenTime"] as Timestamp).toDate().toString();
                    items.add([
                      e['participantID'],
                      e["takenBy"],
                      time,
                      e["isPresent"].toString()
                    ]);
                    if (widget.rollnumber == "") {
                      return ListTile(
                        title: Text(e['participantID']),
                        subtitle: Text(time),
                        trailing: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Are you sure you want to delete ?"),
                                    //content: Text("Dialog Content"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Yes"),
                                        onPressed: () {
                                          participants
                                              .doc(e['participantID'])
                                              .delete()
                                              .then((_) => print('Deleted'))
                                              .catchError((error) => print(
                                                  'Delete failed: $error'));
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("No"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      );
                    } else if (e['participantID']
                        .toString().toUpperCase()
                        .contains(widget.rollnumber.toString().toUpperCase())) {
                      return ListTile(
                        title: Text(e['participantID']),
                        subtitle: Text(time),
                        trailing: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        "Are you sure you want to delete ?"),
                                    //content: Text("Dialog Content"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Yes"),
                                        onPressed: () {
                                          participants
                                              .doc(e['participantID'])
                                              .delete()
                                              .then((_) => print('Deleted'))
                                              .catchError((error) => print(
                                                  'Delete failed: $error'));
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("No"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      );
                    } else {
                      return Container();
                    }
                  }).toList());
          },
        ),
      ),
    );
  }

  getCSV() async {
    String csvData = const ListToCsvConverter().convert(items);
    print(csvData);
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      final String directory = (await getApplicationDocumentsDirectory()).path;
      final String path = "$directory/ams${widget.eventID}.csv";
      final File file = File(path);
      dynamic data = await file.writeAsString(csvData);
      print(data);
      print(path);
      try {
        await OpenFilex.open(file.path);
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }
}
