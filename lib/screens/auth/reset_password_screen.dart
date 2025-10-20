import 'package:flutter/material.dart';
import 'package:m5data_app/services/api_service.dart';
import 'package:m5data_app/screens/auth/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) emailController.text = widget.email!;
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final res = await ApiService.resetPassword(
      email: emailController.text.trim(),
      token: tokenController.text.trim(),
      password: passwordController.text,
      passwordConfirmation: confirmController.text,
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? ''), backgroundColor: res['success'] ? Colors.green : Colors.red),
    );

    if (res['success']) {
      // go to login
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tokenController,
                decoration: const InputDecoration(labelText: 'Token (from email)', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Enter token' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder()),
                validator: (v) => v == null || v.length < 6 ? 'At least 6 chars' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm password', border: OutlineInputBorder()),
                validator: (v) => v != passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: isLoading ? null : submit, child: isLoading ? const CircularProgressIndicator() : const Text('Reset Password')),
            ],
          ),
        ),
      ),
    );
  }
}
