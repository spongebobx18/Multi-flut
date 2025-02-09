import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "https://auth-service-rbc3.onrender.com";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Login function
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'token', value: data['token']); // Save JWT token
      return true;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Sign-up function with enhanced debug statements
  Future<bool> signup(
      String email, String password, String role, String phone) async {
    try {
      // Validate role first
      String normalizedRole = role.trim().toUpperCase();
      if (normalizedRole != 'BUYER' && normalizedRole != 'SELLER') {
        throw Exception('Invalid role. Role must be either BUYER or SELLER');
      }

      print('=== Starting Signup Process ===');
      print('URL: $baseUrl/signup');
      print('Attempting signup with:');
      print('- Email: ${email.trim()}');
      print('- Role: $normalizedRole');
      print('- Phone: ${phone.trim()}');
      print('- Password length: ${password.length}');

      final requestBody = {
        'email': email.trim(),
        'password': password,
        'role': normalizedRole,
        'phone': phone.trim(),
      };
      print('Request headers: ${{'Content-Type': 'application/json'}}');
      print('Request body: ${json.encode(requestBody)}');

      final uri = Uri.parse('$baseUrl/signup');
      print('Parsed URI: $uri');

      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'The server is taking too long to respond. This might be due to slow server startup on the free tier. Please try again.');
        },
      );

      print('=== Response Info ===');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await storage.write(key: 'token', value: data['token']);
        print('Signup successful, token saved');
        return true;
      } else {
        // Enhanced error handling
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData.toString();
        } catch (e) {
          errorMessage = response.body.contains('<!DOCTYPE html>')
              ? 'Server Error: The server might be starting up. Please wait a moment and try again.'
              : response.body;
        }

        print('Error during signup: $errorMessage');
        throw Exception('Sign-up failed: $errorMessage');
      }
    } catch (e) {
      print('=== Exception Details ===');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      rethrow;
    }
  }

  // Logout function
  Future<void> logout() async {
    await storage.delete(key: 'token'); // Remove token from storage
  }

  // Fetch token
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }
}
