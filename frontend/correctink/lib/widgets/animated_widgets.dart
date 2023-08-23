import 'dart:math';

import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {

  final Widget child;
  final bool expand;
  final int duration;
  final Axis axis;
  final double startValue;
  const ExpandedSection({super.key, this.expand = false, required this.child, this.duration = 500, this.axis = Axis.vertical, this.startValue = 0});

  @override
  State createState() => _ExpandedSectionState();
}
class _ExpandedSectionState extends State<ExpandedSection> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration)
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    expandController.value = widget.startValue;
  }

  void _runExpandCheck() {
    if(widget.expand) {
      expandController.forward();
    }
    else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: widget.axis,
        axisAlignment: 1.0,
        sizeFactor: animation,
        child: widget.child
    );
  }
}

class SortDirectionButton extends StatefulWidget {
  final bool sortDir;
  final Function(bool) onChange;
  final double initAngle;

  const SortDirectionButton({super.key, required this.sortDir, required this.onChange, required this.initAngle});

  @override
  State<StatefulWidget> createState() => _SortDirectionButton();
}

class _SortDirectionButton extends State<SortDirectionButton> {
  late double arrowAngle = widget.initAngle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          arrowAngle = (arrowAngle + pi) % (2 * pi);
        });
        widget.onChange(!widget.sortDir);
      },
      icon: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: arrowAngle),
        duration: const Duration(milliseconds: 250),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform(
            alignment: Alignment.center,
            transform:  Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(value),
            child: const Icon(Icons.keyboard_arrow_up_rounded, size: 30,),
          );
        },
      ),
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

}