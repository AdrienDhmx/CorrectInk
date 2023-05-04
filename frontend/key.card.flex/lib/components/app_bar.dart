import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:key_card/main.dart';

class TodoAppBar extends StatelessWidget with PreferredSizeWidget {
  TodoAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Key Card'),
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.primary,
      elevation: 1,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
            onPressed: () { GoRouter.of(context).push(RouterHelper.settingsRoute); },
            icon: const Icon(Icons.settings),
        ),
        const SizedBox(width: 5,),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
