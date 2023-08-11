import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../widgets/snackbars_widgets.dart';
import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';
import '../services/localization.dart';
import '../services/theme.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>{
  late String selectedTheme;
  late ThemeProvider themeProvider;
  late RealmServices realmServices;
  late List<ColorScheme> colorSchemes;
  late double colorSchemesWidth;
  final double colorSchemesMaxWidth = 120;
  late ScrollController colorSchemesController;
  late StreamSubscription stream;
  late bool streamInit = false;
  Users? user;

  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();

    themeProvider = Provider.of<ThemeProvider>(context);
    realmServices = Provider.of<RealmServices>(context);

    colorSchemes = <ColorScheme>[];
    for(int i = 0; i < ThemeProvider.themes.length; i++){
      colorSchemes.add(themeProvider.getColorSchemeFromSeed(ThemeProvider.themeColors[i]));
    }

    // scroll to selected colorScheme if needed
    final maxWidth = MediaQuery.of(context).size.width;
    colorSchemesWidth = maxWidth / 5;
    colorSchemesWidth = colorSchemesWidth < 90 ? 90 : colorSchemesWidth;

    // if bigger it has all the space it needs to render
    final bool needInitScrollOffset = colorSchemesWidth < colorSchemesMaxWidth;
    double initScrollOffset = 0;
    if(needInitScrollOffset){
      final selectedThemeIndex = ThemeProvider.themes.indexOf(themeProvider.theme);
      // there are 2 rows of themes in the grid and only 10 themes
      if(selectedThemeIndex > ThemeProvider.themes.length / 2) {
        // find by how much it's overflowing and scroll to that amount (to the end of the scroll extent)
        initScrollOffset = (colorSchemesWidth + 10) * 5 - maxWidth;
      }
    } else {
      colorSchemesWidth = colorSchemesMaxWidth; // max width of the colorScheme
    }

    colorSchemesController = ScrollController(initialScrollOffset: initScrollOffset);

    user ??= realmServices.usersCollection.currentUserData;
    if(user == null){
      final currentUser = await realmServices.usersCollection.getCurrentUser();
      setState(() {
        user = currentUser;
      });
    }

    if(!streamInit){
      stream = user!.changes.listen((event) {
        setState(() {
          user = event.object;
        });
      });
    }
  }

  @override
  void dispose(){
    super.dispose();
    stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    LocalizationProvider localizationProvider = Provider.of<LocalizationProvider>(context);
    selectedTheme = themeProvider.theme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: backButton(context),
        titleSpacing: 4,
        title: Text('Settings'.i18n(), style: Theme.of(context).textTheme.headlineMedium,),
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          colorSchemesWidth = constraint.maxWidth / 5;
          colorSchemesWidth = colorSchemesWidth < 90 ? 90 : colorSchemesWidth;
          colorSchemesWidth = colorSchemesWidth > 140 ? 140 : colorSchemesWidth;

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            primary: false,
            children: [
              profileInfo(context: context, user: user),
              Center(child: Text('Theme'.i18n(), style: Theme.of(context).textTheme.titleMedium)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 18),
                child: TextButton(
                  style: flatTextButton(
                    Theme.of(context).colorScheme.secondaryContainer,
                    Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  onPressed: () { themeProvider.toggleTheme(); },
                  child: iconTextCard(
                    themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      themeProvider.isDarkMode
                          ? 'Light mode'.i18n()
                          : 'Dark mode'.i18n(),
                  ),
                ),
              ),
              SizedBox(
                height: (colorSchemesWidth + 10) * 2,
                child: Center(
                  child: GridView.count(
                    crossAxisCount: 2,
                    controller: colorSchemesController,
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    scrollDirection: Axis.horizontal,
                    children: [
                      for(int i =0; i < ThemeProvider.themeColors.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Tooltip(
                            message: ThemeProvider.themes[i],
                            waitDuration: const Duration(milliseconds: 800),
                            child: colorDisplay(
                              color: colorSchemes[i].primary,
                              selected: selectedTheme == ThemeProvider.themes[i],
                              secondaryColor: colorSchemes[i].secondaryContainer,
                              tertiaryColor: colorSchemes[i].tertiaryContainer,
                              background: colorSchemes[i].primaryContainer.withAlpha(40),
                              foreground: colorSchemes[i].onPrimary.withAlpha(140),
                              onPressed: () => setState(() {
                                themeProvider.changeTheme(ThemeProvider.themes[i]);
                              }),
                              size: colorSchemesWidth,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              Center(child: Text('Language'.i18n(), style: Theme.of(context).textTheme.titleMedium)),
              const SizedBox(height: 4,),
              Center(
                child: DropdownButton(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  alignment: AlignmentDirectional.topStart,
                  value: localizationProvider.localeFriendly,
                  items: [
                    DropdownMenuItem(
                      value: LocalizationProvider.friendlySupportedLocales[0],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(LocalizationProvider.friendlySupportedLocales[0]),
                      ),
                    ),
                    DropdownMenuItem(
                      value: LocalizationProvider.friendlySupportedLocales[1],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(LocalizationProvider.friendlySupportedLocales[1]),
                      ),
                    ),
                  ],
                  onChanged: (dynamic value) {
                    localizationProvider.changeLocalizationFromFriendly(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: TextButton(
                  style: flatTextButton(
                    Theme.of(context).colorScheme.surfaceVariant,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    await realmServices.toggleSyncSession();
                    if(context.mounted) infoMessageSnackBar(context, realmServices.offlineModeOn ? "Offline message".i18n() : "Online message".i18n()).show(context);
                    },
                  child: iconTextCard(realmServices.offlineModeOn ? Icons.wifi_rounded : Icons.wifi_off_rounded, realmServices.offlineModeOn ? 'Go online'.i18n() : 'Go offline'.i18n()),
                ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: TextButton(
                  style: flatTextButton(
                    Theme.of(context).colorScheme.errorContainer,
                    Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    onPressed: () async { await logOut(context, realmServices); },
                    child: iconTextCard(Icons.logout, 'Logout'.i18n()),
                ),
              ),
            ]
          );
        }
      ),
    );
  }

  Future<void> logOut(BuildContext context, RealmServices realmServices) async {
    realmServices.logout();
    GoRouter.of(context).go(RouterHelper.loginRoute);
  }
}