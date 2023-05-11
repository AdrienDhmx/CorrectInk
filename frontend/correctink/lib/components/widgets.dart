import 'dart:io';

import 'package:correctink/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';
import '../realm/schemas.dart';
import '../theme.dart';

Widget formLayout(BuildContext context, Widget? contentWidget) {
  return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        elevation: 1,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 25),
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
          textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 20)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)))),
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
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 20.0)),
      ),
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
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
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 20.0)),
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
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(horizontal: 20.0)),
      ),
      onPressed: onPressed,
      child: const Text('Delete'),
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
    {required void Function() onPressed, IconData icon = Icons.add, String tooltip = 'Add'}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: FloatingActionButton(
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

Widget labeledAction({required BuildContext context, required Widget child, required String label, double? width, bool labelFirst = true}){
  return SizedBox(
      width: width?? Size.infinite.width,
      child:Row(
        mainAxisAlignment: width == null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if(labelFirst) Text(label, style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: Platform.isIOS || Platform.isAndroid ? 14 : 16
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: child,
          ),
          if(!labelFirst)Text(label, style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: Platform.isIOS || Platform.isAndroid ? 14 : 16
          )),
        ]
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
    initialTime: TimeOfDay.fromDateTime(selectedDate),
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

profileInfo({required BuildContext context, required Users? user}){
  if(user == null || !user.isValid) return const SizedBox();

  return
    Column(
      children: [
        Text('You are connected as ', style: Theme.of(context).textTheme.titleMedium,),
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
        if(user.studyStreak > 1) Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0,8.0),
          child: Text('Current study streak: ${user.studyStreak} days'),
        ),
        TextButton(
          style: flatTextButton(
            Theme.of(context).colorScheme.surfaceVariant,
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () async {
            GoRouter.of(context).push(RouterHelper.settingsAccountRoute);
          },
          child: iconTextCard(Icons.account_circle_rounded, 'Modify account'),
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

