class BusinessLocation{
  final int id;
  final String name;

  BusinessLocation({required this.id, required this.name});

  @override
  bool operator ==  (Object other) =>
      identical(this, other) || other is BusinessLocation &&
          runtimeType == other.runtimeType &&
          id == other.id && name == other.name;

  @override
  String toString() {
    return name;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode ^ name.hashCode;
}