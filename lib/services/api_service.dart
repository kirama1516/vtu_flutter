import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:m5data_app/models/user.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api"; // change to your server if hosted

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String username,
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

  // static Future<Map<String, dynamic>> loginUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   final url = Uri.parse('$baseUrl/login');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       return {
  //         'status': false,
  //         'message': 'Invalid credentials or server error',
  //       };
  //     }
  //   } catch (e) {
  //     return {'status': false, 'message': 'Error: ${e.toString()}'};
  //   }
  // }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == true) {
      return {
        "success": true,
        "user": UserModel.fromJson(data['user']),
      };
    } else {
      return {
        "success": false,
        "message": data['message'] ?? 'Login failed',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchWallet(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet'),
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

}
