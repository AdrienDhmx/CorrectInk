import 'package:correctink/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';

class TodoAppBar extends StatefulWidget with PreferredSizeWidget {
  TodoAppBar({required this.backBtn, Key? key}) : super(key: key);

  final bool backBtn;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => TodoAppBarState();
}

class TodoAppBarState extends State<TodoAppBar>{
  late bool backBtn = widget.backBtn;

  void update(bool showBtn){
    setState(() {
      backBtn = showBtn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('CorrectInk'),
      leading: backBtn ? backButton(context) : null,
      titleSpacing: backBtn ? 4 : null,
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
}
