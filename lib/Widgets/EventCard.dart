import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/Scanner/Nfc.dart';
import 'package:ftest/Data/constants.dart';
import '../Presentation/Participants/Participants.dart';
import '../Presentation/Scanner/scan.dart';

// ignore: must_be_immutable
class EventCard extends StatefulWidget {
  String imageUrl, eventName, departName, date, venue, time, id;
  bool button, isOpenForall;
  EventCard(
      {super.key,
      required this.imageUrl,
      required this.eventName,
      required this.departName,
      required this.date,
      required this.time,
      required this.venue,
      required this.button,
      required this.id,
      required this.isOpenForall});
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
      height: 550,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          color: Colors.white,
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
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                            Text(
                              "No Image Available",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ));
                      },
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 0,
                //fit: FlexFit.tight,
                child: Container(
                  //color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.eventName,
                              style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Inter',
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        sizedbox10,
                        Row(
                          children: [
                            Text(
                              "Organised by - ${widget.departName}",
                              style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Inter',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
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
                                      fontWeight: FontWeight.w400),
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
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            )
                          ],
                        ),
                        sizedbox10,
                        divider,
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
                                      fontWeight: FontWeight.w400),
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
                                      fontWeight: FontWeight.w400),
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
                                  'Time ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.time,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Inter',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            )
                          ],
                        ),
                        sizedbox10,
                        divider,
                        sizedbox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: widget.button
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
                                  fixedSize: Size(200.w, 60.h),
                                  backgroundColor: primaryBlue),
                              child: Text(
                                'Scanner',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: widget.button
                                  ? () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const nfcScanner(),
                                      ));
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(200.w, 60.h),
                                  backgroundColor: primaryBlue),
                              child: Text(
                                'NFC',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                        sizedbox10,
                        Container(
                          color: primaryBlue,
                          child: Row(
                            children: [
                              Expanded(
                                // take possible horizontal height
                                child: SizedBox(
                                  // beyound certain amount which makes the image stay inside the possible vertical and horizontal limits
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => Participants(
                                                eventID: widget.id,
                                                isOpenForall:
                                                    widget.isOpenForall),
                                          ));
                                        },
                                        style: ElevatedButton.styleFrom(
                                            fixedSize: Size(200.w, 70.h),
                                            backgroundColor: primaryBlue),
                                        child: Text(
                                          'Participants',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ],
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



*/