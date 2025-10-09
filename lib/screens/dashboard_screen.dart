import 'package:flutter/material.dart';
import 'package:m5data_app/models/user.dart';
import 'package:m5data_app/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadWallet(); // Fetch latest wallet balance on screen load
  }

  Future<void> loadWallet() async {
    setState(() => isLoading = true);

    final response = await ApiService.fetchWallet(widget.user.token ?? '');

    setState(() => isLoading = false);

    if (response['status'] == true) {
      setState(() {
        widget.user.walletBalance = response['data']['balance'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to fetch wallet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Menu clicked")),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Wallet Card
           Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("Wallet Balance", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            "₦${user.walletBalance.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap refresh to update",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

             Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(user.bankName, style: const TextStyle(fontSize: 18)),
                    Text(user.accName, style: const TextStyle(fontSize: 16)),
                    Text(user.accNumber, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Services Grid
            const Text(
              "Available Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ServiceTile(icon: Icons.phone_android, label: "Airtime"),
                _ServiceTile(icon: Icons.data_usage, label: "Data"),
                _ServiceTile(icon: Icons.tv, label: "Cable"),
                _ServiceTile(icon: Icons.school, label: "Exam"),
                _ServiceTile(icon: Icons.lightbulb, label: "Electricity"),
                _ServiceTile(icon: Icons.more_horiz, label: "More"),
              ],
            ),

            const SizedBox(height: 20),

            // User Info Section
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(user.name),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Customer Care"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
