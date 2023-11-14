import 'package:flutter/material.dart';

import '../widgets/buttons.dart';

class IconPickerDialog extends StatelessWidget {
  final List<Icon> icons;
  final int selectedIconIndex;
  final Function(int) onIconSelected;

  const IconPickerDialog({super.key, required this.icons, required this.selectedIconIndex, required this.onIconSelected});

  @override
  Widget build(BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Wrap(
            runAlignment: WrapAlignment.start,
            spacing: 2,
            runSpacing: 2,
            alignment: WrapAlignment.start,
            children: [
              for(int index = 0; index < icons.length; index++)
                iconPickerButton(context, icon: icons[index],
                    isSelected: index == selectedIconIndex,
                    onPressed: () => onIconSelected(index),
                    width: 40
                ),
            ],
          ),
        ),
      );
  }

}