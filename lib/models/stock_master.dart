class StockMaster {
  final int? id;
  final String name;
  final String partCode;
  final String type; // 'machine' or 'part'
  final double? priceUsd;
  final double? priceJpy;
  final double? priceInr;
  final int stockCount;
  final int threshold;

  StockMaster({
    this.id,
    required this.name,
    required this.partCode,
    required this.type,
    this.priceUsd,
    this.priceJpy,
    this.priceInr,
    this.stockCount = 0,
    this.threshold = 0,
  });

  factory StockMaster.fromMap(Map<String, dynamic> map) {
    return StockMaster(
      id: map['id'],
      name: map['name'],
      partCode: map['part_code'],
      type: map['type'],
      priceUsd: map['price_usd'],
      priceJpy: map['price_jpy'],
      priceInr: map['price_inr'],
      stockCount: map['stock_count'] ?? 0,
      threshold: map['threshold'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'part_code': partCode,
      'type': type,
      'price_usd': priceUsd,
      'price_jpy': priceJpy,
      'price_inr': priceInr,
      'stock_count': stockCount,
      'threshold': threshold,
    };
  }

  StockMaster copyWith({
    int? id,
    String? name,
    String? partCode,
    String? type,
    double? priceUsd,
    double? priceJpy,
    double? priceInr,
    int? stockCount,
    int? threshold,
  }) {
    return StockMaster(
      id: id ?? this.id,
      name: name ?? this.name,
      partCode: partCode ?? this.partCode,
      type: type ?? this.type,
      priceUsd: priceUsd ?? this.priceUsd,
      priceJpy: priceJpy ?? this.priceJpy,
      priceInr: priceInr ?? this.priceInr,
      stockCount: stockCount ?? this.stockCount,
      threshold: threshold ?? this.threshold,
    );
  }
}