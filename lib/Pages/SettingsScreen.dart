import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projekt_izynierski/Services/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isLocationEnabled = true;
  bool _isPushEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isLocationEnabled = prefs.getBool('isLocationEnabled') ?? true;
      _isPushEnabled = prefs.getBool('isPushEnabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ustawienia"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [

          SwitchListTile(
            secondary: const Icon(Icons.brightness_6, color: Colors.blue),
            title: const Text("Ciemny motyw", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Włącz ciemny tryb interfejsu"),
            value: _isDarkMode,
            onChanged: (bool value) async {
              setState(() {
                _isDarkMode = value;
              });
              await _saveSetting('isDarkMode', value);
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(height: 1),


          SwitchListTile(
            secondary: const Icon(Icons.location_on, color: Colors.red),
            title: const Text("Lokalizacja dla mapy", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Zezwalaj na dostęp do lokalizacji urządzenia"),
            value: _isLocationEnabled,
            onChanged: (bool value) {
              setState(() {
                _isLocationEnabled = value;
              });
              _saveSetting('isLocationEnabled', value);
            },
          ),
          const Divider(height: 1),


          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text("Powiadomienia Push", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Otrzymuj powiadomienia o zmianach i planie"),
            value: _isPushEnabled,
            onChanged: (bool value) {
              setState(() {
                _isPushEnabled = value;
              });
              _saveSetting('isPushEnabled', value);
            },
          ),
          const Divider(height: 1),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/Home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/Plan');
          if (index == 2) Navigator.pushReplacementNamed(context, '/Map');
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
}