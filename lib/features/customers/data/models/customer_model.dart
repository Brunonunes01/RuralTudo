import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  CustomerModel({
    required super.id,
    required super.name,
    required super.createdAt,
    super.phone,
    super.address,
    super.notes,
  });

  factory CustomerModel.fromMap(Map<String, Object?> map) {
    return CustomerModel(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      notes: customer.notes,
      createdAt: customer.createdAt,
    );
  }
}
