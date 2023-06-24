import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/components/widgets.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/theme.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../components/snackbars_widgets.dart';
import '../localization.dart';
import '../main.dart';
import '../realm/app_services.dart';
import '../realm/schemas.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>{
  late String selectedTheme;
  late ThemeProvider themeProvider;
  late RealmServices realmServices;
  Users? user;

  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();

    themeProvider = Provider.of<ThemeProvider>(context);
    realmServices = Provider.of<RealmServices>(context);

    user ??= realmServices.usersCollection.currentUserData;
    if(user == null){
      final currentUser = await realmServices.usersCollection.getCurrentUser();
      setState(() {
        user = currentUser?.freeze();
      });
    } else if(user!.isValid){
        user = user!.freeze();
    }
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            profileInfo(context: context, user: user),
            Text('Theme'.i18n(), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  alignment: AlignmentDirectional.topStart,
                  value: selectedTheme,
                    items: [
                      DropdownMenuItem(
                        value: ThemeProvider.themes[0],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(ThemeProvider.themes[0]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeProvider.themes[1],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(ThemeProvider.themes[1]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeProvider.themes[2],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(ThemeProvider.themes[2]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeProvider.themes[3],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(ThemeProvider.themes[3]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeProvider.themes[4],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(ThemeProvider.themes[4]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeProvider.themes[5],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(ThemeProvider.themes[5]),
                        ),
                      ),
                    ],
                    onChanged: (dynamic value) {
                      themeProvider.changeTheme(value.toString());
                      setState(() {
                        selectedTheme = value.toString();
                      });
                     },
                ),
                const SizedBox(width: 12,),
                IconButton(
                  icon: Icon(themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode),
                  tooltip: themeProvider.isDarkMode
                      ? 'Light mode'.i18n()
                      : 'Dark mode'.i18n(),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            Text('Language'.i18n(), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4,),
            DropdownButton(
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            TextButton(
              style: flatTextButton(
                Theme.of(context).colorScheme.surfaceVariant,
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () async { 
                await realmServices.sessionSwitch();
                if(context.mounted) infoMessageSnackBar(context, realmServices.offlineModeOn ? "Offline message".i18n() : "Online message".i18n()).show(context);
                },
              child: iconTextCard(realmServices.offlineModeOn ? Icons.wifi_rounded : Icons.wifi_off_rounded, realmServices.offlineModeOn ? 'Go online'.i18n() : 'Go offline'.i18n()),
            ),
            const SizedBox(height: 10,),
            TextButton(
              style: flatTextButton(
                Theme.of(context).colorScheme.errorContainer,
                Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () async { await logOut(context, realmServices); },
                child: iconTextCard(Icons.logout, 'Logout'.i18n()),
            ),
            const Expanded(child: SizedBox(height: 5,)),
          ],
        ),
      ),
    );
  }

  Future<void> logOut(BuildContext context, RealmServices realmServices) async {
    final appServices = Provider.of<AppServices>(context, listen: false);
    appServices.logOut();
    await realmServices.close();
    if(context.mounted) GoRouter.of(context).go(RouterHelper.loginRoute);
  }
}