import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/main.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../blocs/sets/card_list.dart';
import '../../utils/learn_utils.dart';
import '../../utils/utils.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/snackbars_widgets.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';
import '../services/theme.dart';
import 'create/create_card.dart';
import 'edit/modify_set.dart';

class SetPage extends StatefulWidget{

  final String id;

  const SetPage(this.id, {super.key});

  @override
  State<StatefulWidget> createState() => _SetPage();

}

class _SetPage extends State<SetPage> {
  double get learningButtonWidth => Utils.isOnPhone() ? 350 : 500;
  static const double learningButtonHeight = 40;
  late RealmServices realmServices;
  late CardSet? set;
  late Users? setOwner;
  late String ownerText;
  late int? descriptionMaxLine = 4;
  late bool extendLearningMenu = false;
  late StreamSubscription stream;
  late double arrowAngle = 0;
  bool streamInit = false;
  TapGestureRecognizer? originalOwnerTapRecognizer;

  void updateDescriptionMaxLine(){
    setState(() {
      descriptionMaxLine == 4 ? descriptionMaxLine = null : descriptionMaxLine = 4;
    });
  }


  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    realmServices = Provider.of<RealmServices>(context);
    set = realmServices.setCollection.get(widget.id);

    setOwner = null;
    if(set == null || !set!.isValid){
      set = realmServices.setCollection.get(widget.id);

      if(set == null || !set!.isValid){
        errorMessageSnackBar(context, "Error", "The set could not be fetched correctly, try again later !").show(context);
        GoRouter.of(context).pop();
      }
    }

    if(!streamInit){
      stream = set!.changes.listen((event) {
        setState(() {
          set = event.object;
        });
      });
    }

    if(setOwner == null && set!.owner!.userId.hexString != realmServices.currentUser!.id || set!.originalOwner != null){
      // the set is not saved by the user, therefor the original owner is not set
      if(set!.originalOwner == null){
        setState(() {
          ownerText = '${set!.owner!.firstname} ${set!.owner!.lastname}';
        });      } else {
        setState(() {
          ownerText = '${set!.originalOwner!.firstname} ${set!.originalOwner!.lastname}';
        });
      }

        originalOwnerTapRecognizer = TapGestureRecognizer()..onTap = goToOriginalSet;
    }
  }

  @override
  void dispose(){
    super.dispose();
    stream.cancel();
    originalOwnerTapRecognizer?.dispose();
  }

  void goToOriginalSet() async{
      String error = "Error offline sets".i18n();
      if(realmServices.offlineModeOn){
        errorMessageSnackBar(context, 'Error'.i18n(), error).show(context);
        return;
      }

      if(set!.originalSet != null && set!.originalSet!.isPublic){
          if(context.mounted) GoRouter.of(context).push(RouterHelper.buildSetRoute(set!.originalSet!.id.hexString));
          return;
      } else {
        error = 'Error navigate set'.i18n();
      }

      if(context.mounted) errorMessageSnackBar(context, 'Error'.i18n(), error).show(context);
  }

  @override
  Widget build(BuildContext context) {
    if(set == null || !set!.isValid || set!.owner == null){
        return Container(
          color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.error, 5),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Error".i18n(), style: errorTextStyle(context, bold: true)),
              const SizedBox(height: 8,),
              Text("Error set null".i18n(), textAlign: TextAlign.center, style: errorTextStyle(context)),
              const SizedBox(height: 12,),
              Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18,),
                      const SizedBox(width: 8,),
                      Flexible(child: Text("Error set null tip".i18n(), textAlign: TextAlign.start, style: errorTextStyle(context))),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
    }

    int totalKnowCount = 0;
    int totalDontKnowCount = 0;
    (totalKnowCount, totalDontKnowCount) = LearnUtils.getRatio(set!.cards);

    Color progressColor = LearnUtils.getBoxColor(LearnUtils.getMeanBox(set!.cards));
    Color setColor = set!.color != null ? HexColor.fromHex(set!.color!) : Theme.of(context).colorScheme.surface;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: set!.owner!.userId.hexString != realmServices.currentUser!.id
         ? styledFloatingButton(context,
              onPressed: () async {
                // GoRouter.of(context).pop();
                final newSetId = await realmServices.setCollection.copyToCurrentUser(set!);
                if(context.mounted){
                  infoMessageSnackBar(context, "Set saved message".i18n()).show(context);
                  GoRouter.of(context).push(RouterHelper.buildSetRoute(newSetId.hexString));
                }
              },
              icon: Icons.save_rounded,
              tooltip: 'Save set'.i18n(),
          )
         : styledFloatingButton(context,
            onPressed: () => {
              if(realmServices.currentUser!.id == set!.owner!.userId.hexString){
                showModalBottomSheet(isScrollControlled: true,
                context: context,
                builder: (_) => Wrap(children: [CreateCardForm(set!.id)]))
              } else {
                errorMessageSnackBar(context, "Error action not allowed".i18n(),
                "Error add cards".i18n()
                ).show(context)
              }
          }, tooltip: 'Add card'.i18n()),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraint) {
          return BottomAppBar(
            height: 45,
            shape: const CircularNotchedRectangle(),
            child: Align(
              alignment: constraint.maxWidth < 500 ? Alignment.centerLeft : Alignment.center,
              child: Text('Created on'.i18n() + set!.id.timestamp.format(formatting: 'MMM dd, yyyy'),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          );
        }
      ),
      body: Column(
        children: [
          Material(
            elevation: 1,
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Container(
                color: setColor.withAlpha(40),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(set!.name, style:const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                ),
                                if(set!.description != null && set!.description!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                        set!.description!,
                                       maxLines: 4,
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground.withAlpha(220)),
                                      maxFontSize: 16,
                                      minFontSize: 14,
                                       overflowReplacement: Material(
                                         color: Colors.transparent,
                                         child: InkWell(
                                           splashFactory: InkRipple.splashFactory,
                                           borderRadius: const BorderRadius.all(Radius.circular(4)),
                                           splashColor: setColor.withAlpha(100),
                                           onTap: (){
                                             updateDescriptionMaxLine();
                                           },
                                           child: Padding(
                                             padding: const EdgeInsets.fromLTRB(4, 4, 2, 4),
                                             child: Text(set!.description!, style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withAlpha(220)), maxLines: descriptionMaxLine, overflow: TextOverflow.fade,),
                                           ),
                                         ),
                                       ),
                                    ),
                                  ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        if(set!.originalOwner == null && set!.cards.isNotEmpty && set!.lastStudyDate != null)
                                          Tooltip(
                                            waitDuration: Duration.zero,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.onBackground.withAlpha(225),
                                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                                            ),
                                            showDuration: Utils.isOnPhone() ? const Duration(seconds: 5) : null,
                                            triggerMode: Utils.isOnPhone() ? TooltipTriggerMode.tap : null,
                                            richMessage: TextSpan(
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.background
                                                      ),
                                                    children: [
                                                      TextSpan(text: totalKnowCount.toString(), style: const TextStyle(color: Colors.green)),
                                                      const TextSpan(text: ' / '),
                                                      TextSpan(text: totalDontKnowCount.toString(), style: const TextStyle(color: Colors.red)),
                                                      TextSpan(text: "  -  ${"Card know ratio".i18n(["${(totalKnowCount * 100 / (totalKnowCount + totalDontKnowCount)).round()}"])}"),
                                                      TextSpan(text: "\n${"Set last studied".i18n()} ${set!.lastStudyDate!.format()}", style: const TextStyle(fontWeight: FontWeight.w500, height: 2))
                                                    ]
                                                ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                      color: progressColor,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: progressColor.withAlpha(180),
                                                          blurRadius: 0.8,
                                                          spreadRadius: 0.8,
                                                        )
                                                      ])
                                              ),
                                            ),
                                          ),
                                        Text(set!.cards.length <= 1 ? '${set!.cards.length} card' : '${set!.cards.length} cards', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                      ],
                                    ),
                                ),
                                if(set!.originalOwner != null) Align(
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
                                                    text: "${"Set saved from".i18n()}\""
                                                ),
                                                TextSpan(
                                                  text: set!.originalSet!.name,
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                                                  recognizer: originalOwnerTapRecognizer,
                                                ),
                                                TextSpan(
                                                  text: "\" ${"by".i18n()}",
                                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
                                                ),
                                                TextSpan(
                                                  text: ownerText,
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
                                                )
                                              ],
                                            )
                                          )
                                      )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => modifySet(context, set!, realmServices),
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                    if(set!.cards.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(maxWidth: learningButtonWidth, minHeight: learningButtonHeight),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                    fixedSize: const MaterialStatePropertyAll(Size.fromHeight(40)),
                                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25), topRight: Radius.circular(4), bottomRight: Radius.circular(4)))),
                                ),
                                onPressed: () => {
                                      GoRouter.of(context).push(RouterHelper.buildLearnRoute(widget.id, 'flashcards'))
                                  },
                                child: iconTextCard(Icons.quiz_rounded, 'Flashcards'.i18n()),
                              ),
                            ),
                            const SizedBox(width: 4,),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                fixedSize: const MaterialStatePropertyAll(Size(70, learningButtonHeight)),
                                  shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4), topRight: Radius.circular(25), bottomRight: Radius.circular(25)))),
                                ),
                              onPressed: () => {
                                setState(() => {
                                  arrowAngle = (arrowAngle + pi) % (2 * pi),
                                  extendLearningMenu = !extendLearningMenu,
                                }),
                              },
                              child:  TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: arrowAngle),
                                duration: const Duration(milliseconds: 300),
                                builder: (BuildContext context, double value, Widget? child) {
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform:  Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(value),
                                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 2),
                    ExpandedSection(expand: extendLearningMenu,
                      duration: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: learningButtonWidth - 20, minHeight: learningButtonHeight),
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                    foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(25)))),
                                  ),
                                  onPressed: () => {
                                    GoRouter.of(context).push(RouterHelper.buildLearnRoute(widget.id, 'written'))
                                  },
                                  child: iconTextCard(Icons.text_fields_rounded, 'Written mode'.i18n()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: CardList(
                  set!.id,
                  realmServices.currentUser!.id == set!.owner!.userId.hexString,
              ),
          ),
        ],
      ),
    );
  }
}