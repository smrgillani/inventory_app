import 'package:image_picker/image_picker.dart';

class ProductVariations {
  final int id;
  final String sku;
  final String value;
  final double defaultPurchasePriceExcTax;
  final double defaultPurchasePriceIncTax;
  final double xMargin;
  final double defaultSellingPriceExcTax;
  final double defaultSellingPriceIncTax;
  final List<XFile> images;

  ProductVariations(this.id, this.sku, this.value, this.defaultPurchasePriceExcTax, this.defaultPurchasePriceIncTax, this.xMargin, this.defaultSellingPriceExcTax, this.defaultSellingPriceIncTax, this.images);
}

class ProductVariation {
  final int id;
  final String name;
  final List<ProductVariations> productVariations;

  ProductVariation(this.id, this.name, this.productVariations);
}