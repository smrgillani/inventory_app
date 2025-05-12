class AccountingMethod {

  final String label;
  final String value;
  AccountingMethod(this.label, this.value);

  static List<AccountingMethod> defaultList(){
    return [
      AccountingMethod('FIFO (First In First Out)', 'fifo'),
      AccountingMethod('LIFO (Last In First Out)', 'lifo')
    ];
  }
}