
import 'dart:io';

import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../main.dart';
import '../realm/schemas.dart';
import '../theme.dart';

Widget formLayout(BuildContext context, Widget? contentWidget) {
  return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        elevation: 1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Theme.of(context).colorScheme.surface,
        child: Container(
            padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(20, 15, 15, 10) : const EdgeInsets.fromLTRB(30, 25, 30, 10),
            child: Center(
              child: contentWidget,
            )),
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
    {required void Function() onPressed, IconData icon = Icons.add, String tooltip = 'Add', String heroTag = 'hero1'}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: FloatingActionButton(
      heroTag: heroTag,
      elevation: 2,
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
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

deadlineInfo({required BuildContext context, required Task task}){
  if(task.hasDeadline && !task.isComplete){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.calendar_month_rounded, color: task.deadline!.getDeadlineColor(context, task.isComplete), size: 14,),
        const SizedBox(width: 4,),
        Text(task.deadline!.getWrittenFormat(), style: task.deadline!.getDeadlineStyle(context, task.isComplete),),
      ],
    );
  }
  return const SizedBox();
}

reminderInfo({required BuildContext context, required Task task}){
  if(task.hasReminder) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary, size: 14,),
        const SizedBox(width: 4,),
        Text(task.reminder!.getWrittenFormat(), style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600
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

