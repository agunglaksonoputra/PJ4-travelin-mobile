/// Error handler for User Master operations
/// Provides user-friendly error messages for API responses

class UserMasterErrorHandler {
  /// Parse error message and return user-friendly message
  static String parseErrorMessage(String error) {
    // Remove common exception prefixes
    final cleanError = error.replaceAll('Exception: Error', '').trim();

    // Username/Email exists errors
    if (cleanError.contains('Username already exists') ||
        cleanError.contains('username') && cleanError.contains('exists')) {
      return 'Username already exists. Please choose another username.';
    }

    if (cleanError.contains('Email already exists') ||
        cleanError.contains('email') && cleanError.contains('exists')) {
      return 'Email already exists. Please choose another email.';
    }

    // Not found errors (404)
    if (cleanError.contains('404') || cleanError.contains('not found')) {
      return 'User not found. It may have been deleted already. Please refresh the list.';
    }

    // Unauthorized errors (401)
    if (cleanError.contains('401') ||
        cleanError.contains('Unauthorized') ||
        cleanError.contains('unauthorized')) {
      return 'You are not authorized to perform this action. Please check your permissions.';
    }

    // Forbidden errors (403)
    if (cleanError.contains('403') || cleanError.contains('Forbidden')) {
      return 'Access denied. You do not have permission to perform this action.';
    }

    // Server errors (500+)
    if (cleanError.contains('500') ||
        cleanError.contains('Internal') ||
        cleanError.contains('Server Error')) {
      return 'Server error occurred. Please try again later.';
    }

    // Network/Connection errors
    if (cleanError.contains('Network') ||
        cleanError.contains('connection') ||
        cleanError.contains('Connection refused') ||
        cleanError.contains('Failed host lookup')) {
      return 'Network error. Please check your internet connection.';
    }

    // Timeout errors
    if (cleanError.contains('timeout') ||
        cleanError.contains('Timeout') ||
        cleanError.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Validation errors
    if (cleanError.contains('validation') ||
        cleanError.contains('Validation')) {
      return 'Invalid input. Please check your data and try again.';
    }

    // Default: return cleaned error message
    return cleanError.isEmpty
        ? 'An unknown error occurred. Please try again.'
        : cleanError;
  }
}
