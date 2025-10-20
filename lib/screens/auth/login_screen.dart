import 'package:flutter/material.dart';
import 'package:m5data_app/models/user.dart';
import 'package:m5data_app/screens/auth/forgot_password_screen.dart';
import 'package:m5data_app/screens/auth/register_screen.dart';
import 'package:m5data_app/screens/auth/set_pin_screen.dart';
import 'package:m5data_app/widgets/custom_input.dart';
import 'package:m5data_app/services/api_service.dart';
import 'package:m5data_app/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logging in...")),
    );

    final result = await ApiService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() => isLoading = false);

    if (result['status'] == true) {
      final token = result['token'];
      final userData = result['user'];

      // create user model using fromJson factory
      final user = UserModel.fromJson({
        ...userData,
        'token': token,
      });

      if (user.hasPin == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SetPinScreen(user: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                "assets/images/loginIcon.png", // make sure you added this in pubspec.yaml
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome Back!!!",
                style: TextStyle(color: Colors.indigo[900], fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Login",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                    fontSize: 22),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                hintText: "Email/Username",
                icon: Icons.email_outlined,
                controller: emailController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                hintText: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
                controller: passwordController,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // const Text(
                  //   "Forgot Password",
                  //   style: TextStyle(
                  //       // color: Colors.indigo[900],
                  //       fontWeight: FontWeight.bold),
                  // ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.indigo),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.indigo[900])
                    : Text(
                        "Login",
                        style:
                            TextStyle(color: Colors.indigo[900], fontSize: 16),
                      ),
              ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
