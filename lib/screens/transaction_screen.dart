import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  bool _isExporting = false;

  final _searchController = TextEditingController();
  String _selectedStatus = '';
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions(
      {String? search, String? status, String? date}) async {
    setState(() => _isLoading = true);

    final result = await ApiService.fetchFilteredTransactions(
      search: search,
      status: status,
      date: date,
    );

    setState(() {
      if (result['success']) {
        _transactions = result['transactions'];
      }
      _isLoading = false;
    });
  }

  Future<void> exportAndShareTransactions() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    setState(() => _isExporting = true);

    final filePath = await ApiService.exportTransactionsToCSV(_transactions);
    if (filePath != null) {
      await ApiService.shareTransactionsCSV(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export transactions')),
      );
    }

    setState(() => _isExporting = false);
  }

  void resetFilters() {
    _searchController.clear();
    _selectedStatus = '';
    _selectedDate = '';
    fetchTransactions();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isExporting
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Icon(Icons.download),
            onPressed: _isExporting ? null : exportAndShareTransactions,
            tooltip: 'Export Orders',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔍 Filters Section
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by User, Ref, Service...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus.isEmpty ? null : _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'Completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'Failed', child: Text('Failed')),
                      DropdownMenuItem(
                          value: 'Cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate.isEmpty ? 'Select date' : _selectedDate,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      fetchTransactions(
                        search: _searchController.text.trim(),
                        status: _selectedStatus,
                        date: _selectedDate,
                      );
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📦 Orders List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                      ? const Center(child: Text('No transactions found'))
                      : ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  '₦${transaction['price']} - ₦${transaction['balanceBefore']} & ₦${transaction['balanceAfter']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                subtitle: Text(
                                  'Ref: ${transaction['reference']}\nStatus: ${transaction['status']}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: transaction['status'] == 'Completed'
                                      ? const TextStyle(color: Colors.green)
                                      : transaction['status'] == 'Pending'
                                          ? const TextStyle(
                                              color: Colors.orange)
                                          : const TextStyle(color: Colors.red),
                                ),
                                trailing: Text(
                                  transaction['created_at'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
