import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BookProvider>().loadBooks());
  }

  Future<void> _refresh() async {
    await context.read<BookProvider>().loadBooks();
  }

  void _toggleStatus(BookModel book) {
    final updatedBook = BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      isbn: book.isbn,
      quantity: book.quantity,
      issued: !book.issued,
    );
    context.read<BookProvider>().updateBook(updatedBook);
  }

  void _confirmDelete(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to remove this book from the library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<BookProvider>().deleteBook(bookId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Library Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/addBook'),
        label: const Text('Add Book'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.loading && provider.books.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Collection',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          Text(
                            'Manage and track your library inventory',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.books.isEmpty)
                    SliverFillRemaining(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_rounded, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No books found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text('Start by adding a new book to your list'),
                        ],
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final book = provider.books[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Book Icon
                                    Container(
                                      height: 70,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color: (book.issued ? Colors.red : AppTheme.primaryColor).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        book.issued ? Icons.bookmark_remove : Icons.menu_book_rounded,
                                        color: book.issued ? Colors.red : AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Book Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text('By ${book.author}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          const SizedBox(height: 8),
                                          _statusBadge(book.issued),
                                        ],
                                      ),
                                    ),

                                    // Action Buttons Row
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 1. Quick toggle status
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          tooltip: book.issued ? "Mark Available" : "Mark Issued",
                                          icon: Icon(
                                            book.issued ? Icons.assignment_return : Icons.assignment_turned_in,
                                            color: book.issued ? Colors.green : Colors.orange,
                                            size: 20,
                                          ),
                                          onPressed: () => _toggleStatus(book),
                                        ),
                                        // 2. Edit button
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          tooltip: "Edit details",
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            '/editBook',
                                            arguments: book.toJson(),
                                          ),
                                        ),
                                        // 3. Delete button
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          tooltip: "Delete book",
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                          onPressed: () => _confirmDelete(context, book.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: provider.books.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }

  Widget _statusBadge(bool isIssued) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isIssued ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isIssued ? 'ISSUED' : 'AVAILABLE',
        style: TextStyle(
          color: isIssued ? Colors.red[800] : Colors.green[800],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}