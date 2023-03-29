import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  String? eventID;
 Scanner({required this.eventID});
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
 final GlobalKey globalKey=GlobalKey();
 
 late QRViewController qrViewController;
 String? result;
 Color? scanStatus;
 int totalCount=0;
 String status="";
 Future<int> countProducts() async {
  print("count products");
  final CollectionReference<Map<String, dynamic>> productList = FirebaseFirestore.instance.collection('Event').doc(widget.eventID).collection("Participants");
  AggregateQuerySnapshot query = await productList.count().get();
  print('The number of products: ${query.count}');
  setState(() {
    totalCount=query.count;
  });
  print(query.count);
  return query.count;
  }

  @override
  void initState() {
    //countProducts();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Column(
        children: [
          Container(
          height: 400,width: 400,
          child: QRView(
          key: globalKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
          borderColor: scanStatus ?? Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 20,
          ),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          )),
          ElevatedButton(onPressed: (){
            qrViewController.resumeCamera();
          }, child: Text("Start Camera")),
          Padding(
            padding: const EdgeInsets.only(left:8.0,right:8.0),
            child: Text("$status"),
          ),
          Container(height: 270,
            child: StreamBuilder(stream: FirebaseFirestore.instance.collection('Event').doc(widget.eventID).collection('Participants').orderBy('takenTime',descending: false).snapshots(),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
               if(snapshot.connectionState==ConnectionState.waiting){
                return Center(child: CircularProgressIndicator());
              }else if(!snapshot.hasData){
                return Container();
              }else if(snapshot.hasData){
                  return ListView(children: snapshot.data!.docs.map((e) {
                    return ListTile(title: Text(e['participantID']),
                    trailing: GestureDetector(
                      onTap: () {
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
                      .doc(e['participantID']) // <-- Doc ID to be deleted. 
                      .delete() // <-- Delete
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
                      },
                      child: Icon(Icons.delete,color: Colors.red,)),
                    // subtitle: Text(e['takenTime'].toDate()),
                    );
                  }).toList());
              }
              else{
                return CircularProgressIndicator();
              }
            }
            ),
          ) ,
        ],
    ),),);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      print("ITs sancnning");
      //print(scanData);
      if (scanData.code != null) {
            setState(() { result = scanData.code; });
            var participantref =FirebaseFirestore.instance.collection("Event").doc(widget.eventID).collection("Participants").doc(result);
            var a = await FirebaseFirestore.instance.collection("Event").doc(widget.eventID).collection("Participants").doc(result).get();
            if (result!=null && !a.exists) {
               scanStatus = Colors.green;
               participantref.set({
               'takenTime': DateTime.now(),
               'isPresent':true,
               'takenBy':FirebaseAuth.instance.currentUser!.email,
               'participantID':result
                });
                status="$result Attendance Marked";
                qrViewController.resumeCamera();
            }else if(a.exists){
              scanStatus = Colors.orange;
              status="$result Attendance already Marked";
            }else{
              status="Some problem occured";
            }
         setState(() {});
        } 
    });
  }

}