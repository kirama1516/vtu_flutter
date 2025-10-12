import 'package:flutter/material.dart';
import 'package:m5data_app/services/api_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    final result = await apiService.fetchOrders();

    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success']) {
          orders = result['orders'];
        } else {
          orders = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to fetch orders')),
          );
        }
      });
    }
  }

  Future<void> exportAndShareCSV() async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No orders available to export.")),
      );
      return;
    }

    final path = await apiService.exportOrdersToCSV(orders);
    if (path != null) {
      await apiService.shareOrdersCSV(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to export orders.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Export CSV",
            onPressed: exportAndShareCSV,
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : orders.isEmpty
          ? const Center(child: Text("No orders found."))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(order['serviceName'] ?? 'Unknown Service'),
                    subtitle: Text(
                      '₦${order['total']} - ${order['status'] ?? 'N/A'}',
                    ),
                    trailing: Text(order['created_at'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
