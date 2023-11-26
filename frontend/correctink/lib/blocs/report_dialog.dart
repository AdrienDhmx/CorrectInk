import 'package:correctink/app/data/models/schemas.dart';
import 'package:correctink/app/data/repositories/realm_services.dart';
import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../utils/message_utils.dart';
import '../widgets/buttons.dart';
import '../widgets/widgets.dart';

class ReportSetDialog extends StatefulWidget {
  final CardSet set;

  const ReportSetDialog({super.key, required this.set});

  @override
  State<StatefulWidget> createState() => _ReportSetDialog();
}

class _ReportType {
  final ReportType reportType;
  late bool isSelected = false;

  _ReportType(this.reportType);
}

class _ReportSetDialog extends State<ReportSetDialog> {
  late List<_ReportType> reportTypes = <_ReportType>[];
  List<_ReportType> get selectedReasons => reportTypes.where((report) => report.isSelected).toList();
  late bool additionalInformationRequired = false;
  late bool invalidReport = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    for(ReportType reportType in ReportType.values) {
      reportTypes.add(_ReportType(reportType));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Report set".i18n()),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      contentPadding: const EdgeInsets.all(16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Select at least 1 inappropriate reason.".i18n(),
              style: invalidReport && selectedReasons.isEmpty
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
            ),
            const SizedBox(height: 8,),
            for(_ReportType reportType in reportTypes)
              customCheckButton(context,
                  label: reportType.reportType.translatedName,
                  isChecked: reportType.isSelected,
                  onPressed: (bool selected) {
                      setState(() {
                        reportType.isSelected = selected;
                        if(reportType.reportType == ReportType.other) {
                          additionalInformationRequired = selected;
                        }
                      });
                  },
                infiniteWidth: false,
                center: false,
              ),

            multilineField(
              _textEditingController,
              labelText: additionalInformationRequired
                  ? "${"Additional information".i18n()} (${"Required".i18n()})"
                  : "Additional information".i18n(),
              hintText: "",
              labelStyle: invalidReport && additionalInformationRequired && _textEditingController.text.trim().isEmpty
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
          ],
        ),
      ),
      contentTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface
      ),
      actions: [
        cancelButton(context),
        okButton(context, "Report".i18n(),
          onPressed: () {
            if((additionalInformationRequired && _textEditingController.text.trim().isEmpty)
                || selectedReasons.isEmpty) {
              setState(() {
                invalidReport = true;
              });
              return;
            }

            Report finalReport = Report(
                selectedReasons.map((report) => report.reportType).toList(),
                _textEditingController.text
            );

            RealmServices realmServices = Provider.of(context, listen: false);
            InboxService inboxService = Provider.of(context, listen: false);
            ReportMessage reportMessage = finalReport.toReportMessage(widget.set, widget.set.owner!, realmServices.userService.currentUserData!);

            realmServices.userService.addReportedSet(widget.set);
            realmServices.setCollection.reportSet(widget.set, reportMessage);
            inboxService.sendReport(reportMessage);

            GoRouter.of(context).pop();
            successMessageSnackBar(context, "Set reported".i18n(), description: "Reported content thank you".i18n(), icon: Icons.report_rounded).show(context);
          }
        ),
      ],
    );
  }
}