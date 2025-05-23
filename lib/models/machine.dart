class Machine {
  final int? id;
  final String name;
  final int? customerId;
  final String? serialNo;
  final DateTime? purchaseDate;
  final double? priceUsd;
  final double? priceJpy;
  final double? priceInr;
  final String? seller;
  final DateTime? amcStartMonth;
  final DateTime? amcExpireMonth;
  final int totalVisits;
  final int pendingVisits;
  
  // Denormalized for convenience
  final String? customerName;

  const Machine({
    this.id,
    required this.name,
    this.customerId,
    this.serialNo,
    this.purchaseDate,
    this.priceUsd,
    this.priceJpy,
    this.priceInr,
    this.seller,
    this.amcStartMonth,
    this.amcExpireMonth,
    this.totalVisits = 0,
    this.pendingVisits = 0,
    this.customerName,
  });

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      name: map['name'],
      customerId: map['customer_id'],
      serialNo: map['serial_no'],
      purchaseDate: map['purchase_date'] != null 
          ? DateTime.parse(map['purchase_date']) 
          : null,
      priceUsd: map['price_usd'],
      priceJpy: map['price_jpy'],
      priceInr: map['price_inr'],
      seller: map['seller'],
      amcStartMonth: map['amc_start_month'] != null 
          ? DateTime.parse(map['amc_start_month']) 
          : null,
      amcExpireMonth: map['amc_expire_month'] != null 
          ? DateTime.parse(map['amc_expire_month']) 
          : null,
      totalVisits: map['total_visits'] ?? 0,
      pendingVisits: map['pending_visits'] ?? 0,
      customerName: map['customer_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'customer_id': customerId,
      'serial_no': serialNo,
      'purchase_date': purchaseDate?.toIso8601String(),
      'price_usd': priceUsd,
      'price_jpy': priceJpy,
      'price_inr': priceInr,
      'seller': seller,
      'amc_start_month': amcStartMonth?.toIso8601String(),
      'amc_expire_month': amcExpireMonth?.toIso8601String(),
      'total_visits': totalVisits,
      'pending_visits': pendingVisits,
    };
  }

  Machine copyWith({
    int? id,
    String? name,
    int? customerId,
    String? serialNo,
    DateTime? purchaseDate,
    double? priceUsd,
    double? priceJpy,
    double? priceInr,
    String? seller,
    DateTime? amcStartMonth,
    DateTime? amcExpireMonth,
    int? totalVisits,
    int? pendingVisits,
    String? customerName,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      customerId: customerId ?? this.customerId,
      serialNo: serialNo ?? this.serialNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      priceUsd: priceUsd ?? this.priceUsd,
      priceJpy: priceJpy ?? this.priceJpy,
      priceInr: priceInr ?? this.priceInr,
      seller: seller ?? this.seller,
      amcStartMonth: amcStartMonth ?? this.amcStartMonth,
      amcExpireMonth: amcExpireMonth ?? this.amcExpireMonth,
      totalVisits: totalVisits ?? this.totalVisits,
      pendingVisits: pendingVisits ?? this.pendingVisits,
      customerName: customerName ?? this.customerName,
    );
  }
}