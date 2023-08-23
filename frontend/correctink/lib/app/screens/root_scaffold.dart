import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:correctink/app/services/connectivity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import '../../blocs/app_bar.dart';
import '../../utils/router_helper.dart';
import '../../widgets/snackbars_widgets.dart';
import '../data/app_services.dart';
import '../data/repositories/realm_services.dart';
import '../services/notification_service.dart';
import 'create/create_set.dart';
import 'create/create_task.dart';

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
  void initState(){
    super.initState();

    NotificationService.onNotifications.stream.listen(notificationClicked);
    BackButtonInterceptor.add(interceptBackButton);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptBackButton);
    super.dispose();
  }

  void notificationClicked(payload){
    if(payload != null && context.mounted) {
      GoRouter.of(context).push(RouterHelper.buildTaskRoute(payload));
    }
  }

  bool interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info){
    if(!GoRouter.of(context).canPop() && RouterHelper.canGoToPreviousRoute && ![RouterHelper.loginRoute, RouterHelper.signupRoute].contains(GoRouter.of(context).location)) {
      GoRouter.of(context).go(RouterHelper.previousRoute);
      RouterHelper.popPreviousRoute();
      return true;
    }
    return false;
  }

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
    realmServices.changeSyncSession(hasConnection);

    if (kDebugMode) {
      print('connection changed: $hasConnection');

    }
    if(context.mounted) infoMessageSnackBar(context, hasConnection ? 'Online message'.i18n() : 'Offline message'.i18n()).show(context);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      selectedIndex = _calculateSelectedIndex(context);
    });
    return Scaffold(
          appBar: selectedIndex >= -1 ? CorrectInkAppBar(backBtn: backBtn, key: _appBarKey,) : null,
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
                            items: [
                              BottomNavigationBarItem(
                                icon: const Icon(Icons.task_alt_outlined),
                                label: 'Tasks'.i18n(),
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(Icons.folder_outlined),
                                activeIcon: const Icon(Icons.folder),
                                label: 'Sets'.i18n(),
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
                          useIndicator: true,
                          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundColor: Theme.of(context).colorScheme.background,
                          selectedIndex: selectedIndex,
                          minExtendedWidth: 150,
                          onDestinationSelected:(int index) {
                            _onItemTapped(index, context);
                          },
                          destinations: [
                             NavigationRailDestination(
                              icon: const Icon(Icons.task_alt_outlined),
                              selectedIcon: Icon(Icons.task_alt_rounded, color: Theme.of(context).colorScheme.primary,),
                              label: Text('Tasks'.i18n()),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.folder_outlined),
                              selectedIcon: Icon(Icons.folder, color: Theme.of(context).colorScheme.primary,),
                              label: Text('Sets'.i18n()),
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
        (_appBarKey.currentState as CorrectInkAppBarState).update(backBtn);
      });
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).location;
    setState(() {
      backBtn = false;
    });
    updateAppBar();
    if (location.startsWith(RouterHelper.taskLibraryRoute)) {
      if(location.startsWith('${RouterHelper.taskLibraryRoute}/')){
        floatingAction = null;
        setState(() {
          backBtn = true;
        });
        updateAppBar();
        return -1;
      }
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
        GoRouter.of(context).go(RouterHelper.taskLibraryRoute);
        break;
      case 1:
        GoRouter.of(context).go(RouterHelper.setLibraryRoute);
        break;
    }
  }
}