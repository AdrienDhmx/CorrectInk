import 'package:correctink/app/services/localization.dart';
import 'package:correctink/widgets/painters.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../app/data/models/schemas.dart';
import '../app/services/theme.dart';
import '../utils/markdown_extension.dart';
import '../utils/router_helper.dart';
import 'buttons.dart';

headerFooterBoxDecoration(BuildContext context, bool isHeader) {
  final theme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: ElevationOverlay.applySurfaceTint(theme.surface, theme.surfaceTint, 5),
    border: Border(
        top: isHeader
            ? BorderSide.none
            : BorderSide(width: 2, color: theme.primary.withAlpha(120)),
        bottom: isHeader
            ? BorderSide(width: 2, color: theme.primary.withAlpha(120))
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

errorTextStyle(BuildContext context, {bool bold = false}) {
  final theme = Theme.of(context);
  return TextStyle(
      color: theme.colorScheme.error,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal
  );
}

infoTextStyle(BuildContext context, {bool bold = false}) {
  return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}

boldTextStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold);
}

listTitleTextStyle(){
  return const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
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

Widget modalLayout(BuildContext context, Widget? contentWidget) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
    child: SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Material(
            elevation: 1,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
                padding: Utils.isOnPhone() ? const EdgeInsets.fromLTRB(16, 8, 16, 8) : const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: contentWidget,
            ),
          )),
    ),
  );
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
            hintText: hintText
        )
    ),
  );
}

Widget multilineField(TextEditingController controller,
    {String? labelText, String? hintText, InputBorder inputBorder = const OutlineInputBorder(), TextStyle? labelStyle,
      int? maxLength = 250,
      int? maxLines,}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: TextField(
        obscureText: false,
        controller: controller,
        keyboardType: TextInputType.multiline,
        minLines: null,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: InputDecoration(
            border: inputBorder,
            labelText: labelText,
            hintText: hintText,
            labelStyle: labelStyle,
        )
    ),
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

Widget styledHeaderFooterBox(BuildContext context, {bool isHeader = false, Widget? child}) {
  return Container(
    decoration: headerFooterBoxDecoration(context, isHeader),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: child,
    ),
  );
}

Widget styledBox(BuildContext context, {
    required Widget child,
    Color? background,
    double borderRadius = 0,
    bool showBorder = false,
    Color? borderColor,
    double? width
}) {
  final theme = Theme.of(context).colorScheme;
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    decoration: BoxDecoration(
      color: ElevationOverlay.applySurfaceTint(theme.surface, background ?? theme.surfaceTint, 5),
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder ? Border.all(
        color: borderColor ?? theme.primary.withAlpha(180)
      ) : null,
    ),
    child: child,
  );
}

Container waitingIndicator() {
  return Container(
    color: Colors.black.withOpacity(0.2),
    child: const Center(child: CircularProgressIndicator()),
  );
}

Widget placeHolder({required bool condition, required Widget placeholder, required Widget child, }) {
  if(condition) {
    return child;
  }
  return placeholder;
}

Widget textPlaceHolder(BuildContext context, {required bool condition, required String placeholder, required Widget child, }) {
  return placeHolder(
      condition: condition,
      placeholder: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            placeholder,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      child: child
  );
}

void showBottomSheetModal(BuildContext context, Widget child, {bool isDismissible = true, BoxConstraints? constraints}) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    enableDrag: isDismissible,
    isDismissible: isDismissible,
    constraints: constraints,
    builder: (_) => Wrap(children: [child]),
  );
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final savedInitialDate = initialDate;
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: LocalizationProvider.locale,
  );

  if (selectedDate == null) return savedInitialDate;

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
    final TextStyle style = task.deadline!.getDeadlineStyle(context, task.isComplete, defaultColor: defaultColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_month_rounded, color: style.color, size: 14,),
        const SizedBox(width: 4,),
        Text(task.deadline!.getWrittenFormat(), style: style,),
      ],
    );
  }
  return const SizedBox();
}

reminderInfo({required BuildContext context, required Task task, Color? defaultColor}){
  if(task.hasReminder) {
    final String repeatMode = task.reminderRepeatMode == 0 ? "" : " • ${Utils.getRepeatString(task.reminderRepeatMode)}";
    final TextStyle style = task.reminder!.getReminderStyle(context, defaultColor: defaultColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.notifications_active_rounded, color: style.color, size: 14,),
        const SizedBox(width: 4,),
        Flexible(
          child: Text("${task.reminder!.getWrittenFormat()}$repeatMode", style: style,
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
    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                selected: selectedIndex == ThemeProvider.setColors.length,
                background: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(50),
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

void deleteConfirmationDialog(BuildContext context, {required String title, required String content, required Function() onDelete}){
  showDialog<void>(context: context, builder: (context){
    return AlertDialog(
      title: Text(title),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: SizedBox(
        height: 60,
        width: 320,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(content,),
        ),
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface
      ),
      actions: [
       TextButton(
           onPressed: () { GoRouter.of(context).pop(); },
           style: ButtonStyle(
             foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
             minimumSize: MaterialStateProperty.all(const Size(90, 40)),
             padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 10.0) : const EdgeInsets.symmetric(horizontal: 15.0)),
           ),
           child: Text(
             "Cancel".i18n(),
             textAlign: TextAlign.end,
           )
       ),
        TextButton(
            onPressed: onDelete,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if(states.contains(MaterialState.hovered)){
                  return Theme.of(context).colorScheme.errorContainer;
                }
                return Colors.transparent;
              }),
              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.error),
              minimumSize: MaterialStateProperty.all(const Size(90, 40)),
              padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 10.0) : const EdgeInsets.symmetric(horizontal: 15.0)),
            ),
            child: Text(
              "Delete".i18n(),
              textAlign: TextAlign.end,
            )
        )
      ],
    );
  });
}

void reportActionConfirmationDialog(BuildContext context, {required String title, required String content, required Function(String) onConfirm}) {
  TextEditingController controller = TextEditingController();
  showDialog<void>(context: context, builder: (context){
    return AlertDialog(
      title: Text(title),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      contentPadding: const EdgeInsets.all(16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 40,
                child: MarkdownBody(
                    data: content,
                  softLineBreak: true,
                  builders: MarkdownUtils.styleSheet(),
                  styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                  styleSheet: MarkdownUtils.getStyle(context),
                ),
            ),
            const SizedBox(height: 8,),
            multilineField(controller,
              labelText: "Explain decision".i18n(),
              maxLines: 4
            )
          ],
        ),
      ),
      actions: [
        cancelButton(context),
        okButton(context, "Confirm".i18n(), onPressed: () {
            onConfirm(controller.text);
            GoRouter.of(context).pop();
          },
        ),
      ],
    );
  });
}

Widget errorTip(BuildContext context, {required String tip}) {
  return Material(
    elevation: 1,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18,),
          const SizedBox(width: 8,),
          Flexible(child: Text(tip, textAlign: TextAlign.start, style: errorTextStyle(context))),
        ],
      ),
    ),
  );
}