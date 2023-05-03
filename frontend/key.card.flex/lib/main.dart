import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:key_card/components/scaffold_navigation_bar.dart';
import 'package:key_card/config.dart';
import 'package:key_card/realm/app_services.dart';
import 'package:key_card/realm/realm_services.dart';
import 'package:key_card/screens/learn_page.dart';
import 'package:key_card/screens/log_in.dart';
import 'package:key_card/screens/set_page.dart';
import 'package:key_card/theme.dart';
import 'package:key_card/screens/set_library_page.dart';
import 'package:key_card/screens/task_library_page.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final realmConfig = json.decode(await rootBundle.loadString('assets/config/atlasConfig.json'));
  String appId = realmConfig['appId'];
  Uri baseUrl = Uri.parse(realmConfig['baseUrl']);

  final AppConfigHandler appConfigHandler = AppConfigHandler();
  await appConfigHandler.init();
  final ThemeProvider themeProvider = ThemeProvider(appConfigHandler);
  await themeProvider.init();

  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppServices>(create: (_) => AppServices(appId, baseUrl)),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider),
    ChangeNotifierProxyProvider<AppServices, RealmServices?>(
        // RealmServices can only be initialized only if the user is logged in.
        create: (context) => null,
        update: (BuildContext context, AppServices appServices, RealmServices? realmServices) {
          return appServices.app.currentUser != null ? RealmServices(appServices.app) : null;
        }),
  ], child: const App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<RealmServices?>(context, listen: false)?.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final GoRouter router = GoRouter(
      initialLocation: currentUser != null ? RouterHelper.taskRoute : RouterHelper.loginRoute,
      redirect: (BuildContext context, GoRouterState state) {
        if(state.location == '/'){
          return RouterHelper.loginRoute;
        } else{
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
              path: RouterHelper.taskRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const TasksView();
              },
            ),
            GoRoute(
              path: RouterHelper.loginRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const LogIn();
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
                if(state.params['setId'] == null){
                  return const SetsLibraryView();
                }
                return LearnPage(state.params['setId']?? '');
              },
            ),
          ],
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async => true,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Key Card',
        theme: themeProvider.lightAppThemeData(),
        darkTheme: themeProvider.darkAppThemeData(),
        themeMode: themeProvider.themeMode,
        routerConfig: router,
      ),
    );
  }
}

class RouterHelper{
  static const String loginRoute = '/login';
  static const String taskRoute = '/tasks';
  static const String setLibraryRoute = '/sets';
  static const String setRoute = '/sets/:setId';
  static const String learnBaseRoute = '/learn/';
  static const String learnRoute = '/learn/:setId';

  static String buildSetRoute(String parameter){
    return '/sets/$parameter';
  }

  static String buildLearnRoute(String parameter){
    return '/learn/$parameter';
  }
}


