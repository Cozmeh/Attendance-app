import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ftest/InfraStructure/authRepo.dart';
import 'package:ftest/Presentation/Authentication/login.dart';
import 'package:ftest/Presentation/History/history.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});
  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var spacer10 = const SizedBox(
    height: 10,
  );

  var divider = const Divider(
    color: dimGrey,
  );

  var bigDivider = const Divider(
    color: Color.fromARGB(50, 255, 255, 255),
    thickness: 1,
  );

  Widget header(BuildContext context) => SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              PhysicalModel(
                color: Colors.transparent,
                shadowColor: Colors.white12,
                elevation: 10,
                shape: BoxShape.circle,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  foregroundImage: NetworkImage(
                      FirebaseAuth.instance.currentUser!.photoURL!),
                ),
              ),
              spacer10,
              Text(
                FirebaseAuth.instance.currentUser!.displayName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                ),
              ),
              spacer10,
              Text(
                FirebaseAuth.instance.currentUser!.providerData[0].email!,
                style: const TextStyle(
                  color: dimGrey,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontFamily: "Inter",
                ),
              ),
              spacer10,
            ],
          ),
        ),
      );

  Widget menuItems(BuildContext context) => SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              item(
                "History",
                Icons.history,
                () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const History()));
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 100, right: 100),
                child: divider,
              ),
              item("Feedback", Icons.feedback_outlined, () {}),
              item("About", Icons.info_outline, () {})
            ],
          ),
        ),
      );

  Widget item(String title, IconData leadingIcon, void Function() onTap) {
    return Card(
      color: const Color.fromARGB(255, 53, 53, 53),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        onTap: onTap,
        iconColor: Colors.white,
        textColor: Colors.white,
        leading: Icon(
          leadingIcon,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: "Inter",
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_right_outlined),
      ),
    );
  }

  Widget logoutBtn() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: pageHeaderBgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(
              color: Colors.red,
              width: 1.5,
            )),
        child: ListTile(
          dense: true,
          splashColor: Colors.red,
          titleAlignment: ListTileTitleAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          iconColor: Colors.white,
          textColor: Colors.white,
          title: Center(
            child: Text(
              "Log Out",
              style: GoogleFonts.inter(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () async {
            await AuthRepo.signOut().whenComplete(() {
              debugPrint("completes");
            });
            SchedulerBinding.instance.addPostFrameCallback((_) =>
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Login())));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: pageHeaderBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header(context),
          bigDivider,
          menuItems(context),
          const Expanded(child: SizedBox()),
          logoutBtn(),
          const Center(
            child: Text(
              "@Kristu jayanti - Attendance Management System",
              style: TextStyle(
                color: dimGrey,
                fontSize: 10,
                fontFamily: "Inter",
              ),
            ),
          ),
          spacer10,
        ],
      ),
    );
  }
}


/*Container(
      margin: const EdgeInsets.all(15),
      width: 400,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(borderRadius)),
      child: TextButton(
        child: Text(
          "Log Out",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.red,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          await AuthRepo.signOut().whenComplete(() {
            debugPrint("completes");
          });
          SchedulerBinding.instance.addPostFrameCallback((_) =>
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Login())));
        },
      ),
    );*/