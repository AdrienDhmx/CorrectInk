import 'package:correctink/app/screens/error_page.dart';
import 'package:correctink/app/screens/inbox_message_page.dart';
import 'package:correctink/app/screens/inbox_page.dart';
import 'package:correctink/app/screens/learn/cards_carousel.dart';
import 'package:correctink/app/screens/profile_page.dart';
import 'package:correctink/app/screens/reset_password_page.dart';
import 'package:correctink/app/services/localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../app/screens/set_page.dart';
import '../app/screens/set_settings_page.dart';
import '../app/screens/settings_page.dart';
import '../app/screens/signup.dart';
import '../app/screens/task_library_page.dart';
import '../app/screens/task_page.dart';
import '../app/screens/learn_page.dart';
import '../app/screens/log_in.dart';
import '../app/screens/root_scaffold.dart';
import '../app/screens/set_library_page.dart';
import '../app/services/theme.dart';

class RouterHelper{
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String resetPasswordRoute = '/resetPassword';
  static const String taskLibraryRoute = '/tasks';
  static const String taskRoute = '$taskLibraryRoute/:taskId';
  static const String setLibraryRoute = '/sets';
  static const String setRoute = '$setLibraryRoute/:setId';
  static const String learnBaseRoute = '/learn';
  static const String learnRoute = '/learn/:setId&:learningMode';
  static const String learnCarouselRoute = '/learn/carousel/:setId&:startIndex';
  static const String learnSetSettingsRoute = '/learn/settings/:setId';
  static const String settingsRoute = '/settings';
  static const String settingsAccountRoute = '/settings/account';
  static const String inboxRoute = '/inbox';
  static const String inboxMessageRoute = '/inbox/:messageId&:isUserMessage&:isReportMessage';
  static const String profileBaseRoute = '/profile';
  static const String profileRoute = '/profile/:userId&:startTab';
  static const String pageNotFoundRoute = '/404';


  static List<RouteBase>? _routes;
  static List<RouteBase> get routes => _routes ?? _getRoutes();

  static bool redirected = false;
  static bool _redirectedRoute = false;

  static String buildSetRoute(String parameter){
    return '$setLibraryRoute/$parameter';
  }

  static String buildLearnRoute(String setId, String learningMode){
    return '$learnBaseRoute/$setId&$learningMode';
  }

  static String buildLearnCarouselRoute(String setId, String startIndex){
    return '$learnBaseRoute/Carousel/$setId&$startIndex';
  }

  static String buildTaskRoute(String parameter){
    return '$taskLibraryRoute/$parameter';
  }

  static String buildProfileRoute(String userId, {String? startTab}){
    startTab ??= '0';
    return '$profileBaseRoute/$userId&$startTab';
  }

  static String buildInboxMessageRoute(String parameter, bool isUserMessage, {bool isReportMessage = false}){
    return '$inboxRoute/$parameter&$isUserMessage&$isReportMessage';
  }

  static String buildLearnSetSettingsRoute(String parameter){
    return '/learn/settings/$parameter';
  }

  static List<RouteBase> _getRoutes(){
    _routes = <RouteBase>[
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
              path: RouterHelper.resetPasswordRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const ResetPassword();
              },
            ),
            GoRoute(
              path: RouterHelper.profileRoute,
              builder: (BuildContext context, GoRouterState state) {
                int startTab = int.parse(state.params['startTab'] ?? '0');
                return ProfilePage(userId: state.params['userId'] ?? '', startTab: startTab,);
              },
            ),
            GoRoute(
              path: RouterHelper.inboxRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const InboxPage();
              },
            ),
            GoRoute(
              path: RouterHelper.inboxMessageRoute,
              builder: (BuildContext context, GoRouterState state) {
                String messageId = state.params['messageId']?? '';
                bool isUserMessage = bool.parse(state.params['isUserMessage']?? '0', caseSensitive: false);
                bool isReportMessage = bool.parse(state.params['isReportMessage'] ?? '0', caseSensitive: false);
                return InboxMessagePage(messageId: messageId, userMessage: isUserMessage, isReportMessage: isReportMessage);
              },
            ),
            GoRoute(
              path: RouterHelper.settingsRoute,
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsPage();
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
                return SetPage(state.params['setId']?? '');
              },
            ),
            GoRoute(
              path: RouterHelper.learnRoute,
              builder: (BuildContext context, GoRouterState state) {
                return LearnPage(state.params['setId']?? '', state.params['learningMode']?? '');
              },
            ),
            GoRoute(
              path: RouterHelper.learnCarouselRoute,
              builder: (BuildContext context, GoRouterState state) {
                int startIndex = int.parse(state.params['startIndex']?? '0');
                return CardsCarouselPage(state.params['setId']?? '', startIndex);
              },
            ),
            GoRoute(
              path: RouterHelper.learnSetSettingsRoute,
              builder: (BuildContext context, GoRouterState state) {
                return SetSettingsPage(set: state.params['setId']?? '');
              },
            ),
            GoRoute(
              path: RouterHelper.pageNotFoundRoute,
              builder: (BuildContext context, GoRouterState state) {
                return ErrorPage(errorDescription: "Page not found !".i18n(), tips: const <String>[],);
              },
            ),
          ]
      )
    ];
    return _routes!;
  }

  static redirect(BuildContext context, GoRouterState state, ThemeProvider themeProvider, LocalizationProvider localizationProvider) {
     if(state.location == '/') {
        return RouterHelper.loginRoute;
     } else if(state.location == RouterHelper.taskLibraryRoute && (themeProvider.themeChanged || localizationProvider.languageChanged)) {
        themeProvider.themeChanged = false;
        localizationProvider.languageChanged = false;
        // when changing the theme or the language, the app pop the context and lose all the route history
        // redirecting to the settings to make it looks like nothing happened to the user
        redirected = true;
        _redirectedRoute = true;
        return RouterHelper.settingsRoute;
     } else {
       if(!_redirectedRoute) {
         redirected = false;
       } else {
         _redirectedRoute = false;
       }
        return null;
     }
  }
}