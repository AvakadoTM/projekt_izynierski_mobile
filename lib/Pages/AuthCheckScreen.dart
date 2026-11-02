import 'package:flutter/material.dart';
import 'package:projekt_izynierski/Services/api_service.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await _apiService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {

      Navigator.pushReplacementNamed(context, '/Home');
    } else {

      Navigator.pushReplacementNamed(context, '/Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}