/// Validation Utilities
class Validators {
  Validators._();

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (value.length < minLength) {
      return 'Minimum $minLength characters required';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength) {
    if (value != null && value.length > maxLength) {
      return 'Maximum $maxLength characters allowed';
    }
    return null;
  }

  static String? validateRange(String? value, int min, int max) {
    final minError = validateMinLength(value, min);
    if (minError != null) return minError;
    return validateMaxLength(value, max);
  }
}
