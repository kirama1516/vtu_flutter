import 'package:flutter/material.dart';
import 'package:m5data_app/services/api_service.dart';

class BuyAirtimeScreen extends StatefulWidget {
  const BuyAirtimeScreen({Key? key}) : super(key: key);

  @override
  State<BuyAirtimeScreen> createState() => _BuyAirtimeScreenState();
}

class _BuyAirtimeScreenState extends State<BuyAirtimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  String? selectedNetwork;
  bool isLoading = false;

  final List<Map<String, dynamic>> networks = [
    {'id': 1, 'name': 'Airtel', 'image': 'assets/images/airtel.jpeg'},
    {'id': 2, 'name': 'MTN', 'image': 'assets/images/mtn.jpeg'},
    {'id': 3, 'name': 'Glo', 'image': 'assets/images/glo.jpeg'},
    {'id': 4, 'name': '9mobile', 'image': 'assets/images/9mobile.jpeg'},
  ];

  void buyAirtime() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // print("➡️ Buying airtime...");
      final result = await ApiService().buyAirtime(
        billerId: selectedNetwork!,
        amount: double.parse(amountController.text),
        phone: phoneController.text,
        pin: pinController.text,
      );
      print("✅ API Result: $result");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Something went wrong'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Airtime", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Network Grid
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: networks.map((network) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedNetwork = network['id'].toString()),
                        child: Card(
                          color: selectedNetwork == network['id'].toString()
                              ? Colors.blue[100]
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(network['image']),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.length < 10 ? "Enter valid phone" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || double.tryParse(v) == null ? "Enter amount" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: "Transaction PIN",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.length != 4 ? "Enter 4-digit PIN" : null,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : buyAirtime,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.indigo[900],
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Buy Airtime", style: TextStyle(color: Color(0xFFFFFFFF))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
