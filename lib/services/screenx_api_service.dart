import 'dart:convert';
import 'package:http/http.dart' as http;

class ScreenXApiService {
  // Replace with your actual backend API endpoint
  static const String _tokenEndpoint = 'https://your-backend.com/api/get-screenx-token';

  // Temporary testing token - Replace with actual API call in production
  static const String _testToken = 'lmTFyN8EmdRq2Sv3JSsgmVLQbXUgYuwb+ff5wHa3C6Hr4KLn/O7SFEhrfyABlMZ0KWqcSmjqn3q8bFvlAeERVtemFzCKdiO9tKNUwu4zNX9RX3lfyuEBRmcyitdArEEZcKsK0yAkVz9S1em+B/bg0qjMngFfSVi91kToKoM3kvpXeqlDqW2Zt6fT9P7QsNWPexBXT2pA0skkipMJLpm00PpHGg2RHi4PI4RD4nfsdjxbNseoKecuHBL8TslGQJTRZ42GZAa55k+IUKliw23LyaYjaEjuMAoiF8iIlf4TG3VydYYtjihHYBU1dpYVVmAMOBu4QGmEH4H48oDj0nl2JICeHTNNR0mUwKBpkKO4TEnpUNhxyak7dOW7RRHENQjuHt1zQLqK/PgzIR1rpHK3vK04KGilsXiGWN8i0lnAZNv7OODOLvTwPL0uNBu9yFpXZVJNGV2sfErm8SuB7Rg9+/h2i4S548qy868U5t5hnc2MHDRxEnAcZ/WkftHtkTKy+zixN0aKhiF6CGUesY85jBRnpz0cGIPEmfhaFwakRHzptzmajiDEqJOFoUYFnS1mkkupwIz5W/qNdqewq6AIcQ==';

  /// Fetches the JWT token from your backend API
  /// Returns the token string or throws an exception on error
  /// Currently using a hardcoded test token for development
  Future<String> fetchJwtToken() async {
    // TODO: Remove this in production and uncomment the API call below
    // For testing purposes, returning the test token directly
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    return _testToken;

    /* Uncomment this block when you have a backend API ready:
    try {
      final response = await http.get(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers your backend requires
          // 'Authorization': 'Bearer your-api-key',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Adjust the key based on your backend response structure
        // Example: {"token": "eyJhbGciOiJIUzI1NiIs..."}
        if (data['token'] != null) {
          return data['token'] as String;
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching JWT token: $e');
    }
    */
  }

  /// Optional: Fetch token with POST request if your backend requires it
  Future<String> fetchJwtTokenPost({Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body ?? {}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] != null) {
          return data['token'] as String;
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching JWT token: $e');
    }
  }
}
