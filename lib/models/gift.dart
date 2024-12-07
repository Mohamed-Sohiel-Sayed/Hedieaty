// lib/models/gift.dart
class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final DateTime dueDate;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.dueDate,
  });
}