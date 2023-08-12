import 'package:correctink/app/screens/signup.dart';
import 'package:correctink/utils/router_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'app/data/app_services.dart';
import 'app/data/repositories/realm_services.dart';
import 'app/screens/learn_page.dart';
import 'app/screens/log_in.dart';
import 'app/screens/root_scaffold.dart';
import 'app/screens/set_library_page.dart';
import 'app/screens/set_page.dart';
import 'app/screens/set_settings_page.dart';
import 'app/screens/settings_account_page.dart';
import 'app/screens/settings_page.dart';
import 'app/screens/task_library_page.dart';
import 'app/screens/task_page.dart';
import 'app/services/config.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/localization.dart';
import 'app/services/notification_service.dart';
import 'app/services/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  final AppConfigHandler appConfigHandler = AppConfigHandler();
  await appConfigHandler.init();

  // listen to connectivity changes
  final connectivityService = ConnectivityService.getInstance();
  connectivityService.init();

  if (kDebugMode) {
    print('[INFO] connected: ${connectivityService.hasConnection}');
  }

  final realmConfig = json.decode(await rootBundle.loadString('assets/config/atlasConfig.json'));
  String appId = realmConfig['appId'];
  Uri baseUrl = Uri.parse(realmConfig['baseUrl']);

  final ThemeProvider themeProvider = ThemeProvider(appConfigHandler);
  await themeProvider.init();

  final LocalizationProvider localizationProvider = LocalizationProvider(appConfigHandler);

  // init notifications
  await NotificationService.init(initScheduled: true);

  return runApp(MultiProvider(providers: [
    Provider<AppConfigHandler>(create: (_) => appConfigHandler),
    ChangeNotifierProvider<AppServices>(create: (_) => AppServices(appId, baseUrl)),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider),
    ChangeNotifierProvider<LocalizationProvider>(create: (_) => localizationProvider),
    ChangeNotifierProxyProvider<AppServices, RealmServices?>(
        // RealmServices can only be initialized only if the user is logged in.
        create: (context) => null,
        update: (BuildContext context, AppServices appServices, RealmServices? realmServices) {
          if(appServices.app.currentUser != null){
            realmServices ??= RealmServices(appServices, !connectivityService.hasConnection);

            if (kDebugMode) {
              print('[INFO] Realm initialized!');
            }
            if(appServices.registered && appServices.currentUserData != null){ // the user just registered
              realmServices.usersCollection.registerUserData(userData: appServices.currentUserData); // save the user data in the database
              if (kDebugMode) {
                print('[INFO] User Registered!');
              }

            } else if(realmServices.usersCollection.currentUserData == null){ // user logged in but data not fetched or deleted
              realmServices.usersCollection.getCurrentUser();
            }

            return realmServices;
          }
          return null;
        }),
  ], child: const App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['assets/i18n/'];

    final currentUser = Provider.of<RealmServices?>(context, listen: false)?.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);

    final GoRouter router = GoRouter(
      initialLocation: currentUser != null ? RouterHelper.taskLibraryRoute : RouterHelper.loginRoute,
      redirect: (BuildContext context, GoRouterState state) {
        if(GoRouter.maybeOf(context) != null) {
          // save previous (current) page
          RouterHelper.updatePreviousRoute(GoRouter.of(context).location);
        }

        if(state.location == '/'){
          return RouterHelper.loginRoute;
        } else if(state.location == RouterHelper.taskLibraryRoute && (themeProvider.themeChanged || localizationProvider.languageChanged)) {
          // when changing the theme the app pop the context
          themeProvider.themeChanged = false;
          return RouterHelper.settingsRoute;
        } else {
          return null;
        }
      },
      routes: <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child){
            return ScaffoldNavigationBar(child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: RouterHelper.taskLibraryRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const TasksView();
              },
            ),
            GoRoute(
              path: RouterHelper.taskRoute,
              builder: (BuildContext context, GoRouterState state) {
                if(state.params['taskId'] == null){
                  return const TasksView();
                }
                return TaskPage(state.params['taskId']?? '');
              },
            ),
            GoRoute(
              path: RouterHelper.loginRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const LogIn();
              },
            ),
            GoRoute(
              path: RouterHelper.signupRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const Signup();
              },
            ),
            GoRoute(
              path: RouterHelper.settingsRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsPage();
              },
            ),
            GoRoute(
              path: RouterHelper.settingsAccountRoute,
              builder: (BuildContext context, GoRouterState state) {
                  return const SettingsAccountPage();
              },
            ),
            GoRoute(
              path: RouterHelper.setLibraryRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const SetsLibraryView();
              },
            ),
            GoRoute(
              path: RouterHelper.setRoute,
              builder: (BuildContext context, GoRouterState state) {
                if(state.params['setId'] == null)
                {
                  return const SetsLibraryView();
                }
                return SetPage(state.params['setId']?? '');
              },
            ),
            GoRoute(
              path: RouterHelper.learnRoute,
              builder: (BuildContext context, GoRouterState state) {
                if(state.params['setId'] == null || state.params['learningMode'] == null){
                  return const SetsLibraryView();
                }
                return LearnPage(state.params['setId']?? '', state.params['learningMode']?? '');
              },
            ),
            GoRoute(
              path: RouterHelper.learnSetSettingsRoute,
              builder: (BuildContext context, GoRouterState state) {
                if(state.params['setId'] == null){
                  return const SetsLibraryView();
                }
                return SetSettingsPage(set: state.params['setId']?? '');
              },
            ),
          ],
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        if(themeProvider.themeChanged || localizationProvider.languageChanged) {
          GoRouter.of(context).go(RouterHelper.previousRoute);
          RouterHelper.popPreviousRoute();
          return false;
        }
        return true;
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'CorrectInk',
        // theme
        theme: themeProvider.lightAppThemeData(),
        darkTheme: themeProvider.darkAppThemeData(),
        themeMode: themeProvider.themeMode,
        // localization
        localizationsDelegates: localizationProvider.localizationsDelegates,
        supportedLocales: localizationProvider.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) =>
            localizationProvider.localeResolutionCallback(locale, supportedLocales),
        locale: LocalizationProvider.locale,
        routerConfig: router,
      ),
    );
  }
}


