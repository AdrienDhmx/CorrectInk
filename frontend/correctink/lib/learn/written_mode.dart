import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
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
  final String top;
  final String bottom;

  const WrittenMode(this.set, this.card, this.currentCardIndex, this.onSwap, this.undo, {super.key, required this.top, required this.bottom});

  @override
  State<StatefulWidget> createState() => _WrittenMode();
}

class _WrittenMode extends State<WrittenMode> {
  static const int transitionDuration = 700;
  late RealmServices realmServices;
  late String input = '';
  late TextEditingController inputController;
  late bool wrongAnswer = false;
  late bool checked = false;
  late int distance = 0;
  late Color color;
  late String wrongInputs = "";
  double containerWidth = 150;
  double containerHeight = 200;
  late int side = 0;
  double angle = 0;
  int know = 0;

  late final _focusNode = FocusNode(
    onKey: (FocusNode node, RawKeyEvent evt) {
      if (!evt.isShiftPressed && !evt.isControlPressed && evt.logicalKey.keyLabel == 'Enter' && !Utils.isOnPhone()) {
        if (evt is RawKeyDownEvent) {
            check();
        }
        return KeyEventResult.handled;
      }
      else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    print("------- DID CHANGE DEPENDENCIES WRITTEN PAGE --------");
    print("top: ${widget.top} ---- bottom: ${widget.bottom}");
    realmServices = Provider.of(context);
    inputController = TextEditingController(text: input);
    color = widget.set.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(widget.set.color!);
  }

  void update(int k) {
    setState(() {
      know = k;
    });
  }

  void flipCard(){
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  @override
  Widget build(BuildContext context) {

    print("------- BUIDING WRITTEN PAGE --------");
    print("current card index: ${widget.currentCardIndex}");
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
                  child: SizedBox(
                    width: containerWidth,
                    height: containerHeight,
                    child:TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: angle),
                        duration: const Duration(milliseconds: 250),
                        builder: (BuildContext context, double value, Widget? child) {
                          if (value >= (pi / 2)) {
                            side = 0;
                          } else {
                            side = 1;
                          }
                          return (
                              Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(value),
                                  child: side == 1
                                      ? Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        side: know != 0
                                            ? BorderSide(width: 4.0,
                                            color: know == 1 ? Colors.green.withAlpha(200) : Colors.red.withAlpha(200)): BorderSide.none
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: color.withAlpha(80),
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(child:
                                          AutoSizeText(widget.top,
                                            style: const TextStyle(fontSize: 20),
                                            textAlign: TextAlign.center,
                                          )
                                        ),
                                      ),
                                    ),
                                  )
                                      : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(10.0)),
                                            side: know != 0 ? BorderSide(
                                                width: 4.0,
                                                color: know == 1? Colors.green.withAlpha(200) : Colors.red.withAlpha(200)) : BorderSide.none
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: color.withAlpha(80),
                                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Center(child:
                                            AutoSizeText(
                                              widget.bottom,
                                              style: const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.center,
                                            )
                                            ),
                                          ),
                                        ),
                                      )
                                  )
                              ));
                        }
                    ),
                  ),
                  /*FlipCard(
                          color: widget.set.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(widget.set.color!),
                          containerWidth: containerWidth,
                          containerHeight: containerHeight,
                          onFlipEnd: null,
                          top: widget.top,
                          bottom: widget.bottom,
                          key: _flipCardKey,
                        ),*/
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
                                  style: Theme.of(context).textTheme.titleLarge,),
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
                                if(widget.set.lenientMode && distance <= 1)
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
                                suffixIcon: Tooltip(
                                  message: widget.set.lenientMode ? "Lenient mode on".i18n() : "Lenient mode off".i18n(),
                                  waitDuration: const Duration(milliseconds: 500),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: Icon(Icons.spellcheck),
                                  ),
                                ),
                                suffixIconColor: widget.set.lenientMode ? Colors.green.withAlpha(180) : Colors.red.withAlpha(180),
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
                                    update(1);

                                    Timer(const Duration(milliseconds: transitionDuration - 200), () {
                                        reset(flip: true);
                                        Timer(const Duration(milliseconds: 250), () {
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
    update(0);
    if(wrongAnswer || flip) {
        flipCard();
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
            input: input,
            correctAnswer: widget.bottom,
            getAllAnswersRight: widget.set.getAllAnswersRight,
            lenientMode: widget.set.lenientMode);

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

    update(wrongAnswer ? -1 : 1);

    if(!wrongAnswer){
      Timer(const Duration(milliseconds: transitionDuration),() {
        reset();
        Timer(const Duration(milliseconds: 250),(){
          widget.onSwap(true);
        });
      });
    } else {
      flipCard();
    }
  }

  void next() {
    reset();
    Timer(const Duration(milliseconds: 250), () {
      widget.onSwap(false);
    });
  }
}
