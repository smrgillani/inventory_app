class Warranty{
  final int id;
  final String name;
  final String? description;
  final double? duration;
  final String? durationType;

  Warranty({required this.id, required this.name, this.description, this.duration, this.durationType});

  @override
  String toString() => name;
}