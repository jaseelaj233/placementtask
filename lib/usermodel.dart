class Formmodal {
  final String name;
  final String age;
  final int phone;

  Formmodal({
    required this.name,
    required this.age,
    required this.phone,
  });
  factory Formmodal.fromJson(Map<String, dynamic> json) {
    return Formmodal(
      name: json['name'],
      age: json['age'],
      phone: json['phone'],
    );
  }

  get docs => null;
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'phone': phone,
    };
  }
}
