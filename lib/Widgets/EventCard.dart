// ignore_for_file: unrelated_type_equality_checks


import 'package:flutter/material.dart';
import '../Presentation/Participants/Participants.dart';
import '../Presentation/Scanner/Scanner.dart';

// ignore: must_be_immutable
class EventCard extends StatelessWidget{

  DateTime dateTime;
  String imageUrl, eventName, departName, venue, page, id;

  EventCard({required this.imageUrl, required this.eventName, required this.departName, required this.venue, required this.dateTime, required this.page, required this.id});

  @override
  Widget build(BuildContext context) {
    bool disableButton = true;
    String date = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    String time = "";
    String minute = "";
    if(dateTime.minute.toInt() > 9) {
      minute = dateTime.minute.toString();
    }else{
      minute  = '0${dateTime.minute}';
    }
    if(dateTime.hour.toInt() > 12){
      // ignore: prefer_interpolation_to_compose_strings
      time = (dateTime.hour.toInt() - 12).toString() + ':' + minute + " PM";
    }else if(dateTime.hour.toString() == 12){
      // ignore: prefer_interpolation_to_compose_strings
      time = dateTime.hour.toString() + ':' + minute + " PM";
    }else{
      // ignore: prefer_interpolation_to_compose_strings
      time = dateTime.hour.toString() + ':' + minute + " AM";
    }
    if(page == 'history'){
      disableButton = false;
    }
    return  Container(
      constraints: const BoxConstraints(minHeight: 0, maxHeight: 700.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11)
        ),
        elevation:30,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.3),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
                        child: Image.asset('assets/xactitude.jpg'))
                    //child: Image.network('imageUrl'))
                ),
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(eventName,
                              style: const TextStyle(color: Color.fromRGBO(58, 58, 58, 1),
                              fontFamily: 'Inter',
                              height: 1.2,
                              fontSize: 24,
                              fontWeight: FontWeight.w500),)
                            ],),
                          Row(
                            children: [
                              Text(departName,
                                style: const TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                    fontFamily: 'Inter',
                                    height: 2,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400),)
                            ],),
                          const Divider(
                            color: Color.fromRGBO(192, 192, 192, 1),
                            height: 22,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: const [
                                  Text('Date: ', textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),),
                                ],),
                              Column(
                                children: [
                                  Text(date,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),),
                                ],)
                            ],),
                          const Divider(
                            color: Color.fromRGBO(192, 192, 192, 1),
                            height: 22,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: const [
                                  Text('Venue: ', textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),),
                                ],),
                              Column(
                                children: [
                                  Text(venue, textAlign: TextAlign.right,
                                    style: const TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),),
                                ],)
                            ],),
                          const Divider(
                            color: Color.fromRGBO(192, 192, 192, 1),
                            height: 22,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: const [
                                  Text('Time: ', textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),),
                                ],),
                              Column(
                                children: [
                                  Text(time, textAlign: TextAlign.right,
                                    style: const TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                        fontFamily: 'Inter',
                                        height: 1.2,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),),
                                ],)
                            ],),
                          const SizedBox(height: 15,),
                          Row(
                            children: const [
                              SizedBox(
                                width: 320,
                                height: 130,
                                child: Text("event details will be here i hav emade it multi line hope it works proper ly and doe snot give any anomalies aor in our languge bugs",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(color: Color.fromRGBO(90, 90, 90, 1),
                                  fontFamily: 'Inter',
                                  height: 1.2,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 7,
                                  child: ElevatedButton(
                                      onPressed: disableButton? () { Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (context) => Scanner(eventID: id),
                                                  ));
                                                  }: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(29, 78, 216, 1),
                                        disabledForegroundColor: const Color.fromRGBO(29, 78, 216, 1).withOpacity(0.38), disabledBackgroundColor: const Color.fromRGBO(29, 78, 216, 1).withOpacity(0.12)
                                    ),
                                      child: const Text('Open Scanner',
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1),
                                            fontFamily: 'Inter',
                                            height: 1.2,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400),
                                      ),
                                  )
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Expanded(
                                flex: 7,
                                  child: ElevatedButton(
                                      onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => Participants(eventID: id),
                                      ));},
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(29, 78, 216, 1))
                                    ),
                                      child: const Text('View Participents',
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1),
                                            fontFamily: 'Inter',
                                            height: 1.2,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400),),
                                  )
                              )
                            ],
                          )
                        ],
                      ),
                    )
                )],
            )
          ),
        ),
    );
  }

}