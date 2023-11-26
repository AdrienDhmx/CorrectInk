import 'package:correctink/widgets/animated_widgets.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onSearchTextUpdated});

  final Function(String) onSearchTextUpdated;

  @override
  State<StatefulWidget> createState() => _SearchField();
}

class _SearchField extends State<SearchField> {
  late bool extendedSearchField = false;
  String searchText = "";
  late TextEditingController searchController;
  late FocusNode searchFieldFocusNode;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    searchController = TextEditingController(text: searchText);
    searchFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    extendedSearchField = !extendedSearchField || searchText.isNotEmpty;
                  });
                  if(extendedSearchField) {
                    searchFieldFocusNode.requestFocus();
                  }
                },
                icon: const Icon(Icons.search_rounded,),
                iconSize: 26,
                color: extendedSearchField ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
              ExpandedSection(
                expand: extendedSearchField || searchText.isNotEmpty,
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