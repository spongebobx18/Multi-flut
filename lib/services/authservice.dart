import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://localhost:8001"; // Update this with your backend URL
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
  // Sign-up function
  Future<bool> signup(String email, String password,  String role, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'role': role.toUpperCase(),
        'phone': phone, // Now correctly passed
      }),
     
      
      
    );
  


    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await storage.write(key: 'token', value: data['token']); // Save JWT token
      return true;
    } else {
      throw Exception('Sign-up failed: ${response.body}');
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
