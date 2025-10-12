import 'package:flutter/material.dart';
import 'package:m5data_app/widgets/custom_input.dart';
import 'package:m5data_app/services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              Text("Create an Account",
                  style: TextStyle(color: Colors.indigo[900], fontSize: 18)),
              const SizedBox(height: 10),
              Text("Register",
                  style: TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              CustomTextField(
                hintText: "Firstname",
                icon: Icons.person_outline,
                controller: firstNameController,
              ),

              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Surname",
                icon: Icons.person_outline,
                controller: surnameController,
              ),

              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Username",
                icon: Icons.person_outline,
                controller: usernameController,
              ),

              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Phone Number",
                icon: Icons.phone,
                controller: phoneController,
              ),

              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Email",
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
                controller: passwordController,
              ),
              
              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Confirm Password",
                icon: Icons.lock_outline,
                obscureText: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Checkbox(value: false, onChanged: (_) {}),
                  Expanded(
                    child: Text(
                      "By signing up, you agree to our Terms & Conditions",
                      style: TextStyle(color: Colors.indigo[900]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Registering...")),
                  );

                  final response = await ApiService.registerUser(
                    name: "${firstNameController.text} ${surnameController.text}",
                    username: usernameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    confirmPassword: confirmPasswordController.text,
                  );

                  if (response['status'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registration Successful")),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? "Failed to register")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.indigo),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: Text("Register",
                    style: TextStyle(color: Colors.indigo[900], fontSize: 16)),
              ),


              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.indigo[900], fontWeight: FontWeight.bold),
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
