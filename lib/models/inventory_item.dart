class InventoryItem {
  final int? id;
  final String name;
  final String type; // 'Machine' or 'Spare Part'
  final int quantity;
  final double unitPrice;
  final DateTime lastUpdated;
  final String notes;

  const InventoryItem({
    this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.lastUpdated,
    this.notes = '',
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      lastUpdated: DateTime.parse(map['last_updated']),
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'quantity': quantity,
      'unit_price': unitPrice,
      'last_updated': lastUpdated.toIso8601String(),
      'notes': notes,
    };
  }

  InventoryItem copyWith({
    int? id,
    String? name,
    String? type,
    int? quantity,
    double? unitPrice,
    DateTime? lastUpdated,
    String? notes,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }
}