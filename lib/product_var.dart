import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'main.dart';
import 'models/Category.dart';
import 'models/Currency.dart';
import 'models/Global.dart';
import 'models/ProductVariations.dart';
import 'models/Tax.dart';
import 'models/Unit.dart';
import 'models/Variation.dart';

class PhotoItem {
  final String image;
  final String name;
  PhotoItem(this.image, this.name);
}

class BarcodeType {
  final String name;
  final String value;
  BarcodeType(this.name, this.value);

  @override
  String toString() {
    return name;
  }
}


class VariationUI{
  final Variation variation;
  final TextEditingController skusCntrlr;
  final TextEditingController skusValCntrlr;
  final TextEditingController ppExcTaxValCntrlr;
  final TextEditingController ppIncTaxValCntrlr;
  final TextEditingController mrgnValCntrlr;
  final TextEditingController spExcTaxValCntrlr;
  final TextEditingController spIncTaxValCntrlr;
  final List<XFile> files;

  VariationUI(this.variation, this.skusCntrlr, this.skusValCntrlr, this.ppExcTaxValCntrlr, this.ppIncTaxValCntrlr, this.mrgnValCntrlr, this.spExcTaxValCntrlr, this.spIncTaxValCntrlr, this.files);
}

class ProductVar extends StatefulWidget {
  final Function(int mainVarId, String mainVarName, List<ProductVariations> products) addProd;
  final double taxVal;
  final String taxType;
  const ProductVar({super.key, required this.addProd, required this.taxVal, required this.taxType});

  @override
  State<ProductVar> createState() => ProductVarState();
}

class ProductVarState extends State<ProductVar> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  bool? checkBox;
  late bool alertQuantity;
  late AllComponents allComponents;
  Currency? selectedCurrency;
  final TextEditingController qtyController = TextEditingController();
  FinancialYearMonth? selectedMonth;
  File? productImage;
  File? productBrochureImage;
  List<XFile> images = <XFile>[];
  late List<Unit> units = [];
  late List<Brand> brands = [];
  final List<BarcodeType> barcodeTypes = [BarcodeType("name 1", "value 1"),BarcodeType("name 2", "value 2")];
  late List<ProductCategory> categories = [];
  late List<ProductCategory> subCategories = [];
  late List<BusinessLocation> businessLocations = [];
  late List<Tax> taxes = [];
  late int categoryId;
  late int subCategoryId;
  final List<String> sellingPriceTaxType = ["Inclusive", "Exclusive"];
  final List<String> productType = ["Single", "Variable", "Combo"];
  late String selectedSellingPriceTaxType = "Inclusive";
  late String selectedProductType = "Single";
  late List<Product> searchProducts = [];

  late List<Variation> variations = [];

  late List<Variation> subVariations = [];

  late List<VariationUI> selectedSubVars = [];

  late List<Variation> selectedSubVarsCB = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Product singleProduct = Product(productId: 0, productName: "", productUnit: "", productPurchasePriceExcTax: 0, productPurchasePriceIncTax: 0);

  Variation? singleVariation;

  late bool showVariationsList = false;

  late List<ProductVariations> varsProds = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    selectedMonth = FinancialYearMonth.values[0];
    getUnits();
    getAllVariations();
  }

  getUnits() async{
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
    }
  }

  getVariations() async{
    dynamic response = await RestSerice().getData("/variations");

    print(response);
    // List<dynamic> unitList = (response['data'] as List).cast<dynamic>();

    // for (dynamic unit in unitList) {
    //   units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
    // }
  }


  getSearchedProducts(String searchTerm) async {
    if(searchTerm.length > 1) {
      dynamic response = await RestSerice().getData(
          "/get-products?check_enable_stock=false&term=$searchTerm");
      List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      for (dynamic product in productList) {
        searchProducts.add(Product(
            productId: product['product_id'], productName: product['text']));
      }
    }
  }

  getSingleProduct(int productId) async {
    if(productId > 0) {
      dynamic response = await RestSerice().getData(
          "/product/$productId");

      setState(() {
        singleProduct = Product(productId: response['data'][0]['id'], productName: '${response['data'][0]['name']} - ${response['data'][0]['sku']}', productUnit: '${response['data'][0]['unit']['actual_name']} (${response['data'][0]['unit']['short_name']})', productPurchasePriceExcTax: double.parse(response['data'][0]['product_variations'][0]['variations'][0]['default_purchase_price']));
        qtyController.text = "1";
      });


      // Map<String, dynamic> data = resp['data'];
      // for(var entry in erpGlobals.entries){
      //   print('${entry.key}: ${entry.value}');
      // }

      // List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      // for (dynamic product in productList) {
      //   searchProducts.add(Product(
      //       productId: product['product_id'], productName: product['text']));
      // }
    }
  }

  getAllVariations() async {
    variations = [];
    dynamic response = await RestSerice().getData('/variations');
    List<dynamic> variationList = (response['data'] as List).cast<dynamic>();

    for(var variation in variationList){

      String varValues = variation['values'].map((varVal) => varVal["name"].toString()).join(',');

      bool isDel = !(variation['total_pv'] > 0);

      List<Variation> sbl = [];

      for(var sv in variation['values']){
        sbl.add(Variation(id: sv['id'], name: sv['name'], values: '', isDelete: false));
      }

      variations.add(Variation(id: variation['id'], name: variation['name'], values: varValues, isDelete: isDel, subVars: sbl));

    }

    setState(() {
      showVariationsList = true;
    });

  }

  Future<void> pickProductImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        productImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickBrochureImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        productBrochureImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final List<XFile> medias = await picker.pickMultiImage();
    if (medias != null) {
      setState(() {
        for(XFile image in medias) {
          images.add(image);
        }
      });
    }
  }

  void removeProductImage() {
    setState(() {
      productImage = null;
    });
  }

  void removeBrochureImage() {
    setState(() {
      productBrochureImage = null;
    });
  }

  void removeProductImages(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  updateProductImages(int index) async {

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        images[index] = pickedFile;
      });
    }

  }

  removeProductVar(int index) {
      setState(() {
        selectedSubVars.removeAt(index);
      });
  }

  removeCBProductVar(Variation varVal) {
      setState(() {
        selectedSubVarsCB = List.from(selectedSubVarsCB)..remove(varVal);
      });
  }

  getPrinciple({double amount = 0, double percentage = 0, bool minus = false}) {
    var mul = 100 * amount;
    double sum = 1;

    if (minus) {
      sum = 100 - percentage;
    } else {
      sum = 100 + percentage;
    }

    return mul / sum;
  }

  getRate({double principal = 0, double amount = 0}) {
    double interest = amount - principal;
    double div = interest/ principal;
    return div * 100;
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PhotoItem> _items = [
      PhotoItem(
          "https://images.pexels.com/photos/1772973/pexels-photo-1772973.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
          "Stephan Seeber")
    ];

    return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double imagePickerSize = isTablet ? 200 : 120;
          double bottom = MediaQuery
              .of(context)
              .viewInsets
              .bottom;
          return Scaffold(
              appBar: AppBar(
                title: const Text('Add Product Variation'),
              ),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, top: 16.0, right: 16.0, bottom: bottom),
                      child: Column(
                          children: <Widget>[

                            const SizedBox(height: 16),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [

                                      DropdownButtonFormField<Variation>(
                                          value: singleVariation,
                                          decoration: const InputDecoration(
                                            labelText: 'Variation:*',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        4.0))
                                            ),
                                          ),
                                          items: variations.map((varVal) {
                                            return DropdownMenuItem<Variation>(
                                              value: varVal!,
                                              child: Text(varVal.name),
                                            );
                                          }).toList(),
                                          onChanged: (Variation? value) {
                                            setState(() {
                                              singleVariation = value;
                                            });

                                            subVariations = [];
                                            for (var svl in value!.subVars!
                                                .toList()) {
                                              setState(() {
                                                subVariations.add(Variation(
                                                    id: svl.id,
                                                    name: svl.name,
                                                    values: '',
                                                    isDelete: false));
                                              });
                                            }
                                          }
                                      ),

                                      DropdownSearch<Variation>.multiSelection(
                                        items: subVariations,
                                        selectedItems: selectedSubVarsCB,
                                        dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                            hintText: 'Select variation values',
                                            labelText: 'Variation Values:',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        4.0)
                                                )
                                            ),
                                          ),
                                        ),
                                        onChanged: (List<Variation> subVars) {
                                          if (selectedSubVarsCB.isEmpty) {
                                            selectedSubVarsCB = [];
                                            for (var subVar in subVars) {
                                              setState(() {
                                                selectedSubVars.add(VariationUI(
                                                    subVar,
                                                    TextEditingController(),
                                                    TextEditingController(
                                                        text: subVar.name),
                                                    TextEditingController(),
                                                    TextEditingController(),
                                                    TextEditingController(
                                                        text: erpGlobals['default_profit_percent']
                                                            .toString()),
                                                    TextEditingController(),
                                                    TextEditingController(),
                                                    []));
                                                selectedSubVarsCB.add(subVar);
                                              });
                                            }
                                          } else
                                          if (selectedSubVarsCB.isNotEmpty) {
                                            List<Variation> tempSubVars = [];
                                            tempSubVars.addAll(subVars);

                                            for (var subVar in selectedSubVars
                                                .where((element) =>
                                            element.variation.id > 0)
                                                .toList()) {
                                              if (!tempSubVars.contains(
                                                  subVar.variation)) {
                                                setState(() {
                                                  selectedSubVars.remove(
                                                      subVar);
                                                  selectedSubVarsCB.remove(
                                                      subVar.variation);
                                                });
                                              } else {
                                                setState(() {
                                                  tempSubVars.remove(
                                                      subVar.variation);
                                                });
                                              }
                                            }

                                            for (var subVar in tempSubVars) {
                                              setState(() {
                                                selectedSubVars.add(VariationUI(
                                                    subVar,
                                                    TextEditingController(),
                                                    TextEditingController(
                                                        text: subVar.name),
                                                    TextEditingController(),
                                                    TextEditingController(),
                                                    TextEditingController(
                                                        text: erpGlobals['default_profit_percent']
                                                            .toString()),
                                                    TextEditingController(),
                                                    TextEditingController(),
                                                    []));
                                                selectedSubVarsCB.add(subVar);
                                              });
                                            }
                                          }
                                        },
                                      ),

                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      const Text(
                                          'All variations and their values',
                                          style: TextStyle(fontSize: 22,
                                              fontWeight: FontWeight.bold)
                                      ),

                                      Container(
                                          height: 85,
                                          padding: const EdgeInsets.all(4),
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Flexible(
                                                    child: Text(
                                                        'Tax Info: @${widget
                                                            .taxVal}% ${widget
                                                            .taxType}',
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight
                                                                .bold))
                                                ),
                                                const SizedBox(width: 16),
                                                OutlinedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        selectedSubVars.add(
                                                            VariationUI(
                                                                Variation(id: 0,
                                                                    name: '',
                                                                    values: '',
                                                                    isDelete: false),
                                                                TextEditingController(),
                                                                TextEditingController(),
                                                                TextEditingController(),
                                                                TextEditingController(),
                                                                TextEditingController(
                                                                    text: erpGlobals['default_profit_percent']
                                                                        .toString()),
                                                                TextEditingController(),
                                                                TextEditingController(),
                                                                []));
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .all(0),
                                                      textStyle: buttonTextStyle,
                                                      foregroundColor: Colors
                                                          .white,
                                                      backgroundColor: const Color(
                                                          0xff1572e8),
                                                      shadowColor: Colors
                                                          .yellow,
                                                      side: const BorderSide(
                                                          color: Color(
                                                              0xffE0E3E7)),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(12),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                  top: 9,
                                                                  bottom: 9,
                                                                  left: 10,
                                                                  right: 10),
                                                              child: Icon(
                                                                Icons
                                                                    .add,
                                                                color: Colors
                                                                    .white,
                                                                size: 50,)
                                                          )
                                                        ]
                                                    ) // Set a tooltip for long-press
                                                ),
                                              ]
                                          )
                                      ),


                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            Form(
                                key: formKey,
                                child: Column(children: [

                                  ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: selectedSubVars.length,
                                      separatorBuilder: (BuildContext context,
                                          int index) {
                                        return const Divider();
                                      },
                                      itemBuilder: (ibContext, index) {
                                        return Column(
                                            children: [

                                              const SizedBox(height: 24),

                                              allComponents
                                                  .buildResponsiveWidget(
                                                  Column(
                                                      children: [

                                                        Text(
                                                            'Variation Name: ${selectedSubVars[index]
                                                                .variation
                                                                .name}',
                                                            style: const TextStyle(
                                                                fontSize: 21,
                                                                fontWeight: FontWeight
                                                                    .bold)),
                                                        InkWell(
                                                          onTap: () {
                                                            if (selectedSubVars[index]
                                                                .variation.id >
                                                                0) {
                                                              removeCBProductVar(
                                                                  selectedSubVars[index]
                                                                      .variation);
                                                            }
                                                            removeProductVar(
                                                                index);
                                                          },
                                                          child: const Column(
                                                              children: <
                                                                  Widget>[
                                                                Icon(
                                                                    Icons
                                                                        .delete_outline,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 45)
                                                              ]
                                                          ),
                                                        ),

                                                      ]
                                                  ),
                                                  context
                                              ),


                                              const SizedBox(height: 12),
                                              allComponents
                                                  .buildResponsiveWidget(
                                                  Column(
                                                      children: [

                                                        allComponents
                                                            .buildTextFormField(
                                                            labelText: 'SKU: (keep it blank to automatically generate SKU)',
                                                            controller: selectedSubVars[index]
                                                                .skusCntrlr
                                                        ),

                                                        allComponents
                                                            .buildTextFormField(
                                                          labelText: 'Value:',
                                                          controller: selectedSubVars[index]
                                                              .skusValCntrlr,
                                                          isReadOnly: selectedSubVars[index]
                                                              .variation
                                                              .name.isNotEmpty,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'This field is required.';
                                                            }
                                                            return null;
                                                          },
                                                        )

                                                      ]
                                                  ),
                                                  context
                                              ),

                                              const SizedBox(height: 24),

                                              allComponents
                                                  .buildResponsiveWidget(
                                                  Column(
                                                      children: [

                                                        allComponents
                                                            .buildTextFormField(
                                                            labelText: 'Default Purchase Price (Exc. tax):',
                                                            controller: selectedSubVars[index]
                                                                .ppExcTaxValCntrlr,
                                                            validator: (value) {
                                                              if (value ==
                                                                  null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'This field is required.';
                                                              }
                                                              return null;
                                                            },
                                                            onChanged: (
                                                                String value) {
                                                              setState(() {
                                                                double dppet = double
                                                                    .parse(
                                                                    value
                                                                        .isNotEmpty
                                                                        ? value
                                                                        : "0");

                                                                double taxValue = widget
                                                                    .taxVal /
                                                                    100;

                                                                double ppit = (dppet *
                                                                    taxValue) +
                                                                    dppet;

                                                                selectedSubVars[index]
                                                                    .ppIncTaxValCntrlr
                                                                    .text = ppit
                                                                    .toString();

                                                                String mrgnTxtVal = selectedSubVars[index]
                                                                    .mrgnValCntrlr
                                                                    .text;

                                                                double marginVal = (double
                                                                    .parse(
                                                                    mrgnTxtVal
                                                                        .isNotEmpty
                                                                        ? mrgnTxtVal
                                                                        : "0") /
                                                                    100);

                                                                double dspet = (dppet *
                                                                    marginVal) +
                                                                    dppet;

                                                                selectedSubVars[index]
                                                                    .spExcTaxValCntrlr
                                                                    .text =
                                                                    dspet
                                                                        .toString();

                                                                double dspit = (dspet *
                                                                    taxValue) +
                                                                    dspet;

                                                                selectedSubVars[index]
                                                                    .spIncTaxValCntrlr
                                                                    .text =
                                                                    dspit
                                                                        .toString();
                                                              });
                                                            }
                                                        ),

                                                        allComponents
                                                            .buildTextFormField(
                                                          labelText: 'Default Purchase Price (Inc. tax):',
                                                          controller: selectedSubVars[index]
                                                              .ppIncTaxValCntrlr,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'This field is required.';
                                                            }
                                                            return null;
                                                          },
                                                        )

                                                      ]
                                                  ),
                                                  context
                                              ),

                                              const SizedBox(height: 24),

                                              allComponents
                                                  .buildResponsiveWidget(
                                                  Column(
                                                      children: [

                                                        allComponents
                                                            .buildTextFormField(
                                                          labelText: 'x Margin(%):',
                                                          controller: selectedSubVars[index]
                                                              .mrgnValCntrlr,
                                                          onChanged: (
                                                              String value) {
                                                            setState(() {
                                                              String dppetTxt = selectedSubVars[index]
                                                                  .ppExcTaxValCntrlr
                                                                  .text;

                                                              double dppet = double
                                                                  .parse(
                                                                  dppetTxt
                                                                      .isNotEmpty
                                                                      ? dppetTxt
                                                                      : "0");

                                                              double marginVal = (double
                                                                  .parse(value
                                                                  .isNotEmpty
                                                                  ? value
                                                                  : "0") / 100);

                                                              double dspet = (dppet *
                                                                  marginVal) +
                                                                  dppet;

                                                              selectedSubVars[index]
                                                                  .spExcTaxValCntrlr
                                                                  .text = dspet
                                                                  .toString();

                                                              double taxVal = widget
                                                                  .taxVal / 100;

                                                              double dspit = (dspet *
                                                                  taxVal) +
                                                                  dspet;

                                                              selectedSubVars[index]
                                                                  .spIncTaxValCntrlr
                                                                  .text = dspit
                                                                  .toString();
                                                            });
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'This field is required.';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        if(widget.taxType
                                                            .toLowerCase() ==
                                                            "inclusive")
                                                          allComponents
                                                              .buildTextFormField(
                                                              labelText: 'Default Selling Price (Inc. Tax):',
                                                              controller: selectedSubVars[index]
                                                                  .spIncTaxValCntrlr,
                                                              validator: (
                                                                  value) {
                                                                if (value ==
                                                                    null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'This field is required.';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (
                                                                  String value) {
                                                                double sellingPriceIncTax = double
                                                                    .parse(value
                                                                    .isNotEmpty
                                                                    ? value
                                                                    : "0");

                                                                var sellingPrice = getPrinciple(
                                                                    amount: sellingPriceIncTax,
                                                                    percentage: widget
                                                                        .taxVal);

                                                                String dppetTxt = selectedSubVars[index]
                                                                    .ppExcTaxValCntrlr
                                                                    .text;

                                                                double purchaseExcTax = double
                                                                    .parse(
                                                                    dppetTxt
                                                                        .isNotEmpty
                                                                        ? dppetTxt
                                                                        : "0");

                                                                var ppTxt = selectedSubVars[index]
                                                                    .mrgnValCntrlr
                                                                    .text;

                                                                double profitPercent = double
                                                                    .parse(ppTxt
                                                                    .isNotEmpty
                                                                    ? ppTxt
                                                                    : "0");

                                                                if (purchaseExcTax ==
                                                                    0) {
                                                                  profitPercent =
                                                                  0;
                                                                } else {
                                                                  profitPercent =
                                                                      getRate(
                                                                          principal: purchaseExcTax,
                                                                          amount: sellingPrice);
                                                                }

                                                                setState(() {
                                                                  selectedSubVars[index]
                                                                      .mrgnValCntrlr
                                                                      .text =
                                                                      (profitPercent)
                                                                          .toString();
                                                                });
                                                              }
                                                          ),

                                                        if(widget.taxType
                                                            .toLowerCase() ==
                                                            "exclusive")
                                                          allComponents
                                                              .buildTextFormField(
                                                              labelText: 'Default Selling Price (Exc. Tax):',
                                                              controller: selectedSubVars[index]
                                                                  .spExcTaxValCntrlr,
                                                              validator: (
                                                                  value) {
                                                                if (value ==
                                                                    null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'This field is required.';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged: (
                                                                  String value) {
                                                                double sellingPrice = double
                                                                    .parse(value
                                                                    .isNotEmpty
                                                                    ? value
                                                                    : "0");

                                                                // var sellingPrice = getPrinciple(amount: sellingPriceIncTax, percentage: widget.taxVal);

                                                                String dppetTxt = selectedSubVars[index]
                                                                    .ppExcTaxValCntrlr
                                                                    .text;

                                                                double purchaseExcTax = double
                                                                    .parse(
                                                                    dppetTxt
                                                                        .isNotEmpty
                                                                        ? dppetTxt
                                                                        : "0");

                                                                var ppTxt = selectedSubVars[index]
                                                                    .mrgnValCntrlr
                                                                    .text;

                                                                double profitPercent = double
                                                                    .parse(ppTxt
                                                                    .isNotEmpty
                                                                    ? ppTxt
                                                                    : "0");

                                                                if (purchaseExcTax ==
                                                                    0) {
                                                                  profitPercent =
                                                                  0;
                                                                } else {
                                                                  profitPercent =
                                                                      getRate(
                                                                          principal: purchaseExcTax,
                                                                          amount: sellingPrice);
                                                                }

                                                                double taxVal = widget
                                                                    .taxVal /
                                                                    100;

                                                                var sellingPriceIncTax = ((sellingPrice *
                                                                    taxVal) +
                                                                    sellingPrice);

                                                                setState(() {
                                                                  selectedSubVars[index]
                                                                      .mrgnValCntrlr
                                                                      .text =
                                                                      (profitPercent)
                                                                          .toString();
                                                                  selectedSubVars[index]
                                                                      .spIncTaxValCntrlr
                                                                      .text =
                                                                      (sellingPriceIncTax)
                                                                          .toString();
                                                                });
                                                              }
                                                          )

                                                      ]
                                                  ),
                                                  context
                                              ),

                                              const SizedBox(height: 24),

                                              if(images.isNotEmpty)
                                                SingleChildScrollView(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      top: 11),
                                                  child: Column(
                                                    children: <Widget>[
                                                      // Other widgets...
                                                      GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisSpacing: 0,
                                                          mainAxisSpacing: 0,
                                                          crossAxisCount: 3,
                                                        ),
                                                        itemCount: images
                                                            .length,
                                                        itemBuilder: (context,
                                                            index) {
                                                          return Stack(
                                                              children: [
                                                                Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        top: 16),
                                                                    alignment: Alignment
                                                                        .center,
                                                                    width: MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width,
                                                                    height: imagePickerSize,
                                                                    decoration: BoxDecoration(
                                                                      border: Border
                                                                          .all(
                                                                        color: const Color(
                                                                            0xffa1a0a1),
                                                                        width: 1, // 20-pixel border
                                                                      ),
                                                                      borderRadius: BorderRadius
                                                                          .circular(
                                                                          5),
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                      child: Image
                                                                          .file(
                                                                          File(
                                                                              images[index]
                                                                                  .path),
                                                                          fit: BoxFit
                                                                              .cover),
                                                                    )
                                                                ),
                                                                Positioned(
                                                                  top: 26,
                                                                  right: 10,
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      removeProductImages(
                                                                          index);
                                                                    },
                                                                    child: const Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Icon(
                                                                              Icons
                                                                                  .cancel,
                                                                              color: Colors
                                                                                  .red,
                                                                              size: 45)
                                                                        ]
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: 76,
                                                                  right: 10,
                                                                  child: InkWell(
                                                                    onTap: () async {
                                                                      await updateProductImages(
                                                                          index);
                                                                    },
                                                                    child: const Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Icon(
                                                                              Icons
                                                                                  .border_color,
                                                                              color: Colors
                                                                                  .blueAccent,
                                                                              size: 45)
                                                                        ]
                                                                    ),
                                                                  ),
                                                                )
                                                              ]
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              Padding(
                                                  padding: const EdgeInsets
                                                      .all(
                                                      16),
                                                  child: GestureDetector(
                                                      onTap: pickImage,
                                                      child: Container(
                                                          width: 200,
                                                          height: 200,
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                                0xffeeeeee),
                                                            border: Border
                                                                .all(
                                                              color: const Color(
                                                                  0xffa1a0a1),
                                                              width: 1,
                                                            ),
                                                            borderRadius: BorderRadius
                                                                .circular(
                                                                5),
                                                          ),
                                                          child: const Column(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .add_photo_alternate,
                                                                  size: 100,
                                                                  color: Color(
                                                                      0xff9e9e9e),
                                                                ),
                                                                Text(
                                                                    'Select product images',
                                                                    style: TextStyle(
                                                                        fontSize: 16,
                                                                        color: Color(
                                                                            0xff797676),
                                                                        fontWeight: FontWeight
                                                                            .bold))
                                                              ]
                                                          )
                                                      )
                                                  )
                                              ),

                                              const SizedBox(height: 24),

                                            ]
                                        );
                                      }
                                  ),


                                  const SizedBox(height: 24),

                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(
                                            onPressed: () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                for (var slctSubVar in selectedSubVars) {
                                                  varsProds.add(
                                                      ProductVariations(
                                                          slctSubVar.variation
                                                              .id,
                                                          slctSubVar.skusCntrlr
                                                              .text,
                                                          slctSubVar
                                                              .skusValCntrlr
                                                              .text,
                                                          double.parse(
                                                              slctSubVar
                                                                  .ppExcTaxValCntrlr
                                                                  .text),
                                                          double.parse(
                                                              slctSubVar
                                                                  .ppIncTaxValCntrlr
                                                                  .text),
                                                          double.parse(
                                                              slctSubVar
                                                                  .mrgnValCntrlr
                                                                  .text),
                                                          double.parse(
                                                              slctSubVar
                                                                  .spExcTaxValCntrlr
                                                                  .text),
                                                          double.parse(
                                                              slctSubVar
                                                                  .spIncTaxValCntrlr
                                                                  .text),
                                                          images
                                                      ));
                                                }

                                                widget.addProd(
                                                    singleVariation?.id ?? 0,
                                                    singleVariation?.name ?? "",
                                                    varsProds);

                                                Navigator.pop(context);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.all(
                                                    10),
                                                fixedSize: const Size(200, 54),
                                                textStyle: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight
                                                        .bold),
                                                foregroundColor: Colors.black87,
                                                shadowColor: Colors.yellow,
                                                shape: const StadiumBorder()
                                            ),
                                            child: const Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text(' Add '),
                                                  Icon(Icons.add)
                                                ]
                                            )
                                        )
                                      ]),
                                ]
                                )
                            ),

                            const SizedBox(height: 16.0),

                          ]
                      )
                  )
              )
          );
        }
    );
  }
}
