import 'package:flutter/material.dart';
import 'package:m5data_app/services/api_service.dart';
import 'package:m5data_app/models/user.dart';
import 'package:m5data_app/screens/dashboard_screen.dart';

class SetPinScreen extends StatefulWidget {
  final UserModel user;

  const SetPinScreen({super.key, required this.user});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  Future<void> _submitPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty || confirmPin.isEmpty) {
      _showMessage("Please fill all fields", Colors.red);
      return;
    }

    if (pin.length != 4) {
      _showMessage("PIN must be 4 digits", Colors.red);
      return;
    }

    if (pin != confirmPin) {
      _showMessage("PINs do not match", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final response = await ApiService.setPin(
      token: widget.user.token!,
      pin: _pinController.text,
      confirmPin: _confirmPinController.text,
    );
    setState(() => _isLoading = false);

    if (response['success']) {
    _showMessage("PIN created successfully", Colors.green);
    widget.user.hasPin = 1;
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(user: widget.user)),
      );
    });
    } else {
      _showMessage(response['message'], Colors.red);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create Your PIN",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),

              // PIN field
              TextField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: "Enter 4-digit PIN",
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.indigo),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin ? Icons.visibility_off : Icons.visibility,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePin = !_obscurePin;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Confirm PIN
              TextField(
                controller: _confirmPinController,
                obscureText: _obscureConfirmPin,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: "Confirm PIN",
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.indigo),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPin ? Icons.visibility_off : Icons.visibility,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create PIN",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
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
