class ProductCategory{
  final int id;
  final String name;
  final String? shortCode;
  final String? description;

  ProductCategory({required this.id, required this.name, this.shortCode, this.description});

  @override
  String toString() => name;
}