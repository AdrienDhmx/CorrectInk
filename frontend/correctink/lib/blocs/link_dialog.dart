import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

import '../utils/utils.dart';

class LinkForm extends StatefulWidget {
  final String link;
  final String placeholder;
  final Function(String, String, int?, String?) onConfirm;
  final Function(int?)? onCancel;
  final int? position;
  final bool image;

  const LinkForm({super.key, this.position, required this.link, required this.placeholder, required this.onConfirm, this.image = false, this.onCancel});

  @override
  State<StatefulWidget> createState() => _LinkForm();
}

class _LinkForm extends State<LinkForm>{
  late TextEditingController linkController;
  late TextEditingController placeholderController;
  late TextEditingController linkUnderImageController;
  late bool validUrl = true;
  late bool validUrlUnderImage = true;

  @override
  void initState(){
    super.initState();

    linkController = TextEditingController(text: widget.link);
    placeholderController = TextEditingController(text: widget.placeholder);
    linkUnderImageController = TextEditingController(text: "");
  }

  @override
  void dispose(){
    super.dispose();

    linkController.dispose();
    placeholderController.dispose();
    linkUnderImageController.dispose();
  }

  void onConfirm() async {
    if(widget.image){
      bool validImageUrl = await Utils.validateImage(linkController.text);
      setState(() {
        validUrl = validImageUrl;
        if(linkUnderImageController.text.isNotEmpty) {
          validUrlUnderImage = Utils.isURL(linkUnderImageController.text);
        }
      });

      if(validUrl && validUrlUnderImage){
        widget.onConfirm(linkController.text, placeholderController.text, widget.position, linkUnderImageController.text);
        if(context.mounted) GoRouter.of(context).pop();
      }
    } else {
      setState(() {
        validUrl = Utils.isURL(linkController.text);
      });
      if(validUrl) {
        widget.onConfirm(linkController.text, placeholderController.text, widget.position, null);
        GoRouter.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
        padding: widget.image ? const EdgeInsets.only(right:  8.0) : const EdgeInsets.only(right: 30.0),
        child: Text(widget.image ? "Enter link Image".i18n() : "Enter link".i18n()),
      ),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: SizedBox(
        height: widget.image ? 220 : 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: placeholderController,
              decoration: InputDecoration(
                label: Text("Placeholder (optional)".i18n())
              ),
            ),
            if(widget.image)
              const SizedBox(height: 12,),
            if(widget.image)
              TextField(
                controller: linkUnderImageController,
                decoration: InputDecoration(
                  label: Text("Link under image (optional)".i18n()),
                  errorText: !validUrlUnderImage ? "Url invalid".i18n() : null,
                ),
              ),
            const SizedBox(height: 12,),
            TextField(
              controller: linkController,
              decoration: InputDecoration(
                label: Text(!widget.image ? "URL".i18n() : "URL of image".i18n()),
                errorText: !validUrl ? widget.image ? "Image url invalid".i18n() : "Url invalid".i18n() : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
                if(widget.onCancel != null){
                  widget.onCancel!(widget.position);
                }
                GoRouter.of(context).pop();
              },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onSurfaceVariant),
              minimumSize: MaterialStateProperty.all(const Size(90, 40)),
              padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 10.0) : const EdgeInsets.symmetric(horizontal: 15.0)),
            ),
            child: Text(
              "Cancel".i18n(),
              textAlign: TextAlign.end,
            )
        ),
        TextButton(
            onPressed: () { onConfirm(); },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
              minimumSize: MaterialStateProperty.all(const Size(90, 40)),
              padding: MaterialStateProperty.all<EdgeInsets>(Utils.isOnPhone() ? const EdgeInsets.symmetric(horizontal: 10.0) : const EdgeInsets.symmetric(horizontal: 15.0)),
            ),
            child: Text(
              "Done".i18n(),
              textAlign: TextAlign.end,
            )
        )
      ],
    );
  }

}