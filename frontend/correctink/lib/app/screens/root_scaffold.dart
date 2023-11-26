import 'dart:async';

import 'package:correctink/app/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import '../../blocs/app_bar.dart';
import '../../utils/router_helper.dart';
import '../../widgets/snackbars_widgets.dart';
import '../data/app_services.dart';
import '../data/repositories/realm_services.dart';
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
  bool floatingButtonVisible = true;
  final floatingButtonAnimationDuration = const Duration(milliseconds: 200);
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
    realmServices.changeSyncSession(hasConnection);
    if(context.mounted) {
      infoMessageSnackBar(context, hasConnection ? 'Online message'.i18n() : 'Offline message'.i18n()).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      selectedIndex = _calculateSelectedIndex(context);
    });
    return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: selectedIndex >= -1 ? CorrectInkAppBar(backBtn: backBtn, key: _appBarKey,) : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: AnimatedSlide(
                duration: floatingButtonAnimationDuration,
                curve: Curves.easeInOut,
                offset: floatingButtonVisible ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                    duration: floatingButtonAnimationDuration,
                    opacity: floatingButtonVisible ? 1 : 0,
                    curve: Curves.easeInOut,
                    child: floatingAction
                )
            ),
            bottomNavigationBar: constraints.maxWidth <= 450 && selectedIndex >= 0
                ? BottomNavigationBar(
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
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_outline_rounded),
                      activeIcon: const Icon(Icons.person_rounded),
                      label: 'Profile'.i18n(),
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (int idx) => _onItemTapped(idx, context),
                )
                : null,
            body: selectedIndex <= -1
                ? Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: widget.child
                )
                : Row(
              children: [
                if(constraints.maxWidth > 450)
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
                        NavigationRailDestination(
                          icon: const Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary,),
                          label: Text('Profile'.i18n()),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                    child: NotificationListener<UserScrollNotification>(
                        onNotification: (notification) {
                          if(floatingAction != null && notification.metrics.maxScrollExtent > 0){
                            setState(() {
                              floatingButtonVisible = notification.metrics.pixels < notification.metrics.maxScrollExtent / 2;
                            });
                          }
                          return true;
                        },
                        child: widget.child
                    )
                ),
              ],
            ),
          );
        }
    );
  }

  void updateAppBar(){
    if(_appBarKey.currentState != null){
      setState(() {
        (_appBarKey.currentState as CorrectInkAppBarState).update(backBtn);
      });
    }
  }

  int showBackBtn() {
    floatingAction = null;
    setState(() {
      backBtn = true;
    });
    updateAppBar();
    return -1;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).location;
    setState(() {
      backBtn = false;
    });
    updateAppBar();

    if (location.startsWith(RouterHelper.taskLibraryRoute)) {
      if(location.startsWith('${RouterHelper.taskLibraryRoute}/')){
        return showBackBtn();
      }
      floatingAction = const CreateTaskAction();
      return 0;
    } else  if (location.startsWith(RouterHelper.setLibraryRoute)) {
      if(location.startsWith('${RouterHelper.setLibraryRoute}/')){
        return showBackBtn();
      }
      floatingAction = const CreateSetAction();
      return 1;
    } else  if (location.startsWith(RouterHelper.profileBaseRoute)) {
      showBackBtn();
      return 2;
    } else  if (location.startsWith(RouterHelper.inboxRoute)) {
      return showBackBtn();
    }

    floatingAction = null;
    return -2;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go(RouterHelper.taskLibraryRoute);
        setState(() {
          floatingButtonVisible = true;
        });
        break;
      case 1:
        GoRouter.of(context).go(RouterHelper.setLibraryRoute);
        setState(() {
          floatingButtonVisible = true;
        });
        break;
      case 2:
        if(realmServices.userService.currentUserData ==  null) {
          errorMessageSnackBar(context, "Error".i18n(), "You don't seem to be logged in correctly, try to restart the app and if the problem persist try to logout and log back in.").show(context);
        } else {
          GoRouter.of(context).go(RouterHelper.buildProfileRoute(realmServices.userService.currentUserData!.userId.hexString));
          setState(() {
            floatingButtonVisible = false;
          });
        }
        break;
    }
  }
}