import 'dart:async';

import 'package:correctink/learn/learn_card.dart';
import 'package:correctink/learn/services/text_distance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

import '../realm/schemas.dart';
import '../theme.dart';
import '../utils.dart';

class WrittenMode extends StatefulWidget{
  final Function(bool know) onSwap;
  final Function() undo;
  final KeyValueCard card;
  final CardSet set;
  final int currentCardIndex;

  const WrittenMode(this.set, this.card, this.currentCardIndex, this.onSwap, this.undo, {super.key});

  @override
  State<StatefulWidget> createState() => _WrittenMode();

}

class _WrittenMode extends State<WrittenMode>{
  late String input = '';
  late TextEditingController inputController;
  late bool wrongAnswer = false;
  late bool checked = false;
  late bool strictMode = true;
  late int distance = 0;
  double containerWidth = 150;
  double containerHeight = 200;
  final GlobalKey _flipCardKey = GlobalKey();
  late final _focusNode = FocusNode(
    onKey: (FocusNode node, RawKeyEvent evt) {
      if (!evt.isShiftPressed && !evt.isControlPressed && evt.logicalKey.keyLabel == 'Enter' && !Utils.isOnPhone()) {
        if (evt is RawKeyDownEvent) {
          if(wrongAnswer){
            next();
          } else {
            check();
          }
        }
        return KeyEventResult.handled;
      }
      else {
        return KeyEventResult.ignored;
      }
    },
  );

  static const int transitionDuration = 800;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    inputController = TextEditingController(text: input);
  }

  void flipCard(){
    if(_flipCardKey.currentState != null) {
      (_flipCardKey.currentState as PFlipCard).flip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder:(context, constraint){
          containerWidth = constraint.maxWidth * 0.8;
          containerWidth = containerWidth > 900 ? 900 : containerWidth;
          containerHeight = constraint.maxHeight;
          return Column(
            children: [
              Expanded(
                flex: containerHeight <= 550 ? 11 : 21,
                  child: Center(
                    child: LayoutBuilder(
                        builder: (context, constraint) {
                          containerHeight = constraint.maxHeight * 0.85;
                          containerHeight = containerHeight > 500 ? 500 : containerHeight;
                          return FlipCard(
                            color: widget.set.color == null ? Theme
                                .of(context)
                                .colorScheme
                                .surfaceVariant : HexColor.fromHex(
                                widget.set.color!),
                            containerWidth: containerWidth,
                            containerHeight: containerHeight,
                            onFlipEnd: null,
                            top: widget.card.key,
                            bottom: widget.card.value,
                            key: _flipCardKey,
                          );
                        }
                    ),
                  )
              ),
              Expanded(
                flex: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: SizedBox(
                        width: containerWidth + 0.2 * containerWidth,
                        child: wrongAnswer
                            ? Column(
                              children: [
                                Text(
                                'You Entered'.i18n([input]), textAlign: TextAlign.center,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleLarge,),
                                if(strictMode && distance <= 1)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                                    child: Text('Lenient mode correct result'.i18n(),
                                      style: TextStyle(
                                        color: Colors.green.withAlpha(200),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700
                                      )),
                                  )
                              ],
                            )
                            : TextField(
                              controller: inputController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              autofocus: true,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: IconButton(
                                    tooltip: strictMode ? 'Lenient mode off'.i18n() : 'Lenient mode on'.i18n(),
                                    icon: const Icon(Icons.spellcheck),
                                    onPressed: () {
                                      setState(() {
                                        strictMode = !strictMode;
                                      });
                                    },
                                  ),
                                ),
                                suffixIconColor: strictMode ? Colors.red.withAlpha(180) : Colors.green.withAlpha(180),
                                filled: false,
                                labelText: 'Enter your Answer'.i18n(),
                              ),
                              onChanged: (value) =>
                              {
                                setState(() => {
                                  input = value
                                })
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(!wrongAnswer)
                            SizedBox(
                              width: 140,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  check();
                                },
                                style: primaryTextButtonStyle(context),
                                child: Text('Check'.i18n()),
                              ),
                            ),
                          if(checked && wrongAnswer)
                            SizedBox(
                              width: containerWidth/2,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    wrongAnswer = false;
                                  });
                                  if(_flipCardKey.currentState != null) {
                                    (_flipCardKey.currentState as PFlipCard).update(1);
                                  }

                                  Timer(const Duration(milliseconds: transitionDuration - 200), () {
                                      reset(flip: true);
                                      Timer(const Duration(milliseconds: 300), () {
                                        widget.onSwap(true);
                                      });
                                  });
                                },
                                style: surfaceTextButtonStyle(context),
                                child: Text('is Correct?'.i18n()),
                              ),
                            ),
                          if(checked && wrongAnswer)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: SizedBox(
                                width: containerWidth/2,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: next,
                                  style: primaryTextButtonStyle(context),
                                  child: Text('Next'.i18n()),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
      );
        },
    );
  }

  void reset({bool flip = false}){
    if(_flipCardKey.currentState != null) {
      (_flipCardKey.currentState as PFlipCard).update(0);
      if(wrongAnswer || flip) {
        (_flipCardKey.currentState as PFlipCard).flip();
      }
    }

    setState(() {
      input = '';
      inputController.text = '';
      wrongAnswer = false;
      checked = false;
    });

  }

  void check() {
    setState(() {
      String value =  widget.card.value.toLowerCase().trim();
      String userInput = inputController.text.toLowerCase().trim();

      distance = TextDistance.distance(value, userInput);

      if(strictMode){
        wrongAnswer = value != userInput;
      } else {
        wrongAnswer = value != userInput && distance > 1;
      }
      checked = true;
    });

    if (kDebugMode) {
      print('distance is: $distance');
    }

    if(_flipCardKey.currentState != null) {
      (_flipCardKey.currentState as PFlipCard).update(wrongAnswer ? -1 : 1);
    }

    if(!wrongAnswer){
      Timer(const Duration(milliseconds: transitionDuration),() {
        reset();
        Timer(const Duration(milliseconds: 350),(){ widget.onSwap(true); });
      });
    } else {
      flipCard();
    }
  }

  void next() {
    reset();
    Timer(const Duration(
        milliseconds: transitionDuration), () {
      widget.onSwap(false);
    });
  }
}
