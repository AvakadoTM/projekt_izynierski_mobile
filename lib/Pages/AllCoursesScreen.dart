import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final ApiService _apiService = ApiService();
  late Future<dynamic> _allCoursesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _allCoursesFuture = _apiService.fetchMojeKursy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wszystkie kursy kierunku"),
      ),
      body: FutureBuilder<dynamic>(
        future: _allCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final responseBody = snapshot.data;
          final data = (responseBody is Map<String, dynamic>) ? responseBody : <String, dynamic>{};

          final List wszystkieKursy = data['wszystkiekursy'] ?? [];
          final List mojeKursy = data['mojekursy'] ?? [];

          final myCourseIds = mojeKursy.map((e) => e['idkurs']).toSet();

          if (wszystkieKursy.isEmpty) {
            return const Center(child: Text("Brak dostępnych kursów"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: wszystkieKursy.length,
            itemBuilder: (context, index) {
              final kurs = wszystkieKursy[index];
              final bool isEnrolled = myCourseIds.contains(kurs['idkurs']);

              final prow = kurs['prowadzacy']?['user'] ?? {};
              final teacherName = "${prow['name'] ?? ''} ${prow['surname'] ?? ''}".trim();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    kurs['nazwa'] ?? 'Kurs',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Semestr ${kurs['Semester']} | Prowadzący: ${teacherName.isNotEmpty ? teacherName : 'Brak'}",
                  ),
                  trailing: isEnrolled
                      ? const Text(
                    "Zapisany",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      try {

                        await _apiService.zapiszNaKurs(kurs['idkurs']);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pomyślnie zapisano na kurs")),
                          );

                          _loadData();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Nie udało się zapisać na kurs")),
                          );
                        }
                      }
                    },
                    child: const Text("Zapisz się"),
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