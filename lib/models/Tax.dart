class Tax{
  final int id;
  final String name;

  Tax({required this.id, required this.name});

  @override
  String toString() {
    return name;
  }
}