class Institution {
  const Institution({
    required this.id,
    required this.name,
    this.periodCount,
  });

  final String id;
  final String name;
  final int? periodCount;

  factory Institution.fromMap(Map<String, dynamic> data) {
    return Institution(
      id: data['id'],
      name: data['name'],
      periodCount: data['periodCount'] ?? 8,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'periodCount': periodCount,
      };
}
