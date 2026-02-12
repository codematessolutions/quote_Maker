import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple domain exception used across the app so we can show
/// friendly, consistent error messages.
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;

  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return AppException(
            'You do not have permission to perform this action.',
            code: error.code,
          );
        case 'unavailable':
        case 'network-request-failed':
          return AppException(
            'Network error. Please check your connection and try again.',
            code: error.code,
          );
        default:
          return AppException(
            'Something went wrong while talking to the server. Please try again.',
            code: error.code,
          );
      }
    }
    return AppException(
      'Something went wrong. Please try again.',
    );
  }
}

