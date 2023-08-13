import 'dart:async';
import 'dart:math';

import 'package:correctink/blocs/tasks/task_item.dart';
import 'package:correctink/blocs/tasks/task_sorting.dart';
import 'package:correctink/widgets/animated_widgets.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:correctink/utils/sorting_helper.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../app/data/models/schemas.dart';
import '../../app/data/repositories/realm_services.dart';
import '../../app/services/config.dart';
import '../../utils/task_helper.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  static const int animationDuration = 250;
  late double checkmarkAngle = 0;
  late double arrowAngle = 0;
  late bool myDay = false;
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
    sortBy = config.getConfigValue(AppConfigHandler.taskSortBy);
    sortDir = config.getConfigValue(AppConfigHandler.taskSortDir);
    myDay = config.getConfigValue(AppConfigHandler.taskMyDay) == '1';

    if(!notificationVerified){
      notificationVerified = true;
      // verify that all the notifications are scheduled or canceled
      TaskHelper.verifyAllTask(realmServices);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            styledHeaderFooterBox(
              context,
              isHeader: true,
              child: Row(
                   children: [
                     Expanded(
                         child: Wrap(
                           spacing: 8,
                           runSpacing: 4,
                           children: [
                             labeledAction(context: context,
                               child: Padding(
                                 padding: const EdgeInsets.only(right: 8.0),
                                 child: Icon(!myDay ? Icons.sunny : Icons.checklist_rounded, color: Theme.of(context).colorScheme.primary,),
                               ),
                               label: !myDay ? "My day".i18n() : "All tasks".i18n(),
                               color: Theme.of(context).colorScheme.onPrimaryContainer,
                               center: false,
                               infiniteWidth: false,
                               onTapAction: () {
                                  setState(() {
                                    myDay = !myDay;
                                  });
                                  config.setConfigValue(AppConfigHandler.taskMyDay, myDay ? '1' : '0');
                               },
                               height: 40,
                               labelFirst: false
                             ),
                           ],
                         )
                     ),
                     IconButton(
                       onPressed: () {
                         showDialog(context: context, builder: (context){
                           return SortTask(
                             onChange: (value) {
                               setState(() {
                                 sortBy = value;
                               });
                               config.setConfigValue(AppConfigHandler.setSortBy, sortBy);
                             },
                             startingValue: sortBy,
                           );
                         });
                       },
                       icon: const Icon(Icons.sort_rounded),
                       color: Theme.of(context).colorScheme.onPrimaryContainer,
                     ),
                     const SizedBox(width: 8,),
                     SortDirectionButton(
                         sortDir: sortDir == 'ASC',
                         onChange: (dir) {
                           setState(() {
                             arrowAngle = (arrowAngle + pi) % (2 * pi);
                             sortDir = dir ? 'ASC' : 'DESC';
                           });
                           config.setConfigValue(AppConfigHandler.taskSortDir, sortDir);
                         },
                         arrowAngle: arrowAngle
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

                    if(myDay){
                      tasks = tasks.where((task) {
                        return (task.hasReminder && (task.reminder!.isToday()
                                                    || TaskHelper.getPreviousReminderDate(task.reminder!, task.reminderRepeatMode).isToday()))
                              || (task.hasDeadline && task.deadline!.isToday()
                              || (task.completionDate != null && task.completionDate!.isToday())
                            );
                      }).toList();
                    }

                    if(sortBy == TaskSortingField.deadline.name){
                      tasks = SortingHelper.sortTaskByDeadline(tasks, sortDir == 'ASC');
                    } else if(sortBy == TaskSortingField.creationDate.name){
                      tasks = SortingHelper.sortTaskByCreationDate(tasks, sortDir == 'ASC');
                    } else if(sortBy == TaskSortingField.reminder.name){
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
                            ExpandedSection(
                              expand: myDay,
                              duration: 500,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                child: labeledAction(
                                  context: context,
                                  height: 40,
                                  child: Container(width: 0,),
                                  color: Theme.of(context).colorScheme.secondary,
                                  label: DateTime.now().getFullWrittenDate(),
                                  fontSize: 22,
                                  fontWeigh: FontWeight.w600,
                                  margin: EdgeInsets.zero,
                                  labelFirst: false,
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(
                                        width: 1,
                                        color: Theme.of(context).colorScheme.secondary
                                    )
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if(notCompleted.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    myDay ? completed.isNotEmpty ? "No tasks uncompleted left myDay".i18n() : "No tasks uncompleted myDay".i18n() : "No tasks uncompleted".i18n(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                  )
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                  itemCount: data.results.realm.isClosed ? 0 : notCompleted.length,
                                  itemBuilder: (context, index) => TaskItem(notCompleted[index], border: index != notCompleted.length - 1)
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                            child: labeledAction(
                              context: context,
                              height: 44,
                              child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: checkmarkAngle),
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
                                              ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.secondary, size: 30,)
                                              : Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.secondary, size: 30,),
                                        ),
                                      );
                                    }
                                   ),
                              color: Theme.of(context).colorScheme.secondary,
                              label: 'Completed'.i18n(),
                              fontSize: 22,
                              fontWeigh: FontWeight.w600,
                              margin: EdgeInsets.zero,
                              labelFirst: false,
                              onTapAction: ()  {
                                setState(() {
                                  completedExpanded = !completedExpanded;
                                  checkmarkAngle = (checkmarkAngle + pi) % (2 * pi);
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
                                    width: 1,
                                    color: Theme.of(context).colorScheme.secondary
                                  )
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
    if(sortBy == TaskSortingField.creationDate.name){
      return "TRUEPREDICATE SORT(_id $sortDir)";
    }else{
      return "TRUEPREDICATE SORT($sortBy $sortDir)";
    }
  }
}
