class Tax{
  final int id;
  final String name;
  double? amount;
  bool? isTaxGroup;
  bool? forTaxGroup;
  Tax({required this.id, required this.name, this.amount, this.isTaxGroup, this.forTaxGroup});

  @override
  String toString() {
    return name;
  }
}