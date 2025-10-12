import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m5data_app/models/user.dart';
import 'package:m5data_app/services/api_service.dart';
import 'auth/login_screen.dart';
import 'package:m5data_app/screens/buyAirtime_screen.dart';
import 'package:m5data_app/widgets/wallet_balance.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = false;
  bool showBalance = true;

  @override
  void initState() {
    super.initState();
    loadWallet(); // Fetch wallet balance when dashboard loads
  }

  /// 🔄 Fetch user's wallet balance
  Future<void> loadWallet() async {
    setState(() => isLoading = true);

    final response = await ApiService.fetchWallet(widget.user.token ?? '');

    setState(() => isLoading = false);

    if (response['status'] == true) {
      setState(() {
        widget.user.mainBalance =
            double.tryParse(response['data']['mainBalance'].toString()) ?? 0.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to fetch wallet'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 🚪 Logout logic
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      // Custom AppBar
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () => Scaffold.of(context).openDrawer(),
        tooltip: "Open Menu",
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Profile dropdown (simulated with PopupMenuButton)
          PopupMenuButton<int>(
        icon: CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/images/profileIcon.png'),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 0,
            child: Row(
          children: [
            Icon(Icons.edit, color: Colors.indigo[900]),
            SizedBox(width: 8),
            Text("Edit Profile"),
          ],
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Row(
          children: [
            Icon(Icons.settings, color: Colors.indigo[900]),
            SizedBox(width: 8),
            Text("Settings"),
          ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 2,
            child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            Navigator.pushNamed(context, '/profile');
          } else if (value == 1) {
            Navigator.pushNamed(context, '/settings');
          } else if (value == 2) {
            logoutUser();
          }
        },
          ),
          const SizedBox(width: 10),
        ],
      ),

      // Sidebar Drawer (Offcanvas style)
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.indigo[900]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/profileIcon.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(user.name,
                style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
            const SizedBox(height: 4),
            Text(user.email,
                style: const TextStyle(
                color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
            ],
          ),
        ),
        // Menu Section
        const _DrawerSection(title: "Menu"),
        _buildDrawerItem(Icons.dashboard, "Dashboard", () {
          Navigator.pop(context);
        }),
        _buildDrawerItem(Icons.add_circle_outline, "Add Money", () {
          Navigator.pushNamed(context, '/add-money');
        }),
        _buildDrawerItem(Icons.account_balance_wallet, "Wallet", () {
          Navigator.pushNamed(context, '/wallet');
        }),
        const Divider(),
        // Services Section
        const _DrawerSection(title: "Services"),
        _buildDrawerItem(Icons.phone_android, "Buy Airtime", () {
          Navigator.pushNamed(context, '/buyAirtime');
        }),
        _buildDrawerItem(Icons.wifi, "Buy Data", () {
          Navigator.pushNamed(context, '/buyData');
        }),
        _buildDrawerItem(Icons.message, "Bulk SMS", () {
          Navigator.pushNamed(context, '/bulkSMS');
        }),
        _buildDrawerItem(Icons.tv, "Buy Cable", () {
          Navigator.pushNamed(context, '/buyCable');
        }),
        _buildDrawerItem(Icons.electric_bolt, "Buy Electricity", () {
          Navigator.pushNamed(context, '/buyElectricity');
        }),
        _buildDrawerItem(Icons.school, "Exams", () {
          Navigator.pushNamed(context, '/buyExam');
        }),
        const Divider(),
        // History Section
        const _DrawerSection(title: "History"),
        _buildDrawerItem(Icons.receipt_long, "Orders", () {
          Navigator.pushNamed(context, '/orders');
        }),
        _buildDrawerItem(Icons.history, "Transactions", () {
          Navigator.pushNamed(context, '/transactions');
        }),
        _buildDrawerItem(Icons.payment, "Payment", () {
          Navigator.pushNamed(context, '/payment');
        }),
        const Divider(),
        // Logout
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            "Logout",
            style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
            ),
          ),
          onTap: logoutUser,
        ),
          ],
        ),
      ),

      // ✅ Body Content
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Wallet Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🏦 Wallet Icon + Balance
                Row(
                  children: [
                    // Wallet icon
                    InkWell(
                      onTap: () {
                        // Navigate to wallet page
                        Navigator.pushNamed(context, '/wallet');
                      },
                      child: Image.asset(
                        'assets/images/walletIcon.png',
                        width: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Wallet text + amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Wallet balance",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 2, 13, 76),
                          ),
                        ),
                        const SizedBox(height: 1),
                        WalletBalance(token: widget.user.token ?? '')
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

            // Add Money / History Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🟢 Add Money Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-money');
                      },
                      icon: Image.asset(
                        'assets/images/addIcon.png',
                        width: 20,
                      ),
                      label: const Text("Add Money"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🟠 History Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/transactions');
                      },
                      icon: Image.asset(
                        'assets/images/historyIcon.png',
                        width: 20,
                      ),
                      label: const Text("History"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

          // 🏦 Account Details
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: (user.accName.isNotEmpty &&
                user.accNumber.isNotEmpty &&
                user.bankName.isNotEmpty)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Account Number & Bank Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.accNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.bankName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ],
                  ),

                  // Right: Copy Button & Account Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'assets/images/copyIcon.png',
                          width: 20,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: user.accNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Account number copied!"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      Text(
                        user.accName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  icon: const Icon(Icons.touch_app, color: Colors.indigo),
                  label: const Text(
                    "Click here to create virtual account",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // 🧩 Quick Services Section
          const SizedBox(height: 10),

          Material(
            color: Colors.transparent,
            child: Card(
              color: Colors.grey[200], // Light ash background
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ServiceTile(
                      imagePath: 'assets/images/airtimeIcon.png',
                      label: "Airtime",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BuyAirtimeScreen()),
                        );
                      },
                    ),
                    _ServiceTile(
                      imagePath: 'assets/images/dataIcon.png',
                      label: "Data",
                      onTap: () => Navigator.pushNamed(context, '/buyData'),
                    ),
                    _ServiceTile(
                      imagePath: 'assets/images/cableIcon.png',
                      label: "Cable",
                      onTap: () => Navigator.pushNamed(context, '/buyCable'),
                    ),
                    _ServiceTile(
                      imagePath: 'assets/images/examIcon.png',
                      label: "Exam",
                      onTap: () => Navigator.pushNamed(context, '/buyExam'),
                    ),
                    _ServiceTile(
                      imagePath: 'assets/images/electricityIcon.png',
                      label: "Electricity",
                      onTap: () => Navigator.pushNamed(context, '/buyElectricity'),
                    ),
                    _ServiceTile(
                      imagePath: 'assets/images/bulkIcon.png',
                      label: "More",
                      onTap: () => Navigator.pushNamed(context, '/bulkSMS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ✅ Custom Bottom Navigation Bar (Flutter version of provided HTML)
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
        // Home
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Already on dashboard, maybe scroll to top or refresh
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Image.asset(
            'assets/images/homeIcon.png',
            width: 25,
          ),
          const SizedBox(height: 2),
          const Text(
            "Home",
            style: TextStyle(
              fontSize: 12,
              color: Colors.indigo,
              fontWeight: FontWeight.w500,
            ),
          ),
            ],
          ),
        ),
        // Customer Care
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/customerCare');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Image.asset(
            'assets/images/customerIcon.png',
            width: 25,
          ),
          const SizedBox(height: 2),
          const Text(
            "Customer Care",
            style: TextStyle(
              fontSize: 12,
              color: Colors.indigo,
              fontWeight: FontWeight.w500,
            ),
          ),
            ],
          ),
        ),
        // Account
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Image.asset(
            'assets/images/accountIcon.png',
            width: 25,
          ),
          const SizedBox(height: 2),
          const Text(
            "Account",
            style: TextStyle(
              fontSize: 12,
              color: Colors.indigo,
              fontWeight: FontWeight.w500,
            ),
          ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  // 🔹 Drawer Item Builder
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo[900]),
      title: Text(title, style: TextStyle(color: Colors.indigo[900])),
      onTap: onTap,
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  const _DrawerSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  const _ServiceTile({
    required this.imagePath,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.indigo[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.indigo[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}