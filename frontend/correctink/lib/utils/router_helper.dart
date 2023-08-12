class RouterHelper{
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String taskLibraryRoute = '/tasks';
  static const String taskRoute = '$taskLibraryRoute/:taskId';
  static const String setLibraryRoute = '/sets';
  static const String setRoute = '$setLibraryRoute/:setId';
  static const String learnBaseRoute = '/learn/';
  static const String learnRoute = '/learn/:setId&:learningMode';
  static const String learnSetSettingsRoute = '/learn/settings/:setId';
  static const String settingsRoute = '/settings';
  static const String settingsAccountRoute = '/settings/account';

  static final List<String> _previousRoute = <String>['/'];
  static String get previousRoute => _previousRoute.last;

  static updatePreviousRoute(String route){
    _previousRoute.add(route);

    if(_previousRoute.length > 10) {
      _previousRoute.removeAt(0);
    }
  }

  static popPreviousRoute(){
    _previousRoute.removeLast();
  }

  static String buildSetRoute(String parameter){
    return '$setLibraryRoute/$parameter';
  }

  static String buildLearnRoute(String setId, String learningMode){
    return '/learn/$setId&$learningMode';
  }

  static String buildTaskRoute(String parameter){
    return '$taskLibraryRoute/$parameter';
  }

  static String buildLearnSetSettingsRoute(String parameter){
    return '/learn/settings/$parameter';
  }
}