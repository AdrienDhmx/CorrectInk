import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {

  final Widget child;
  final bool expand;
  final int duration;
  final Axis axis;
  const ExpandedSection({super.key, this.expand = false, required this.child, this.duration = 500, this.axis = Axis.vertical});

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

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration)
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
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