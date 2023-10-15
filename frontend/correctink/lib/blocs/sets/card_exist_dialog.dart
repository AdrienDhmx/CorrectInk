import 'package:correctink/app/data/models/schemas.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../widgets/widgets.dart';

enum CardExistChoice {
  cancel,
  create,
  addBackToExistingCard,
}

class CardExistDialog extends StatefulWidget {
  final KeyValueCard card;
  final String originalBack;
  final String newBack;
  final bool backAlreadyExists;
  final Function(CardExistChoice choice) onConfirm;

  const CardExistDialog({super.key, required this.card, required this.backAlreadyExists, required this.originalBack, required this.newBack, required this.onConfirm});

  @override
  State<StatefulWidget> createState() => _CardExistDialog();

}

class _CardExistDialog extends State<CardExistDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Existing card found".i18n()),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Existing card found description".i18n()),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  keyValueCardPreview(context, front: widget.card.front, back: widget.originalBack, backAlreadyExists: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(endIndent: 8, indent: 8,),
                  ),
                  keyValueCardPreview(context, front: widget.card.front, back: widget.card.back, backAlreadyExists: widget.backAlreadyExists, newBack: widget.newBack),
                  if(!widget.backAlreadyExists) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                          "Found card modified tip".i18n(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Align(
                      alignment: Alignment.centerRight,
                      child: okButton(
                          context,
                          "Modify existing card".i18n(),
                          onPressed: () => widget.onConfirm(CardExistChoice.addBackToExistingCard)
                      ),
                    ),
                  ] // enf if
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        cancelButton(
          context,
        ),
        okButton(
          context,
          "Create".i18n(),
          onPressed: () => widget.onConfirm(CardExistChoice.create)
        )
      ],
    );
  }
}

keyValueCardPreview(BuildContext context, {required String front, required String back, required bool backAlreadyExists, String? newBack}) {
  return Material(
      color: Colors.transparent,
      elevation: 1,
      borderRadius: BorderRadius.circular(6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        horizontalTitleGap: 6,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(front, style: Theme.of(context).textTheme.bodyLarge)
              ),
              const SizedBox(height: 8.0),
              Align(
                  alignment: Alignment.centerLeft,
                  child: backAlreadyExists
                      ? Text(back, style: Theme.of(context).textTheme.bodyLarge)
                      : RichText(text: TextSpan(
                      children: [
                        TextSpan(
                            text: back,
                            style: Theme.of(context).textTheme.bodyLarge
                        ),
                        TextSpan(
                            text: newBack,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.green,
                            )
                        ),
                      ]
                  )
                  )
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textColor: Theme.of(context).colorScheme.onSecondaryContainer,
        tileColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
  );
}