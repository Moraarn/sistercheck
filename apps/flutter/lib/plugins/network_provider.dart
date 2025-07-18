import 'dart:developer' show log;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/network_service.dart';
import 'network_constant.dart';

enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  String get value => name.toUpperCase();
}

enum BackendType {
  nodejs,  // For authentication, user management, clinic finder, crystal chat
  python,  // For patients, care plans, risk assessment, etc.
}

class NetworkState {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  const NetworkState({this.success = false, this.message, this.data});

  NetworkState copyWith({
    bool? success,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return NetworkState(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class NetworkCache extends StateNotifier<Map<String, NetworkState>> {
  NetworkCache() : super({});

  void cacheData(String path, NetworkState response) {
    state = {...state, path: response};
  }

  NetworkState? getCachedData(String path) {
    return state[path];
  }

  void clearCache() {
    state = {};
  }
}

final networkCacheProvider =
    StateNotifierProvider<NetworkCache, Map<String, NetworkState>>((ref) {
      return NetworkCache();
    });

class NetworkProvider {
  final NetworkHandler _networkHandler;
  final NetworkCache _cache;

  NetworkProvider(this._networkHandler, this._cache);

  String _getBaseUrl(BackendType backendType) {
    switch (backendType) {
      case BackendType.nodejs:
        return nodebaseUrl;
      case BackendType.python:
        return pythonbaseUrl;
    }
  }

  String _buildUrl(String path, Map<String, dynamic>? query, BackendType backendType) {
    final baseUrl = _getBaseUrl(backendType);
    final fullPath = '$baseUrl$path';
    
    if (query == null || query.isEmpty) return fullPath;

    final queryString = query.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
        )
        .join('&');

    return '$fullPath?$queryString';
  }

  Future<NetworkState> get(String path, {Map<String, dynamic>? query, BackendType backendType = BackendType.nodejs}) async {
    final fullPath = _buildUrl(path, query, backendType);

    // Check cache first
    final cachedData = _cache.getCachedData(fullPath);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final response = await _networkHandler.getRequest(endpoint: fullPath);

      log('response on network provider: $response');

      final networkState = NetworkState(
        success: !response.containsKey('error'),
        message: response['message'] as String?,
        data: response,
      );

      // Cache successful responses
      if (networkState.success) {
        _cache.cacheData(fullPath, networkState);
      }

      return networkState;
    } catch (e) {
      return NetworkState(success: false, message: 'Request failed: $e');
    }
  }

  Future<NetworkState> submit({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? body,
    BackendType backendType = BackendType.nodejs,
  }) async {
    try {
      final baseUrl = _getBaseUrl(backendType);
      final fullPath = '$baseUrl$path';
      
      Map<String, dynamic> response;

      switch (method) {
        case HttpMethod.post:
          response = await _networkHandler.postRequest(
            endpoint: fullPath,
            body: body ?? {},
          );
        case HttpMethod.put:
          response = await _networkHandler.putRequest(
            endpoint: fullPath,
            body: body ?? {},
          );
        case HttpMethod.patch:
          response = await _networkHandler.patchRequest(
            endpoint: fullPath,
            body: body ?? {},
          );
        case HttpMethod.delete:
          response = await _networkHandler.deleteRequest(endpoint: fullPath);
        case HttpMethod.get:
          throw Exception('Use get() method for GET requests');
      }

      log('response on network provider: $response');

      return NetworkState(
        success: response['success'] == true || response['status'] == 'success',
        message: response['message'] as String? ?? 'No message',
        data: response as Map<String, dynamic>?,
      );
    } catch (e) {
      return NetworkState(success: false, message: 'Request failed: $e');
    }
  }

  // Convenience methods for specific backends
  Future<NetworkState> submitToNodeJS({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    return submit(method: method, path: path, body: body, backendType: BackendType.nodejs);
  }

  Future<NetworkState> submitToPython({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    return submit(method: method, path: path, body: body, backendType: BackendType.python);
  }

  Future<NetworkState> getFromNodeJS(String path, {Map<String, dynamic>? query}) async {
    return get(path, query: query, backendType: BackendType.nodejs);
  }

  Future<NetworkState> getFromPython(String path, {Map<String, dynamic>? query}) async {
    return get(path, query: query, backendType: BackendType.python);
  }

  Future<NetworkState> uploadFileToPython({
    required String path,
    required String filePath,
    required String fileName,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final baseUrl = _getBaseUrl(BackendType.python);
      final fullPath = '$baseUrl$path';
      
      final response = await _networkHandler.uploadFile(
        endpoint: fullPath,
        filePath: filePath,
        fileName: fileName,
        additionalFields: additionalFields,
      );

      log('File upload response: $response');

      return NetworkState(
        success: !response.containsKey('error'),
        message: response['message'] as String? ?? 'File upload completed',
        data: response,
      );
    } catch (e) {
      return NetworkState(success: false, message: 'File upload failed: $e');
    }
  }
}

// Provider for NetworkProvider instance
final networkProvider = Provider((ref) {
  final networkHandler = ref.watch(networkHandlerProvider);
  final cache = ref.watch(networkCacheProvider.notifier);
  return NetworkProvider(networkHandler, cache);
});

// Convenience provider for accessing cached data
final cachedDataProvider = Provider.family<NetworkState?, String>((ref, path) {
  final cache = ref.watch(networkCacheProvider);
  return cache[path];
});

// Provider for watching specific API endpoints
final apiDataProvider = FutureProvider.family<NetworkState, String>((
  ref,
  path,
) async {
  final network = ref.watch(networkProvider);
  return await network.get(path);
});

// Provider for watching specific API endpoints with query parameters
final apiDataWithQueryProvider = FutureProvider.family<
  NetworkState,
  ({String path, Map<String, dynamic> query})
>((ref, params) async {
  final network = ref.watch(networkProvider);
  return await network.get(params.path, query: params.query);
});
