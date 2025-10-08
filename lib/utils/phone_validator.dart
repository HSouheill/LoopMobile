class PhoneValidator {
  // Basic phone number validation
  static String? validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters for validation
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid length (typically 7-15 digits)
    if (cleanNumber.length < 7 || cleanNumber.length > 15) {
      return 'Phone number must be between 7 and 15 digits';
    }
    
    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'Phone number must contain only digits';
    }
    
    return null; // Valid phone number
  }

  // Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length <= 3) {
      return cleanNumber;
    } else if (cleanNumber.length <= 6) {
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3)}';
    } else if (cleanNumber.length <= 9) {
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';
    } else {
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6, 9)} ${cleanNumber.substring(9)}';
    }
  }

  // Validate email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null; // Valid email
  }
}
