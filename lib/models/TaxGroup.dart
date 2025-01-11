class TaxGroup{
  final int id;
  final String name;
  final double? amount;
  String? subTaxesName;
  TaxGroup({required this.id, required this.name, this.amount, this.subTaxesName});

  @override
  String toString() {
    return name;
  }
}