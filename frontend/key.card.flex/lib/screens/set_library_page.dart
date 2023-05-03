import 'package:flutter/material.dart';
import '../components/set_list.dart';

class SetsLibraryView extends StatefulWidget{
  const SetsLibraryView({super.key});

  @override
  State<StatefulWidget> createState() => _SetsLibraryView();

}

class _SetsLibraryView extends State<SetsLibraryView>{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SetList(),
    );
  }
}