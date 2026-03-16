class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.createdAt,
    this.phone,
    this.address,
    this.notes,
  });

  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;
}
