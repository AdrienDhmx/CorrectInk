import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/router_helper.dart';

class CorrectInkAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CorrectInkAppBar({required this.backBtn, Key? key}) : super(key: key);

  final bool backBtn;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => CorrectInkAppBarState();
}

class CorrectInkAppBarState extends State<CorrectInkAppBar>{
  late bool backBtn = widget.backBtn;
  late bool hideBtnSpace = !widget.backBtn;
  final animationDuration = const Duration(milliseconds: 300);

  void update(bool showBtn){
    setState(() {
      backBtn = showBtn;
      if(backBtn) {
        hideBtnSpace = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('CorrectInk'),
      leading: hideBtnSpace ? null : AnimatedSlide(
        duration: animationDuration,
        offset: backBtn ? Offset.zero : const Offset(-1, 0),
        onEnd: () {
          setState(() {
            hideBtnSpace = true;
          });
        },
        child: backButton(context),
      ),
      titleSpacing: hideBtnSpace ?  null : 4,
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
