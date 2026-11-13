import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Pages/CoursesScreen.dart';
import 'package:projekt_izynierski/Services/theme_notifier.dart';
import 'package:projekt_izynierski/Pages/AuthCheckScreen.dart';
import 'package:projekt_izynierski/Pages/EPodanieScreen.dart';
import 'package:projekt_izynierski/Pages/FinancesScreen.dart';
import 'package:projekt_izynierski/Pages/Login.dart';
import 'package:projekt_izynierski/Pages/Home.dart';
import 'package:projekt_izynierski/Pages/ConsultationsScreen.dart';
import 'package:projekt_izynierski/Pages/Prof.dart';
import 'package:projekt_izynierski/Pages/Plan.dart';
import 'package:projekt_izynierski/Pages/GradesScreen.dart';
import 'package:projekt_izynierski/Pages/MapaKampusu.dart';
import 'package:projekt_izynierski/Pages/SettingsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemePreference();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Projekt Inżynierski',
          debugShowCheckedModeBanner: false,


          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),


          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),


          themeMode: currentThemeMode,


          initialRoute: '/',
          routes: {
            '/Login': ((context) => Login()),
            '/Home': ((context) => Home()),
            '/Konsultacje': ((context) => ConsultationsScreen()),
            '/Oceny': ((context) => GradesScreen()),
            '/Finansy': ((context) => FinancesScreen()),
            //'/Komunikaty':((context)=> Coms()),
            '/EPodania': ((context) => EPodanieScreen()),
            '/Przedmioty':((context)=>CoursesScreen()),
            '/Plan': ((context) => PlanZajecScreen()),
            '/Map': ((context) => MapaKampusu()),
            '/Ustawienia': ((context) => SettingsScreen()),
            '/Profil': ((context) => Prof()),
            '/': ((context) => AuthCheckScreen()),
          },
        );
      },
    );
  }
}