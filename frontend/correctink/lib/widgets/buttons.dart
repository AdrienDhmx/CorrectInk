import 'package:flutter/material.dart';

Widget inkButton({
  required Widget child,
  required Function() onTap,
  Function()? onLongPress,
  double? width,
  double? height,
}){
  return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
            child: child
        ),
      )
  );
}