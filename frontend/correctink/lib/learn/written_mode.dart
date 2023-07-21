import 'dart:async';

import 'package:correctink/learn/learn_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../components/widgets.dart';
import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import '../theme.dart';
import '../utils.dart';
import 'helper/learn_utils.dart';

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

class _WrittenMode extends State<WrittenMode> {
  late RealmServices realmServices;
  late String input = '';
  late TextEditingController inputController;
  late bool wrongAnswer = false;
  late bool checked = false;
  late bool strictMode = true;
  late int distance = 0;
  late String wrongInputs = "";
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

    realmServices = Provider.of(context);
    strictMode = !widget.set.lenientMode;
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
          containerWidth = constraint.maxWidth * 0.85;
          containerWidth = containerWidth > 900 ? 900 : containerWidth;
          containerHeight = constraint.maxHeight;

          final span = TextSpan(text: input, style: const TextStyle(fontSize: 14,),);
          final tp = TextPainter(text: span, maxLines: null, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
          tp.layout(maxWidth: containerWidth - 60); // 60 is approximately the lenient mode button + padding width
          double textHeight = tp.height;

          final cardAvailableHeight = containerHeight - textHeight - 170; // 170 is approximately the total default of the text field + buttons + paddings

          return Column(
            children: [
              Center(
                child: SizedBox(
                  width: containerWidth,
                  height: cardAvailableHeight,
                  child: FlipCard(
                          color: widget.set.color == null ? Theme
                              .of(context)
                              .colorScheme
                              .surfaceVariant : HexColor.fromHex(
                              widget.set.color!),
                          containerWidth: containerWidth,
                          containerHeight: containerHeight,
                          onFlipEnd: null,
                          top: widget.card.front,
                          bottom: widget.card.back,
                          key: _flipCardKey,
                        ),
                ),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: SizedBox(
                  width: containerWidth * 1.1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: containerWidth + 0.2 * containerWidth,
                        child: wrongAnswer
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                'You Entered'.i18n(['']),
                                  textAlign: TextAlign.center,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleLarge,),
                                Text(wrongInputs,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14,)
                                ),
                                if(wrongInputs.isEmpty)
                                  Text(
                                    input,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14,)
                                  ),
                                if(strictMode && distance <= 1)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                                    child: Text('Lenient mode correct result'.i18n(),
                                      textAlign: TextAlign.center,
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
                              style: const TextStyle(fontSize: 14,),
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
                                      realmServices.setCollection.updateSettings(widget.set, lenientMode: !strictMode);
                                    },
                                  ),
                                ),
                                suffixIconColor: strictMode ? Colors.red.withAlpha(180) : Colors.green.withAlpha(180),
                                filled: false,
                                labelText: 'Enter your Answer'.i18n(),
                              ),
                              onChanged: (value) => {
                                setState(() => input = value)
                          },
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
    bool correct = false;
    int distanceFound = 0;
    List<String> wrongAnswers = <String>[];
    String wrongInputsString = "";
    (correct, distanceFound, wrongAnswers) = LearnUtils.checkWrittenAnswer(
            card: widget.card,
            input: input,
            inputIsValue: widget.set.sideToGuess == 0,
            getAllAnswersRight: widget.set.getAllAnswersRight,
            lenientMode: !strictMode);

    if(wrongAnswers.isNotEmpty){
      for(int i = 0; i < wrongAnswers.length; i++){
        wrongInputsString += '${wrongAnswers[i]}, ';
      }
      wrongInputsString = wrongInputsString.replaceRange(wrongInputsString.length - 2, wrongInputsString.length - 1, '');
    }
    setState(() {
      wrongAnswer = !correct;
      distance = distanceFound;
      wrongInputs = wrongInputsString;

      checked = true;
    });

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
