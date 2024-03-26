import 'package:flutter/material.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../widgets/buttons.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/realm_services.dart';

class ModifyMultipleCardsForm extends StatefulWidget {
  final List<Flashcard> cards;
  const ModifyMultipleCardsForm(this.cards, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ModifyMultipleCardsFormState();
}

class ModifyMultipleCardsFormState extends State<ModifyMultipleCardsForm> {
  late bool canBeReversed = false;

  ModifyMultipleCardsFormState();

  @override
  void initState() {
    canBeReversed = widget.cards.any((card) => card.canBeReversed);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context, listen: false);
    return modalLayout(
        context,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Tooltip(
                message: "Whether the front can be guessed from the back of the card".i18n(),
                waitDuration: const Duration(milliseconds: 500),
                child: labeledAction(
                  context: context,
                  child: Switch(
                    value: canBeReversed,
                    onChanged: (value) {
                      setState(() {
                        canBeReversed = value;
                      });
                    },
                  ),
                  label: 'Can be reversed'.i18n(),
                  center: true,
                  infiniteWidth: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelButton(context),
                    okButton(context, "Update all".i18n(),
                        onPressed: () async {
                          await realmServices.cardCollection.updateAll(widget.cards, canBeReversed);
                          if(context.mounted) Navigator.pop(context);
                        },
                    ),
                  ]
              ),
            ),
          ],
        ));
  }
}