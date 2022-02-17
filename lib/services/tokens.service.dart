import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';

class TokensService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> toggleReceiveNotifications() async {
    String userId = this._firebaseAuth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> tokenReference =
        await this._firebaseFirestore.collection('tokens').doc(userId).get();

    if (tokenReference.exists) {
      await this._firebaseFirestore.collection('tokens').doc(userId).delete();
      return false;
    } else {
      await this.generateAndSaveTokenToDatabase();
      return true;
    }
  }

  Future<bool> checkNotificationsAvailability() async {
    String userId = this._firebaseAuth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> tokenReference =
        await this._firebaseFirestore.collection('tokens').doc(userId).get();

    return tokenReference.exists;
  }

  /*
   * Save FCM token to database on each update.
   * @param token FCM Token to be saved.
   */
  Future<void> saveTokenToDatabase(String token) async {
    // Save token to the respective document collection.
    String userId = this._firebaseAuth.currentUser!.uid;
    await this._firebaseFirestore.collection('tokens').doc(userId).set({
      'id': userId,
      'token': token,
    });
  }

  /*
   * Save token to the database on first run.
   */
  Future<void> generateAndSaveTokenToDatabase() async {
    //  Generate an FCM token and save it to firestore.
    String? token = await this._firebaseMessaging.getToken();
    this.saveTokenToDatabase(token!);

    log.i('FCM Token Generated and Saved');
  }
}
