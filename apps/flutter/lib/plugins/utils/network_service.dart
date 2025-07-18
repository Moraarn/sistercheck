import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../app_provider.dart';
import 'network_util.dart';

final networkHandlerProvider = Provider((ref) {
  final appState = ref.watch(appNotifierProvider);
  return NetworkHandler(
    isConnected: appState.isInternetConnected,
    authToken: appState.authToken,
    patientToken: appState.patientToken,
  );
});

class NetworkHandler {
  final bool isConnected;
  final String? authToken;
  final String? patientToken;

  NetworkHandler({
    required this.isConnected, 
    this.authToken, 
    this.patientToken,
  });

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};

    // Use patient token if available, otherwise use regular auth token
    final token = patientToken ?? authToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// General function to handle requests (GET, POST, etc.) with internet and cache checks
  Future<Map<String, dynamic>> _handleRequest({
    required String url,
    required Future<http.Response> Function() request,
  }) async {
    if (!isConnected) {
      log('No internet connection.');
      final cachedData = await NetworkUtils.getCachedResponse(url);
      if (cachedData != null) {
        return await NetworkUtils.handleResponse(cachedData);
      }

      return {'error': 'No internet connection and no cached response.'};
    }

    try {
      final response = await request();
      return await NetworkUtils.handleResponse(response);
    } catch (e) {
      log('$url request failed: $e');
      return {'error': 'Request failed.'};
    }
  }

  /// Perform GET request with caching
  Future<Map<String, dynamic>> getRequest({required String endpoint}) async {
    log('GET request to: $endpoint');

    return await _handleRequest(
      url: endpoint,
      request: () async {
        final response = await http.get(
          Uri.parse(endpoint),
          headers: _headers,
        );
        await NetworkUtils.cacheResponse(endpoint, response);
        return response;
      },
    );
  }

  /// Perform POST request (no caching needed for POST requests)
  Future<Map<String, dynamic>> postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    log('POST request to: $endpoint');
    return await _handleRequest(
      url: endpoint,
      request: () async {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: _headers,
          body: jsonEncode(body),
        );
        return response;
      },
    );
  }

  /// Perform PUT request (no caching needed for PUT requests)
  Future<Map<String, dynamic>> putRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    log('PUT request to: $endpoint');
    return await _handleRequest(
      url: endpoint,
      request: () async {
        final response = await http.put(
          Uri.parse(endpoint),
          headers: _headers,
          body: jsonEncode(body),
        );
        return response;
      },
    );
  }

  /// Perform DELETE request (no caching needed for DELETE requests)
  Future<Map<String, dynamic>> deleteRequest({required String endpoint}) async {
    log('DELETE request to: $endpoint');
    return await _handleRequest(
      url: endpoint,
      request: () async {
        final response = await http.delete(
          Uri.parse(endpoint),
          headers: _headers,
        );
        return response;
      },
    );
  }

  /// Perform PATCH request (no caching needed for PATCH requests)
  Future<Map<String, dynamic>> patchRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    log('PATCH request to: $endpoint');
    return await _handleRequest(
      url: endpoint,
      request: () async {
        final response = await http.patch(
          Uri.parse(endpoint),
          headers: _headers,
          body: jsonEncode(body),
        );
        return response;
      },
    );
  }

  /// Upload file to backend
  Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required String filePath,
    required String fileName,
    Map<String, String>? additionalFields,
  }) async {
    log('File upload to: $endpoint');
    
    if (!isConnected) {
      return {'error': 'No internet connection.'};
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'error': 'File not found: $filePath'};
      }

      final bytes = await file.readAsBytes();
      final multipartRequest = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      // Add authorization header
      final token = patientToken ?? authToken;
      if (token != null) {
        multipartRequest.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      multipartRequest.files.add(
        http.MultipartFile.fromBytes(
         fileName,
          bytes,
          filename: fileName,
        ),
      );

      // Add additional fields
      if (additionalFields != null) {
        multipartRequest.fields.addAll(additionalFields);
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      return await NetworkUtils.handleResponse(response);
    } catch (e) {
      log('File upload failed: $e');
      return {'error': 'File upload failed: $e'};
    }
  }
}
