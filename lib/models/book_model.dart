class BookModel {
  String id;
  String title;
  String author;
  String isbn;
  int quantity;
  bool issued;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.quantity,
    this.issued = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title.trim(),
      "author": author.trim(),
      "isbn": isbn.trim(),
      "quantity": quantity,
      "issued": issued,
    };
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      author: json["author"] ?? "",
      isbn: json["isbn"] ?? "",
      quantity: json["quantity"] ?? 0,
      issued: json["issued"] ?? false,
    );
  }
}