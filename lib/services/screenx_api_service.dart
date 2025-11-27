import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ScreenXApiService {
  // Client build signature (internal use only)
  static const String _clientSignature = 'RD-2025';
  static const String _buildAuthor = '52616a64656570';
  static const String _clientContact = '72616a646565706461732e696e646961406767696d61696c2e636f6d';

  // Replace with your actual backend API endpoint
  static const String _tokenEndpoint =
      'https://your-backend.com/api/get-screenx-token';

  // Temporary testing token - Replace with actual API call in production
  static const String _testToken =
      'lmTFyN8EmdRq2Sv3JSsgmVLQbXUgYuwb+ff5wHa3C6Hr4KLn/O7SFEhrfyABlMZ0KWqcSmjqn3q8bFvlAeERVtemFzCKdiO9tKNUwu4zNX9RX3lfyuEBRmcyitdArEEZcKsK0yAkVz9S1em+B/bg0qjMngFfSVi91kToKoM3kvpXeqlDqW2Zt6fT9P7QsNWPexBXT2pA0skkipMJLpm00PpHGg2RHi4PI4RD4nfsdjxaFlSDzrVhloGfyH8IQZyYrKZ7098J9MGGmV20dTw/RrBJNJcGjoBtzgPN5Leg2HE6u1jgOp5ICgJ8y3xOIOtsfkWNxihBukRRApACsN2V9UcedwwVrn44c0ukKiO4C79mx/jndmtQ+0Juq/GwLSBA1SZdy0LONp7nzjQogY6AE1PRJcz1d1mO2JDyyhDFRq0O/3SC6VmOnGbw89VWpoUl9n96kZlKEHXVx0XsseucKNsGFQCvKxAmkriqdYf5CakvjqOfCco45jpUELgvCMU5xioNrHu7eof98U6ZnwMLxC9QOGCm/5M9hkvsPbaVLOoDji6Ig/GS1ARurywg6We62TP57x9sxfb3V8cI9htJCw==';

  /// Fetches the JWT token from your backend API
  /// Returns the token string or throws an exception on error
  /// Currently using a hardcoded test token for development
  ///
  /// [customToken] - Optional custom access token provided by user
  /// If provided, this token will be used instead of the default test token
  Future<String> fetchJwtToken({String? customToken}) async {
    // If custom token is provided, use it
    if (customToken != null && customToken.isNotEmpty) {
      debugPrint('Using custom access token');
      return customToken;
    }

    // TODO: Remove this in production and uncomment the API call below
    // For testing purposes, returning the test token directly
    debugPrint('Using default test token');
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate API delay
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

  /// Calls the Candidate Consent Acceptance API
  ///
  /// [customToken] - Optional custom access token provided by user
  /// If provided, this token will be used instead of the default test token
  Future<Map<String, dynamic>> candidateConsentAcceptance({
    String? customToken,
  }) async {
    const String endpoint =
        'https://devopenapi.offerx.global/CandidateE2E/v1/CandidateConsentAcceptance';
    const String defaultToken =
        'nRxD/od/IW4qmGb0flA2CFFe3DBkb/rOuLllCQ+hgDgxJyodMeCwXtIXbAMikzbfvCa44VmMhk1HRuZUYwsBVgJuh89Ssua60UbwdrXjOA5bc5w2DlwHP9PPHng6HZaOKfPLfNv++5816zbjxkwgO5drEHMJT5Cbd7rcJJ6yJO03A3OA/UPhGCQ1DeyEhHedoWpxpqwp/BMsqmxmZ3cJ+MIQB7ByA5YCmVoVGAefZTn4wkT9ggejIeZDflY+ynNCA0v2d+sF/MUSld4GUr/8tmXPvYHH20/rmEhn6xndDiBOFfv/1BbDTQkWyjkhZUgbVD7HvyfKn2LOpOridPIAOrvQ/OEQMKZkId4xZe/4rrTCqBl/VvyYjuQj6y6EQssjWbK2Pa4dansXja1TgLv/IUsZCeauB113BCRMPK/3d4hqWGVLS80DNsC/m4fH0LRjFuUeo/Ku9XPMyFuJ9DjfnQ/h4sJWMLTSky2gFnslqX4IdQCxS37jUsgZQR5yJws7FNcgb4cddixgYNzxO0ubJVaiHfFduLf01PDGxeiq2ddjD9gNVOx8yzYtmW9TSyKrcO2oe7Gsv5hJ4Zib1H5JJhPQGrZ7G75hXZrQeOdiUCMGOGr9RfKQCfxrQqWPrIbmxz+wyVguqQx/jloqO1urrIiMLRgtR/whCfQm31E4QvH7rBWQQlmPXlDUem7OsgOpDPAzKcT2LSRg67FfCyUUs/1vz12Vbvi/YVkf8Anb6PIUmWV4EPS2h+dNP4a+PgOTOo3IZtvKdwjspGYbqg5ujlxRO5M07IirAKYnDbqkLWDpm0OocuE7MNSZSExanIf/HXgD48aXMr+fRyLu5AD+l7HaYte7WKtYam0SSGA6njAnky/FQYwpjFRLbd3DIQi+4WVWxEl4FLgzKOZbOB0WNhslLrzLB7TFZs/ssclXkjLoYZ2WLX7NVCC22lgY7GdL1gv1Wh+W1hzS8OUahNCoyg==';

    // Use custom token if provided, otherwise use default
    final token = customToken ?? defaultToken;
    debugPrint('Calling Consent API with ${customToken != null ? "custom" : "default"} token');

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'encryptedRequest':
              '+0FliP88/X7a1CJIhZmJjtjDqnxBAVZ6oqfGVs0i8B44r1IiJ42/1bq6newc2nxs',
        }),
      );

      debugPrint('=== Candidate Consent Acceptance API Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('===============================================');

      return {
        'statusCode': response.statusCode,
        'body': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      debugPrint('=== API Error ===');
      debugPrint('Error: $e');
      debugPrint('=================');
      rethrow;
    }
  }
}
