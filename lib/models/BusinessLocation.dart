class BusinessLocation{
  final int id;
  final String name;

  BusinessLocation({required this.id, required this.name});

  @override
  String toString() {
    return name;
  }
}