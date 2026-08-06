/// Mirrors the password rules configured in Supabase (Authentication >
/// Providers > Email > Password Requirements): min 8 chars, at least one
/// each of lowercase, uppercase, digit and symbol. This is purely a
/// client-side UX helper — Supabase still enforces the real rule
/// server-side regardless of what this says.
class PasswordPolicy {
  const PasswordPolicy._();

  static const minLength = 8;
  static final _lower = RegExp(r'[a-z]');
  static final _upper = RegExp(r'[A-Z]');
  static final _digit = RegExp(r'[0-9]');
  static final _symbol = RegExp(r'[^a-zA-Z0-9]');

  static bool hasMinLength(String password) => password.length >= minLength;
  static bool hasLower(String password) => _lower.hasMatch(password);
  static bool hasUpper(String password) => _upper.hasMatch(password);
  static bool hasDigit(String password) => _digit.hasMatch(password);
  static bool hasSymbol(String password) => _symbol.hasMatch(password);

  static bool isValid(String password) =>
      hasMinLength(password) &&
      hasLower(password) &&
      hasUpper(password) &&
      hasDigit(password) &&
      hasSymbol(password);
}
