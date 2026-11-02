import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projekt_izynierski/DataModels/budynek_mapy.dart';

class ApiService{
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final _storage = FlutterSecureStorage();
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> saveToken(String token) async{
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async{
    return await _storage.read(key: 'auth_token');
  }


  Future<void> logoutStorage() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, dynamic>> Login(String email, String password) async{
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email':email,
        'password':password,
      }),
    );
    if (response.statusCode==200){
      final data=jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    }
    else{
      final error = jsonDecode(response.body);
      //print(error['message']);
      throw Exception(error['message'] ?? 'Auth error');
    }
  }

  Future<Map<String, dynamic>> fetchMojeDane() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/mojedane'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await logoutStorage();
      throw Exception('Session ended. Login again');
    } else {
      throw Exception('Data loading error');
    }
  }

  //Logout
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    await logoutStorage();
  }


  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


  Future<Map<String, dynamic>> fetchPlanZajec() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/planzajec'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await logoutStorage();
      throw Exception('Session ended');
    } else {
      throw Exception('Loading error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchPlanZajecForGroup(int grupaId) async {
    final headers = await _getHeaders();

    final response = await http.get(Uri.parse('$baseUrl/planzajec/$grupaId'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await logoutStorage();
      throw Exception('Session ended');
    } else {
      throw Exception('Loading error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchOceny() async {
    final headers = await _getHeaders();


    final response = await http.get(Uri.parse('$baseUrl/student/ocenykoncowe'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await logoutStorage();
      throw Exception('Session ended');
    } else {
      throw Exception('Loading error: ${response.statusCode}');
    }

  }


  Future<Map<String, dynamic>> fetchFinances() async {
  final token = await getToken();
  if (token == null) throw Exception('Token not found');

  final response = await http.get(
    Uri.parse('$baseUrl/student/mojefinanse'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Błąd ładowania danych finansowych');
  }
  }

  Future<bool> sendPodanieM({required String type, required String content}) async {

    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> sendPodanie({required String type, required String content}) async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/podania'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': type,
        'content': content,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Nie udało się wysłać podania');
    }
  }


  Future<List<dynamic>> fetchKonsultacjeM({String? searchQuery}) async {
    // Временная заглушка с демо-данными
    await Future.delayed(const Duration(milliseconds: 500));

    final List<dynamic> allConsultations = [
      {
        'id': 1,
        'teacherName': 'dr. inż. Adam Nowak',
        'subject': 'Matematyka dla informatyków I',
        'day': 'Wtorek',
        'time': '14:00 - 15:30',
        'room': 'Gabinet 312, bud. A',
        'isMyTeacher': true, // Ведет у текущего студента
      },
      {
        'id': 2,
        'teacherName': 'dr. hab. inż. Jan Kozieł',
        'subject': 'Informatyka II',
        'day': 'Czwartek',
        'time': '10:15 - 11:45',
        'room': 'Gabinet 405, bud. B',
        'isMyTeacher': true,
      },
      {
        'id': 3,
        'teacherName': 'prof. dr hab. Maria Wójcik',
        'subject': 'Fizyka ogólna',
        'day': 'Poniedziałek',
        'time': '12:00 - 13:30',
        'room': 'Gabinet 110, bud. C',
        'isMyTeacher': false,
      },
      {
        'id': 4,
        'teacherName': 'mgr inż. Piotr Zieliński',
        'subject': 'Bazy Danych SQL',
        'day': 'Środa',
        'time': '16:00 - 17:30',
        'room': 'Lab 204, bud. A',
        'isMyTeacher': false,
      },
    ];


    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      return allConsultations.where((item) {
        final teacher = item['teacherName'].toString().toLowerCase();
        final subject = item['subject'].toString().toLowerCase();
        return teacher.contains(query) || subject.contains(query);
      }).toList();
    }

    return allConsultations;
  }
  Future<List<dynamic>> fetchKonsultacje({String? searchQuery}) async {
    final headers = await _getHeaders();


    final Uri uri = Uri.parse('$baseUrl/student/konsultacje').replace(
      queryParameters: (searchQuery != null && searchQuery.isNotEmpty)
          ? {'search': searchQuery}
          : null,
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('konsultacje')) {
        return data['konsultacje'];
      } else if (data is Map && data.containsKey('consultations')) {
        return data['consultations'];
      }
      return [];
    } else if (response.statusCode == 401) {
      await logoutStorage();
      throw Exception('Session ended');
    } else {
      throw Exception('Loading error: ${response.statusCode}');
    }
  }

  Future<List<BudynekMapy>> fetchBudynki() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');
    final response = await http.get(
      Uri.parse('$baseUrl/mapa'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Błąd serwera: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    ) as Map<String, dynamic>;

    final sale = decoded['sale'] as List<dynamic>? ?? [];

    final Map<int, BudynekMapy> budynki = {};

    for (final item in sale) {
      final json = Map<String, dynamic>.from(item as Map);

      final lat = double.tryParse(
        json['szerokosc']?.toString() ?? '',
      );
      final lon = double.tryParse(
        json['dlugosc']?.toString() ?? '',
      );

      if (lat == null || lon == null ||
          !lat.isFinite || !lon.isFinite ||
          lat < -90 || lat > 90 ||
          lon < -180 || lon > 180) {
        continue;
      }

      final building = BudynekMapy.fromJson(json);
      final previous = budynki[building.id];

      if (previous == null) {
        budynki[building.id] = building;
      } else {

        budynki[building.id] = BudynekMapy(
          id: previous.id,
          nazwa: previous.nazwa,
          ulica: previous.ulica,
          nrBudynku: previous.nrBudynku,
          szerokosc: previous.szerokosc,
          dlugosc: previous.dlugosc,
          numerySal: [
            ...previous.numerySal,
            ...building.numerySal,
          ].toSet().toList(),
        );
      }
    }

    return budynki.values.toList();
  }
}
