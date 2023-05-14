import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:correctink/components/task_item.dart';
import 'package:correctink/components/widgets.dart';
import 'package:correctink/sorting/sorting_helper.dart';
import 'package:correctink/sorting/task_sorting.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../config.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late AppConfigHandler config;
  late String sortBy = '_id';
  late String sortDir = "ASC";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    config = Provider.of<AppConfigHandler>(context);
    sortBy = config.getConfigValue(AppConfigHandler.taskSortBy)?? '';
    sortDir = config.getConfigValue(AppConfigHandler.taskSortDir)?? '';
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                    }

                    final results = tasks;
                    return ListView.builder(
                      padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(0, 0, 0, 18) : const EdgeInsets.fromLTRB(0, 0, 0, 60),
                      shrinkWrap: true,
                      itemCount: data.results.realm.isClosed ? 0 : results.length,
                      itemBuilder: (context, index) => results[index].isValid
                          ? TodoItem(results[index])
                          : Container(),
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
