import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/bloc_observer.dart';
import 'layout/home_layout.dart';

void main() {
  runApp(const MyApp());
  Bloc.observer = MyBlocObserver();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  HomeLayout(),
    );
  }
}

