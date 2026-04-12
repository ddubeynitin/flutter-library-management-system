import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class LocalStorageService {
  static const String key = "books_cache";

  /// SAVE
  static Future<void> saveBooks(List<BookModel> books) async {
    final prefs = await SharedPreferences.getInstance();

    final data = books.map((e) => e.toJson()).toList();

    await prefs.setString(key, jsonEncode(data));
  }

  /// GET
  static Future<List<BookModel>> getBooks() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) return [];

    final decoded = jsonDecode(data) as List;

    return decoded.map((e) => BookModel.fromJson(e)).toList();
  }

  /// CLEAR (optional)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}