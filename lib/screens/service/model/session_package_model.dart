class SessionPackage {
  final String title;
  final double? price;
  final int? sessions;

  SessionPackage({
    required this.title,
    this.price,
    this.sessions,
  });

  factory SessionPackage.fromJson(Map<String, dynamic> json) {
    return SessionPackage(
      title: json['title'] ?? '',
      price: json['price']?.toDouble(),
      sessions: json['sessions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'sessions': sessions,
    };
  }
}
