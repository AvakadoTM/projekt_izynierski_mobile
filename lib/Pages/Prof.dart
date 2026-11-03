import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class Prof extends StatefulWidget {
  const Prof({super.key});

  @override
  State<Prof> createState() => _ProfState();
}

class _ProfState extends State<Prof> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _apiService.fetchMojeDane();
  }
/*
  Uint8List? _parseBlobToBytes(String? photoStr) {
    if (photoStr == null || photoStr.isEmpty) return null;

    try {
      // 1. Удаляем префикс "data:image/jpeg;base64," если он есть
      String cleanStr = photoStr;
      if (cleanStr.contains(',')) {
        cleanStr = cleanStr.split(',').last;
      }

      // 2. Удаляем префикс "0x", который указывает на HEX формат из БД
      if (cleanStr.startsWith('0x')) {
        cleanStr = cleanStr.substring(2);
      }

      // 3. Декодируем HEX-строку в массив байтов (Uint8List)
      return Uint8List.fromList(hex.decode(cleanStr));
    } catch (e) {
      print("Ошибка декодирования изображения: $e");
      return null;
    }
  }
*/
  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/Home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mój Profil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Błąd: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/Login',
                            (route) => false,
                      );
                    },
                    child: const Text("Zaloguj się ponownie!"),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            print("${snapshot}");
            final userData = snapshot.data!;

            final String name = userData['name'] ?? '';
            final String surname = userData['surname'] ?? '';
            final String email = userData['email'] ?? '';
            final String role = userData['rol'] ?? 'Brak roli';
            final String phone = userData['numerTelefonu'] ?? 'Brak';
            final String birthDate = userData['DataUrodzenia'] ?? 'Brak';
            final int studentCard = userData['index'] ?? 'Brak';
            final String payoutAccount = userData['kontoBankowe'] ?? 'Brak';
            final String wydzial = userData['wydzial'] ?? 'Brak';
            final String kierunek = userData['kierunek'] ?? 'Brak';
            final String? specjalizacja = userData['Specjalnosc'];
            final int? rokStudiow = userData['rok'];
            final int? semestr = userData['semester'];
            final String trybStudiow = userData['trybStudiow'] ?? 'Stacjonarne';
            //final String? photoBase64 = userData['photo'];
            //final Uint8List? imageBytes = _parseBlobToBytes(photoBase64);
            print("$userData");
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
/*
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes)
                          : null,
                      child: imageBytes == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
*/
                  const SizedBox(height: 12),
                  Text(
                    "$name $surname",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.toUpperCase(),
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),


                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Dane osobowe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const Divider(),
                          _buildInfoRow("Email", email),
                          _buildInfoRow("Telefon", phone),
                          _buildInfoRow("Data urodzenia", birthDate),
                          _buildInfoRow("Konto do wypłat", payoutAccount),

                          const SizedBox(height: 20),
                          const Text("Dane akademickie", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const Divider(),
                          _buildInfoRow("Nr legitymacji", "${studentCard ?? '-'}"),
                          _buildInfoRow("Wydział", wydzial),
                          _buildInfoRow("Kierunek", kierunek),
                          if (specjalizacja != null && specjalizacja.isNotEmpty)
                            _buildInfoRow("Specjalizacja", specjalizacja),
                          _buildInfoRow("Rok / Semestr", "${rokStudiow ?? '-'} rok, ${semestr ?? '-'} semestr"),
                          _buildInfoRow("Tryb studiów", trybStudiow),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Brak danych"));
        },
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle( fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}