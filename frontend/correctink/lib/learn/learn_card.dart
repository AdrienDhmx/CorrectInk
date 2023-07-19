import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:correctink/realm/schemas.dart';
import 'package:localization/localization.dart';

class DraggableCard extends StatefulWidget{
  const DraggableCard(this.card, this.side, this.color, this.onSwap, {super.key});

  final KeyValueCard card;
  final int side;
  final Color color;
  final Function(bool know) onSwap;

  @override
  State<StatefulWidget> createState() => _DraggableCard();

}

class _DraggableCard extends State<DraggableCard>{
  late int side = widget.side;
  double angle = 0;

  double xPos = 0;
  double yPos = 0;

  double containerWidth = 150;
  double containerHeight = 200;

  bool dragStarted = false;
  double dragOriginOffsetFromCenter = 0;
  bool swipe = false;
  int know = 0;

  final GlobalKey _feedbackKey = GlobalKey();
  final GlobalKey _flipCardKey = GlobalKey();

  void flip(){
    setState(() {
      angle = (angle + pi) % (2 * pi);
      if(_feedbackKey.currentState != null) {
        (_feedbackKey.currentState as _FeedbackCard).updateText(angle == 0 ? widget.card.keys.first : widget.card.values.first);
      }
      if(_flipCardKey.currentState != null) {
        (_flipCardKey.currentState as PFlipCard).flip();
      }
    });
  }

  void nextCard(){
    if (know != 0) {
      widget.onSwap(know > 0);
      setState(() {
        know = 0;
      });

      if(_flipCardKey.currentState != null) {
        (_flipCardKey.currentState as PFlipCard).update(know);
      }
    }
    swipe = false;
  }
  
  void swipeEnd(){
    swipe = true;
    // card is flipped and the card will change to the next one => we don't want to see the next card value
    if(angle != 0) {
      flip();
    }
    else {
      nextCard();
      if(_feedbackKey.currentState != null) {
        (_feedbackKey.currentState as _FeedbackCard).update(know, containerWidth, containerHeight);
      }
    }
  }

  void onDragUpdated(DragUpdateDetails details){
    final constraint = MediaQuery.of(context).size;
    int isKnow = know;
    final halfScreenWidth = constraint.width / 2;
    final safeSpaceOffset = halfScreenWidth * 0.2;

    // get the pointer pos to find the real pos of the widget
    if(dragStarted){
      setState(() {
        dragOriginOffsetFromCenter = halfScreenWidth - details.globalPosition.dx;
        dragStarted = false;
      });
    }

    // Swiping in right direction.
    if (details.globalPosition.dx + dragOriginOffsetFromCenter > halfScreenWidth + safeSpaceOffset) {
      isKnow = 1;
    } else if (details.globalPosition.dx + dragOriginOffsetFromCenter < halfScreenWidth - safeSpaceOffset) {
      isKnow = -1;
    }
    else { // in the middle, 'safe' space
      isKnow = 0;
    }

    setState(() {
      know = isKnow;
      if(_feedbackKey.currentState != null) {
        (_feedbackKey.currentState as _FeedbackCard).update(know, containerWidth, containerHeight);
      }
      if(_flipCardKey.currentState != null) {
        (_flipCardKey.currentState as PFlipCard).update(know);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
              setState(() {
                know = -1;
              });
              swipeEnd();
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight): () {
              setState(() {
                know = 1;
              });
              swipeEnd();
           },
          const SingleActivator(LogicalKeyboardKey.space): () {
            flip();
          },
        },
        child: Focus(
          autofocus: true,
          child: LayoutBuilder(
            builder:(context, constraint){
              containerHeight = constraint.maxHeight * 0.85;
              containerWidth = constraint.maxWidth * 0.8;

              containerWidth = containerWidth > 900 ? 900 : containerWidth;
              containerHeight = containerHeight > 500 ? 500 : containerHeight;
          return GestureDetector(
              onTap: flip,
              child: Draggable(
                rootOverlay: true,
                feedback:  FeedbackCard(angle == 0 ? widget.card.keys.first : widget.card.values.first,
                                        widget.color, know, containerHeight, containerWidth,
                                        key: _feedbackKey,),
                onDraggableCanceled: (velocity, offset){
                  swipeEnd(); // there is no target for the drag, it will always be canceled
                },
                onDragUpdate: (details){
                  onDragUpdated(details);
                },
                onDragStarted: (){
                  setState(() {
                    dragStarted = true;
                  });
                },
                childWhenDragging: Text(know == 1 ? 'Know'.i18n().toUpperCase() : know != 0 ?  'Learning'.i18n().toUpperCase() : '',
                  style: TextStyle(
                    fontSize: 26,
                    color: know == 1 ? Colors.green.withAlpha(200) : Colors.red.withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child:  SizedBox(
                  width: containerWidth,
                  height: containerHeight,
                  child:TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: angle),
                      duration: const Duration(milliseconds: 300),
                      onEnd: () {
                        if(swipe) {
                          nextCard();
                        }
                      },
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
                                      color: widget.color.withAlpha(80),
                                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(child:
                                      AutoSizeText(widget.card.keys.first,
                                        style: const TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      )),
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
                                          color: widget.color.withAlpha(80),
                                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(child:
                                          AutoSizeText(
                                            widget.card.values.first,
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
                )
                )
              );
            },
          ),
        ),
      ),
    );
  }
}

class FeedbackCard extends StatefulWidget{
  const FeedbackCard(this.text, this.color, this.know, this.containerHeight, this.containerWidth, {super.key});

  @override
  State<StatefulWidget> createState() => _FeedbackCard();

  final String text;
  final Color color;

  final double containerWidth;
  final double containerHeight;

  final int know;
}

class _FeedbackCard extends State<FeedbackCard>{

  late String text = widget.text;

  late double containerWidth = widget.containerWidth;
  late double containerHeight = widget.containerHeight;

  late int know  = widget.know;

  void update(int k, double width, double height){
    setState(() {
      know = k;
      containerWidth = width;
      containerHeight = height;
    });
  }

  void updateText(String txt){
    setState(() {
      text = txt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: SizedBox(
        width: containerWidth,
        height: containerHeight,
        child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    side: know != 0
                        ? BorderSide(width: 4.0,
                        color: know == 1 ? Colors.green.withAlpha(200) : Colors.red.withAlpha(200)): BorderSide.none
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color.withAlpha(80),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(child: AutoSizeText(text,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
              ),
        ),
      );
  }

}

class FlipCard extends StatefulWidget{
  final Color color;

  final double containerWidth;
  final double containerHeight;

  final Function()? onFlipEnd;

  final String top;
  final String bottom;

  const FlipCard({super.key, required this.color, required this.containerWidth, required this.containerHeight, required this.onFlipEnd, required this.top, required this.bottom});

  @override
  State<StatefulWidget> createState()=> PFlipCard();

}

class PFlipCard extends State<FlipCard>{
  late int side = 0;
  double angle = 0;
  int know = 0;

  void update(int k) {
    setState(() {
      know = k;
    });
  }

  void flip(){
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.containerWidth,
      height: widget.containerHeight,
      child:TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: angle),
          duration: const Duration(milliseconds: 250),
          onEnd: widget.onFlipEnd,
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
                          color: widget.color.withAlpha(80),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(child: AutoSizeText(widget.top,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          )),
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
                              color: widget.color.withAlpha(80),
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
    );
  }


}

