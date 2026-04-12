import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "books";

  /// FETCH
  Future<List<BookModel>> fetchBooks() async {
    final snapshot = await _firestore.collection(collection).get();

    return snapshot.docs
        .map((doc) => BookModel.fromJson(doc.data()))
        .toList();
  }

  /// ADD
  Future<void> addBook(BookModel book) async {
    await _firestore.collection(collection).doc(book.id).set(book.toJson());
  }

  /// UPDATE
  Future<void> updateBook(BookModel book) async {
    await _firestore.collection(collection).doc(book.id).update(book.toJson());
  }

  /// DELETE
  Future<void> deleteBook(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }
}