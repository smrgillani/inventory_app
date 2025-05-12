class FinancialYearMonth {

  final String label;
  final int value;
  FinancialYearMonth(this.label, this.value);

  static List<FinancialYearMonth> defaultList(){
    return [
      FinancialYearMonth('January', 1),
      FinancialYearMonth('February', 2),
      FinancialYearMonth('March', 3),
      FinancialYearMonth('April', 4),
      FinancialYearMonth('May', 5),
      FinancialYearMonth('June', 6),
      FinancialYearMonth('July', 7),
      FinancialYearMonth('August', 8),
      FinancialYearMonth('September', 9),
      FinancialYearMonth('October', 10),
      FinancialYearMonth('November', 11),
      FinancialYearMonth('December', 12)
    ];
  }

}