import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/components/ComponentUtil.dart';
import 'package:gs_erp/models/FinancialYearMonth.dart';
import 'package:gs_erp/models/AccountingMethod.dart';

class RegistrationScreenTwo extends StatefulWidget {
  final Function updateFormData;
  final Function getFormData;
  final Function updateLoading;
  const RegistrationScreenTwo({super.key, required this.updateFormData, required this.getFormData, required this.updateLoading});

  @override
  RegistrationScreenTwoState createState() => RegistrationScreenTwoState();
}

class RegistrationScreenTwoState extends State<RegistrationScreenTwo> {

  final TextEditingController businessTaxOneName = TextEditingController();
  final TextEditingController businessTaxOneVal = TextEditingController();
  final TextEditingController businessTaxTwoName = TextEditingController();
  final TextEditingController businessTaxTwoVal = TextEditingController();
  FinancialYearMonth? selectedMonth;
  AccountingMethod? selectedMethod;
  late ComponentUtil componentUtil;

  late List<FinancialYearMonth> financialYearMonths = [];

  late List<AccountingMethod> accountingMethods = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeForm();
    });

    componentUtil = ComponentUtil();
  }

  initializeForm() {
    widget.updateLoading(true);
    businessTaxOneName.text = widget.getFormData('tax_label_1') ?? '';
    businessTaxOneVal.text = widget.getFormData('tax_number_1') ?? '';
    businessTaxTwoName.text = widget.getFormData('tax_label_2') ?? '';
    businessTaxTwoVal.text = widget.getFormData('tax_number_2') ?? '';
    financialYearMonths = FinancialYearMonth.defaultList();
    accountingMethods = AccountingMethod.defaultList();
    selectedMonth = getFinancialMonth(financialYearMonths);
    selectedMethod = getAccountingMethod(accountingMethods);
    widget.updateLoading(false);
  }

  FinancialYearMonth? getFinancialMonth(var months) {

    try {
      int intValue = widget.getFormData('fy_start_month') ?? 0;
      if (intValue > 0) {
        for (var month in months) {
          if (month.value == intValue) {
            return month;
          }
        }
      }

      return null;
    }catch(ex){
      if(kDebugMode)
        print("[Debug] $ex");
      return null;
    }
  }

  AccountingMethod? getAccountingMethod(var methods) {
    try {
      String stringValue = widget.getFormData('accounting_method') ?? '';
      if (stringValue.isNotEmpty) {
        for (var method in methods) {
          if (method.value.contains(stringValue)) {
            return method;
          }
        }
      }
      return null;
    } catch (ex) {
      if (kDebugMode)
        print("[Debug] $ex");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<AccountingMethod>> accountingMethodEntries = <DropdownMenuEntry<AccountingMethod>>[];

    for (final AccountingMethod label in AccountingMethod.defaultList()) {
      accountingMethodEntries.add(
          DropdownMenuEntry<AccountingMethod>(value: label, label: label.label));
    }

    final List<DropdownMenuEntry<FinancialYearMonth>> financialYearMonthEntries = <DropdownMenuEntry<FinancialYearMonth>>[];
    for (final FinancialYearMonth label in FinancialYearMonth.defaultList()) {
      financialYearMonthEntries.add(DropdownMenuEntry<FinancialYearMonth>(
          value: label, label: label.label));
    }

    return Padding(
      padding: const EdgeInsets.all(0),
      child: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              componentUtil.buildResponsiveWidget(
                  Column(
                      children: [
                        componentUtil.buildTextFormField(
                            labelText: 'Tax 1 Name',
                            onChanged: (value) =>
                                widget.updateFormData('tax_label_1', value),
                            controller: businessTaxOneName),
                        componentUtil.buildTextFormField(
                            labelText: 'Tax 1 Percentage(%)',
                            onChanged: (value) =>
                                widget.updateFormData('tax_number_1', value),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            controller: businessTaxOneVal)
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              componentUtil.buildResponsiveWidget(
                  Column(
                      children: [
                        componentUtil.buildTextFormField(
                            labelText: 'Tax 2 Name',
                            onChanged: (value) =>
                                widget.updateFormData('tax_label_2', value),
                            controller: businessTaxTwoName),
                        componentUtil.buildTextFormField(
                            labelText: 'Tax 2 Percentage(%)',
                            onChanged: (value) =>
                                widget.updateFormData('tax_number_2', value),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            controller: businessTaxTwoVal)
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              componentUtil.buildResponsiveWidget(
                  Column(
                      children: [
                        componentUtil.ddButtonFormField<FinancialYearMonth>(
                            selectedItem: selectedMonth,
                            labelText: 'Financial year start month',
                            hintText: 'Select a month',
                            items: financialYearMonths.map((
                                financialyearmonth) {
                              return DropdownMenuItem<FinancialYearMonth>(
                                value: financialyearmonth,
                                child: Text(financialyearmonth.label),
                              );
                            }).toList(),
                            onChanged: (FinancialYearMonth? value) {
                              setState(() {
                                widget.updateFormData('fy_start_month', value?.value);
                              });
                            }
                        ),
                        componentUtil.ddButtonFormField<AccountingMethod>(
                            selectedItem: selectedMethod,
                            labelText: 'Stock Accounting Method',
                            hintText: 'Select a method',
                            items: accountingMethods.map((
                                accountingMonth) {
                              return DropdownMenuItem<AccountingMethod>(
                                value: accountingMonth,
                                child: Text(accountingMonth.label),
                              );
                            }).toList(),
                            onChanged: (AccountingMethod? value) {
                              setState(() {
                                widget.updateFormData(
                                    'accounting_method', value?.value);
                              });
                            }
                        )
                      ]
                  ),
                  context
              )
            ]),
      ),
    );
  }
}