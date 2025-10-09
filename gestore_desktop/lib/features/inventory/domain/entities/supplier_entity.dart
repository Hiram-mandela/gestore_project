// gestore_desktop/lib/features/inventory/domain/entities/supplier_entity.dart
import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String name;
  final String? code;
  final String? contactPerson;
  final String? email;
  final String? phone;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.code,
    this.contactPerson,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, code, contactPerson, email, phone];
}