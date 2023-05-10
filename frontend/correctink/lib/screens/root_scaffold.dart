import 'dart:async';

import 'package:correctink/connectivity/connectivity_service.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/create/create_set.dart';
import 'package:provider/provider.dart';
import '../components/widgets.dart';
import '../create/create_task.dart';
import '../main.dart';
import '../components/app_bar.dart';
import '../realm/app_services.dart';

class ScaffoldNavigationBar extends StatefulWidget{
  const ScaffoldNavigationBar(this.child, {super.key});

  final Widget child;

  @override
  State<ScaffoldNavigationBar> createState() =>_ScaffoldNavigationBar();
}

class _ScaffoldNavigationBar extends State<ScaffoldNavigationBar>{
  late RealmServices realmServices;
  late Stream stream;
  bool listeningToConnectionChange = false;
  int selectedIndex = 0;
  late bool backBtn = false;
  late Widget? floatingAction;

  final GlobalKey _appBarKey = GlobalKey();

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    final appServices = Provider.of<AppServices>(context);
    if(appServices.app.currentUser != null) {
      if(!listeningToConnectionChange){
        stream = ConnectivityService.getInstance().connectionChange;
        stream.listen(connectionChanged);
      }

      realmServices = Provider.of<RealmServices>(context);
    }
  }

  void connectionChanged(dynamic hasConnection){
    realmServices.changeSession(hasConnection);

    if(context.mounted) infoMessageSnackBar(context, hasConnection ? 'You are back online!' : 'You are offline!').show(context);
  }

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
                                icon: Icon(Icons.folder_outlined),
                                activeIcon: Icon(Icons.folder),
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
                          destinations: [
                             NavigationRailDestination(
                              icon: const Icon(Icons.task_alt_outlined),
                              selectedIcon: Icon(Icons.task_alt_rounded, color: Theme.of(context).colorScheme.primary,),
                              label: const Text('Tasks'),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.folder_outlined),
                              selectedIcon: Icon(Icons.folder, color: Theme.of(context).colorScheme.primary,),
                              label: const Text('Sets'),
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