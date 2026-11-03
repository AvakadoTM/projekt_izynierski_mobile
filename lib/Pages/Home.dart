import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Profil');
              },
              icon: const Icon(Icons.person_2_rounded),
            ),
            const Text("Moja Uczelnia", style: TextStyle(fontSize: 22)),
            IconButton(
              onPressed: () async {
                await _apiService.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/Login', (route) => false);
                }
              },
              icon: const Icon(Icons.exit_to_app),
            )
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuButton(
            context,
            iconData: Icons.stars_outlined,
            title: "Moje oceny",
            onPressed: () => Navigator.pushNamed(context, '/Oceny'),
          ),
          _buildMenuButton(
            context,
            iconData: Icons.money_outlined,
            title: "Moje finansy",
            onPressed: () => Navigator.pushNamed(context, '/Finansy'),
          ),
          _buildMenuButton(
            context,

            iconData: Icons.mail_outlined,
            title: "Komunikaty",
            onPressed: () {},
          ),
          _buildMenuButton(
            context,
            iconData: Icons.my_library_books_outlined,
            title: "EPodanie",
            onPressed: () => Navigator.pushNamed(context, '/EPodania'),
          ),
          _buildMenuButton(
            context,
            iconData: Icons.handshake_outlined,
            title: "Konsultacje",
            onPressed: () => Navigator.pushNamed(context, '/Konsultacje'),
          ),
          _buildMenuButton(
            context,
            iconData: Icons.book_outlined,
            title: "Moje przedmioty",
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.pushReplacementNamed(context, '/Plan');
          if (index == 2) Navigator.pushReplacementNamed(context, '/Map');
          if (index == 3) Navigator.pushReplacementNamed(context, '/Ustawienia');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Opcje'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData iconData, required String title, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(iconData, size: 24),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}