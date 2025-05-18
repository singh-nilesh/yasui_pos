class Customer {
  final int? id;
  final String name;
  final String? city;
  final String? state;
  final String? country;
  final String? email;
  final String? contactPrn1;
  final String? contactPrn2;
  final String? address;
  final String? telNo;
  final String? fax;
  final String? geoCoord;

  Customer({
    this.id,
    required this.name,
    this.city,
    this.state,
    this.country,
    this.email,
    this.contactPrn1,
    this.contactPrn2,
    this.address,
    this.telNo,
    this.fax,
    this.geoCoord,
  });

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id'],
        name: map['name'],
        city: map['city'],
        state: map['state'],
        country: map['country'],
        email: map['email'],
        contactPrn1: map['contact_prn_1'],
        contactPrn2: map['contact_prn_2'],
        address: map['address'],
        telNo: map['tel_no'],
        fax: map['fax'],
        geoCoord: map['geo_coord'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'city': city,
        'state': state,
        'country': country,
        'email': email,
        'contact_prn_1': contactPrn1,
        'contact_prn_2': contactPrn2,
        'address': address,
        'tel_no': telNo,
        'fax': fax,
        'geo_coord': geoCoord,
      };
}
