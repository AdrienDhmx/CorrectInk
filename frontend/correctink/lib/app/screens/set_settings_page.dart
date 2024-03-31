import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../utils/card_helper.dart';
import '../../utils/utils.dart';
import '../../widgets/buttons.dart';
import '../../widgets/widgets.dart';
import '../data/models/schemas.dart';
import '../data/repositories/realm_services.dart';
import '../services/theme.dart';


class SetSettingsPage extends StatefulWidget{
  final String set;

  const SetSettingsPage({super.key, required this.set});

  @override
  State<StatefulWidget> createState() => _SetSettingsPage();
}

class _SetSettingsPage extends State<SetSettingsPage>{
  late RealmServices realmServices;
  late FlashcardSet set;
  late StreamSubscription stream;
  late bool streamInit = false;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    realmServices = Provider.of(context);
    set = realmServices.setCollection.get(widget.set)!;
    if(!streamInit) {
      stream = set.changes.listen((event) {
      setState(() {
        set = event.object;
      });
    });
    }
  }

  @override
  void dispose(){
    super.dispose();
    stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Color setColor = set.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(set.color!);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow,
        surfaceTintColor: setColor,
        leading: backButton(context),
        titleSpacing: 2,
        title: Text('Settings for'.i18n([set.name]), style: listTitleTextStyle(),),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              leading: const Icon(Icons.upload_rounded),
              title: Text("Export set".i18n(), style: Theme.of(context).textTheme.titleMedium,),
              subtitle: Text("Export set description".i18n(), style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
              onTap: () => CardHelper.exportCards(context, set.cards, set.name),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              leading: const Icon(Icons.download_rounded),
              title: Text("Import cards".i18n(), style: Theme.of(context).textTheme.titleMedium,),
              subtitle: Text("Import cards description".i18n(), style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
              onTap: () => CardHelper.importCards(context: context, realmServices: realmServices, set: set),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Divider(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Side to guess'.i18n(), style: Theme.of(context).textTheme.titleMedium,),
              ),
              Wrap(
                spacing: 4,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: [
                  customRadioButton(context,
                      label: "Back of the card".i18n(),
                      isSelected: set.sideToGuess == 0,
                      onPressed: (){
                      realmServices.setCollection.updateSettings(set, guessSide: 0);
                    },
                    infiniteWidth: false
                  ),
                  customRadioButton(context,
                      label: "Front of the card".i18n(),
                      isSelected: set.sideToGuess == 1,
                      onPressed: (){
                        realmServices.setCollection.updateSettings(set, guessSide: 1);
                      },
                      infiniteWidth: false
                  ),
                  customRadioButton(context,
                      label: "Random".i18n(),
                      isSelected: set.sideToGuess == 2,
                      onPressed: (){
                        realmServices.setCollection.updateSettings(set, guessSide: 2);
                      },
                      infiniteWidth: false
                  ),
                  if(set.studyMethod == 1)
                    customRadioButton(context,
                        label: "Side to guess auto".i18n(),
                        isSelected: set.sideToGuess == 3,
                        onPressed: (){
                          realmServices.setCollection.updateSettings(set, guessSide: 3);
                        },
                        infiniteWidth: false
                    ),
                ],
              ),
              const SizedBox(height: 12,),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: SwitchListTile(
              value: set.studyMethod == 1,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              title: Text("Study method".i18n(), style: Theme.of(context).textTheme.titleMedium,),
              subtitle: Text(set.studyMethod == 1 ? "Spaced repetition info".i18n() : "Study all cards info".i18n(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
              onChanged: (value){
                if(value) {
                  realmServices.setCollection.updateSettings(set, studyMethod: 1, guessSide: 3);
                } else {
                  realmServices.setCollection.updateSettings(set, studyMethod: 0, guessSide: 0);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: SwitchListTile(
              value: set.repeatUntilKnown,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              title: Text("Repeat until known".i18n(), style: Theme.of(context).textTheme.titleMedium,),
              subtitle: Text(set.repeatUntilKnown ? "Repeat until known on".i18n() : "Repeat until known off".i18n(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
              onChanged: (value){
                realmServices.setCollection.updateSettings(set, repeatUntilKnown: value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: SwitchListTile(
              value: set.getAllAnswersRight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              title: Text("Require all answers".i18n(), style: Theme.of(context).textTheme.titleMedium,),
              subtitle: Text(set.getAllAnswersRight ? "Require all answers on".i18n() : "Require all answers off".i18n(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
              onChanged: (value){
                realmServices.setCollection.updateSettings(set, getAllAnswersRight: value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: SwitchListTile(
              value: set.lenientMode,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              title: Text("Lenient mode".i18n(), style: Theme.of(context).textTheme.titleMedium,),
              subtitle: Text(set.lenientMode ? "Lenient mode on".i18n() : "Lenient mode off".i18n(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
              onChanged: (value){
                realmServices.setCollection.updateSettings(set, lenientMode: value);
              },
            ),
          ),
        ],
      )
    );
  }

}