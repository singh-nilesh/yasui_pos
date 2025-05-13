class Customer {
  final int? id;
  final String code;
  final String name;
  final String country;
  final String destination;
  final String tell;
  final String fax;
  final String address;
  final String geo;

  Customer({
    this.id,
    required this.code,
    required this.name,
    required this.country,
    required this.destination,
    required this.tell,
    required this.fax,
    required this.address,
    required this.geo,
  });

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'],
        code: map['code'],
        name: map['name'],
        country: map['country'],
        destination: map['destination'],
        tell: map['tell'],
        fax: map['fax'],
        address: map['address'],
        geo: map['geo'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'country': country,
        'destination': destination,
        'tell': tell,
        'fax': fax,
        'address': address,
        'geo': geo,
      };
}
