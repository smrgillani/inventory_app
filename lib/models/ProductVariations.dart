import 'package:image_picker/image_picker.dart';

class ProductVariations {
  final int? id;
  final String sku;
  final String value;
  final int variationValueId;
  final double defaultPurchasePriceExcTax;
  final double defaultPurchasePriceIncTax;
  final double xMargin;
  final double defaultSellingPriceExcTax;
  final double defaultSellingPriceIncTax;
  final bool isUpdate;
  final List<MediaFiles> images;

  ProductVariations({this.id, required this.sku, required this.value, required this.variationValueId, required this.defaultPurchasePriceExcTax, required this.defaultPurchasePriceIncTax, required this.xMargin, required this.defaultSellingPriceExcTax, required this.defaultSellingPriceIncTax, required this.isUpdate, required this.images});
}

class ProductVariation {
  final int? id;
  final int? templateId;
  final String name;
  final bool isUpdate;
  final List<ProductVariations> productVariations;

  ProductVariation({this.id, this.templateId, required this.name, required this.isUpdate, required this.productVariations});
}

class MediaFiles {
  final String imagePath;
  final bool isLocal;
  final int? id;
  MediaFiles({this.id, required this.imagePath, required this.isLocal});
}