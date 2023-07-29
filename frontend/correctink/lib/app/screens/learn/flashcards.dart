import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../../widgets/widgets.dart';
import '../../data/models/schemas.dart';
import '../../services/theme.dart';
import '../../../widgets/learn_card.dart';

class Flashcards extends StatefulWidget{
  final Function(bool know) onSwap;
  final Function() undo;
  final KeyValueCard card;
  final CardSet set;
  final int currentCardIndex;
  final String top;
  final String bottom;

  const Flashcards(this.set, this.card, this.currentCardIndex, this.onSwap, this.undo, {super.key, required this.top, required this.bottom});

  @override
  State<StatefulWidget> createState() => _Flashcards();
}

class _Flashcards extends State<Flashcards>{

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: DraggableCard(widget.card,
                widget.set.color == null ? Theme.of(context).colorScheme.surface : HexColor.fromHex(widget.set.color!),
                widget.onSwap,
               top: widget.top, bottom: widget.bottom,
            ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: SizedBox(
            height: 60,
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if(!Platform.isAndroid && !Platform.isIOS)
                    Expanded(
                      child: TextButton(
                          style: flatTextButton(Colors.red.withAlpha(40), Theme.of(context).colorScheme.onBackground),
                          onPressed: () { widget.onSwap(false); },
                          child: const Icon(Icons.close_rounded, color: Colors.red,)
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child:IconButton(
                      disabledColor: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
                      onPressed: widget.currentCardIndex != 0 ? () { widget.undo(); } : null,
                      icon: const Icon(Icons.undo_rounded),
                    ),
                  ),
                  if(!Platform.isAndroid && !Platform.isIOS)
                    Expanded(
                      child: TextButton(
                          style: flatTextButton(Colors.green.withAlpha(40), Theme.of(context).colorScheme.onBackground),
                          onPressed: () { widget.onSwap(true); },
                          child:const Icon(Icons.check_rounded, color: Colors.green,)
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


}
