import 'package:correctink/app/services/inbox_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/router_helper.dart';
import '../widgets/buttons.dart';

class CorrectInkAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CorrectInkAppBar({required this.backBtn, required this.hasDrawer, required this.toggleDrawer, Key? key}) : super(key: key);

  final bool backBtn;
  final bool hasDrawer;
  final void Function() toggleDrawer;

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
    InboxService? inboxService = Provider.of(context);

    return AppBar(
      title: Row(
        children: [
          if(widget.hasDrawer && !hideBtnSpace)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimatedOpacity(
                opacity: backBtn ? 1 : 0,
                duration: animationDuration,
                onEnd: () {
                  setState(() {
                    hideBtnSpace = true;
                  });
                },
                child: backButton(context),
              ),
            ),
          const Text('CorrectInk', style: TextStyle(fontWeight: FontWeight.w500),),
        ],
      ),
      leading: widget.hasDrawer
          ? IconButton(onPressed: widget.toggleDrawer,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              visualDensity: VisualDensity.standard,
              icon: const Icon(Icons.menu_rounded),
            )
          : hideBtnSpace ? null :
              AnimatedSlide(
                duration: animationDuration,
                offset: backBtn ? Offset.zero : const Offset(-1, 0),
                onEnd: () {
                  setState(() {
                    hideBtnSpace = true;
                  });
                },
                child: backButton(context),
              ),
      scrolledUnderElevation: 1,
      titleSpacing: widget.hasDrawer ? 0 : hideBtnSpace ? null : 0,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Theme.of(context).colorScheme.primary,
      elevation: 1,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        if(inboxService != null)
          AnimatedOpacity(
            opacity: GoRouter.of(context).location.startsWith(RouterHelper.inboxRoute) ? 0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              onPressed: () {
                  GoRouter.of(context).push(RouterHelper.inboxRoute);
                },
              icon: Icon(inboxService.unreadMessagesCount == 0 && inboxService.inbox.reports.where((report) => !report.resolved).isEmpty
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
              ),
              color: inboxService.inbox.reports.where((report) => !report.resolved).isNotEmpty
                      ? Theme.of(context).colorScheme.error
                      : inboxService.unreadMessagesCount == 0
                            ? Theme.of(context).colorScheme.onBackground
                            : Theme.of(context).colorScheme.primary
            ),
          ),
        const SizedBox(width: 5,),
        IconButton(
          onPressed: () { GoRouter.of(context).push(RouterHelper.settingsRoute); },
          icon: const Icon(Icons.settings),
        ),
        const SizedBox(width: 5,),
      ],
    );
  }
}
