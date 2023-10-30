import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../widgets/widgets.dart';

class ErrorPage extends StatelessWidget {

  final String errorDescription;
  final List<String> tips;
  const ErrorPage({super.key, required this.errorDescription, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.error, 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Error".i18n(), style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
          ),
          const SizedBox(height: 8,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(errorDescription, textAlign: TextAlign.center, style: errorTextStyle(context)),
          ),

          for(String tip in tips) ... [
            const SizedBox(height: 12,),
            errorTip(context, tip: tip),
          ]
        ],
      ),
    );
  }

}