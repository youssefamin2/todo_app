import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var dateController = TextEditingController();
  var timeController = TextEditingController();
  var statusController = TextEditingController();

  HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          var cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
                title: Text(AppCubit.get(context).titles[cubit.currentIndex])),
            body: ConditionalBuilder(
                condition: state is! AppGetDatabaseLodingState,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator())),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formkey.currentState!.validate()) {
                    cubit.insertDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          padding: const EdgeInsets.all(20.0),
                          color: Colors.grey[100],
                          child: Form(
                            key: formkey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //text-field Title
                                defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'title must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                //text_filed time
                                defaultFormField(
                                    controller: timeController,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeController.text =
                                            value!.format(context);
                                      });
                                    },
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'time must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                //date_formfeild
                                defaultFormField(
                                    controller: dateController,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse('2025-05-03'))
                                          .then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Date',
                                    prefix: Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheet(isshow: false, icon: Icons.edit);
                  });

                  cubit.changeBottomSheet(isshow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeNav(index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined),
                    label: 'Archived Tasks'),
              ],
            ),
          );
        },
      ),
    );
  }
}
