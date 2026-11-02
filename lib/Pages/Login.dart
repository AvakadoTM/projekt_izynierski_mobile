import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projekt_izynierski/Services/api_service.dart';

class Login extends StatefulWidget{
  const Login();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uzupełnij wszystkie pola!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      await _apiService.Login(email, password);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/Home');
    } catch (e) {
      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Moja Uczelnia")),
      body:Column(
      children: [

        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: "Login",
            hintText: "Podaj swój Login",
            border: OutlineInputBorder()
          ),
          onChanged: (text){
            print("$_emailController.text");
          },
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
              labelText: "Hasło",
              hintText: "Podaj swoje hasało",
              border: OutlineInputBorder()
          ),
          onChanged: (text){
            print("$_passwordController.text");
          },
        ),
        ElevatedButton(onPressed: (){
          _handleLogin();
        }, child: Text("Zaloguj się"))
      ]
      )
    );
  }
}