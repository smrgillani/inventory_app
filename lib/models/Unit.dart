class Unit{
  final int id;
  final String name;
  final String? shortName;
  final bool? allowDecimal;
  final bool? allowBaseUnit;
  final String? baseUnitShortName;
  final String? baseUnitMultiplier;
  final int? baseUnitId;

  Unit({required this.id, required this.name, this.shortName, this.allowDecimal, this.allowBaseUnit, this.baseUnitShortName, this.baseUnitMultiplier, this.baseUnitId});

  @override
  String toString() => name;
}