import 'package:flutter/material.dart';
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

void main()=>runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/Login':((context)=>Login()),
    '/Home':((context)=>Home()),
    '/Konsultacje':((context)=>ConsultationsScreen()),
    '/Oceny':((context)=>GradesScreen()),
    '/Finansy':((context) => FinancesScreen()),
    //'/Komunikaty':((context)=> Coms()),
    '/EPodania':((context)=>EPodanieScreen()),
    //'/Przedmioty':((context)=>Przedmioty()),
    '/Plan':((context)=>PlanZajecScreen()),
    '/Map':((context)=>MapaKampusu()),
    //'/Ustawienia':((context)=>Sett()),
    '/Profil':((context)=>Prof()),
    '/':((context)=>AuthCheckScreen())
  },
));