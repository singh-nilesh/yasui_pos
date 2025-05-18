class SparePart {
  final int? id;
  final String name;
  final int? customerId;
  final int quantity;
  final DateTime? purchaseDate;
  final double? priceUsd;
  final double? priceJpy;
  final double? priceInr;
  final String? invoice;
  final String? seller;
  
  // Denormalized for convenience
  final String? customerName;

  SparePart({
    this.id,
    required this.name,
    this.customerId,
    required this.quantity,
    this.purchaseDate,
    this.priceUsd,
    this.priceJpy,
    this.priceInr,
    this.invoice,
    this.seller,
    this.customerName,
  });

  factory SparePart.fromMap(Map<String, dynamic> map) {
    return SparePart(
      id: map['id'],
      name: map['name'],
      customerId: map['customer_id'],
      quantity: map['quantity'],
      purchaseDate: map['purchase_date'] != null 
          ? DateTime.parse(map['purchase_date']) 
          : null,
      priceUsd: map['price_usd'],
      priceJpy: map['price_jpy'],
      priceInr: map['price_inr'],
      invoice: map['invoice'],
      seller: map['seller'],
      customerName: map['customer_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'customer_id': customerId,
      'quantity': quantity,
      'purchase_date': purchaseDate?.toIso8601String(),
      'price_usd': priceUsd,
      'price_jpy': priceJpy,
      'price_inr': priceInr,
      'invoice': invoice,
      'seller': seller,
    };
  }

  SparePart copyWith({
    int? id,
    String? name,
    int? customerId,
    int? quantity,
    DateTime? purchaseDate,
    double? priceUsd,
    double? priceJpy,
    double? priceInr,
    String? invoice,
    String? seller,
    String? customerName,
  }) {
    return SparePart(
      id: id ?? this.id,
      name: name ?? this.name,
      customerId: customerId ?? this.customerId,
      quantity: quantity ?? this.quantity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      priceUsd: priceUsd ?? this.priceUsd,
      priceJpy: priceJpy ?? this.priceJpy,
      priceInr: priceInr ?? this.priceInr,
      invoice: invoice ?? this.invoice,
      seller: seller ?? this.seller,
      customerName: customerName ?? this.customerName,
    );
  }
}