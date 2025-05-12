import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      // Lưu vào localStorage cho web
      html.window.localStorage[_tokenKey] = token;
    } else {
      // Lưu vào SharedPreferences cho mobile
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      // Đọc từ localStorage cho web
      return html.window.localStorage[_tokenKey];
    } else {
      // Đọc từ SharedPreferences cho mobile
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
  }

  Future<void> clearToken() async {
    if (kIsWeb) {
      // Xóa từ localStorage cho web
      html.window.localStorage.remove(_tokenKey);
    } else {
      // Xóa từ SharedPreferences cho mobile
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    if (kIsWeb) {
      html.window.localStorage[_userKey] = jsonString;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonString);
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    String? jsonString;
    if (kIsWeb) {
      jsonString = html.window.localStorage[_userKey];
    } else {
      final prefs = await SharedPreferences.getInstance();
      jsonString = prefs.getString(_userKey);
    }

    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUserData() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_userKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    }
  }
}
