import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:correctink/realm/schemas.dart';

class FlipCard extends StatefulWidget{
  const FlipCard(this.card, this.side, this.color, this.onSwap, {super.key});

  final KeyValueCard card;
  final int side;
  final Color color;
  final Function(bool know) onSwap;

  @override
  State<StatefulWidget> createState() => _FlipCard();

}

class _FlipCard extends State<FlipCard>{
  late int side = widget.side;
  double angle = 0;

  double containerWidth = 150;
  double containerHeight = 200;

  bool swipe = false;
  int know = 0;

  void flip(){
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  void nextCard(){
    if (know != 0) {
      widget.onSwap(know > 0);
    }
    setState(() {
      know = 0;
    });
    swipe = false;
  }
  
  void swipeEnd(){
    swipe = true;
    if(angle != 0) {
      setState(() {
        angle = 0;
      });
    }
    else {
      nextCard();
    }
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
              onPanUpdate: (details) {
                var offset = (constraint.maxWidth - containerWidth) / 2;
                // Swiping in right direction.
                if (details.localPosition.dx > constraint.maxWidth / 2 - offset + 40) {
                  setState(() {
                    know = 1;
                  });
                } else if (details.localPosition.dx < constraint.maxWidth / 2 - offset - 40) {
                  setState(() {
                    know = -1;
                  });
                }
                else {
                  setState(() {
                    know = 0;
                  });
                }
              },
              onPanCancel: () {
                setState(() {
                  know = 0;
                });
              },
              onPanEnd: (details) {
                swipeEnd();
              },
              child: SizedBox(
                height: containerHeight,
                width: containerWidth,
                child: TweenAnimationBuilder(
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
                      return (Transform(
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
                                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(child: Text(widget.card.key,
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
                                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(child: Text(
                                      widget.card.value,
                                      style: const TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    )),
                                  ),
                                ),
                              )
                          )
                      ));
                    }
                ),
              )
              );
            },
          ),
        ),
      ),
    );
  }
}
