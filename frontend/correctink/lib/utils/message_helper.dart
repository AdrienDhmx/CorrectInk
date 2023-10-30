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
  none(type: -1),
  congrats(type: 0),
  notes(type: 1),
  tip(type: 2),
  person(type: 3),
  release(type: 4),
  chat(type: 5),
  mail(type: 6),
  time(type: 7),
  calendar(type: 8),
  premium(type: 9),
  landscape(type: 10),
  book(type: 11),
  ramen(type: 12),
  report(type: 13),
  warning(type: 14),
  editNote(type: 15);

  const MessageIcons({required this.type});

  final int type;
}

enum MessageDestination {
  everyone(destination: 0, name: "Everyone"),
  moderator(destination: 8, name: "Moderator"),
  admin(destination: 10, name: "Admin");

  const MessageDestination({required this.destination, required this.name});

  final int destination;
  final String name;
}

enum ReportType {
  hate(type: 0, name: "Content promoting hate, racism, sexism, or discrimination"),
  sexual(type: 1, name: "Inappropriate sexual content or references"),
  violent(type: 2, name: "Violent or Harmful content"),
  privacy(type: 3, name: "Personal information (email, phone number, social media account...)"),
  misinformation(type: 4, name: "Misinformation or misleading information"),
  copyright(type: 5, name: "Copyrighted content"),
  other(type: 6, name: "Other (specify)");

  const ReportType({required this.type, required this.name});

  final int type;
  final String name;
}

enum ReportAction {
  warn(type: 0, name: "Warn_the_user"),
  blockSet(type: 1, name: "Block_the_set"),
  blockUser(type: 2, name: "Block_the_user"),
  setAppropriate(type: 3, name: "Set_not_inappropriate");

  const ReportAction({required this.type, required this.name});

  final int type;
  final String name;

  String get humanName => name.replaceAll("_", " ").i18n();
}

class Report {
  final List<ReportType> types;
  final String additionalInformation;

  Report(this.types, this.additionalInformation);

  ReportMessage toReportMessage(CardSet set, Users reportedUser, Users reportingUser) {
    return ReportMessage(ObjectId(), set.reportCount, additionalInformation, -1, "", DateTime.now().toUtc(), previousReport: set.lastReport,reportedSet: set, reportedUser: reportedUser, reportingUser: reportingUser, reasons: types.map((reason) => reason.name).toList(),);
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

  static String buildSetLinkMessage(CardSet set) {
    return "*[${set.name}]($linkToSetFormat${set.id.hexString})*";
  }

  static String buildUserLinkMessage(Users user) {
    return "**[${user.firstname} ${user.lastname}]($linkToUserFormat${user.userId.hexString})**";
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
  
  static Icon getIcon(int type, BuildContext context, {bool big = false}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    double size = big ? 32 : 22;
    switch (type) {
      case -1:
        return Icon(Icons.not_interested_rounded, color: colorScheme.onSurfaceVariant, size: size,);
      case 0:
        return Icon(Icons.celebration_rounded, color: colorScheme.primary, size: size,);
      case 1:
        return Icon(Icons.notes_rounded, color: ThemeProvider.whiskey, size: size,);
      case 2:
        return Icon(Icons.tips_and_updates_rounded, color: ThemeProvider.tacha, size: size,);
      case 3:
        return Icon(Icons.person_rounded, color: ThemeProvider.moodyBlue, size: size,);
      case 4:
        return Icon(Icons.new_releases_rounded, color: ThemeProvider.chestnutRose, size: size,);
      case 5:
        return Icon(Icons.chat_rounded, color: ThemeProvider.azure, size: size,);
      case 6:
        return Icon(Icons.mail_rounded, color: ThemeProvider.japaneseLaurel, size: size,);
      case 7:
        return Icon(Icons.access_time_filled_rounded, color: ThemeProvider.downy, size: size,);
      case 8:
        return Icon(Icons.calendar_month_rounded, color: ThemeProvider.amethyst, size: size,);
      case 9:
        return Icon(Icons.workspace_premium_rounded, color: ThemeProvider.tacha, size: size,);
      case 10:
        return Icon(Icons.landscape_rounded, color: ThemeProvider.conifer, size: size,);
      case 11:
        return Icon(Icons.book_rounded, color: ThemeProvider.eden, size: size,);
      case 12:
        return Icon(Icons.ramen_dining_rounded, color: ThemeProvider.copper, size: size,);
      case 13:
        return Icon(Icons.report_rounded, color: colorScheme.error, size: size,);
      case 14:
        return Icon(Icons.warning_rounded, color: ThemeProvider.whiskey, size: size,);
      case 15:
        return Icon(Icons.edit_note_rounded, color: ThemeProvider.azure, size: size,);
      default:
        return Icon(Icons.mail_rounded, color: ThemeProvider.japaneseLaurel, size: size,);
    }
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
    RealmServices realmServices = Provider.of(context, listen: false);
    InboxService inboxService = Provider.of(context, listen: false);

    String actionMessageContent = "";
    Function() onConfirm = () {

    };

    ReportAction reportAction = ReportAction.values.firstWhere((a) => a.name == action);
    String reasons = formatReasons(report.reasons);
    int reportedMessageIcon = MessageIcons.warning.type;
    int outcomeMessageIcon = MessageIcons.editNote.type;
    switch(reportAction) {
      case ReportAction.warn:
        actionMessageContent = reportActionWarn;
        onConfirm = () {
          String message = parseActionMessage(userWarningMessage, set: report.reportedSet!, user: report.reportedUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(contentNotAppropriateTitle, message, reportedMessageIcon, report.reportedUser!);

          message = parseUserReportingMessage(userReportingWarningActionTaken, user: report.reportingUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(contentNotAppropriateOutcomeTitle, message, outcomeMessageIcon, report.reportingUser!);
        };
        break;
      case ReportAction.blockSet:
        actionMessageContent = reportActionBlockSet;
        onConfirm = () {
          realmServices.realm.writeAsync(() {
            report.reportedSet!.blocked = true;
            report.reportedSet!.isPublic = false;
          });

          String message = parseActionMessage(setBlockedMessage, set: report.reportedSet!, user: report.reportedUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(contentNotAppropriateTitle, message, reportedMessageIcon, report.reportedUser!);

          message = parseUserReportingMessage(userReportingActionTaken, user: report.reportingUser!, actionTaken: "definitely block the set");
          inboxService.sendAutomaticMessageToUser(contentNotAppropriateOutcomeTitle, message, outcomeMessageIcon, report.reportingUser!);
        };
        break;
      case ReportAction.blockUser:
        actionMessageContent = reportActionBlockUser;
        onConfirm = () async {
          List<CardSet> sets = await realmServices.setCollection.getAll(report.reportedUser!.userId.hexString);
          realmServices.realm.writeAsync(() {
            report.reportedUser!.blocked = true;
            for(CardSet set in sets) {
              set.isPublic = false;
              set.blocked = true;
            }
          });

          String message = parseActionMessage(userBlockedMessage, set: report.reportedSet!, user: report.reportedUser!, reasons: reasons);
          inboxService.sendAutomaticMessageToUser(contentNotAppropriateTitle, message, reportedMessageIcon, report.reportedUser!);

          message = parseUserReportingMessage(userReportingActionTaken, user: report.reportingUser!, actionTaken: "definitely block the user");
          inboxService.sendAutomaticMessageToUser(contentNotAppropriateOutcomeTitle, message, outcomeMessageIcon, report.reportingUser!);
        };
        break;
      case ReportAction.setAppropriate:
        actionMessageContent = reportActionSetAppropriate;
        onConfirm = () {
          realmServices.realm.writeAsync(() {
            report.reportedSet!.reportCount -= 1;
          });

          String message = parseUserReportingMessage(userReportingNoActionTaken, user: report.reportingUser!);
          inboxService.sendAutomaticMessageToUser(contentAppropriateOutcomeTitle, message, outcomeMessageIcon, report.reportingUser!);
        };
        break;
      default:
        break;
    }

    if(actionMessageContent.isNotEmpty) {
      reportActionConfirmationDialog(context,
        title: action.replaceAll("_", " "),
        content: actionMessageContent,
        onConfirm: (info) {
          onConfirm();
          realmServices.realm.writeAsync(()  {
            report.resolved = true;
            report.moderatorAdditionalInformation = info;
            report.moderatorChoice = reportAction.type;
          });
          successMessageSnackBar(context, "Action executed").show(context);
        },
      );
    }
  }

  static String formatReasons(List<String> reasons) {
    String formattedReasons = "";
    for(String reason in reasons) {
      formattedReasons += "- $reason\n";
    }
    return formattedReasons;
  }

  static String parseActionMessage(String message, {required CardSet set, required Users user, required String reasons}) {
    // insert link to set
    message = message.replaceFirst(MessageHelper.buildLinkTemplate("set"), MessageHelper.buildSetLinkMessage(set));

    // insert information
    message = message.replaceFirst("<userName>", "${user.firstname} ${user.lastname}");
    message = message.replaceFirst("<reportReasons>", reasons);

    return message;
  }

  static String parseUserReportingMessage(String message, {required Users user, String? actionTaken, String? reasons}) {
    // insert information
    message = message.replaceFirst("<userName>", "${user.firstname} ${user.lastname}");
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
    String reportCount = "for the **first time**";
    if(setReportCount > 0) {
      reportCount = "**${setReportCount + 1} times**";
    }

    String previousReportLink = "";
    if(previousReport != null) {
      previousReportLink = "**Here is a link to the ";
      previousReportLink += MessageHelper.buildMessageLinkReportMessage(previousReport!, "Previous report");
      previousReportLink += "**";
    }

    String formattedAdditionalInformation = r"> *No additional information provided*";
    if(additionalInformation.isNotEmpty) {
      formattedAdditionalInformation = r"###### Additional information provided";
      formattedAdditionalInformation += "\n";
      formattedAdditionalInformation += "> ${additionalInformation.trim()}";
    }

    String reportMessage = setReportTemplate;
    // insert links
    reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("set"), MessageHelper.buildSetLinkMessage(reportedSet!));
    reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("reportedUser"), MessageHelper.buildUserLinkMessage(reportedUser!));
    reportMessage = reportMessage.replaceFirst(MessageHelper.buildLinkTemplate("reportingUser"), MessageHelper.buildUserLinkMessage(reportingUser!));
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

      reportMessage += "- ${ReportAction.values[moderatorChoice].humanName}\n\n";
      reportMessage += "> $moderatorAdditionalInformation";
    }

    return Message(reportMessageId, title, reportMessage, MessageIcons.report.type, reportDate, reportDate);
  }
  String getTitle() {
    String title = "'${reportedSet!.name}' - ${reportDate.format(formatting: "yyyy/MM/dd")}";
    if(setReportCount > 0) {
      title += " (${setReportCount + 1})";
    }
    return title;
  }
}

const String setReportTemplate =
"""
The set "<${MessageHelper.linkToFormat}:set>" by <${MessageHelper.linkToFormat}:reportedUser> has been reported by <${MessageHelper.linkToFormat}:reportingUser>.
This set has been flagged inappropriate <reportCount>.
<${MessageHelper.linkToFormat}:previousReport>


#### Report from the user
<reportReasons>

<reportDetails>


#### Your decision
- [Warn the user](${MessageHelper.actionFormat}Warn_the_user)
- [Block the set](${MessageHelper.actionFormat}Block_the_set)
- [Block the user](${MessageHelper.actionFormat}Block_the_user)
- [The set is **not** inappropriate ?](action:Set_not_inappropriate)
""";

const String contentNotAppropriateTitle = "Moderation: Inappropriate content";
const String contentNotAppropriateOutcomeTitle = "Moderation Outcome: Inappropriate content";
const String contentAppropriateOutcomeTitle = "Moderation Outcome: Content not deemed inappropriate";

const String reportActionWarn =
"""
##### What will happen ?
A message will be send to the user who created the set explaining why it has been reported and the decision taken by the moderators.
It will also encourage the user to edit his set and be more careful.

##### When to choose ?
- **first time** this set has been reported
- the set is **not offensive** (e.g: misinformation, copyright...)
""";

const String reportActionBlockSet =
"""
##### What will happen ?
A message will be send to the user who created the set explaining why it has been reported and the decision taken by the moderators.
The set will immediately be made private and can *never* be made public again.

##### When to choose ?
- **not the first time** this set has been reported
- the set is **offensive**
- a warning was already send but no action was taken by the user
""";

const String reportActionBlockUser =
"""
##### What will happen ?
A message will be send to the user who created the set explaining why it has been reported and the decision taken by the moderators.
The *all* the public set made by this user will be made private and the user will *never* be able to share sets again.

##### When to choose ?
- **not the first time** this set has been reported
- the set is **offensive**
- **multiple** sets from this user are offensive
- a warning was already send but no action was taken by the user
""";

const String reportActionSetAppropriate =
"""
##### What will happen ?
A message will be send to user who reported the set thanking him for the report but explaining that the set was found **not** to be in **violation of our guidelines**.
*No* message will be send to the user who got his set reported and the report will be removed from the set.

##### When to choose ?
- the set is **absolutely not** offensive
- the set does **not** violate our guidelines
""";

const String userBlockedMessage =
"""
Hello **<userName>**, 

After a thorough review by our moderation team, the content of your set "<${MessageHelper.linkToFormat}:set>" was found to be in **violation of our guidelines**.
Indeed, the guidelines your agreed upon specify that the content shared must not have:
<reportReasons>
However this set does not respect this.
Therefor, the moderation team decided to **block you definitely**. Which means that from now you will not be able to share any content on CorrectInk.

If you have any further questions or concerns, please don't hesitate to reach out. We're here to ensure the best possible experience for all of our users.

> Best regards, 
>  *The CorrectInk Moderation Team*
""";

const String setBlockedMessage =
"""
Hello **<userName>**, 

After a thorough review by our moderation team, the content of your set "<${MessageHelper.linkToFormat}:set>" was found to be in **violation of our guidelines**.
Indeed, the guidelines your agreed upon specify that the content shared must not have:
<reportReasons>
However this set does not respect this.
Therefor, the moderation team decided to **block your set definitely**. Which means that your set is no longer public and you will not be able to make it public.

If you have any further questions or concerns, please don't hesitate to reach out. We're here to ensure the best possible experience for all of our users.

> Best regards, 
>  *The CorrectInk Moderation Team*
""";

const String userWarningMessage =
"""
Hello **<userName>**, 

After a thorough review by our moderation team, the content of your set "<${MessageHelper.linkToFormat}:set>" was found to be in **violation of our guidelines**.
Indeed, the guidelines your agreed upon specify that the content shared must not have:
<reportReasons>
However this set does not respect this.
As your violation has been deemed light the moderation team decided to **warn** you this time. We encourage you to edit your set and be more mindful of what you share. 

If you have any further questions or concerns, please don't hesitate to reach out. We're here to support you and ensure the best possible experience for all of our users.

We thank you for using CorrectInk.

> Best regards, 
>  *The CorrectInk Moderation Team*
""";

const String userReportingActionTaken =
"""
Hello **<userName>**, 
We want to sincerely **thank you** for taking the time to report content ! 
After a thorough review by our moderation team, the content you reported was found to be in **violation of our guidelines**.
The moderation team decided to <actionTaken>.

If you have any further questions or concerns, please don't hesitate to reach out. We're here to support you and ensure the best possible experience for all of our users.   

We encourage you to continue reporting any content that you believe may be inappropriate or harmful to the community.

> Best regards, 
>  *The CorrectInk Moderation Team*
""";

const String userReportingWarningActionTaken =
"""
Hello **<userName>**,
We want to sincerely **thank you** for taking the time to report content ! 
After a thorough review by our moderation team, the content you reported was found to be in **violation of our guidelines**. 
The moderation team decided to **warn the user** about the content of his set having :
<reportReasons>
We will keep an eye on the content this user shares and take more severe action if needed.

If you have any further questions or concerns, please don't hesitate to reach out. We're here to support you and ensure the best possible experience for all of our users.   

We encourage you to continue reporting any content that you believe may be inappropriate or harmful to the community.

> Best regards, 
>  *The CorrectInk Moderation Team*
""";



const String userReportingNoActionTaken =
"""
Hello **<userName>**,
We want to sincerely **thank you** for taking the time to report content ! 
However after a thorough review by our moderation team, the content you reported was found not to be in **violation of our guidelines**. 

We understand that perspectives on content can vary, if you have any further questions or concerns, please don't hesitate to reach out. We're here to support you and ensure the best possible experience for all of our users.   

We encourage you to continue reporting any content that you believe may be inappropriate or harmful to the community.

> Best regards,
>  *The CorrectInk Moderation Team*
""";