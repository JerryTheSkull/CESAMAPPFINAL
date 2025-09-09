class Quote {
  final int id;
  final String text;
  final String author;
  final String submittedBy;
  bool isPublished;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.submittedBy,
    this.isPublished = false,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
  return Quote(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    text: json['text'].toString(),            // 🔹 conversion
    author: json['author'].toString(),        // 🔹 conversion
    submittedBy: json['submitted_by'].toString(), // 🔹 conversion
    isPublished: json['is_published'] == 1 || json['is_published'] == true,
  );
}


  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'submitted_by': submittedBy,
        'is_published': isPublished,
      };
}
