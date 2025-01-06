class Tables{
  final int id;
  final String name;
  final String blName;
  final String description;
  Tables({required this.id, required this.name, required this.blName, required this.description});

  @override
  String toString() => name;
}