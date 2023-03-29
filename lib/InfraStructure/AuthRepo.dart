import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo{
  static Future<bool> googleSignup() async {
    final GoogleSignInAccount? google=await GoogleSignIn().signIn();
    if(google!=null){ 
      final GoogleSignInAuthentication goo=await google.authentication;
      final authCred=GoogleAuthProvider.credential(accessToken: goo.accessToken,idToken: goo.idToken);
      final data=await FirebaseAuth.instance.signInWithCredential(authCred);
      if(data.credential==null){
        return false;
      }else{
        return true;
      }
    }
    return false;
  }

  static Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}
}