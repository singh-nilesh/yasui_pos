class ImportOrder {
  final int? id;
  final String orderId;
  final DateTime date;
  final String partCode;
  final String itemName;
  final String serialNumber;
  final int quantity;
  final int? customerId;
  final String customerName;
  final int year;
  final String yncInvoice;
  final DateTime invoiceDate;
  final double priceInr;
  final double priceJpy;
  final double priceUsd;
  final String status; // 'Pending', 'Shipped', 'Delivered', 'Completed', 'Cancelled'

  const ImportOrder({
    this.id,
    required this.orderId,
    required this.date,
    required this.partCode,
    required this.itemName,
    required this.serialNumber,
    required this.quantity,
    this.customerId,
    required this.customerName,
    required this.year,
    required this.yncInvoice,
    required this.invoiceDate,
    required this.priceInr,
    required this.priceJpy,
    required this.priceUsd,
    required this.status,
  });

  factory ImportOrder.fromMap(Map<String, dynamic> map) {
    return ImportOrder(
      id: map['id'],
      orderId: map['order_id'],
      date: DateTime.parse(map['date']),
      partCode: map['part_code'],
      itemName: map['item_name'],
      serialNumber: map['serial_number'],
      quantity: map['quantity'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      year: map['year'],
      yncInvoice: map['ync_invoice'],
      invoiceDate: DateTime.parse(map['invoice_date']),
      priceInr: map['price_inr'],
      priceJpy: map['price_jpy'],
      priceUsd: map['price_usd'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'date': date.toIso8601String(),
      'part_code': partCode,
      'item_name': itemName,
      'serial_number': serialNumber,
      'quantity': quantity,
      'customer_id': customerId,
      'customer_name': customerName,
      'year': year,
      'ync_invoice': yncInvoice,
      'invoice_date': invoiceDate.toIso8601String(),
      'price_inr': priceInr,
      'price_jpy': priceJpy,
      'price_usd': priceUsd,
      'status': status,
    };
  }

  ImportOrder copyWith({
    int? id,
    String? orderId,
    DateTime? date,
    String? partCode,
    String? itemName,
    String? serialNumber,
    int? quantity,
    int? customerId,
    String? customerName,
    int? year,
    String? yncInvoice,
    DateTime? invoiceDate,
    double? priceInr,
    double? priceJpy,
    double? priceUsd,
    String? status,
  }) {
    return ImportOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      date: date ?? this.date,
      partCode: partCode ?? this.partCode,
      itemName: itemName ?? this.itemName,
      serialNumber: serialNumber ?? this.serialNumber,
      quantity: quantity ?? this.quantity,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      year: year ?? this.year,
      yncInvoice: yncInvoice ?? this.yncInvoice,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      priceInr: priceInr ?? this.priceInr,
      priceJpy: priceJpy ?? this.priceJpy,
      priceUsd: priceUsd ?? this.priceUsd,
      status: status ?? this.status,
    );
  }
}