import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:key_card/main.dart';
import 'package:key_card/theme.dart';
import 'package:provider/provider.dart';

import '../realm/app_services.dart';
import '../realm/realm_services.dart';

class TodoAppBar extends StatelessWidget with PreferredSizeWidget {
  TodoAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      title: const Text('Key Card'),
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.primary,
      elevation: 1,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.color_lens),
          tooltip: themeProvider.theme == 'default'
          ?'blue theme'
          : 'green theme',
          onPressed: () => themeProvider.changeTheme(),
        ),
        IconButton(
          icon: Icon(themeProvider.isDarkMode
              ? Icons.light_mode
              : Icons.dark_mode),
          tooltip: themeProvider.isDarkMode
              ? 'Light mode'
              : 'Dark mode',
          onPressed: () => themeProvider.toggleTheme(),
        ),
        const SizedBox(width: 5.0,),
        IconButton(
          icon: Icon(realmServices.offlineModeOn
              ? Icons.wifi_off_rounded
              : Icons.wifi_rounded),
          tooltip: 'Offline mode',
          onPressed: () async => await realmServices.sessionSwitch(),
        ),
        const SizedBox(width: 5.0,),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Log out',
          onPressed: () async => await logOut(context, realmServices),
        ),
        const SizedBox(width: 10.0,),
      ],
    );
  }

  Future<void> logOut(BuildContext context, RealmServices realmServices) async {
    final appServices = Provider.of<AppServices>(context, listen: false);
    appServices.logOut();
    await realmServices.close();
    if(context.mounted) GoRouter.of(context).go(RouterHelper.loginRoute);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
