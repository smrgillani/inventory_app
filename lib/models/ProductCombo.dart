
class ProductCombo {
  final int id;
  final String prodName;
  final double qty;
  final String unitName;
  final int unitId;
  final double defaultPurchasePriceExcTax;
  final double totalPurchasePriceExcTax;
  final double defaultPurchasePriceIncTax;
  final double defaultSellingPriceExcTax;
  final double defaultSellingPriceIncTax;

  ProductCombo(this.id, this.prodName, this.qty, this.unitName, this.unitId, this.defaultPurchasePriceExcTax, this.totalPurchasePriceExcTax, this.defaultPurchasePriceIncTax, this.defaultSellingPriceExcTax, this.defaultSellingPriceIncTax);
}
