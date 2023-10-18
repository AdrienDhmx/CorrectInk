import 'package:correctink/app/data/models/schemas.dart';
import 'package:correctink/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/markdown_extension.dart';
import '../../utils/message_helper.dart';

class MessageReader extends StatelessWidget {
  final Message message;

  const MessageReader({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if(message.type != -1) ... [
                    MessageHelper.getIcon(message.type, Theme.of(context).colorScheme.primary, big: true),
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
                  launchUrl(Uri.parse(link ?? ""))
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
                      Text(message.creationDate.getWrittenFormat(),
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
      ),
    );
  }
}