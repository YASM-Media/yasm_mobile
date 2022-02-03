import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:hive/hive.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/activity/activity.model.dart';

class ActivityService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final Box<List<dynamic>> _yasmActivityDb =
      Hive.box<List<dynamic>>(YASM_ACTIVITY_BOX);

  void _saveActivitiesToDevice(List<Activity> activity) {
    log.i("Saving ACTIVITY to Hive DB");
    this._yasmActivityDb.put(ACTIVITIES, activity);
    log.i("Saved ACTIVITY to Hive DB");
  }

  List<Activity> _fetchActivitiesFromDevice() {
    log.i("Fetching ACTIVITY from Hive DB");
    return this
        ._yasmActivityDb
        .get(ACTIVITIES, defaultValue: [])!.cast<Activity>();
  }
}
