import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';
import 'CourseDetailScreen.dart';
import 'AllCoursesScreen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<dynamic> _coursesFuture;
  List<dynamic> _allAvailableCourses = [];
  List<dynamic> _myCourses = [];
  int _currentSemester = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _coursesFuture = _apiService.fetchMojeKursy().then((responseBody) {
        final data = responseBody as Map<String, dynamic>;
        _myCourses = data['mojekursy'] ?? [];
        _allAvailableCourses = data['wszystkiekursy'] ?? [];

        // Определяем текущий семестр (максимальный семестр среди моих курсов)
        if (_myCourses.isNotEmpty) {
          _currentSemester = _myCourses.map((e) => e['Semester'] ?? 1).reduce((a, b) => a > b ? a : b);
        }
        return data;
      });
    });
  }

  // Поиск и запись по введенному коду или названию
  void _searchAndEnroll() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final foundCourse = _allAvailableCourses.firstWhere(
          (kurs) => kurs['nazwa'].toString().toLowerCase().contains(query) || kurs['idkurs'].toString() == query,
      orElse: () => null,
    );

    if (foundCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie znaleziono kursu o takim kodzie lub nazwie")),
      );
      return;
    }

    final bool isEnrolled = _myCourses.any((kurs) => kurs['idkurs'] == foundCourse['idkurs']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(foundCourse['nazwa'] ?? 'Kurs'),
        content: Text(
          isEnrolled
              ? "Już jesteś zapisany na ten kurs."
              : "Czy chcesz zapisać się na ten kurs (Semestr ${foundCourse['Semester']})?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          if (!isEnrolled)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _apiService.zapiszNaKurs(foundCourse['idkurs']);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pomyślnie zapisano na kurs!")),
                  );
                  _loadData();
                }
              },
              child: const Text("Zapisz się"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moje kursy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "Wszystkie kursy kierunku",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllCoursesScreen()),
              ).then((_) => _loadData());
            },
          )
        ],
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Wpisz kod lub nazwę kursu...",
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchAndEnroll,
                  child: const Text("Szukaj"),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: FutureBuilder<dynamic>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Błąd: ${snapshot.error}"));
                }

                if (_myCourses.isEmpty) {
                  return const Center(child: Text("Nie jesteś zapisany na żaden kurs"));
                }

                List sortedCourses = List.from(_myCourses);
                sortedCourses.sort((a, b) {
                  bool aIsCurrent = (a['Semester'] == _currentSemester);
                  bool bIsCurrent = (b['Semester'] == _currentSemester);
                  if (aIsCurrent && !bIsCurrent) return -1;
                  if (!aIsCurrent && bIsCurrent) return 1;
                  return (b['Semester'] ?? 0).compareTo(a['Semester'] ?? 0);
                });

                return ListView.builder(
                  itemCount: sortedCourses.length,
                  itemBuilder: (context, index) {
                    final kurs = sortedCourses[index];
                    bool isCurrent = (kurs['Semester'] == _currentSemester);
                    final prow = kurs['prowadzacy']?['user'] ?? {};
                    final teacherName = "${prow['name'] ?? ''} ${prow['surname'] ?? ''}".trim();

                    return Card(
                      color: isCurrent ? Colors.lightGreenAccent.shade400 : Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          kurs['nazwa'] ?? 'Kurs',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: Text(
                          "Semestr ${kurs['Semester']} | Prowadzący: $teacherName",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailScreen(
                                idKurs: kurs['idkurs'],
                                courseName: kurs['nazwa'],
                                teacherName: teacherName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}