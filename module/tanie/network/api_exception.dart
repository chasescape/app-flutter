import 'dart:io';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ApiExceptionHandler {
  static Exception handleException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return ApiException('Bad request. Please check your input.', statusCode);
          case 401:
            return ApiException('Unauthorized. Please login again.', statusCode);
          case 403:
            return ApiException('Forbidden. You don\'t have permission.', statusCode);
          case 404:
            return ApiException('Resource not found.', statusCode);
          case 500:
            return ApiException('Server error. Please try again later.', statusCode);
          default:
            return ApiException('Request failed with status $statusCode', statusCode);
        }

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException('No internet connection.');
        }
        return NetworkException('An unknown error occurred.');

      default:
        return NetworkException('An unexpected error occurred.');
    }
  }
}
