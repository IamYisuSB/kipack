class Suitcase {
  Suitcase({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Suitcase.fromJson(Map<String, dynamic> json) =>
      Suitcase(id: json['id'] as String, name: json['name'] as String);
}
