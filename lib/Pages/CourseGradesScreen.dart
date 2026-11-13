import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';
import 'package:projekt_izynierski/Pages/ZadanieScreen.dart';

class CourseGradesScreen extends StatefulWidget {
  final int idKurs;
  final String courseName;

  const CourseGradesScreen({
    super.key,
    required this.idKurs,
    required this.courseName,
  });

  @override
  State<CourseGradesScreen> createState() => _CourseGradesScreenState();
}

class _CourseGradesScreenState extends State<CourseGradesScreen> {
  final ApiService _apiService = ApiService();
  late Future<dynamic> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _gradesFuture = _apiService.fetchKursDetails(widget.courseName, widget.idKurs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Oceny: ${widget.courseName}"),
      ),
      body: FutureBuilder<dynamic>(
        future: _gradesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final responseBody = snapshot.data;
          final data = (responseBody is Map<String, dynamic>) ? responseBody : <String, dynamic>{};

          final List rawOceny = data['oceny'] ?? [];

          if (rawOceny.isEmpty) {
            return const Center(
              child: Text(
                "Brak ocen dla tego kursu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: rawOceny.length,
            itemBuilder: (context, index) {
              final item = rawOceny[index];

              final String nazwaZadania = item['nazwaZadania'] ?? 'Zadanie';
              final String skalaOceny = item['skalaOceny'] ?? '-';
              final int? idZadanie = item['Zadanie_idZadanie'] ?? item['idZadanie'];

              final String displayGrade = skalaOceny.isNotEmpty ? skalaOceny[0] : '-';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      displayGrade,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  title: Text(
                    nazwaZadania,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Ocena: $skalaOceny"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (idZadanie != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ZadanieScreen(idZadanie: idZadanie),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}