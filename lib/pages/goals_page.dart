import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:sqflite/sqflite.dart';

import 'package:goalkeeper/pages/about_page.dart';
import 'package:goalkeeper/pages/create_page.dart';
import 'package:goalkeeper/pages/edit_page.dart';
import 'package:goalkeeper/pages/empty_page.dart';
import 'package:goalkeeper/utils/colors.dart';
import 'package:goalkeeper/utils/database_helper.dart';
import 'package:goalkeeper/utils/goal.dart';
import 'package:goalkeeper/utils/public.dart';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<GoalClass> goalsList;
  int len = 0;

  void _changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        isThemeCurrentlyDark(context) ? Brightness.light : Brightness.dark);
  } //switch between light & dark modes

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initDatabase();
    dbFuture.then((database) {
      Future<List<GoalClass>> goalsListFuture = databaseHelper.getGoalsList();
      goalsListFuture.then((goalsList) {
        setState(() {
          this.goalsList = goalsList;
          this.len = goalsList.length;
        });
      });
    });
  }

  void navigateToCreateGoal(GoalClass goal) async {
    await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return CreateGoal(goal);
    }));
    updateListView();
  }

  void navigateToEditGoal(GoalClass goal) async {
    await Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return EditGoal(goal);
    }));
    updateListView();
  }

  Widget buildGoalsList() {
    return Container(
      child: ListView.builder(
        itemCount: len,
        itemBuilder: (BuildContext context, int id) {
          return buildTile(
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Hero(
                          tag: "dartIcon$id",
                          child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/icon.png")))),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Goal #${id + 1}",
                            style: TextStyle(color: MyColors.accentColor)),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text(this.goalsList[id].title,
                            style: TextStyle(
                                color: invertColors(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0)),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text(this.goalsList[id].body,
                            style: TextStyle(color: invertColors(context))),
                      ],
                    ),
                    Spacer(),
                  ]),
            ),
            onTap: () => navigateToEditGoal(this.goalsList[id]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PageController _myPage = PageController(initialPage: 0);
    if (goalsList == null) {
      goalsList = List<GoalClass>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 5.0,
        backgroundColor: MyColors.primaryColor,
        title: Text("My Goals",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22.0)),
        actions: <Widget>[
          IconButton(
            icon: isThemeCurrentlyDark(context)
                ? Icon(EvaIcons.sun) //use sun icon
                : Icon(EvaIcons.moon), //use moon icon
            tooltip: isThemeCurrentlyDark(context)
                ? "Switch to light mode"
                : "Switch to dark mode",
            onPressed: _changeBrightness,
          ),
        ],
      ),
      body: PageView(
        controller: _myPage,
        children: <Widget>[
          noGoals == false ? buildEmptyPage(context) : buildGoalsList(),
          buildAboutPage(context),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToCreateGoal(GoalClass("", ""));
        },
        child: Icon(EvaIcons.plus),
        foregroundColor: MyColors.light,
        backgroundColor: MyColors.accentColor,
        elevation: 3.0,
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 15.0,
        shape: CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                EvaIcons.home,
                size: 26,
              ),
              color: invertColors(context),
              onPressed: () {
                _myPage.jumpToPage(0);
              },
            ),
            IconButton(
              icon: Icon(
                EvaIcons.info,
                size: 26,
              ),
              color: invertColors(context),
              onPressed: () {
                _myPage.jumpToPage(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}