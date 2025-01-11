class Tax{
  final int id;
  final String name;
  double? amount;
  bool? isTaxGroup;
  bool? forTaxGroup;
  Tax({required this.id, required this.name, this.amount, this.isTaxGroup, this.forTaxGroup});

  @override
  bool operator ==  (Object other) =>
      identical(this, other) ||
          other is Tax &&
          runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  String toString() {
    return name;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode ^ name.hashCode;

}