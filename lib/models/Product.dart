class Product {
  final int productId;
  final String productName;
  final String? productSKU;
  final String? productBarcodeType;
  final String? productUnit;
  final String? productBrand;
  final String? productCategory;
  final String? productSubCategory;
  final String? productWarranty;
  final String? productBusinessLocation;
  final bool? isProductStockLevelEnabled;
  final int? productAlertQuantity;
  final String? productDescription;
  final String? productImage;
  final String? productBrochure;
  final bool? isProductImeiSerialEnabled;
  final bool? isProductForSale;
  final double? productWeight;
  final double? productPrepTime;
  final String? productTax;
  final String? productTaxType;
  final String? productType;
  final double? productPurchasePriceExcTax;
  final double? productPurchasePriceIncTax;
  final double? productStock;
  final double? productProfitMargin;
  final double? productSellPriceExcTax;
  final double? productSellPriceIncTax;

  Product({
    required this.productId,
    required this.productName,
    this.productSKU,
    this.productBarcodeType,
    this.productUnit,
    this.productBrand,
    this.productCategory,
    this.productSubCategory,
    this.productWarranty,
    this.productBusinessLocation,
    this.isProductStockLevelEnabled,
    this.productAlertQuantity,
    this.productDescription,
    this.productImage,
    this.productBrochure,
    this.isProductImeiSerialEnabled,
    this.isProductForSale,
    this.productWeight,
    this.productPrepTime,
    this.productTax,
    this.productTaxType,
    this.productType,
    this.productPurchasePriceExcTax,
    this.productPurchasePriceIncTax,
    this.productStock,
    this.productProfitMargin,
    this.productSellPriceExcTax,
    this.productSellPriceIncTax,
  });

  @override
  String toString() {
    return productName;
  }
}