import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/create/create_set.dart';
import '../create/create_task.dart';
import '../main.dart';
import 'app_bar.dart';

class ScaffoldNavigationBar extends StatefulWidget{
  const ScaffoldNavigationBar(this.child, {super.key});

  final Widget child;

  @override
  State<ScaffoldNavigationBar> createState() =>_ScaffoldNavigationBar();
}

class _ScaffoldNavigationBar extends State<ScaffoldNavigationBar>{
  _ScaffoldNavigationBar();
  int selectedIndex = 0;
  late bool backBtn = false;
  late Widget? floatingAction;

  final GlobalKey _appBarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    setState(() {
      selectedIndex = _calculateSelectedIndex(context);
    });
    return Scaffold(
          appBar: selectedIndex >= -1 ? TodoAppBar(backBtn: backBtn, key: _appBarKey,) : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: floatingAction,
          body: selectedIndex <= -1
              ? Container(
                color: Theme.of(context).colorScheme.surface,
                child: widget.child
                )
              : LayoutBuilder(
                builder: (context , constraints) {
                  if(constraints.maxWidth <= 450){
                  return Column(
                    children: [
                      Expanded(child: widget.child),
                      SafeArea(
                          child: BottomNavigationBar(
                            items: const [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.task_alt_outlined),
                                label: 'Tasks',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.folder),
                                label: 'Sets',
                              ),
                            ],
                            currentIndex: selectedIndex,
                            onTap: (int idx) => _onItemTapped(idx, context),
                          ),
                      ),
                    ],
                  );
                }else{
                  return Row(
                    children: [
                      SafeArea(
                        child: NavigationRail(
                          extended: constraints.maxWidth > 850,
                          elevation: 1.0,
                          backgroundColor: Theme.of(context).colorScheme.background,
                          selectedIndex: selectedIndex,
                          onDestinationSelected:(int index) {
                            _onItemTapped(index, context);
                          },
                          destinations:const [
                             NavigationRailDestination(
                              icon: Icon(Icons.task_alt_outlined),
                              selectedIcon: Icon(Icons.task_alt_rounded),
                              label: Text('Tasks'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.folder_outlined),
                              selectedIcon: Icon(Icons.folder),
                              label: Text('Sets'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: widget.child),
                    ],
                  );
            }
          },
        )
    );
  }

  void updateAppBar(){
    if(_appBarKey.currentState != null){
      setState(() {
        (_appBarKey.currentState as TodoAppBarState).update(backBtn);
      });
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).location;
    setState(() {
      backBtn = false;
    });
    updateAppBar();
    if (location.startsWith(RouterHelper.taskRoute)) {
      floatingAction = const CreateTaskAction();
      return 0;
    } else  if (location.startsWith(RouterHelper.setLibraryRoute)) {
      if(location.startsWith('${RouterHelper.setLibraryRoute}/')){
        floatingAction = null;
        setState(() {
          backBtn = true;
        });
        updateAppBar();
        return -1;
      }
      floatingAction = const CreateSetAction();
      return 1;
    } else if (location.startsWith('/learn')) {
      floatingAction = null;
      return -2;
    }
    floatingAction = null;
    return -2;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go(RouterHelper.taskRoute);
        break;
      case 1:
        GoRouter.of(context).go(RouterHelper.setLibraryRoute);
        break;
    }
  }
}