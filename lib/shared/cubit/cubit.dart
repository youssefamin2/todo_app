import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archived_tasks.dart';
import '../../modules/done__tasks.dart';
import '../../modules/new_tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  int currentIndex = 0;
  List<Widget> screens = const [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived tasks'];

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeNav(int index) {
    currentIndex = index;
    emit(ChangeBottonNav());
  }

  void changeBottomSheet({required bool isshow, required IconData icon}) {
    isBottomSheetShown = isshow;
    fabIcon = icon;
    emit(AppChangeBottomNaSheetState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT,date TEXT,time TEXT,status TEXT)')
          .then((value) {})
          .catchError((error) {});
    }, onOpen: (database) {
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  Future insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database?.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError((error) {});
    });
  }

  void getDataFromDatabase(database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLodingState());
    await database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateDatabase({
    required String status,
    required int id,
  }) async {
    return await database?.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    database?.rawDelete(
      'DELETE FROM tasks WHERE id = ?',
      [id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }
}
