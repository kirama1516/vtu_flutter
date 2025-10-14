import 'dart:async';
import 'package:flutter/material.dart';
import 'package:m5data_app/services/api_service.dart';

class WalletBalance extends StatefulWidget {
  final String token; // pass in user token

  const WalletBalance({super.key, required this.token});

  @override
  State<WalletBalance> createState() => _WalletBalanceState();
}

class _WalletBalanceState extends State<WalletBalance> {
  bool showBalance = true;
  double balance = 0.0;
  bool loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchBalance();

    // 🔁 Auto refresh every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchBalance();
    });
  }

  Future<void> fetchBalance() async {
    setState(() => loading = true);

    final result = await ApiService.fetchWallet(widget.token);

    if (!mounted) return;

    setState(() {
      loading = false;
      if (result['data'] != null && result['data']['mainBalance'] != null) {
        balance = double.tryParse(result['data']['mainBalance'].toString()) ?? 0.0;
      } else {
        balance = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 🧹 Stop timer when leaving page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
              showBalance
                  ? "₦${balance.toStringAsFixed(2)}"
                  : "*****",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
          const SizedBox(width: 8),
        // 👁️ Toggle balance visibility button
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: IconButton(
            onPressed: () {
              setState(() {
                showBalance = !showBalance;
              });
            },
            icon: Image.asset(
              showBalance
                  ? 'assets/images/hideIcon.png'
                  : 'assets/images/showIcon.png',
              width: 25,
            ),
          ),
        ),
      ],
    );
  }
}
