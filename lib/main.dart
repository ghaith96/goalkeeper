import 'package:flutter/material.dart';
import 'package:goalkeeper/colors.dart';
import 'package:goalkeeper/goals_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Goalkeeper",
      theme: ThemeData(
        primaryColor: MyColors.primaryColor,
        accentColor: MyColors.accentColor,
      ),
      home: GoalsPage(),
    );
  }
}