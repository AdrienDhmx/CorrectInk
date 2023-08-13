import 'package:correctink/app/services/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class HeaderWithDividerBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(text.text, style: preferredStyle),
        ),
        Divider(color: preferredStyle?.color?.withAlpha(225),)
      ],
    );
  }
}

class HeaderBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
      child: Text(text.text, style: preferredStyle),
    );
  }
}

class BlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(text.text, style: preferredStyle),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text.text));
                },
                icon: const Icon(Icons.copy),
              color: preferredStyle?.color,
              iconSize: 18,
            ),
          ),
        )
      ],
    );
  }
}


class MarkdownUtils {

  static const List<String> headers = <String>[
    "H1",
    "H2",
    "H3",
    "H4",
    "H5",
    "H6",
  ];

  static String getHeaderMarkdown(String header){
    for(int index = 0; index < headers.length; index++){
      if(header == headers[index]){
        String markdown = "";
        for(int j = 0; j <= index; j++){
          markdown += '#';
        }
        return markdown;
      }
    }
    return "";
  }


 static Map<String, MarkdownElementBuilder> styleSheet(){
  return <String, MarkdownElementBuilder>{
   'h1': HeaderWithDividerBuilder(),
   'h2': HeaderWithDividerBuilder(),
    'h3': HeaderWithDividerBuilder(),
    'h4': HeaderWithDividerBuilder(),
    'h5': HeaderWithDividerBuilder(),
    'h6': HeaderBuilder(),
    'pre': BlockBuilder(),
   };
 }

 static MarkdownStyleSheet getStyle(BuildContext context){
   Color onBackground = Theme.of(context).colorScheme.onBackground;
   Color primary = Theme.of(context).colorScheme.primary;
   return MarkdownStyleSheet(
     p: TextStyle(
       color: onBackground,
       fontSize: 16
     ),
    h1: TextStyle(
      color: primary,
      fontWeight: FontWeight.w500,
      fontSize: 36,
    ),
     h2: TextStyle(
       color: primary,
       fontWeight: FontWeight.w500,
       fontSize: 32,
     ),
     h3: TextStyle(
       color: primary,
       fontWeight: FontWeight.w500,
       fontSize: 28,
     ),
     h4: TextStyle(
       color: primary,
       fontWeight: FontWeight.w500,
       fontSize: 24,
     ),
     h5: TextStyle(
       color: primary,
       fontWeight: FontWeight.w600,
       fontSize: 20,
     ),
     h6: TextStyle(
       color: primary,
       fontWeight: FontWeight.w600,
       fontSize: 20,
     ),
     strong: TextStyle(
       color: HexColor.fromHex("#Cb4945"),
       fontWeight: FontWeight.w600,
       fontSize: 16,
       fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily
     ),
     em: TextStyle(
       color: HexColor.fromHex("#43b435"),
       fontStyle: FontStyle.italic,
       fontSize: 16,
     ),
     code: TextStyle(
       color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(225),
       backgroundColor: Colors.transparent
     ),
     codeblockDecoration: BoxDecoration(
       color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(120),
       borderRadius: const BorderRadius.all(Radius.circular(6))
     ),
      checkbox: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
     a: TextStyle(
       color: Theme.of(context).colorScheme.primary,
     ),
     blockquote: TextStyle(
         color: Theme.of(context).colorScheme.onTertiaryContainer,
         fontSize: 16
     ),
     blockquoteDecoration: BoxDecoration(
       color: Theme.of(context).colorScheme.tertiaryContainer.withAlpha(140),
       borderRadius: const BorderRadius.all(Radius.circular(6))
     ),
     blockSpacing: 8,
    listBulletPadding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
     listIndent: 16
   );
 }
}
