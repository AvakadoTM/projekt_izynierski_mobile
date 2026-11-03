import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class Home extends StatefulWidget{
  const Home();
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  final ApiService _apiService = ApiService();
  Widget build(BuildContext context){

    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      home: Scaffold(
        body: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.pushNamed(context, '/Profil');
                  }, icon: Icon(Icons.person_2_rounded)),
                  Text("Moja Uczelnia", style: TextStyle(fontSize: 25),),
                  IconButton(onPressed: ()async{
                    await _apiService.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/Login', (route) => false);
                    }
                  }, icon: Icon(Icons.exit_to_app))
                ],
              ),
              Container(//Oceny
                child:
                  ElevatedButton(onPressed: (){
                    Navigator.pushNamed(context,'/Oceny');
                  }, child:
                    Row(
                      children:[
                        Icon(Icons.stars_outlined),
                        Text("Moje oceny")
                      ])
                )),
              Container(//finansy
                  child:
                  ElevatedButton(onPressed: (){
                    Navigator.pushNamed(context,'/Finansy');
                  }, child:
                  Row(
                      children:[
                        Icon(Icons.money_outlined),
                        Text("Moje finansy")
                      ])
                  )
              ),
              Container(//komunikaty
                  child:
                  ElevatedButton(onPressed: (){
                    //Вставити посилання на відповідну сторінку
                  }, child:
                  Row(
                      children:[
                        Icon(Icons.mail_outlined),
                        Text("Komunikaty")
                      ])
                  )
              ),
              Container(//epodania
                  child:
                  ElevatedButton(onPressed: (){
                    Navigator.pushNamed(context, '/EPodania');
                  }, child:
                  Row(
                      children:[
                        Icon(Icons.my_library_books_outlined),
                        Text("EPodanie")
                      ])
                  )
              ),
              Container(//konsultacje
                  child:
                  ElevatedButton(onPressed: (){
                    Navigator.pushNamed(context, '/Konsultacje');
                  }, child:
                  Row(
                      children:[
                        Icon(Icons.handshake_outlined),
                        Text("Konsultacje")
                      ])
                  )
              ),
              Container(//moje przedmioty
                  child:
                  ElevatedButton(onPressed: (){
                    //Вставити посилання на відповідну сторінку
                  }, child:
                  Row(
                      children:[
                        Icon(Icons.book_outlined),
                        Text("Moje przedmioty")
                      ])
                  )
              ),

            ]
        ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/Plan');
          if (index == 2) Navigator.pushNamed(context, '/Map');
          if (index == 3) Navigator.pushNamed(context, '/Ustawienia');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Opcje'),
        ],
      ),
      ),
    );
  }
}