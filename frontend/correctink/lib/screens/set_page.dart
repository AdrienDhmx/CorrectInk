import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/create/create_card.dart';
import 'package:correctink/main.dart';
import 'package:correctink/modify/modify_set.dart';
import 'package:correctink/theme.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import '../components/animated_widgets.dart';
import '../components/card_list.dart';
import '../components/snackbars_widgets.dart';
import '../components/widgets.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../utils.dart';

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
    if(set == null) return;

    if(!streamInit){
      stream = set!.changes.listen((event) {
        setState(() {
          set = event.object;
        });
      });
    }

    if(setOwner == null && (set!.owner!.userId.hexString != realmServices.currentUser!.id || set!.originalOwner != null)){
      if(set!.originalOwner == null){
        setState(() {
          ownerText = '${set!.originalOwner!.firstname} ${set!.originalOwner!.lastname}';
        });
      } else {
       if(set!.originalOwner != null){
         setState(() {
           ownerText = '${set!.originalOwner!.firstname} ${set!.originalOwner!.lastname}';
         });
       }
      }
    }
  }

  @override
  void dispose(){
    super.dispose();
    stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return set == null || !set!.isValid ? Container()
     : Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: set!.owner!.userId.hexString != realmServices.currentUser!.id
         ? styledFloatingButton(context,
              onPressed: () {
                realmServices.setCollection.copyToCurrentUser(set!);
                infoMessageSnackBar(context, "Set saved message".i18n()).show(context);
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
      bottomNavigationBar: BottomAppBar(
        height: 45,
        shape: const CircularNotchedRectangle(),
        child: LayoutBuilder(
          builder: (context, constraint) {
            return Align(
              alignment: constraint.maxWidth < 500 ? Alignment.centerLeft : Alignment.bottomCenter,
              child: Text('Created on'.i18n() + set!.id.timestamp.format(formatting: 'MMM dd, yyyy'),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500
                ),
              ),
            );
          }
        )
      ),
      body: Column(
        children: [
          Material(
            elevation: 1,
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Container(
                color: set?.color == null ? Theme.of(context).colorScheme.background : HexColor.fromHex(set!.color!).withAlpha(40),
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
                                    child: Text(set!.name, style:const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                                ),
                                if(set!.description != null && set!.description!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                        set!.description!,
                                       maxLines: 4,
                                      style: const TextStyle(fontSize: 16),
                                      maxFontSize: 16,
                                      minFontSize: 14,
                                       overflowReplacement: Material(
                                         color: Colors.transparent,
                                         child: InkWell(
                                           splashFactory: InkRipple.splashFactory,
                                           borderRadius: const BorderRadius.all(Radius.circular(4)),
                                           splashColor: set!.color != null ? HexColor.fromHex(set!.color!).withAlpha(60) : Theme.of(context).colorScheme.surfaceVariant.withAlpha(120),
                                           onTap: (){
                                             updateDescriptionMaxLine();
                                           },
                                           child: Padding(
                                             padding: const EdgeInsets.fromLTRB(4, 4, 2, 4),
                                             child: Text(set!.description!, maxLines: descriptionMaxLine, overflow: TextOverflow.fade,),
                                           ),
                                         ),
                                       ),
                                    ),
                                  ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(set!.cards.length <= 1 ? '${set!.cards.length} card' : '${set!.cards.length} cards', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                ),
                                if(setOwner != null) Align(
                                      alignment: Alignment.centerLeft,
                                      child: set!.originalSet == null
                                      ? Text("By x".i18n([ownerText]), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                      : RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
                                                    text: "Set saved from".i18n()
                                                ),
                                                TextSpan(
                                                  text: ownerText,
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                                                  recognizer: TapGestureRecognizer()..onTap = () async {
                                                    String error = "Error offline sets".i18n();
                                                    if(realmServices.offlineModeOn){
                                                      errorMessageSnackBar(context, 'Error'.i18n(), error).show(context);
                                                      return;
                                                    }

                                                    if(set!.originalSet != null){
                                                      if(set!.originalSet!.isPublic){
                                                        if(context.mounted) GoRouter.of(context).push(RouterHelper.buildSetRoute(set!.originalSet!.id.hexString));
                                                        return;
                                                      } else {
                                                        error = "Error navigate set not public".i18n();
                                                      }
                                                    } else {
                                                      error = 'Error navigate set deleted'.i18n();
                                                    }

                                                    if(context.mounted) errorMessageSnackBar(context, 'Error'.i18n(), error).show(context);
                                                  },
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