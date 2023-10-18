import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Data/constants.dart';
import '../Presentation/Participants/Participants.dart';
import '../Presentation/Scanner/scan.dart';

// ignore: must_be_immutable
class EventCard extends StatefulWidget {
  String imageUrl, eventName, departName, date, venue, startTime, endTime, id;
  bool isOpenForall, isStarted, isEnded;
  var faculty;
  EventCard({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.departName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.id,
    required this.isOpenForall,
    required this.isStarted,
    required this.isEnded,
    required this.faculty,
  });
  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  var divider = Divider(
    color: dimGrey,
    height: 10.h,
  );

  var sizedbox10 = SizedBox(height: 10.h);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 750.h,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 226, 226, 226),
              blurRadius: 10,
              spreadRadius: 0.1,
              offset: Offset.zero,
            )
          ]),
          child: Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: Image.network(
                        fit: BoxFit.cover,
                        widget.imageUrl, // lets the image clip and zoom
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(child: Text("Loading.."));
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Text(
                                widget.eventName.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 0,
                  //fit: FlexFit.tight,
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  widget.eventName.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Organizer : ${widget.departName}",
                              style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Inter',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w100),
                            ),
                            widget.isOpenForall
                                ? Icon(
                              Icons.public,
                              size: 30.sp,
                            )
                                : Icon(
                              Icons.public_off,
                              size: 30.sp,
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
                        sizedbox10,
                        Row(
                          // Venue Row
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Venue ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.venue,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          ],
                        ),
                        sizedbox10,
                        divider,
                        sizedbox10,
                        Row(
                          // Date Row
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Date ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.date,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          ],
                        ),
                        sizedbox10,
                        divider,
                        sizedbox10,
                        Row(
                          // Time Row
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  widget.isStarted ? "Started" : "Start",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: widget.isStarted
                                          ? Colors.green
                                          : textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.startTime,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          ],
                        ),
                        sizedbox10,
                        divider,
                        sizedbox10,
                        Row(
                          // Time Row
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  widget.isEnded ? "Ended" : "End",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: widget.isEnded
                                          ? Colors.red
                                          : textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.endTime,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                          ],
                        ),
                        sizedbox10,
                        sizedbox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: widget.isStarted
                                  ? () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => Scanner(
                                      eventID: widget.id,
                                      isOpenForall: widget.isOpenForall),
                                ));
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(borderRadius),
                                  ),
                                  fixedSize: Size(220.w, 60.h),
                                  backgroundColor: primaryBlue),
                              child: Text(
                                'Attendance',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: !widget.isStarted &&
                                  widget.isOpenForall &&
                                  !widget.isEnded
                                  ? null
                                  : () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => Participants(
                                    faculty: widget.faculty,
                                    eventName: widget.eventName,
                                    eventID: widget.id,
                                    isOpenForall: widget.isOpenForall,
                                    isEnded: widget.isEnded,
                                  ),
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(borderRadius),
                                  ),
                                  fixedSize: Size(220.w, 60.h),
                                  backgroundColor: primaryBlue),
                              child: Text(
                                'Participants',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





/*

Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => Participants(
                                                eventID: widget.id,
                                                isOpenForall:
                                                    widget.isOpenForall),
                                          ));

Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => Scanner(
                                            eventID: widget.id,
                                            isOpenForall: widget.isOpenForall),
                                      ));

Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => const nfcScanner(),
                                    ));


*/