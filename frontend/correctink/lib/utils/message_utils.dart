import 'package:correctink/app/data/repositories/realm_services.dart';
import 'package:correctink/app/services/inbox_service.dart';
import 'package:correctink/app/services/theme.dart';
import 'package:correctink/utils/router_helper.dart';
import 'package:correctink/utils/utils.dart';
import 'package:correctink/widgets/snackbars_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:objectid/objectid.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/data/models/schemas.dart';
import '../widgets/widgets.dart';

enum MessageIcons{
  none(type: -1, icon: Icons.not_interested_rounded, color: Colors.transparent),
  congrats(type: 0, icon: Icons.celebration_rounded, color: Colors.transparent),
  notes(type: 1, icon: Icons.note_rounded, color: ThemeProvider.whiskey),
  editNote(type: 2, icon: Icons.edit_note_rounded, color: ThemeProvider.azure),
  tip(type: 3, icon: Icons.tips_and_updates_rounded, color: ThemeProvider.tacha),
  person(type: 4, icon: Icons.person_rounded, color: ThemeProvider.moodyBlue),
  release(type: 5, icon: Icons.new_releases_rounded, color: ThemeProvider.chestnutRose),
  report(type: 6, icon: Icons.report_rounded, color: Colors.transparent),
  warning(type: 7, icon: Icons.warning_rounded, color: ThemeProvider.whiskey),
  chat(type: 8, icon: Icons.chat_rounded, color: ThemeProvider.azure),
  mail(type: 9, icon: Icons.mail_rounded, color: ThemeProvider.japaneseLaurel),
  time(type: 10, icon: Icons.access_time_filled_rounded, color: ThemeProvider.downy),
  calendar(type: 11, icon: Icons.calendar_month_rounded, color: ThemeProvider.amethyst),
  premium(type: 12, icon: Icons.workspace_premium_rounded, color: ThemeProvider.tacha),
  landscape(type: 13, icon: Icons.landscape_rounded, color: ThemeProvider.conifer),
  book(type: 14, icon: Icons.book_rounded, color: ThemeProvider.eden),
  ramen(type: 15, icon: Icons.ramen_dining_rounded, color: ThemeProvider.copper);

  const MessageIcons({required this.type, required this.icon, required this.color});

  final int type;
  final IconData icon;
  final Color color;

  Icon getIcon(BuildContext context, {bool big = false}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    double size = big ? 32 : 22;
    switch (type) {
      case -1:
        return Icon(Icons.not_interested_rounded, color: colorScheme.onSurfaceVariant, size: size,);
      case 0:
        return Icon(Icons.celebration_rounded, color: colorScheme.primary, size: size,);
      case 6:
        return Icon(Icons.report_rounded, color: colorScheme.error, size: size,);
      default:
        MessageIcons icon = MessageIcons.values[type + 1]; // +1 because it start at -1
        return Icon(icon.icon, color: icon.color, size: size);
    }
  }
}

enum MessageDestination {
  everyone(destination: 0, name: "Everyone"),
  moderator(destination: 8, name: "Moderator"),
  admin(destination: 10, name: "Admin");

  const MessageDestination({required this.destination, required this.name});

  final int destination;
  final String name;

  String get translatedName => name.i18n();
}

enum ReportType {
  hate(type: 0, name: "Content promoting hate, racism, sexism, or discrimination"),
  sexual(type: 1, name: "Inappropriate sexual content or references"),
  violent(type: 2, name: "Violent or Harmful content"),
  privacy(type: 3, name: "Personal information"),
  misinformation(type: 4, name: "Misinformation or misleading information"),
  copyright(type: 5, name: "Copyrighted content"),
  other(type: 6, name: "Other");

  const ReportType({required this.type, required this.name});

  final int type;
  final String name;

  String get translatedName => name.i18n();
}

enum ReportAction {
  warn(type: 0, name: "Warn_the_user"),
  blockSet(type: 1, name: "Block_the_set"),
  blockUser(type: 2, name: "Block_the_user"),
  setAppropriate(type: 3, name: "Set_not_inappropriate");

  const ReportAction({required this.type, required this.name});

  final int type;
  final String name;

  String get translatedName => name.i18n();
}

class Report {
  final List<ReportType> types;
  final String additionalInformation;

  Report(this.types, this.additionalInformation);

  ReportMessage toReportMessage(FlashcardSet set, Users reportedUser, Users reportingUser) {
    return ReportMessage(ObjectId(), set.reportCount, additionalInformation, -1, "", DateTime.now().toUtc(), previousReport: set.lastReport, reportedSet: set, reportedUser: reportedUser, reportingUser: reportingUser, reasons: types.map((reason) => reason.type.toString()).toList(),);
  }
}

class MessageHelper {
  static const String linkToFormat = "linkto";
  static const String linkToSetFormat = "linktoSet:";
  static const String linkToUserFormat = "linktoUser:";
  static const String linkToMessageFormat = "linktoMessage:";
  static const String linkToReportMessageFormat = "linktoReportMessage:";

  static const String actionFormat = "action:";

  static String buildLinkTemplate(String linkTo) {
    return "<$linkToFormat:$linkTo>";
  }

  static String buildSetLinkMessage(FlashcardSet set) {
    return "*[${set.name}]($linkToSetFormat${set.id.hexString})*";
  }

  static String buildUserLinkMessage(Users user) {
    return "**[${user.name}]($linkToUserFormat${user.userId.hexString})**";
  }

  static String buildMessageLinkMessage(Message message) {
    return "*[${message.title}]($linkToMessageFormat${message.messageId.hexString})*";
  }

  static String buildMessageLinkReportMessage(ReportMessage report, String placeholder) {
    return "[$placeholder]($linkToReportMessageFormat${report.reportMessageId.hexString})";
  }

  static String buildActionTemplate(String action) {
    return "<$actionFormat$action>";
  }

  static String buildActionMessage(String action) {
    return "[$action]($actionFormat$action)";
  }
  
  static void onLinkClicked(BuildContext context, String link) {
    if(!onCorrectInkLinkClicked(context, link)) {
      launchUrl(Uri.parse(link));
    }
  }

  static void onReportLinkClicked(BuildContext context, String link, ReportMessage report) {
    if(!onCorrectInkLinkClicked(context, link)) {
      if(link.startsWith(actionFormat)) {
        _executeModeratorChoice(context, link.split(":")[1], report);
      } else {
        launchUrl(Uri.parse(link));
      }
    }
  }

  static bool onCorrectInkLinkClicked(BuildContext context, String link) {
    if(link.startsWith(MessageHelper.linkToFormat)) {
      String linkDestination = link.split(":")[0];
      String id = link.split(":")[1];

      switch("$linkDestination:") {
        case MessageHelper.linkToSetFormat:
          GoRouter.of(context).push(RouterHelper.buildSetRoute(id));
          return true;
        case MessageHelper.linkToUserFormat:
          GoRouter.of(context).push(RouterHelper.buildProfileRoute(id));
          return true;
        case MessageHelper.linkToMessageFormat:
          GoRouter.of(context).push(RouterHelper.buildInboxMessageRoute(id, false));
          return true;
        case MessageHelper.linkToReportMessageFormat:
          GoRouter.of(context).push(RouterHelper.buildInboxMessageRoute(id, false, isReportMessage: true));
          return true;
        default:
          break;
      }
    }
    return false;
  }

  static void _executeModeratorChoice(BuildContext context, String action, ReportMessage report) {
    if(report.reportedSet == null || report.reportedUser == null) {
      errorMessageSnackBar(context, "Error".i18n(), "Invalid report").show(context);
      return;
    }

    RealmServices realmServices = Provider.of(context, listen: false);
    InboxService inboxService = Provider.of(context, listen: false);

    String actionMessageContent = "";
    Function() onConfirm = () {

    };

    String titleInappropriate = "Message title content inappropriate".i18n();
    String titleOutcome = "Message title report outcome".i18n();

    String actionTakenMessage = "Template report notify outcome action taken".i18n();

    ReportAction reportAction = ReportAction.values.firstWhere((a) => a.name == action);
    String reasons = formatReasons(report.reasons);
    int reportedMessageIcon = MessageIcons.warning.type;
    int outcomeMessageIcon = MessageIcons.editNote.type;
    switch(reportAction) {
      case ReportAction.warn:
        actionMessageContent = "Template report action warn".i18n();
        onConfirm = () {
          String message = parseActionMessage("Template report outcome warn".i18n(), set: report.reportedSet!, user: report.reportedUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(titleInappropriate, message, reportedMessageIcon, report.reportedUser!);

          if(report.reportingUser != null) {
            message = parseUserReportingMessage("Template report notify outcome action warn".i18n(), user: report.reportingUser!, reasons: reasons);
            inboxService.sendAutomaticMessageToUser(titleOutcome, message, outcomeMessageIcon, report.reportingUser!);
          }
        };
        break;
      case ReportAction.blockSet:
        actionMessageContent = "Template report action block set".i18n();
        onConfirm = () {
          realmServices.realm.writeAsync(() {
            report.reportedSet!.blocked = true;
            report.reportedSet!.isPublic = false;
          });

          String message = parseActionMessage("Template report outcome block set".i18n(), set: report.reportedSet!, user: report.reportedUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(titleInappropriate, message, reportedMessageIcon, report.reportedUser!);

          if(report.reportingUser == null) {
            message = parseUserReportingMessage(actionTakenMessage, user: report.reportingUser!, actionTaken: "definitely block the set".i18n());
            inboxService.sendAutomaticMessageToUser(titleOutcome, message, outcomeMessageIcon, report.reportingUser!);
          }
        };
        break;
      case ReportAction.blockUser:
        actionMessageContent = "Template report action block user".i18n();
        onConfirm = () async {
          List<FlashcardSet> sets = await realmServices.setCollection.getAll(report.reportedUser!.userId.hexString);
          realmServices.realm.writeAsync(() {
            report.reportedUser!.blocked = true;
            for(FlashcardSet set in sets) {
              set.isPublic = false;
              set.blocked = true;
            }
          });

          String message = parseActionMessage("Template report outcome block user".i18n(), set: report.reportedSet!, user: report.reportedUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(titleInappropriate, message, reportedMessageIcon, report.reportedUser!);
          if(report.reportingUser == null) {
            message = parseUserReportingMessage(actionTakenMessage, user: report.reportingUser!, actionTaken: "definitely block the user".i18n());
            inboxService.sendAutomaticMessageToUser(titleOutcome, message, outcomeMessageIcon, report.reportingUser!);
          }
        };
        break;
      case ReportAction.setAppropriate:
        actionMessageContent = "Template report action set appropriate".i18n();
        onConfirm = () {
          realmServices.realm.writeAsync(() {
            report.reportedSet!.reportCount -= 1;
          });

          if(report.reportingUser == null) {
            String message = parseUserReportingMessage("Template report notify outcome set appropriate".i18n(), user: report.reportingUser!);
            inboxService.sendAutomaticMessageToUser(titleOutcome, message, outcomeMessageIcon, report.reportingUser!);
          }
        };
        break;
      default:
        break;
    }

    if(actionMessageContent.isNotEmpty) {
      reportActionConfirmationDialog(context,
        title: reportAction.translatedName,
        content: actionMessageContent,
        onConfirm: (info) {
          onConfirm();
          realmServices.realm.writeAsync(()  {
            report.resolved = true;
            report.moderatorAdditionalInformation = info;
            report.moderatorChoice = reportAction.type;
          });
          successMessageSnackBar(context, "Action executed".i18n()).show(context);
        },
      );
    }
  }

  static String

  formatReasons(List<String> reasons) {
    String formattedReasons = "";
    for(String reason in reasons) {
      int? index = int.tryParse(reason);
      if(index == null) {
        formattedReasons += "- $reason\n";
      } else {
        formattedReasons += "- ${ReportType.values[index].translatedName}\n";
      }
    }
    return formattedReasons;
  }

  static String parseActionMessage(String message, {required FlashcardSet set, required Users user, required String reasons}) {
    // insert link to set
    message = message.replaceFirst(MessageHelper.buildLinkTemplate("set"), MessageHelper.buildSetLinkMessage(set));

    // insert information
    message = message.replaceFirst("<userName>", user.name);
    message = message.replaceFirst("<reportReasons>", reasons);

    return message;
  }

  static String parseUserReportingMessage(String message, {required Users user, String? actionTaken, String? reasons}) {
    // insert information
    message = message.replaceFirst("<userName>", user.name);
    if(actionTaken != null) {
      message = message.replaceFirst("<actionTaken>", actionTaken);
    }

    if(reasons != null) {
      message = message.replaceFirst("<reportReasons>", reasons);
    }

    return message;
  }
}

extension ReportMessageExtension on ReportMessage {
  Message toMessage() {
    String title = getTitle();
    String reportCount = "for the first time".i18n();
    if(setReportCount > 0) {
      reportCount = "**${setReportCount + 1} ${"times".i18n()}**";
    }

    String previousReportLink = "";
    if(previousReport != null) {
      previousReportLink = "**${"Here is a link to the".i18n()} ";
      previousReportLink += MessageHelper.buildMessageLinkReportMessage(previousReport!, "Previous report".i18n());
      previousReportLink += "**";
    }

    String formattedAdditionalInformation = "> *${"No additional information provided".i18n()}*";
    if(additionalInformation.isNotEmpty) {
      formattedAdditionalInformation = "###### ${"Additional information provided".i18n()}";
      formattedAdditionalInformation += "\n";
      formattedAdditionalInformation += "> ${additionalInformation.trim()}";
    }

    String reportMessage = "Template report set".i18n();
    // insert links
    if(reportedSet != null) {
      reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("set"), MessageHelper.buildSetLinkMessage(reportedSet!));
    }
    if(reportedUser != null) {
      reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("reportedUser"), MessageHelper.buildUserLinkMessage(reportedUser!));
    }
    if(reportingUser != null) {
      reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("reportingUser"), MessageHelper.buildUserLinkMessage(reportingUser!));
    }
    reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("previousReport"), previousReportLink);

    // insert information
    reportMessage = reportMessage.replaceFirst("<reportCount>", reportCount);
    reportMessage = reportMessage.replaceFirst("<reportReasons>", MessageHelper.formatReasons(reasons));
    reportMessage = reportMessage.replaceFirst("<reportDetails>", formattedAdditionalInformation);

    if(resolved) {
      List<String> lines = reportMessage.split("\n");

      // remove the last 5 lines (actions)
      reportMessage = "";
      for(int i = 0; i < lines.length - 5; i++) {
        reportMessage += "${lines[i]}\n";
      }

      reportMessage += "- ${ReportAction.values[moderatorChoice].translatedName}\n\n";
      reportMessage += "> $moderatorAdditionalInformation";
    }

    return Message(reportMessageId, title, reportMessage, MessageIcons.report.type, reportDate, reportDate);
  }

  String getTitle() {
    String title;
    if(reportedSet == null) {
      title = "${"Deleted set".i18n()} - ${reportDate.format(formatting: "yyyy/MM/dd")}";
    } else {
      title = "'${reportedSet!.name}' - ${reportDate.format(formatting: "yyyy/MM/dd")}";
    }

    if(setReportCount > 0) {
      title += " (${setReportCount + 1})";
    }
    return title;
  }
}