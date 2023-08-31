import 'package:encrypt/encrypt.dart';

// AES256
class AesManager {
  static const secretKey = '';
  static const iv = '';

  static String encrypt(String plainText) {
    final encrypter =
        Encrypter(AES(Key.fromUtf8(secretKey), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: IV.fromUtf8(iv));
    return encrypted.base64;
  }

  static String decrypt(String encryptedText) {
    final encrypter =
        Encrypter(AES(Key.fromUtf8(secretKey), mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: IV.fromUtf8(iv));
    return decrypted;
  }
}
