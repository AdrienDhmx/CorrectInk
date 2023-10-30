import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:correctink/app/data/repositories/collections/users_collection.dart';
import 'package:correctink/app/data/repositories/realm_services.dart';
import 'package:correctink/app/screens/edit/modify_profile.dart';
import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/app/services/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../blocs/sets/set_item.dart';
import '../../utils/delete_helper.dart';
import '../../utils/router_helper.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final int startTab;
  const ProfilePage({super.key, required this.userId, required this.startTab});

  @override
  State<StatefulWidget> createState() => _ProfilePage();

}

class _ProfilePage extends State<ProfilePage> {
  late RealmServices realmServices;
  late UserService? userService;
  late Users user;
  late Color avatarColor;
  late String userInitials;
  late bool isCurrentUser;
  late int? descriptionMaxLine = 3;
  late ColorScheme colorScheme;
  TapGestureRecognizer? originalOwnerTapRecognizer;
  bool init = false;
  List<String> tabs = ["Public sets", "Settings"];

  void updateDescriptionMaxLine(){
    setState(() {
      descriptionMaxLine == 3 ? descriptionMaxLine = null : descriptionMaxLine = 3;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    realmServices = Provider.of(context);
    userService = Provider.of(context);
    if(userService == null) return;

    isCurrentUser = userService!.currentUserData != null && widget.userId == userService!.currentUserData!.userId.hexString;
    user = isCurrentUser ? userService!.currentUserData! : userService!.get(ObjectId.fromHexString(widget.userId))!;

    userInitials = (user.firstname[0] + user.lastname[0]).toUpperCase();
    int index = userInitials[0].codeUnitAt(0) + userInitials[1].codeUnitAt(0);
    index = index % ThemeProvider.setColors.length;
    Color seed = Color.alphaBlend(ThemeProvider.setColors[index], Theme.of(context).colorScheme.primary);
    colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Theme.of(context).brightness);
    avatarColor = colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
      return DefaultTabController(
        length: isCurrentUser ? tabs.length : 1,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Builder(
            builder: (context) {
              if(isCurrentUser) {
                DefaultTabController.of(context).animateTo(widget.startTab);
              }
              init = true;
              return Column(
                children: [
                  Material(
                    elevation: 1,
                    surfaceTintColor: avatarColor.withAlpha(10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: user.about.isNotEmpty ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if(user.role >= UserService.moderator)
                                        BoxShadow(
                                          color: avatarColor,
                                          blurRadius: 6,
                                          spreadRadius: 1.2,
                                          blurStyle: BlurStyle.normal,
                                        )
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: avatarColor.withAlpha(110),
                                    foregroundColor: avatarColor,
                                    radius: 32,
                                    child: Center(child: Text(userInitials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 4,),
                                    Text("${user.firstname} ${user.lastname}",
                                      style: TextStyle(fontSize: 18, color: colorScheme.onPrimaryContainer),
                                    ),
                                    if(user.about.isNotEmpty) ...[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: AutoSizeText(
                                          user.about,
                                          maxLines: 3,
                                          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant.withAlpha(220)),
                                          maxFontSize: 14,
                                          minFontSize: 12,
                                          overflowReplacement: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              splashFactory: InkRipple.splashFactory,
                                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                                              splashColor: avatarColor.withAlpha(60),
                                              onTap: (){
                                                updateDescriptionMaxLine();
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(4, 4, 2, 4),
                                                child: Text(user.about, style:
                                                  TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(220)),
                                                    maxLines: descriptionMaxLine, overflow: TextOverflow.fade,),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TabBar(
                          indicatorColor: avatarColor,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: avatarColor,
                            dividerColor: avatarColor,
                            overlayColor: MaterialStatePropertyAll<Color>(
                              avatarColor.withAlpha(30)
                            ),
                            splashFactory: InkSplash.splashFactory,
                            tabs: [
                              if(isCurrentUser)
                                for(String tab in tabs)
                                  Tab(
                                    text: tab.i18n(),
                                  )
                              else
                                Tab(
                                  text: tabs[0].i18n(), // public sets
                                )
                          ]
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        UserPublicSetList(userId: user.userId.hexString, realmServices: realmServices, colorScheme: colorScheme,),

                        if(isCurrentUser) ...[
                          Column(
                            children: [
                              if(user.lastStudySession != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text( "Last study session".i18n([user.lastStudySession!.format()])),
                                ),
                              if(user.studyStreak > 1)
                                Text("Current study streak".i18n([user.studyStreak.toString()])),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
                                child: SizedBox(
                                  width: 220,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed:() {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useRootNavigator: true,
                                        useSafeArea: true,
                                        builder: (_) => Wrap(children: [ModifyProfileForm(user: user, userService: userService!,)]),
                                      );
                                    },
                                    style: customTextButtonStyle(context, colorScheme.primary, colorScheme.onPrimary),
                                    child: Text("Modify account".i18n()),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
                                child: SizedBox(
                                  width: 220,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      GoRouter.of(context).go(RouterHelper.loginRoute);
                                      Timer(
                                        const Duration(milliseconds: 200),
                                        () {
                                          realmServices.logout();
                                        }
                                      );
                                    },
                                    style: customTextButtonStyle(context, colorScheme.secondary, colorScheme.onSecondary),
                                    child: Text('Logout'.i18n()),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 22, 0, 6),
                                child: SizedBox(
                                  width: 220,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () => DeleteUtils.deleteAccount(context, realmServices),
                                    style: customTextButtonStyle(context, colorScheme.error, colorScheme.onError),
                                    child: Text("Delete account confirmation title".i18n()),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ]

                      ],
                    ),
                  )
                ],
              );
            }
          ),
        ),
      );
  }
}

class UserPublicSetList extends StatelessWidget {
  final ScrollController scrollController = ScrollController();
  final RealmServices realmServices;
  final String userId;
  final ColorScheme colorScheme;

  UserPublicSetList({super.key, required this.userId, required this.realmServices, required this.colorScheme});

  RealmResults<CardSet> buildQuery(Realm realm){
    String query = r"is_public = true && owner_id = $0 && cards.@count > 0";
    return realm.query<CardSet>(query, [userId]);
  }

  @override
  Widget build(BuildContext context) {
    return  Material(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: StreamBuilder<RealmResultsChanges<CardSet>>(
          stream: buildQuery(realmServices.realm).changes,
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (data == null) return waitingIndicator();

            final results = data.results;
            return results.isNotEmpty ? Scrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(0, 0, 0, 18) : const EdgeInsets.fromLTRB(0, 0, 0, 60),
                itemCount: results.realm.isClosed ? 0 : results.length,
                itemBuilder: (context, index) => results[index].isValid
                    ? SetItem(results[index], border: index != results.length - 1, publicSets: true,)
                    : null,
              ),
            ): Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: Text("There are no public sets".i18n(), textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.primary, fontSize: 18)
              ),
            );
          },
        ),
      ),
    );
  }

}