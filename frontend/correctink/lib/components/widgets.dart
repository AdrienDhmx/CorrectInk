
import 'dart:io';

import 'package:correctink/components/painters.dart';
import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../main.dart';
import '../realm/schemas.dart';
import '../theme.dart';

headerFooterBoxDecoration(BuildContext context, bool isHeader) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: theme.colorScheme.surfaceVariant,
    border: Border(
        top: isHeader
            ? BorderSide.none
            : BorderSide(width: 2, color: theme.primaryColor),
        bottom: isHeader
            ? BorderSide(width: 2, color: theme.primaryColor)
            : BorderSide.none),
  );
}

errorBoxDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
      border: Border.all(color: theme.colorScheme.error),
      color: theme.colorScheme.errorContainer,
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

infoBoxDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
      border: Border.all(color: theme.colorScheme.onBackground,),
      color: theme.colorScheme.background,
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

studyStreakBoxDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
      border: Border.all(color: theme.colorScheme.primary,),
      color: theme.colorScheme.surfaceVariant,
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

studyStreakTextStyle(BuildContext context) {
  return TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 16,
      fontWeight: FontWeight.bold);
}

errorTextStyle(BuildContext context, {bool bold = false}) {
  final theme = Theme.of(context);
  return TextStyle(
      color: theme.colorScheme.error,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}

infoTextStyle(BuildContext context, {bool bold = false}) {
  return TextStyle(
      color: Theme.of(context).colorScheme.onBackground,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}

boldTextStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold);
}

listTitleTextStyle(){
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
}

primaryTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),)),
  );
}

surfaceTextButtonStyle(BuildContext context) {
  return ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surfaceVariant),
    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onSurfaceVariant),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),)),
  );
}

flatTextButton(Color bgColor, Color foreground){
  return TextButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: foreground,
      minimumSize: const Size(100, 50),
      maximumSize: const Size(340, 60),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ));
}

iconTextCard(IconData icon, String text){
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 10.0,),
        Text(text, style: const TextStyle(fontSize: 16)),
      ]);
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

Widget modalLayout(BuildContext context, Widget? contentWidget) {
  return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        elevation: 1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Theme.of(context).colorScheme.surface,
        child: Container(
            padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(16, 8, 16, 8) : const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: contentWidget
        ),
      ));
}

Widget loginField(TextEditingController controller,
    {String? labelText, String? hintText, bool? obscure}) {
  return Padding(
    padding: const EdgeInsets.all(15),
    child: TextField(
        obscureText: obscure ?? false,
        controller: controller,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: labelText,
            hintText: hintText)),
  );
}

Widget loginButton(BuildContext context,
    {void Function()? onPressed, Widget? child}) {
  return Container(
    height: 50,
    width: 250,
    margin: const EdgeInsets.symmetric(vertical: 25),
    child: ElevatedButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
          textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 20)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)))),
      onPressed: onPressed,
      child: child,
    ),
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

Widget cancelButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0),
    child: TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
        foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurfaceVariant),
        minimumSize: MaterialStateProperty.all(const Size(90, 40)),
        padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 15.0) : const EdgeInsets.symmetric(horizontal: 20.0)),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'.i18n()),
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

OutlinedBorder taskCheckBoxShape(){
  return const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(3.5), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(3.5)),
  );
}

OutlinedBorder stepCheckBoxShape(){
  return const CircleBorder(side: BorderSide());
}

Widget styledBox(BuildContext context, {bool isHeader = false, Widget? child}) {
  return Container(
    decoration: headerFooterBoxDecoration(context, isHeader),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: child,
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

Container waitingIndicator() {
  return Container(
    color: Colors.black.withOpacity(0.2),
    child: const Center(child: CircularProgressIndicator()),
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
  }){
  fontSize ??= Utils.isOnPhone() ? 14 : 16;
  return Container(
      margin: margin?? const EdgeInsets.all(2),
      width: width ?? Size.infinite.width,
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
          child: Row(
            mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if(labelFirst) Flexible(
                child: Text(label, style: TextStyle(
                    color: color ?? Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: fontSize,
                    fontWeight: fontWeigh,
                    )),
              ),
              Padding(
                padding: Utils.isOnPhone() ? const EdgeInsets.all(0) : const EdgeInsets.symmetric(horizontal: 4.0),
                child: child,
              ),
              if(!labelFirst) Flexible(
                child: Text(label, style: TextStyle(
                    color: color ?? Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: fontSize,
                  fontWeight: fontWeigh,
                )),
              ),
            ]
          ),
        ),
      )
  );
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
}

deadlineInfo({required BuildContext context, required Task task, Color? defaultColor}){
  if(task.hasDeadline && !task.isComplete){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.calendar_month_rounded, color: task.deadline!.getDeadlineColor(context, task.isComplete, defaultColor: defaultColor), size: 14,),
        const SizedBox(width: 4,),
        Text(task.deadline!.getWrittenFormat(), style: task.deadline!.getDeadlineStyle(context, task.isComplete, defaultColor: defaultColor),),
      ],
    );
  }
  return const SizedBox();
}

reminderInfo({required BuildContext context, required Task task}){
  if(task.hasReminder) {
    final String repeatMode = task.reminderRepeatMode == 0 ? "" : " • ${Utils.getRepeatString(task.reminderRepeatMode)}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary, size: 14,),
        const SizedBox(width: 4,),
        Flexible(
          child: Text("${task.reminder!.getWrittenFormat()}$repeatMode", style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600
            ),
          ),
        ),
      ],
    );
  }
  return const SizedBox();

}

profileInfo({required BuildContext context, required Users? user}){
  if(user == null || !user.isValid) return const SizedBox();
  return
    Column(
      children: [
        Text("Connected as".i18n(), style: Theme.of(context).textTheme.titleMedium,),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.firstname, style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(width: 5,),
              Text(user.lastname, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if(user.lastStudySession != null) Text( "Last study session".i18n([user.lastStudySession!.format()])),
        if(user.studyStreak > 1) Text("Current study streak".i18n([user.studyStreak.toString()])),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
          child: TextButton(
            style: flatTextButton(
              Theme.of(context).colorScheme.surfaceVariant,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () async {
              GoRouter.of(context).push(RouterHelper.settingsAccountRoute);
            },
            child: iconTextCard(Icons.account_circle_rounded, 'Modify account'.i18n()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Divider(
            thickness: 1,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
}

Widget flashcardsHelp(BuildContext context){
  TextTheme myTextTheme = Theme.of(context).textTheme;
  return Column(
    children: [
      Text('Info'.i18n(), style: myTextTheme.headlineMedium,),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text('Info tap card'.i18n(), style: myTextTheme.bodyLarge, textAlign: TextAlign.center,),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text('Info swipe card'.i18n(), style: myTextTheme.bodyLarge, textAlign: TextAlign.center),
      ),
      if(!Platform.isAndroid && !Platform.isIOS)
        const Divider(),
      if(!Platform.isAndroid && !Platform.isIOS)
        Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Keyboard shortcuts'.i18n(), style: myTextTheme.headlineMedium ),
              ),
              Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(100),
                  1: FixedColumnWidth(260),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.symmetric(inside: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Keyboard space'.i18n()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Info tap card'.i18n()),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Keyboard left arrow'.i18n()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Info swipe left card".i18n()),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Keyboard right arrow'.i18n()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Info swipe right card".i18n()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );
}

Widget writtenModeHelp(BuildContext context){
  TextTheme myTextTheme = Theme.of(context).textTheme;
  return Column(
    children: [
      Text('Info'.i18n(), style: myTextTheme.headlineMedium,),
      const SizedBox(height: 8,),
      Text('Info written mode'.i18n(), textAlign: TextAlign.center, style: myTextTheme.bodyLarge,),
      const SizedBox(height: 2,),
      Text('Info written lenient mode'.i18n(), textAlign: TextAlign.center, style: myTextTheme.bodyLarge,),
      const SizedBox(height: 4,),
      if(!Platform.isAndroid && !Platform.isIOS)
        const Divider(),
      if(!Platform.isAndroid && !Platform.isIOS)
        Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Keyboard shortcuts'.i18n(), style: myTextTheme.headlineMedium ),
            ),
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(160),
                1: FixedColumnWidth(300),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.symmetric(inside: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Keyboard enter'.i18n()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Info written mode enter'.i18n()),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Keyboard ctrl enter'.i18n()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Info written mode ctrl enter'.i18n()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget colorDisplay({
  required Color color,
  required bool selected,
  Color? secondaryColor,
  Color? tertiaryColor,
  Color? background,
  Color? foreground,
  Function()? onPressed,
  double size = 40,
}){
  return Container(
    width: size,
    height: size,
    padding: background == null ? const EdgeInsets.all(0) :  EdgeInsets.all(size/8),
    decoration: background != null ? BoxDecoration(
      color: background,
      borderRadius: BorderRadius.all(Radius.circular(size/8))
    ): null,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(size/2)),
        hoverColor: background?.withOpacity(1),
        splashColor: background?.withOpacity(1),
        splashFactory: InkRipple.splashFactory,
        enableFeedback: true,
        excludeFromSemantics: false,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Stack(
            children: [
              if(secondaryColor != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: SemiCircle(
                    color: secondaryColor,
                    diameter: size,
                    upSide: true,
                  ),
                ),
              if(secondaryColor != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SemiCircle(
                    color: tertiaryColor ?? secondaryColor,
                    diameter: size,
                    upSide: false,
                  ),
                ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(secondaryColor == null ? 0 : size/7),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                ),
              ),
              if(selected)
                  Center(
                    child: Icon(Icons.check_circle, color: foreground, size: secondaryColor == null && background == null ? size * 0.8 : secondaryColor == null || background == null ?  size * 0.5 : size * 0.28,)
                  )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget setColorsPicker({
  required BuildContext context,
  required int selectedIndex,
  required Function(int index) onPressed,
  ScrollController? controller,
}){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: SizedBox(
      height: 60,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemExtent: 60,
        shrinkWrap: true,
        itemCount: ThemeProvider.setColors.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if(index == 0) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: colorDisplay(
                color: Theme.of(context).colorScheme.onBackground,
                selected: selectedIndex == ThemeProvider.setColors.length,
                background: Theme.of(context).colorScheme.onBackground.withAlpha(50),
                foreground: Theme.of(context).colorScheme.background.withAlpha(140),
                onPressed: () => onPressed(index),
                size: 50,
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: colorDisplay(
                color: ThemeProvider.setColors[index - 1],
                background: ThemeProvider.setColors[index - 1].withAlpha(50),
                foreground: Theme.of(context).colorScheme.background.withAlpha(140),
                selected:  selectedIndex == index - 1,
                onPressed: () => onPressed(index),
                size: 50,
              ),
            );
          }
        },
      ),
    ),
  );
}

