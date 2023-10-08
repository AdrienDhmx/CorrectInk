import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../utils/learn_utils.dart';
import '../../../utils/utils.dart';
import '../../../widgets/learn_card.dart';
import '../../../widgets/widgets.dart';
import '../../data/models/learning_models.dart';
import '../../data/models/schemas.dart';
import '../../data/repositories/realm_services.dart';
import '../../services/theme.dart';

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
  late bool checked = false;
  late bool passed = false;
  late int distance = 0;
  late Color color;
  late LearningWrittenReport report = LearningWrittenReport();
  double containerWidth = 150;
  double containerHeight = 200;

  GlobalKey flipCardKey = GlobalKey();

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
    realmServices = Provider.of(context);
    inputController = TextEditingController(text: input);
    color = widget.set.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(widget.set.color!);
  }

  void update(int k) {
    if(flipCardKey.currentState != null) {
      (flipCardKey.currentState as PFlipCard).update(k);
    }
  }

  void flipCard(){
    if(flipCardKey.currentState != null) {
      (flipCardKey.currentState as PFlipCard).flip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:(context, constraint){
        containerWidth = constraint.maxWidth * 0.85;
        containerWidth = containerWidth > 900 ? 900 : containerWidth;
        containerHeight = constraint.maxHeight;

        final span = TextSpan(text: input, style: const TextStyle(fontSize: 16,),);
        final tp = TextPainter(text: span, maxLines: null, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
        tp.layout(maxWidth: containerWidth - 60); // 60 is approximately the lenient mode button + padding width
        double textHeight = tp.height;

        double buttonsAndPaddings = 170;

        if(passed){
          buttonsAndPaddings = 100;
        }

        final cardAvailableHeight = containerHeight - textHeight - buttonsAndPaddings;

        return Column(
          children: [
            const SizedBox(height: 10,),
            Center(
              child: SizedBox(
                width: containerWidth,
                height: cardAvailableHeight,
                child: FlipCard(
                  color: widget.set.color == null ? Theme.of(context).colorScheme.surfaceVariant : HexColor.fromHex(widget.set.color!),
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  onFlipEnd: null,
                  top: widget.top,
                  bottom: widget.bottom,
                  key: flipCardKey,
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
                    if(!passed)
                      Container(
                        width: containerWidth + 0.2 * containerWidth,
                        padding: const EdgeInsets.only(bottom: 10),
                        child: !report.noError
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('You Entered'.i18n(['']),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4,),
                            RichText(
                              text: TextSpan(
                                  children: [
                                    for(ReportPayload payload in report.payload)
                                      TextSpan(
                                          text: payload.answerSpan,
                                          style: TextStyle(
                                            color: payload.correct ? Theme.of(context).colorScheme.onBackground : Colors.red,
                                            fontSize: 16,
                                          )
                                      ),
                                  ]
                              ),
                            ),
                            if(distance == 100 && widget.set.getAllAnswersRight)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                child: Text('Get all answers result missing'.i18n(['']),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.red.withAlpha(200),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              )
                            else if(!report.correct && !widget.set.lenientMode && distance <= 1)
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
                          style: const TextStyle(fontSize: 16,),
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
                      padding: const EdgeInsets.only(
                          bottom: 10.0, left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(report.noError) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SizedBox(
                                width: 140,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    pass();
                                  },
                                  style: surfaceTextButtonStyle(context),
                                  child: Text("Don't know".i18n()),
                                ),
                              ),
                            ),
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
                          ],
                          if(checked && !report.noError && !passed && !report.correct)
                            SizedBox(
                              width: containerWidth/2,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    report.noError = true;
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
                          if(checked && !report.noError)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: SizedBox(
                                width: containerWidth/2,
                                height: 40,
                                child: CallbackShortcuts(bindings: <ShortcutActivator, VoidCallback>{
                                  const SingleActivator(LogicalKeyboardKey.enter): next,
                                },
                                  child: ElevatedButton(
                                    autofocus: true,
                                    onPressed: next,
                                    style: primaryTextButtonStyle(context),
                                    child: Text('Next'.i18n()),
                                  ),
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
    if(!report.noError || flip) {
      flipCard();
    }

    setState(() {
      input = '';
      inputController.text = '';
      report.noError = true;
      report.correct = true;
      report.distance = 0;
      checked = false;
      passed = false;
    });
  }

  void pass(){
    setState(() {
      report.noError = false;
      report.correct = false;
      distance = 100;

      checked = true;
      passed = true;
    });

    update(-1);
    flipCard();
  }

  void check() {
    final newReport = LearnUtils.checkWrittenAnswer(
        userInput: input,
        correctAnswer: widget.bottom,
        getAllAnswersRight: widget.set.getAllAnswersRight,
        lenientMode: widget.set.lenientMode
    );

    setState(() {
      distance = newReport.distance;
      report = newReport;

      checked = true;
    });

    // answer accepted ? (there can be errors...)
    update(report.correct ? 1 : -1);

    if(report.noError){
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
