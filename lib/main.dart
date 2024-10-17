import 'package:flutter/material.dart';
import 'login_page.dart'; // Import login page
import 'register_page.dart'; // Import register page
import 'main_page.dart'; // Import main page after login
import 'forgot_password_page.dart'; // Import Forgot Password page
import 'package:pocketbase/pocketbase.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090'); // Initialize PocketBase

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => MainPage(role: 'member', pb: pb),
      },
    );
  }
}

// HomePage to navigate between Login and Register
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  PocketBase pb = PocketBase('http://127.0.0.1:8090'); // Initialize PocketBase

  final String adminEmail = 'admin@ubu.ac.th';
  final String adminPassword = 'admin@dssi';

  Future<void> loginUser() async {
    try {
      if (_emailController.text == adminEmail && _passwordController.text == adminPassword) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admin login successful!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(role: 'admin', pb: pb)));
      } else {
        final authData = await pb.collection('users').authWithPassword(_emailController.text, _passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(role: 'member', pb: pb)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Logo.png',
                width: 650,
                height: 150,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      loginUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
