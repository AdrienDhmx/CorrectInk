import 'package:correctink/utils/utils.dart';
import 'package:correctink/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../app/data/models/schemas.dart';
import '../../widgets/buttons.dart';

class SetPicker extends StatelessWidget {
  final String title;
  final List<CardSet> sets;
  final Function() onCancel;
  final Function(CardSet) onSetSelected;

  const SetPicker({super.key, required this.title, required this.sets, required this.onCancel, required this.onSetSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 250, maxWidth: 500),
          child: textPlaceHolder(
              context,
              condition: sets.isNotEmpty,
              placeholder: "No sets".i18n(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for(int index = 0; index < sets.length; index++) ...[
                      ListTile(
                        leading: Icon(Icons.folder_rounded, color: sets[index].getColor(context, defaultColor: Theme.of(context).colorScheme.onSurfaceVariant)),
                        title: Text(sets[index].name),
                        subtitle: sets[index].description != null && sets[index].description!.isNotEmpty
                            ? Align(alignment: Alignment.centerLeft,
                            child: Text(sets[index].description!,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            )
                        )
                            : null,
                        shape: index < sets.length - 1
                            ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.onBackground.withAlpha(100)))
                            : null,
                        horizontalTitleGap: 16,
                        contentPadding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
                        onTap: () {
                          onSetSelected(sets[index]);
                        },
                      )
                    ]
                  ],
                ),
              ),
          ),
        ),
      ),
      actions: [
        cancelButton(
          context,
          onCancel: () => onCancel(),
        ),
      ],
    );
  }

}