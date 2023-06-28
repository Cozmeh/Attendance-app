import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ParticipantsTile extends StatefulWidget {
  String participantID, takenTime, eventID;
  bool isPresent, isOpenForall;
  ParticipantsTile(
      {super.key,
      required this.participantID,
      required this.takenTime,
      required this.isPresent,
      required this.isOpenForall,
      this.eventID = ""});

  @override
  _ParticipantsTileState createState() => _ParticipantsTileState();
}

class _ParticipantsTileState extends State<ParticipantsTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        shadowColor: Colors.transparent,
        color: const Color(0xfff1f1f1),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
            ),
            !widget.isOpenForall
                ? widget.isPresent
                    ? Icon(
                        size: 35.h,
                        Icons.check_circle_outline_sharp,
                        color: Colors.green,
                      )
                    : Icon(size: 35.h, Icons.cancel_outlined, color: Colors.red)
                : Icon(
                    size: 35.h,
                    Icons.check_circle_outline_sharp,
                    color: Colors.green,
                  ),
            SizedBox(
              width: 20.w,
            ),
            Text(
              widget.participantID,
              style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: textColor),
            ),
            const Expanded(child: SizedBox()),
            Visibility(
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
                                    .catchError((error) =>
                                        print('Delete failed: $error'));
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
                  child: Icon(
                    Icons.delete,
                    size: 30.sp,
                    color: const Color(0xff838383),
                  )),
            ),
            SizedBox(
              width: 20.w,
            )
          ],
        ),
      ),
    );
  }
}
