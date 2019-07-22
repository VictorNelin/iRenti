class Validators {
  static final RegExp _phoneRegExp = RegExp(
    r'^\+7[0-9]{10}$',
  );
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
  static final RegExp _passwordNumRegExp = RegExp(
    r'\b[0-9A-Za-z._]{8,}\b',
  );

  static isValidPhone(String phone) {
    return _phoneRegExp.hasMatch(phone);
  }

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static isValidPassword(String password) {
    return true;
    return _passwordNumRegExp.hasMatch(password);
  }
}
