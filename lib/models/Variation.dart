class Variation{
  final int id;
  final String name;
  final String values;
  final bool isDelete;
  final List<Variation>? subVars;
  Variation({required this.id, required this.name, required this.values, required this.isDelete, this.subVars});

  @override
  String toString() => name;
}