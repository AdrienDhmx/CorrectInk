import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/components/widgets.dart';
import 'package:correctink/realm/realm_services.dart';
import 'package:correctink/theme.dart';
import 'package:provider/provider.dart';

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
  late AppServices appServices;
  Users? user;

  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();

    themeProvider = Provider.of<ThemeProvider>(context);
    realmServices = Provider.of<RealmServices>(context);
    appServices = Provider.of<AppServices>(context);

    user ??= appServices.currentUserData;
    if(user == null){
      final currentUser = await appServices.getUserData(realmServices.realm);
      setState(() {
        user = currentUser?.freeze();
      });
    } else if(user!.isValid){
      setState(() {
        user = user!.freeze();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    selectedTheme = themeProvider.theme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: backButton(context),
        titleSpacing: 4,
        title: Text('Settings', style: Theme.of(context).textTheme.headlineMedium,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if(appServices.currentUserData != null) Text('You are connected as ', style: Theme.of(context).textTheme.titleMedium,),
            profileInfo(context: context, user: user),
            if(appServices.currentUserData != null && appServices.currentUserData!.studyStreak != 0) Text('study streak: ${appServices.currentUserData!.studyStreak} days'),
            if(appServices.currentUserData != null) TextButton(
                style: flatTextButton(
                  Theme.of(context).colorScheme.surfaceVariant,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () async {
                  GoRouter.of(context).push(RouterHelper.settingsAccountRoute);
                },
                child: iconTextCard(Icons.account_circle_rounded, 'Modify account'),
              ),
            if(appServices.currentUserData != null) Padding(
              padding: const EdgeInsets.all(12.0),
              child: Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
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
                      ? 'Light mode'
                      : 'Dark mode',
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
            TextButton(
              style: flatTextButton(
                Theme.of(context).colorScheme.surfaceVariant,
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () async { 
                realmServices.sessionSwitch();
                infoMessageSnackBar(context, realmServices.offlineModeOn ? 'You are now offline!' : 'You are back online!').show(context);
                },
              child: iconTextCard(realmServices.offlineModeOn ? Icons.wifi_rounded : Icons.wifi_off_rounded, realmServices.offlineModeOn ? 'Go online' : 'Go offline'),
            ),
            const SizedBox(height: 10,),
            TextButton(
              style: flatTextButton(
                Theme.of(context).colorScheme.errorContainer,
                Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () async { await logOut(context, realmServices); },
                child: iconTextCard(Icons.logout, 'Logout'),
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