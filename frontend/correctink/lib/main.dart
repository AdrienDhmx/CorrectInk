import 'package:back_button_interceptor/back_button_interceptor.dart';
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
import 'app/services/config.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/localization.dart';
import 'app/services/notification_service.dart';
import 'app/services/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ask for notification permission if not already given
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  // init user preferences
  final AppConfigHandler appConfigHandler = AppConfigHandler();
  await appConfigHandler.init();

  // init connectivity listener
  final connectivityService = ConnectivityService.getInstance();
  connectivityService.init();

  // init realm => database access
  final realmConfig = json.decode(await rootBundle.loadString('assets/config/atlasConfig.json'));
  String appId = realmConfig['appId'];
  Uri baseUrl = Uri.parse(realmConfig['baseUrl']);

  final ThemeProvider themeProvider = ThemeProvider(appConfigHandler);
  await themeProvider.init();

  final LocalizationProvider localizationProvider = LocalizationProvider(appConfigHandler);

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
      redirect: (BuildContext context, GoRouterState state) => RouterHelper.redirect(context, state, themeProvider, localizationProvider),
      routes: RouterHelper.routes,
    );

    void notificationClicked(payload){
      if(payload != null && context.mounted) {
        router.pushReplacement(RouterHelper.buildTaskRoute(payload));
      }
    }

    bool interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info){
      if(router.location == RouterHelper.settingsRoute && RouterHelper.redirected) {
        router.go(RouterHelper.taskLibraryRoute);
        return true;
      } else if(!router.canPop() && ![RouterHelper.loginRoute, RouterHelper.signupRoute].contains(router.location)) {
        router.go(RouterHelper.taskLibraryRoute);
        return true;
      }
      return false;
    }

    BackButtonInterceptor.removeAll(); // remove the previous callback to add a new one
    NotificationService.onNotifications.stream.listen(notificationClicked);
    BackButtonInterceptor.add(interceptBackButton);

    return WillPopScope(
      onWillPop: () async {
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
        localeResolutionCallback: (locale, supportedLocales) => localizationProvider.localeResolutionCallback(locale, supportedLocales),
        locale: LocalizationProvider.locale,

        routerConfig: router,
      ),
    );
  }
}


