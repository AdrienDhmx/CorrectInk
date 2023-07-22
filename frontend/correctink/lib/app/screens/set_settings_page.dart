import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
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
  late CardSet set;
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
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: Utils.isOnPhone() ? 80 : 60,
            color: set.color == null ? Theme.of(context).colorScheme.surface : HexColor.fromHex(set.color!).withAlpha(40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.navigate_before)),
                    ),
                    Flexible(child: Text('Settings for'.i18n([set.name]), style: listTitleTextStyle(),)),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              shrinkWrap: true,
              children: [
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
                          width: 180,
                        ),
                        customRadioButton(context,
                            label: "Front of the card".i18n(),
                            isSelected: set.sideToGuess == 1,
                            onPressed: (){
                              realmServices.setCollection.updateSettings(set, guessSide: 1);
                            },
                          width: 180,
                        ),
                        customRadioButton(context,
                            label: "Random".i18n(),
                            isSelected: set.sideToGuess == -1,
                            onPressed: (){
                              realmServices.setCollection.updateSettings(set, guessSide: -1);
                            },
                          width: 120,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12,),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Divider(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CheckboxListTile(
                    value: set.studyMethod == 0,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    title: Text("Study method".i18n(), style: Theme.of(context).textTheme.titleMedium,),
                    subtitle: Text(set.studyMethod == 0 ? "Spaced repetition info".i18n() : "Study all cards info".i18n(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                      ),
                    ),
                    onChanged: (value){
                      realmServices.setCollection.updateSettings(set, studyMethod: value! ? 0 : 1);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CheckboxListTile(
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CheckboxListTile(
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CheckboxListTile(
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
            ),
          ),
        ],
      )
    );
  }

}