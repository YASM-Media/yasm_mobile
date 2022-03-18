import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/animations/data_not_found.animation.dart';
import 'package:yasm_mobile/animations/loading.animation.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/activity/activity.model.dart' as AM;
import 'package:yasm_mobile/services/activity.service.dart';
import 'package:yasm_mobile/widgets/activity/activity_tile.widget.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  static const routeName = "/activity";

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  late final ActivityService _activityService;

  List<AM.Activity>? _activities;

  @override
  void initState() {
    super.initState();

    this._activityService =
        Provider.of<ActivityService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FutureBuilder(
              future: this._activityService.fetchActivity(),
              builder: _buildActivityBody,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityBody(
      BuildContext context, AsyncSnapshot<List<AM.Activity>> snapshot) {
    if (snapshot.hasError) {
      log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

      return Text("Something went wrong, please try again later.");
    }

    if (snapshot.connectionState == ConnectionState.done) {
      this._activities = snapshot.data!;

      return _buildActivitiesList();
    }

    return this._activities == null
        ? Loading(message: 'Loading Activities')
        : _buildActivitiesList();
  }

  Widget _buildActivitiesList() {
    return this._activities!.length == 0
        ? DataNotFound(message: 'No Activity Found')
        : ListView.builder(
            itemCount: this._activities!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              AM.Activity activity = this._activities![index];

              return ActivityTile(activity: activity);
            },
          );
  }
}
