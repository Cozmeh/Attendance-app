import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:csv/csv.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Participants extends StatefulWidget {
  String? eventID;
  Participants({required this.eventID});

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
   List<List<String>> items=[];

   @override
  void initState() {
    items=[<String>["participantID","takenBy","takenTime","isPresent"]];
    // TODO: implement initState
    super.initState();
  }

  //const Participants({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        getCSV();
      },child: Icon(Icons.download),),
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        child: Padding(
          padding: const EdgeInsets.only(left:21.0,right: 21.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Event').doc(widget.eventID).collection('Participants').orderBy('takenTime',descending: false).snapshots(),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
               if(snapshot.connectionState==ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator());
                }else if(!snapshot.hasData){
                  return Container();
                }else if(snapshot.hasData){
                    return ListView(children: snapshot.data!.docs.map((e) {
                      var time=(e["takenTime"] as Timestamp).toDate().toString();
                      items.add([
                        e['participantID'],
                        e["takenBy"],
                        time,
                        e["isPresent"].toString()]);
                      return ListTile(
                        title: Text(e['participantID']),
                        subtitle: Text(time),
                        trailing: GestureDetector(onTap: () {
                        showDialog(
                        context: context,
                        builder: (BuildContext context) {
                        return AlertDialog(
                        title: Text("Are you sure you want to delete ?"),
                        //content: Text("Dialog Content"),
                        actions: [
                        TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                      final collection = FirebaseFirestore.instance.collection('Event').doc(widget.eventID).collection('Participants');
                      collection 
                      .doc(e['participantID']) 
                      .delete() 
                      .then((_) => print('Deleted'))
                      .catchError((error) => print('Delete failed: $error'));
                      Navigator.of(context).pop();
                        },
                        ),
                        TextButton(
                        child: Text("No"),
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                        ),
                        ],
                      );
                    },
                  );
                      },child: Icon(Icons.delete,color: Colors.red,)),
                    
                      );
                    }).toList());
                }
                else{
                  return CircularProgressIndicator();
                }
            }
          ),
        )
    ),);
  }

  getCSV() async {
    String csvData=const ListToCsvConverter().convert(items);
    print(csvData);
    try {
       var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final String path = "$directory/ams${widget.eventID}.csv";
    final File file = File(path);
    dynamic data=await file.writeAsString(csvData);
    print(data); 
    print(path); 
    try{
    await OpenFilex.open(file.path);
    }catch(e){
      print(e);
    }
     } catch (e) {
      print(e);
    }

  }
}