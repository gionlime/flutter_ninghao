import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/**
 * Copyright (C), 2015-2020, suntront
 * FileName: EncryptUtil
 * Author: Jeek
 * Date: 2020/12/30
 * Description: 加密解密辅助类
 */

class EncryptUtil {

  static String initialKey = "6#MhbKXxU#4K1XGuvrVMWk3VLWu2*OGG";

  static bool _haveInit = false;
  static FlutterSecureStorage _storage;
  static Key _key;
  static IV _iv;
  static Encrypter _encrypt;

  static Future<String> initEncrypt({bool needFresh = false}) async {
    String keyStored = await _getStoreKey();
    if (needFresh) {
      keyStored = generateRandomKey(32);
      await _setStoreKey(keyStored);
    } else {
      if (keyStored == null) {
        keyStored = initialKey;
        await _setStoreKey(keyStored);
      } else {
        initialKey = keyStored;
      }
    }
    _key = Key.fromUtf8(keyStored);
    _iv = IV.fromLength(16);
    _encrypt = Encrypter(AES(_key));
    _haveInit = true;
    if (needFresh) return keyStored;
    return null;
  }

  static Future<Null> initEncryptByKey(String key) async {
    assert(key.length == 32);
    await _setStoreKey(key);
    _key = Key.fromUtf8(key);
    _iv = IV.fromLength(16);
    _encrypt = Encrypter(AES(_key));
    _haveInit = true;
  }

  static Future<String> getStoreKey() async {
    return await _getStoreKey();
  }

  static Future<Null> clearEncrypt() async {
    final storage = _getSecureStorage();
    await storage.deleteAll();
    _key = null;
    _iv = null;
    _encrypt = null;
    _haveInit = false;
  }

  static String encrypt(String password) {
    if (!_haveInit) throw ArgumentError("请先调用initEncrypt函数");
    return _encrypt.encrypt(password, iv: _iv).base64;
  }

  static String decrypt(String encryptTxt) {
    if (!_haveInit) throw ArgumentError("请先调用initEncrypt函数");
    return _encrypt.decrypt(Encrypted.fromBase64(encryptTxt), iv: _iv);
  }

  static String generateRandomKey(int len, {bool cap = true, bool low = true, bool number = true, bool sym = true}) {

    List<String> _capitalList = List()..addAll(['D', 'E', 'F', 'G',
      'H', 'I', 'J', 'O', 'K', 'L', 'M', 'A', 'B', 'C', 'X', 'Y', 'N',
      'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'Z']);
    List<String> _lowCaseList = List()..addAll(['a', 'v', 'w', 'f', 'g','x', 'm',
      'h', 'i', 'k', 'l', 'n', 'b', 'c', 'd', 'e', 'o', 'p', 'r', 'j',  's', 't', 'u',
      'y', 'q', 'z']);
    List<String> _numberList = List()..addAll(['1', '9', '0', '2', '5', '6', '3', '4', '7', '8']);
    List<String> _symbolList = List()..addAll(['!', '@', '*', '?', '#', '%', '~', '=']);
    List<String> list = List();
    if (cap && low && number && sym) {
      list.addAll(_lowCaseList);
      list.addAll(_capitalList);
      list.addAll(_symbolList);
      list.addAll(_numberList);
    } else if (cap && low && number && !sym) {
      list.addAll(_numberList);
      list.addAll(_capitalList);
      list.addAll(_lowCaseList);
    } else if (cap && low && !number && sym) {
      list.addAll(_capitalList);
      list.addAll(_symbolList);
      list.addAll(_lowCaseList);
    } else if (cap && !low && number && sym) {
      list.addAll(_numberList);
      list.addAll(_capitalList);
      list.addAll(_symbolList);
    } else if (!cap && low && number && sym) {
      list.addAll(_symbolList);
      list.addAll(_lowCaseList);
      list.addAll(_numberList);
    } else if (cap && low && !number && !sym) {
      list.addAll(_capitalList);
      list.addAll(_lowCaseList);
    } else if (cap && !low && number && !sym) {
      list.addAll(_numberList);
      list.addAll(_capitalList);
    } else if (cap && !low && !number && sym) {
      list.addAll(_symbolList);
      list.addAll(_capitalList);
    } else if (!cap && low && number && !sym) {
      list.addAll(_lowCaseList);
      list.addAll(_numberList);
    } else if (!cap && low && !number && sym) {
      list.addAll(_lowCaseList);
      list.addAll(_symbolList);
    } else if (!cap && !low && number && sym) {
      list.addAll(_numberList);
      list.addAll(_symbolList);
    } else if (cap && !low && !number && !sym) {
      list = _capitalList;
    } else if (!cap && low && !number && !sym) {
      list = _lowCaseList;
    } else if (!cap && !low && number && !sym) {
      list = _numberList;
    } else if (!cap && !low && !number && sym) {
      list = _symbolList;
    }
    StringBuffer stringBuffer = StringBuffer();
    Random random = Random(DateTime.now().hashCode - (list.length + len).hashCode);
    for (int i = 0; i < len; i++) {
      int index = random.nextInt(list.length);
      stringBuffer.write(list[index]);
    }
    return stringBuffer.toString();
  }

  static FlutterSecureStorage _getSecureStorage() {
    if (_storage == null) {
      _storage = FlutterSecureStorage();
    }
    return _storage;
  }

  static Future<String> _getStoreKey() async {
    final storage = _getSecureStorage();
    return await storage.read(key: "NINGHAO_SECURE_STORE_KEY");
  }

  static Future<Null> _setStoreKey(String keyValue) async {
    final storage = _getSecureStorage();
    await storage.write(key: "NINGHAO_SECURE_STORE_KEY", value: keyValue);
  }

}

class EncryptHolder {

  Key key;
  IV iv;
  Encrypter encrypt;

  EncryptHolder(String specialKey) {
    key = Key.fromUtf8(specialKey);
    iv = IV.fromLength(16);
    encrypt = Encrypter(AES(key));
  }

  String decrypt(String encryptTxt) {
    return encrypt.decrypt(Encrypted.fromBase64(encryptTxt), iv: iv);
  }
}