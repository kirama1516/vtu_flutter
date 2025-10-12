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
        return {'success': true, 'message': data['message'] ?? 'PIN set successfully'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to set PIN'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error occurred: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchWallet( String token) async {
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
          'category_id': 1, // Adjust to your actual category ID
          'service_id': 1,  // Adjust to your actual service ID
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

    // 🧾 Fetch user orders from API
  Future<Map<String, dynamic>> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final url = Uri.parse('$baseUrl/orders'); // 👈 Replace with your actual endpoint
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'orders': data['orders'] ?? []};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch orders: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 📥 Export orders to CSV file
  Future<String?> exportOrdersToCSV(List<dynamic> orders) async {
    if (orders.isEmpty) return null;

    try {
      List<List<dynamic>> csvData = [
        [
          "ID",
          "User",
          "Service",
          "Biller",
          "Reference",
          "Price",
          "Quantity",
          "Total",
          "Beneficiary",
          "Status",
          "Date"
        ],
        ...orders.map((order) => [
              order['id'] ?? '',
              order['username'] ?? '',
              order['serviceName'] ?? '',
              order['billerName'] ?? '',
              order['reference'] ?? '',
              order['price'] ?? '',
              order['quantity'] ?? '',
              order['total'] ?? '',
              order['beneficiary'] ?? '',
              order['status'] ?? '',
              order['created_at'] ?? '',
            ]),
      ];

      // Convert to CSV format
      String csv = const ListToCsvConverter().convert(csvData);

      // Save file to phone
      final dir = await getExternalStorageDirectory();
      final path = "${dir!.path}/orders_export.csv";
      final file = File(path);
      await file.writeAsString(csv);

      return path;
    } catch (e) {
      return null;
    }
  }

  // 📤 Share the exported CSV
  Future<void> shareOrdersCSV(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(path)],
            text: 'Here is my order history CSV 📄');
      }
    } catch (e) {
      print("Error sharing CSV: $e");
    }
  }

}
