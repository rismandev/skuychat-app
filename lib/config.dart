class Config {
  // API KEY
  static final String apiKey = '<YOUR-API-KEY>';

  // VALIDATION PHONE NUMBER
  // PHONE MUST BE HAVE 08
  // RETURN ERROR MESSAGE OR EMPTY STRING
  static String validationPhoneNumber(String phone) {
    String pattern = r'[0-9]';
    RegExp regExp = new RegExp(pattern);

    if (phone.length == 0) {
      return 'Masukan nomor handphone';
    } else if (!regExp.hasMatch(phone) || !phone.contains('08')) {
      return 'Nomor handphone tidak valid';
    }
    return '';
  }
}
