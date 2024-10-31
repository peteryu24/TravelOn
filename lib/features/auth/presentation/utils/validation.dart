bool validatePasswordMatch(String password, String confirmPassword) {
  return password == confirmPassword;
}

bool validatePasswordLength(String password) {
  return password.length >= 6;
}
