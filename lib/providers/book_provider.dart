import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class BookProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<BookModel> books = [];
  bool loading = false;
  bool _isInitialized = false;
  String? error;
  DateTime? _lastSyncTime;

  static const Duration _cacheValidityDuration = Duration(
    minutes: 5,
  ); // Cache valid for 5 minutes

  /// SMART LOAD BOOKS WITH CACHING
  Future<void> loadBooks({bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh && _isCacheValid()) {
      // Use cached data if still valid
      return;
    }

    try {
      // Only show the full-screen loading indicator if we have no cached data.
      loading = books.isEmpty;
      error = null;
      notifyListeners();

      // Load from local storage first for instant UI
      final cachedBooks = await LocalStorageService.getBooks();
      books = cachedBooks;

      // We already have UI data, so stop showing a full-screen loader.
      loading = false;
      notifyListeners();

      // Sync in the background unless it's a forced refresh
      if (forceRefresh) {
        await _syncWithRemote();
        _isInitialized = true;
        _lastSyncTime = DateTime.now();
      } else {
        _syncWithRemote().then((_) {
          _isInitialized = true;
          _lastSyncTime = DateTime.now();
        });
      }
    } catch (e) {
      error = "Failed to load books: ${e.toString()}";
      // If remote fails but we have cache, keep using cache
      if (books.isEmpty) {
        final cachedBooks = await LocalStorageService.getBooks();
        books = cachedBooks;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// BACKGROUND SYNC WITH REMOTE
  Future<void> _syncWithRemote() async {
    try {
      final remoteBooks = await _api.fetchBooks();

      // Update local cache
      await LocalStorageService.saveBooks(remoteBooks);

      // Update in-memory data and notify UI
      books = remoteBooks;
      notifyListeners();
    } catch (e) {
      // If sync fails, keep existing data
      debugPrint('Background sync failed: $e');
    }
  }

  /// CHECK IF CACHE IS STILL VALID
  bool _isCacheValid() {
    if (_lastSyncTime == null) return false;
    return DateTime.now().difference(_lastSyncTime!) < _cacheValidityDuration;
  }

  /// ADD BOOK WITH OPTIMISTIC UPDATES
  Future<void> addBook(BookModel book) async {
    // Optimistic update
    books.add(book);
    notifyListeners();

    try {
      // Update local cache immediately
      await LocalStorageService.saveBooks(books);

      // Sync with remote
      await _api.addBook(book);

      // Update sync time
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Revert optimistic update on failure
      books.remove(book);
      error = "Failed to add book: ${e.toString()}";
      notifyListeners();

      // Reload from cache to ensure consistency
      final cachedBooks = await LocalStorageService.getBooks();
      books = cachedBooks;
      notifyListeners();
    }
  }

  /// UPDATE BOOK WITH OPTIMISTIC UPDATES
  Future<void> updateBook(BookModel book) async {
    final originalIndex = books.indexWhere((b) => b.id == book.id);
    if (originalIndex == -1) return;

    final originalBook = books[originalIndex];

    // Optimistic update
    books[originalIndex] = book;
    notifyListeners();

    try {
      // Update local cache immediately
      await LocalStorageService.saveBooks(books);

      // Sync with remote
      await _api.updateBook(book);

      // Update sync time
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Revert optimistic update on failure
      books[originalIndex] = originalBook;
      error = "Failed to update book: ${e.toString()}";
      notifyListeners();

      // Reload from cache to ensure consistency
      final cachedBooks = await LocalStorageService.getBooks();
      books = cachedBooks;
      notifyListeners();
    }
  }

  /// DELETE BOOK WITH OPTIMISTIC UPDATES
  Future<void> deleteBook(String id) async {
    final bookIndex = books.indexWhere((b) => b.id == id);
    if (bookIndex == -1) return;

    final deletedBook = books[bookIndex];

    // Optimistic update
    books.removeAt(bookIndex);
    notifyListeners();

    try {
      // Update local cache immediately
      await LocalStorageService.saveBooks(books);

      // Sync with remote
      await _api.deleteBook(id);

      // Update sync time
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Revert optimistic update on failure
      books.insert(bookIndex, deletedBook);
      error = "Failed to delete book: ${e.toString()}";
      notifyListeners();

      // Reload from cache to ensure consistency
      final cachedBooks = await LocalStorageService.getBooks();
      books = cachedBooks;
      notifyListeners();
    }
  }

  /// FORCE REFRESH DATA
  Future<void> refresh() async {
    await loadBooks(forceRefresh: true);
  }

  /// GET BOOK BY ID
  BookModel? getBookById(String id) {
    try {
      return books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  /// SEARCH BOOKS LOCALLY
  List<BookModel> searchBooks(String query) {
    if (query.isEmpty) return books;

    final lowerQuery = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
          book.author.toLowerCase().contains(lowerQuery) ||
          book.isbn.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// CLEAR ALL DATA
  Future<void> clearData() async {
    books.clear();
    _isInitialized = false;
    _lastSyncTime = null;
    error = null;
    await LocalStorageService.clear();
    notifyListeners();
  }
}
