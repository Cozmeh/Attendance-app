import 'package:flutter/material.dart';
import 'package:ftest/Presentation/Participants/widget/ParticipantList.dart';


class Participants extends StatefulWidget {
  String? eventID;
  Participants({super.key, required this.eventID});

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  String number = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Participants"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ParticipantList.getCSV(),
        child: const Icon(Icons.download),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Roll No.'
                ),
                onChanged: (roll) =>
                    setState(() {
                      number = roll;
                }),
              ),
            ),
          ),
          ParticipantList(eventID: widget.eventID, rollnumber: number,),
        ],
      ),),
    );
  }
}
