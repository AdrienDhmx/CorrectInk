import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:correctink/create/create_card.dart';
import 'package:correctink/main.dart';
import 'package:correctink/modify/modify_set.dart';
import 'package:correctink/theme.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';
import '../components/card_list.dart';
import '../components/snackbars_widgets.dart';
import '../components/widgets.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';

class SetPage extends StatefulWidget{

  final String id;

  const SetPage(this.id, {super.key});

  @override
  State<StatefulWidget> createState() => _SetPage();

}

class _SetPage extends State<SetPage>{
  late int cardNumber = 0;
  late String cardCount;
  late RealmServices realmServices;
  late CardSet? set;
  late Users? setOwner;
  late String ownerText;
  late int? descriptionMaxLine = 4;
  late StreamSubscription stream;
  bool streamInit = false;

  void updateCardNumber(cardQty){
    setState(() {
      cardNumber = cardQty;
    });

    if(cardQty == 1){
      setState(() {
        cardCount = '$cardNumber card';
      });
    } else{
      setState(() {
        cardCount = '$cardNumber cards';
      });
    }
  }

  void updateDescriptionMaxLine(){
    setState(() {
      descriptionMaxLine == 4 ? descriptionMaxLine = null : descriptionMaxLine = 4;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);

    updateCardNumber(realmServices.cardCollection.getFromSet(widget.id).length);

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


    if(setOwner == null && (set!.ownerId != realmServices.currentUser!.id || set!.originalOwnerId != null)){
      if(set!.originalOwnerId == null){
        ObjectId ownerId = ObjectId.fromHexString(set!.ownerId);
        final owner = await realmServices.usersCollection.get(ownerId);
        setState(() {
          setOwner = owner;
          ownerText = '${setOwner!.firstname} ${setOwner!.lastname}';
        });
      } else {
       Users? owner = await realmServices.usersCollection.get(set!.originalOwnerId!);
       if(owner != null){
         setState(() {
           setOwner = owner;
           ownerText = '${setOwner!.firstname} ${setOwner!.lastname}';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: set!.ownerId != realmServices.currentUser!.id
         ? styledFloatingButton(context,
              onPressed: () {
                realmServices.setCollection.copyToCurrentUser(set!);
                infoMessageSnackBar(context, 'The set has been saved! \n You will see it in your collection.').show(context);
              },
              icon: Icons.save_rounded,
              tooltip: 'Save set',
          )
         : styledFloatingButton(context,
            onPressed: () => {
              if(realmServices.currentUser!.id == set!.ownerId){
                showModalBottomSheet(isScrollControlled: true,
                context: context,
                builder: (_) => Wrap(children: [CreateCardForm(set!.id, () { updateCardNumber(cardNumber + 1); })]))
              } else {
                errorMessageSnackBar(context, "Action not allowed!",
                "You are not allowed to add cards \nto sets that don't belong to you."
                ).show(context)
              }
          }, tooltip: 'Add a card'),
      bottomNavigationBar: BottomAppBar(
        height: 40,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 0,
        ),
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
                                    child: Text(cardCount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                ),
                                if(setOwner != null) Align(
                                      alignment: Alignment.centerLeft,
                                      child: set!.originalOwnerId == null
                                      ? Text('by $ownerText', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                      : RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
                                                    text: 'saved from a set by '
                                                ),
                                                TextSpan(
                                                  text: ownerText,
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                                                  recognizer: TapGestureRecognizer()..onTap = () async {
                                                    final originalSet = await realmServices.setCollection.getAsync(set!.originalSetId!.hexString, public: true);
                                                    String error = '';
                                                    if(originalSet != null){
                                                      if(originalSet.isPublic){
                                                        if(context.mounted) GoRouter.of(context).push(RouterHelper.buildSetRoute(originalSet.id.hexString));
                                                        return;
                                                      } else {
                                                        error = 'You cannot navigate to this set, it is no longer public.';
                                                      }
                                                    } else {
                                                      error = 'You cannot navigate to this set, it has been deleted';
                                                    }

                                                    if(context.mounted) errorMessageSnackBar(context, 'Error', error).show(context);
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
                    if(cardNumber > 0)
                      Container(
                        constraints: const BoxConstraints(maxWidth: 340, minHeight: 45),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                            style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                            foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)
                          ),
                          onPressed: () => {
                                GoRouter.of(context).push(RouterHelper.buildLearnRoute(widget.id))
                            },
                          child: iconTextCard(Icons.quiz_rounded, 'Flashcards'),
                        ),
                      ),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: CardList(
                  set!.id,
                  realmServices.currentUser!.id == set!.ownerId,
              ),
          ),
        ],
      ),
    );
  }
}