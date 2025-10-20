import 'package:flutter/material.dart';
import 'package:m5data_app/services/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final res = await ApiService.forgotPassword(emailController.text.trim());
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'Result'),
        backgroundColor: res['success'] ? Colors.green : Colors.red,
      ),
    );

    if (res['success']) {
      // Option: navigate user to ResetPasswordScreen to paste token
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: emailController.text.trim()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Enter your account email to receive reset instructions.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading ? const CircularProgressIndicator() : const Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
