import 'dart:async';

import 'package:correctink/widgets/animated_widgets.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onSearchTextUpdated});

  final Function(String) onSearchTextUpdated;

  @override
  State<StatefulWidget> createState() => _SearchField();
}

class _SearchField extends State<SearchField> {
  late bool extendSearchBar = false;
  late bool lastFocus = false;
  String searchText = "";
  late TextEditingController searchController;
  late FocusNode searchFieldFocusNode;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    searchController = TextEditingController(text: searchText);
    searchFieldFocusNode = FocusNode()..addListener(() {
      setState(() {
        extendSearchBar = searchFieldFocusNode.hasFocus;
        lastFocus = !extendSearchBar;
      });
      Timer(const Duration(milliseconds: 200), (){
        setState(() {
          lastFocus = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
            children: [
              IconButton(
                onPressed: () {
                  if(!extendSearchBar && searchText.isEmpty && !lastFocus) {
                    searchFieldFocusNode.requestFocus();
                  }
                  setState(() {
                    lastFocus = false;
                  });
                },
                icon: const Icon(Icons.search_rounded,),
                iconSize: 26,
                color: extendSearchBar || searchText.isNotEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
              ExpandedSection(
                expand: extendSearchBar || searchText.isNotEmpty,
                duration: 200,
                startValue: 0,
                axis: Axis.horizontal,
                child: Container(
                  width: constraints.maxWidth - 60,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFieldFocusNode,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500
                    ),
                    onChanged: (value){
                      setState(() {
                        searchText = value;
                      });
                      widget.onSearchTextUpdated(searchText);
                    },
                  ),
                ),
              ),
            ]
        );
      }
    );
  }

}