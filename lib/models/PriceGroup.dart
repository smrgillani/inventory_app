class PriceGroup{
  final int id;
  final String name;
  final String? description;
  final bool? isActive;
  PriceGroup({required this.id, required this.name, this.description, this.isActive});

  @override
  String toString() => name;
}