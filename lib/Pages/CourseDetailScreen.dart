import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

import 'CourseGradesScreen.dart';

class CourseDetailScreen extends StatefulWidget {
  final int idKurs;
  final String courseName;
  final String teacherName;

  const CourseDetailScreen({
    super.key,
    required this.idKurs,
    required this.courseName,
    required this.teacherName,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<dynamic> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.fetchKursDetails(widget.courseName, widget.idKurs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("O przedmiocie"),
      ),
      body: FutureBuilder<dynamic>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final responseBody = snapshot.data;
          final data = (responseBody is Map<String, dynamic>) ? responseBody : <String, dynamic>{};

          final List materialy = data['materialy'] ?? [];
          final List zadania = data['zadania'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.courseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.teacherName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text("Materiały", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              materialy.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text("Brak", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              )
                  : Column(
                children: materialy.map((m) => Card(
                  child: ListTile(
                    title: Text(m['nazwa'] ?? 'Plik'),
                    trailing: const Icon(Icons.download),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              const Text("Zadania", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              zadania.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text("Brak", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              )
                  : Column(
                children: zadania.map((z) => Card(
                  child: ListTile(
                    title: Text(z['nazwaZadania'] ?? 'Zadanie'),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ListTile(
                  title: const Text("Tabela ocen", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  trailing: const Icon(Icons.arrow_forward, color: Colors.black87),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseGradesScreen(
                          idKurs: widget.idKurs,
                          courseName: widget.courseName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}