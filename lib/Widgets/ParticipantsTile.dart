import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ParticipantsTile extends StatefulWidget {
  String participantID, takenTime, eventID, takenBy;
  bool isPresent, isOpenForall, deleteBtn;
  ParticipantsTile({
    super.key,
    required this.participantID,
    this.takenBy = "",
    required this.takenTime,
    required this.isPresent,
    required this.isOpenForall,
    required this.eventID,
    required this.deleteBtn,
  });

  @override
  _ParticipantsTileState createState() => _ParticipantsTileState();
}

class _ParticipantsTileState extends State<ParticipantsTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      child: ListTile(
        onTap: () {
          widget.isPresent
              ? showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      title: const Text("Participant Info"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID - ${widget.participantID}",
                            style: GoogleFonts.inter(
                                fontSize: 22.sp, color: textColor),
                          ),
                          const Text(""),
                          Text(
                            "Date - ${widget.takenTime.substring(0, 11)} Time - ${widget.takenTime.substring(11, 16)}",
                            style: GoogleFonts.inter(
                                fontSize: 22.sp, color: textColor),
                          ),
                          const Text(""),
                          Text(
                            "By - ${widget.takenBy}",
                            style: GoogleFonts.inter(
                                fontSize: 22.sp, color: textColor),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : null;
        },
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        tileColor: tileColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: !widget.isOpenForall
            ? widget.isPresent
                ? Icon(
                    size: 35.h,
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : Icon(size: 35.h, Icons.cancel, color: Colors.red)
            : Icon(
                size: 35.h,
                Icons.check_circle,
                color: Colors.green,
              ),
        title: Text(
          widget.participantID,
          style: GoogleFonts.inter(
              fontSize: 25.sp, fontWeight: FontWeight.w500, color: textColor),
        ),
        trailing: Visibility(
          visible: widget.takenBy ==
                  FirebaseAuth.instance.currentUser!.providerData[0].email
                      .toString() &&
              widget.deleteBtn,
          child: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 30.sp,
            color: dimGrey,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: !widget.isOpenForall
                        ? const Text("Remove Attendace")
                        : const Text("Delete Participant"),
                    content: !widget.isOpenForall
                        ? Text(
                            "Do you want to mark ${widget.participantID} Absent ?")
                        : Text(
                            "Do you want to Delete ${widget.participantID} ?"),
                    actions: [
                      TextButton(
                        onPressed: !widget.isOpenForall
                            ? () {
                                // if the event is not open for all
                                FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(widget.eventID)
                                    .collection("Participants")
                                    .doc("Attendance")
                                    .update({
                                  widget.participantID: {
                                    "isPresent": false,
                                    "takenTime": 0,
                                    "takenBy": "",
                                  }
                                });
                                Navigator.of(context).pop();
                              }
                            : () {
                                // if the event is open for all
                                FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(widget.eventID)
                                    .collection("Participants")
                                    .doc("Attendance")
                                    .update({
                                  widget.participantID: FieldValue.delete()
                                });
                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.red),
                        ),
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
          ),
        ),
      ),
    );
  }
}