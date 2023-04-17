import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ftest/Data/Colour.dart';
import 'package:google_fonts/google_fonts.dart';

class ParticipantsTile extends StatefulWidget {
  String participantID, takenTime, eventID;
  ParticipantsTile(
      {super.key,
      required this.participantID,
      required this.takenTime,
      this.eventID = ""});

  @override
  _ParticipantsTileState createState() => _ParticipantsTileState();
}

class _ParticipantsTileState extends State<ParticipantsTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      shadowColor: const Color(0xff000000),
      color: const Color(0xfff1f1f1),
      child: ListTile(
        tileColor: Colour.tileColor,
        dense: true,
        title: Text(
          widget.participantID,
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xff404040)),
        ),
        trailing: Visibility(
          visible: (widget.eventID != ""),
          child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Entry"),
                      content: Text(
                          "Do you want to Delete ${widget.participantID} ?"),
                      actions: [
                        TextButton(
                          child: const Text(
                            "Yes",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Event')
                                .doc(widget.eventID)
                                .collection('Participants')
                                .doc(widget.participantID)
                                .delete()
                                .then((_) => print('Deleted'))
                                .catchError(
                                    (error) => print('Delete failed: $error'));
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            "No",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(
                Icons.delete,
                size: 30,
                color: Color(0xff838383),
              )),
        ),
      ),
    );
  }
}
