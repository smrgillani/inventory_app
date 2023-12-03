class Product {
  final String productName;
  final String productSKU;
  final String productBarcodeType;
  final String? productUnit;
  final String? productBrand;
  final String? productCategory;
  final String? productSubCategory;
  final String? productBusinessLocation;
  final bool isProductStockLevelEnabled;
  final int productAlertQuantity;
  final String? productDescription;
  final String? productImage;
  final String? productBrochure;
  final bool isProductImeiSerialEnabled;
  final bool isProductForSale;
  final double productWeight;
  final double productPrepTime;
  final String? productTax;
  final String? productTaxType;
  final String productType;
  final double productPurchasePriceExcTax;
  final double productPurchasePriceIncTax;
  final double productProfitMargin;
  final double productSellPriceExcTax;

  Product({
    required this.productName,
    required this.productSKU,
    required this.productBarcodeType,
    this.productUnit,
    this.productBrand,
    this.productCategory,
    this.productSubCategory,
    this.productBusinessLocation,
    required this.isProductStockLevelEnabled,
    required this.productAlertQuantity,
    this.productDescription,
    this.productImage,
    this.productBrochure,
    required this.isProductImeiSerialEnabled,
    required this.isProductForSale,
    required this.productWeight,
    required this.productPrepTime,
    this.productTax,
    this.productTaxType,
    required this.productType,
    required this.productPurchasePriceExcTax,
    required this.productPurchasePriceIncTax,
    required this.productProfitMargin,
    required this.productSellPriceExcTax
  });
}