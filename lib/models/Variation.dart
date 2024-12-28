class Variation{
  final int id;
  final String name;
  final String values;
  final bool isDelete;
  Variation({required this.id, required this.name, required this.values, required this.isDelete});

  @override
  String toString() => name;
}