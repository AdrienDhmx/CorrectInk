import 'package:correctink/app/data/models/schemas.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../utils/markdown_extension.dart';
import '../../utils/message_helper.dart';

class MessageReader extends StatelessWidget {
  final Message message;
  final ReportMessage? report;

  const MessageReader({super.key, required this.message, this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if(message.icon != -1) ... [
                  MessageHelper.getIcon(message.icon, context, big: true),
                  const SizedBox(width: 10,),
                ],
                Flexible(
                  child: Text(message.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12,),
            MarkdownBody(
              data: message.message,
              softLineBreak: true,
              builders: MarkdownUtils.styleSheet(),
              styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
              styleSheet: MarkdownUtils.getStyle(context),
              onTapLink: (i, link, _) => {
                if(report != null && !report!.resolved) {
                  MessageHelper.onReportLinkClicked(context, link ?? "", report!)
                } else {
                  MessageHelper.onLinkClicked(context, link ?? "")
                }
              },
            ),
            const SizedBox(height: 12,),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    const Divider(
                      endIndent: 12,
                      indent: 12,
                    ),
                    Text(message.sendDate.getWrittenFormat(),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}