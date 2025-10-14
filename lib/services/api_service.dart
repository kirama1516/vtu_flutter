import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:m5data_app/helpers/auth_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:m5data_app/models/user.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api"; // change to your server if hosted

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // Parse error message from backend
        final errorData = jsonDecode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("Response: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == true) {
      await AuthHelper.saveToken(data['token']);
      return {
        "status": true,
        "message": data['message'],
        "user": data['user'],
        "token": data['token'],
      };
    } else {
      return {
        "status": false,
        "message": data['message'] ?? 'Login failed',
      };
    }
  }

  static Future<Map<String, dynamic>> setPin({
    required String token,
    required String pin,
    required String confirmPin,
  }) async {
    final url = Uri.parse('$baseUrl/set_pin'); // adjust to your API route

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pin': pin,
          'pin_confirmation': confirmPin, // matches Laravel’s `confirmed` rule
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'PIN set successfully'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to set PIN'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error occurred: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchWallet(String token) async {
    final url = Uri.parse('$baseUrl/wallet');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'status': false, 'message': 'Error fetching wallet'};
    }
  }

  Future<Map<String, dynamic>> buyAirtime({
    required String billerId,
    required String categoryId,
    required double amount,
    required String phone,
    required String pin,
  }) async {
    try {
      // Get saved token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final url = Uri.parse('$baseUrl/buy-airtime');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'biller_id': billerId,
          'category_id': categoryId, // Adjust to your actual category ID
          'service_id': 1, // Adjust to your actual service ID
          'price': amount,
          'beneficiary': phone,
          'pin': pin,
          'total': amount,
          'quantity': 1,
        }),
      );

      print('🔹 API Response (${response.statusCode}): ${response.body}');

      // Try decode JSON
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📦 Fetch Orders Response: ${response.body}');
      final data = jsonDecode(response.body);

      return data;
    } catch (e) {
      print('❌ Fetch Orders Error: $e');
      return {'success': false, 'message': 'Failed to load orders'};
    }
  }

  // 🧾 Fetch user orders from API
  static Future<Map<String, dynamic>> fetchFilteredOrders({
    String? search,
    String? status,
    String? date,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = token ?? prefs.getString('token');

      if (authToken == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (date != null && date.isNotEmpty) 'date': date,
      };

      final uri =
          Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      print('🔹 Filter Orders Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'orders': data['orders'] ?? []};
      } else {
        return {'success': false, 'message': 'Failed to fetch filtered orders'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<String?> exportOrdersToCSV(List<dynamic> orders) async {
    try {
      List<List<dynamic>> rows = [
        [
          'ID',
          'Reference',
          'Beneficiary',
          'Price',
          'Total',
          'Status',
          'Provider',
          'Date'
        ]
      ];

      for (var order in orders) {
        rows.add([
          order['id'],
          order['reference'],
          order['beneficiary'],
          order['price'],
          order['total'],
          order['status'],
          order['provider'],
          order['created_at'],
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/orders_export.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      return path;
    } catch (e) {
      print('❌ CSV Export Error: $e');
      return null;
    }
  }

  static Future<void> shareOrdersCSV(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is my exported order history 📦',
      );
    } catch (e) {
      print('❌ Share CSV Error: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📦 Fetch Orders Response: ${response.body}');
      final data = jsonDecode(response.body);

      return data;
    } catch (e) {
      print('❌ Fetch Transactions Error: $e');
      return {'success': false, 'message': 'Failed to load Transactions'};
    }
  }

  // 🧾 Fetch user orders from API
  static Future<Map<String, dynamic>> fetchFilteredTransactions({
    String? search,
    String? status,
    String? date,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = token ?? prefs.getString('token');

      if (authToken == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (date != null && date.isNotEmpty) 'date': date,
      };

      final uri = Uri.parse('$baseUrl/transactions')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      print('🔹 Filter Transactions Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'transactions': data['transactions'] ?? []};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch filtered transactions'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<String?> exportTransactionsToCSV(
      List<dynamic> transactions) async {
    try {
      List<List<dynamic>> rows = [
        [
          'ID',
          'wallet_id'
              'order_id'
              'reference'
              'type'
              'price'
              'balanceBefore'
              'balanceAfter'
              'note'
              'status'
        ]
      ];

      for (var transaction in transactions) {
        rows.add([
          transaction['id'],
          transaction['wallet_id'],
          transaction['order_id'],
          transaction['reference'],
          transaction['type'],
          transaction['price'],
          transaction['balanceBefore'],
          transaction['balanceAfter'],
          transaction['note'],
          transaction['status'],
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/transactions_export.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      return path;
    } catch (e) {
      print('❌ CSV Export Error: $e');
      return null;
    }
  }

  static Future<void> shareTransactionsCSV(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is my exported transactions history 📦',
      );
    } catch (e) {
      print('❌ Share CSV Error: $e');
    }
  }
}
