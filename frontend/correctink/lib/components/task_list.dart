import 'dart:async';
import 'dart:math';

import 'package:correctink/components/animated_widgets.dart';
import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:correctink/components/task_item.dart';
import 'package:correctink/components/widgets.dart';
import 'package:correctink/sorting/sorting_helper.dart';
import 'package:correctink/sorting/task_sorting.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../Notifications/notification_service.dart';
import '../config.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  static const int animationDuration = 250;
  late double animationAngle = 0;
  late bool notificationVerified = false;
  late bool completedExpanded = false;
  late bool completedShowBorder = false;
  late AppConfigHandler config;
  late RealmServices realmServices;
  late String sortBy = '_id';
  late String sortDir = "ASC";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);

    config = Provider.of<AppConfigHandler>(context);
    sortBy = config.getConfigValue(AppConfigHandler.taskSortBy)?? '';
    sortDir = config.getConfigValue(AppConfigHandler.taskSortDir)?? '';

    if(!notificationVerified){
      notificationVerified = true;
      // verify that all the notifications are scheduled or canceled
      NotificationService.verifyAllTask(realmServices);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            styledBox(
              context,
              isHeader: true,
              child: Row(
                   children: [
                     Expanded(
                       child: SortTask(
                         (String value){
                           setState(() {
                             sortBy = value;
                           });
                           config.setConfigValue(AppConfigHandler.taskSortBy, sortBy);
                         },
                         sortBy
                       ),
                     ),
                     IconButton(
                         onPressed: () {
                           setState(() {
                             sortDir = sortDir == 'ASC' ? 'DESC' : 'ASC';
                           });
                           config.setConfigValue(AppConfigHandler.taskSortDir, sortDir);
                         },
                       tooltip: sortDir == 'ASC' ? 'ascending' : 'descending',
                         icon: Icon(sortDir == 'ASC' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                     ),
                   ],
                 ),
               ),
            Expanded(
              child: Padding(
                padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(4, 0, 4, 0) : const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: StreamBuilder<RealmResultsChanges<Task>>(
                  stream: realmServices.taskCollection.getStream(sortDir, sortBy),
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (data == null) return waitingIndicator();

                    var tasks = data.results.toList();
                    if(sortBy == SortingField.deadline.name){
                      tasks = SortingHelper.sortTaskByDeadline(tasks, sortDir == 'ASC');
                    } else if(sortBy == SortingField.creationDate.name){
                      tasks = SortingHelper.sortTaskByCreationDate(tasks, sortDir == 'ASC');
                    } else if(sortBy == SortingField.reminder.name){
                      tasks = SortingHelper.sortTaskByReminderDate(tasks, sortDir == 'ASC');
                    }

                    final results = tasks;
                    final completed = results.where((element) => element.isComplete).toList();
                    final notCompleted =  results.where((element) => !element.isComplete).toList();

                    return ListView(
                      padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(0, 0, 0, 18) : const EdgeInsets.fromLTRB(0, 0, 0, 60),
                      shrinkWrap: true,
                      children: [
                       Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                                itemCount: data.results.realm.isClosed ? 0 : notCompleted.length,
                                itemBuilder: (context, index) => TaskItem(notCompleted[index], border: index != notCompleted.length - 1)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
                            child: labeledAction(
                              context: context,
                              height: 40,
                              child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: animationAngle),
                                    duration: const Duration(milliseconds: animationDuration),
                                    builder: (BuildContext context, double value, Widget? child) {
                                      return Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateZ(value),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 0),
                                          child: value == 0
                                              ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary, size: 30,)
                                              : Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.primary, size: 30,),
                                        ),
                                      );
                                    }
                                   ),
                              color: Theme.of(context).colorScheme.primary,
                              label: 'Completed'.i18n(),
                              fontSize: 20,
                              fontWeigh: FontWeight.bold,
                              margin: EdgeInsets.zero,
                              labelFirst: false,
                              onTapAction: ()  {
                                setState(() {
                                  completedExpanded = !completedExpanded;
                                  animationAngle = (animationAngle + pi) % (2 * pi);
                                });

                                if(completedExpanded){
                                  Timer(const Duration(milliseconds: animationDuration - 50),
                                          () {
                                          setState(() {
                                            completedShowBorder = !completedShowBorder;
                                          });
                                        }
                                      );
                                  } else {
                                  setState(() {
                                    completedShowBorder = !completedShowBorder;
                                  });
                                }
                                },
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).colorScheme.primary
                                  )
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ExpandedSection(
                              expand: completedExpanded,
                              duration: animationDuration,
                              child: ListView.builder(
                                shrinkWrap: true,
                                 physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.results.realm.isClosed ? 0 : completed.length,
                                itemBuilder: (context, index) => TaskItem(completed[index], border: completedShowBorder && index != completed.length - 1,)
                              ),
                            ),
                          )
                        ],
                       )
                      ]
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        realmServices.isWaiting ? waitingIndicator() : Container(),
      ],
    );
  }

  String buildQuery(){
    if(sortBy == SortingField.creationDate.name){
      return "TRUEPREDICATE SORT(_id $sortDir)";
    }else{
      return "TRUEPREDICATE SORT($sortBy $sortDir)";
    }
  }
}
