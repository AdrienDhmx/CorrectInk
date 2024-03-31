import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../utils/router_helper.dart';
import '../utils/utils.dart';

primaryTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),)),
  );
}

surfaceTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onSurface),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),)),
  );
}

errorTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.error),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onError),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),)),
  );
}

secondaryTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onSecondary),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),)),
  );
}

customTextButtonStyle(BuildContext context, Color bgColor, Color color) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(bgColor),
    foregroundColor: MaterialStatePropertyAll(color),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),)),
  );
}

flatTextButton(Color bgColor, Color foreground){
  return TextButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: foreground,
      minimumSize: const Size(100, 50),
      maximumSize: const Size(340, 60),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ));
}

Widget backButton(BuildContext context){
  return IconButton(
    onPressed: () {
      if(GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop();
      } else {
        GoRouter.of(context).go(RouterHelper.taskLibraryRoute);
      }
    },
    icon: const Icon(Icons.navigate_before),
  );
}

Widget elevatedButton(BuildContext context,
    {void Function()? onPressed, Widget? child, double width = 250, Color? background, Color? color}) {
  return Container(
    height: 50,
    width: width,
    margin: const EdgeInsets.symmetric(vertical: 25),
    child: ElevatedButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(color ?? Theme.of(context).colorScheme.onBackground),
          textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: color ?? Theme.of(context).colorScheme.onBackground, fontSize: 20)),
          backgroundColor: background != null ? MaterialStateProperty.all<Color>(background) : null,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)))),
      onPressed: onPressed,
      child: child,
    ),
  );
}

Widget linkButton(BuildContext context, {required String text, void Function()? onPressed}){
  return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.focused) || states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                return const TextStyle(fontSize: 16, decoration: TextDecoration.underline);
              }
              return const TextStyle(fontSize: 16, decoration: TextDecoration.none);
            }),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.transparent;
            }),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.transparent;
            }),

      ),
      child: Text(text)
  );
}

Widget templateButton(BuildContext context,
    {String text = "button",
      void Function()? onPressed}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    child: ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surfaceVariant)),
      onPressed: onPressed,
      child: Text(text),
    ),
  );
}

Widget templateIconButton(BuildContext context, {String text = "button", IconData? icon, void Function()? onPressed}){
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    child: ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryContainer),
          foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimaryContainer)
      ),
      onPressed: onPressed,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.add),
            const SizedBox(width: 10.0,),
            Text(text, style: const TextStyle(fontSize: 16)),
          ]),
    ),
  );
}

Widget cancelButton(BuildContext context, {Function? onCancel, String text = "Cancel"}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0),
    child: TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
        foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurfaceVariant),
        minimumSize: MaterialStateProperty.all(const Size(90, 40)),
        padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 15.0) : const EdgeInsets.symmetric(horizontal: 20.0)),
      ),
      onPressed: () {
        if(onCancel != null) {
          onCancel();
        }
        Navigator.pop(context);
      },
      child: Text(text.i18n()),
    ),
  );
}

Widget okButton(BuildContext context, String text,
    {void Function()? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0),
    child: TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primaryContainer),
        foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryContainer),
        minimumSize: MaterialStateProperty.all(const Size(90, 40)),
        padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 15.0) : const EdgeInsets.symmetric(horizontal: 20.0)),
      ),
      onPressed: onPressed,
      child: Text(text),
    ),
  );
}

pushButton(BuildContext context, {Function()? onTap}) {
  return Material(
    elevation: 1,
    color: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(6),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
          width: 40,
          height: 30,
          child: Icon(Icons.keyboard_arrow_up_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer,)),
    ),
  );
}

Widget deleteButton(BuildContext context, {void Function()? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0),
    child: TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.errorContainer),
        foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onErrorContainer),
        minimumSize: MaterialStateProperty.all(const Size(90, 40)),
        padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 15.0) : const EdgeInsets.symmetric(horizontal: 20.0)),
      ),
      onPressed: onPressed,
      child: Text('Delete'.i18n()),
    ),
  );
}

Widget styledFloatingButton(BuildContext context,
    {required void Function() onPressed, IconData icon = Icons.add, String tooltip = 'Add', String heroTag = 'hero1', ShapeBorder? shape}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: FloatingActionButton(
      heroTag: heroTag,
      elevation: 2,
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      shape: shape,
      onPressed: onPressed,
      tooltip: tooltip,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          child: Icon(icon),
        ),
      ),
    ),
  );
}

RadioListTile<bool> radioButton(
    String text, bool value, ValueNotifier<bool> controller) {
  return RadioListTile(
    title: Text(text, style: TextStyle(fontSize: Utils.isOnPhone() ? 13 : 16),),
    visualDensity: Utils.isOnPhone() ? VisualDensity.compact : VisualDensity.standard,
    value: value,
    onChanged: (v) => controller.value = v ?? false,
    groupValue: controller.value,
  );
}

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

Widget customRadioButton(BuildContext context, {required String label, required bool isSelected, required Function() onPressed, double? width, bool center = true, Color? color, bool infiniteWidth = true}){
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  return labeledAction(context: context,
    width: width,
    height: 40,
    child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.onBackground,
                width: 2,
                strokeAlign: BorderSide.strokeAlignCenter
            )
        ),
        child: Center(
          child: SizedBox(
            height: 10,
            width: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    ),
    label: label,
    labelFirst: false,
    onTapAction: onPressed,
    center: center,
    color: color,
    infiniteWidth: infiniteWidth,
  );
}

Widget customCheckButton(BuildContext context, {required String label, required bool isChecked, required Function(bool value) onPressed, double? width, bool center = true, Color? color, bool infiniteWidth = true}){
  return labeledAction(context: context,
    width: width,
    height: 40,
    child: Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Checkbox(value: isChecked,
        onChanged: (bool? value) {
          onPressed(!isChecked);
        },
      ),
    ),
    label: label,
    labelFirst: false,
    onTapAction: () { onPressed(!isChecked); },
    center: center,
    color: color,
    fontSize: Utils.isOnPhone() ? 13 : 15,
    infiniteWidth: infiniteWidth,
  );
}

Widget labeledAction({required BuildContext context,
  required Widget child,
  required String label,
  Function()? onTapAction,
  double? width,
  double? height,
  bool labelFirst = true,
  bool center = false,
  Color? color,
  Decoration? decoration,
  double? fontSize,
  FontWeight? fontWeigh,
  EdgeInsets? margin,
  bool infiniteWidth = true,
}){
  fontSize ??= 16;
  width ??= infiniteWidth ? Size.infinite.width : null;
  return Container(
      margin: margin?? const EdgeInsets.all(2),
      width: width,
      height: height,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          hoverColor: color?.withAlpha(10) ?? Theme.of(context).colorScheme.primary.withAlpha(10),
          splashColor: color?.withAlpha(40) ?? Theme.of(context).colorScheme.primary.withAlpha(40),
          splashFactory: InkRipple.splashFactory,
          onTap: onTapAction,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Utils.isOnPhone() ? 4 : 8),
            child: Row(
                mainAxisSize: infiniteWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  if(labelFirst) Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 6, 0),
                      child: Text(label, style: TextStyle(
                        color: color ?? Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: fontSize,
                        fontWeight: fontWeigh,
                      )),
                    ),
                  ),
                  child,
                  if(!labelFirst) Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 4, 0),
                      child: Text(label, style: TextStyle(
                        color: color ?? Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: fontSize,
                        fontWeight: fontWeigh,
                      )),
                    ),
                  ),
                ]
            ),
          ),
        ),
      )
  );
}


Widget iconPickerButton(BuildContext context, {required Icon icon, required bool isSelected, required Function() onPressed, required double width}){
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  return SizedBox(
    width: width,
    child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(width / 4)),
        hoverColor: colorScheme.secondary.withAlpha(20),
        splashColor: colorScheme.secondary.withAlpha(50),
        splashFactory: InkRipple.splashFactory,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? colorScheme.secondary.withAlpha(40) : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(width / 4)),
              border: Border.all(
                  color: isSelected ? colorScheme.secondary.withAlpha(80) : Colors.transparent,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter
              )
          ),
          child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: icon,
              )
          ),
        )
    ),
  );
}
