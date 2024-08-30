class Institution {
  const Institution({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Institution.fromMap(Map<String, dynamic> data) {
    return Institution(
      id: data['id'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
}