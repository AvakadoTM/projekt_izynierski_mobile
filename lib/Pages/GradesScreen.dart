import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _gradesFuture = _apiService.fetchOceny();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oceny końcowe"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _gradesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final data = snapshot.data;
          final List rawOceny = data?['oceny'] ?? [];
          final int currentStudentSemester = data?['studentsem'] ?? 1;

          if (rawOceny.isEmpty) {
            return const Center(
              child: Text(
                "Brak ocen",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final List subjects = rawOceny.map((item) {
            return {
              'id': item['idPrzedmiot'],
              'name': item['nazwa'] ?? 'Przedmiot',
              'teacher': '${item['TytulNaukowy'] ?? ''} ${item['wykladowca_imie'] ?? ''} ${item['wykladowca_nazwisko'] ?? ''}'.trim(),
              'examType': item['typ'] ?? '',
              'semestr': item['Semester'],
              'parts': [
                {
                  'partName': item['TypZajec'] ?? 'Zajęcia',
                  'finalGrade': item['skalaOceny'] ?? '-',
                  'grades': [item['skalaOceny'] ?? '-'],
                }
              ]
            };
          }).toList();

          subjects.sort((a, b) {
            bool aIsCurrent = (a['semestr'] == currentStudentSemester);
            bool bIsCurrent = (b['semestr'] == currentStudentSemester);
            if (aIsCurrent && !bIsCurrent) return -1;
            if (!aIsCurrent && bIsCurrent) return 1;
            return 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final sub = subjects[index];
              bool isCurrentSemester = (sub['semestr'] == currentStudentSemester);

              final cardColor = isCurrentSemester
                  ? Colors.lightGreenAccent.shade400
                  : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300);


              final textColor = isCurrentSemester
                  ? Colors.black87
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87);

              final subtitleColor = isCurrentSemester
                  ? Colors.black54
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54);

              // Получаем данные оценки
              final part = (sub['parts'] as List).isNotEmpty ? sub['parts'][0] : {};
              final finalGrade = part['finalGrade'] ?? '-';
              final partName = part['partName'] ?? '';

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        sub['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Semestr ${sub['semestr']}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub['teacher'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ocena: $finalGrade ($partName)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub['examType'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}