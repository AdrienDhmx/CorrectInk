import 'package:flutter/material.dart';
import '../components/set_list.dart';

class SetsLibraryView extends StatelessWidget{
  const SetsLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SetList());
  }
}