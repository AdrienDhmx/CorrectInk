import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:key_card/create/create_card.dart';
import 'package:key_card/main.dart';
import 'package:key_card/modify/modify_set.dart';
import 'package:key_card/theme.dart';
import 'package:provider/provider.dart';
import '../components/card_list.dart';
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

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    realmServices = Provider.of<RealmServices>(context);

    cardNumber = realmServices.getKeyValueCards(widget.id).length;

    if(cardNumber == 1){
      cardCount = '$cardNumber card';
    }else{
      cardCount = '$cardNumber cards';
    }
  }

  @override
  Widget build(BuildContext context) {
    final CardSet? set = realmServices.getSet(widget.id);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: styledFloatingButton(context,
          onPressed: () => {
            if(realmServices.currentUser!.id == set!.ownerId){
              showModalBottomSheet(isScrollControlled: true,
              context: context,
              builder: (_) => Wrap(children: [CreateCardForm(set.id)]))
            } else{
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
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                          child: IconButton(onPressed: () => {Navigator.pop(context)}, icon: const Icon(Icons.navigate_before)),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
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
                                if(set.description != null && set.description!.isNotEmpty)
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(set.description ?? '')
                                  ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(cardCount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => modifySet(context, set, realmServices),
                            icon: const Icon(Icons.edit),
                          )
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
                  set.id,
                  realmServices.currentUser!.id == set.ownerId,
              ),
          ),
        ],
      ),
    );
  }
}