import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:key_card/components/widgets.dart';
import 'package:key_card/realm/realm_services.dart';
import 'package:key_card/theme.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../realm/app_services.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPage();

}

class _SettingsPage extends State<SettingsPage>{
  late String selectedTheme;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final realm = Provider.of<RealmServices>(context);
    selectedTheme = themeProvider.theme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: backButton(context),
        title: Text('Settings', style: Theme.of(context).textTheme.headlineMedium,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 4,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton(
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
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                realm.sessionSwitch();
                infoMessageSnackBar(context, realm.offlineModeOn ? 'You are now offline!' : 'You are back online!').show(context);
                },
              child: iconTextCard(realm.offlineModeOn ? Icons.wifi_rounded : Icons.wifi_off_rounded, realm.offlineModeOn ? 'Go online' : 'Go offline'),
            ),
            const SizedBox(height: 10,),
            TextButton(
              style: flatTextButton(
                Theme.of(context).colorScheme.errorContainer,
                Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () async { await logOut(context, realm); },
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