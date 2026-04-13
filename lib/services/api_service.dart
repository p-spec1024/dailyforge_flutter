import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
      : super(401, 'Session expired. Please login again.');
}

class NetworkException extends ApiException {
  NetworkException()
      : super(0, 'Network error. Check your connection and try again.');
}

class ApiService {
  final StorageService _storage;

  /// Called when a 401 is received — set by AuthProvider to trigger logout.
  void Function()? onUnauthorized;

  ApiService(this._storage);

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.url(path)),
        headers: await _getHeaders(),
      );
      return await _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.url(path)),
        headers: await _getHeaders(withAuth: withAuth),
        body: jsonEncode(body),
      );
      return await _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.url(path)),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return await _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.url(path)),
        headers: await _getHeaders(),
      );
      return await _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      await _storage.deleteToken();
      await _storage.deleteUser();
      onUnauthorized?.call();
      throw UnauthorizedException();
    }

    throw ApiException(
      response.statusCode,
      body['error'] as String? ?? 'Something went wrong',
    );
  }
}
