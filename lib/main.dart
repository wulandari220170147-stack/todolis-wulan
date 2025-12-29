import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/providers/task_provider.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wulan TodoList',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          HomeScreen.routeName: (ctx) => const HomeScreen(),
        },
      ),
    );
  }
}