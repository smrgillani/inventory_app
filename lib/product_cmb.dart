import 'package:flutter/material.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:flutter/services.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'main.dart';
import 'models/Category.dart';
import 'models/Currency.dart';
import 'models/Global.dart';
import 'models/ProductCombo.dart';
import 'models/Tax.dart';
import 'models/Unit.dart';


class ComboProducts {
  final int productId;
  final int variationId;
  final String name;
  ComboProducts({required this.productId, required this.variationId, required this.name});

  @override
  String toString() {
    return name;
  }
}

class ProductCmb extends StatefulWidget {
  final Function(ProductCombo p) addProd;
  const ProductCmb({super.key, required this.addProd});

  @override
  State<ProductCmb> createState() => ProductCmbState();
}

class ProductCmbState extends State<ProductCmb> {

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
  late List<ComboProducts> searchProducts = [];

  late ProductCombo singleProduct;

  late int prodId = 0;
  late int variId = 0;
  late String prodName = "";
  late double prodQty = 0;
  late String unitName = "";
  late int unitId = 0;
  late double defaultPurchasePriceExcTax = 0;
  late double totalPurchasePriceExcTax = 0;
  late double defaultPurchasePriceIncTax = 0;
  late double defaultSellingPriceExcTax = 0;
  late double defaultSellingPriceIncTax = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    selectedMonth = FinancialYearMonth.values[0];
  }

  getSearchedProducts(String searchTerm) async {
    if(searchTerm.length > 1) {
      dynamic response = await RestSerice().getData(
          "/get-products?check_enable_stock=false&term=$searchTerm");
      List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      for (dynamic product in productList) {
        searchProducts.add(ComboProducts(productId: product['product_id'], variationId: product['variation_id'], name: product['text']));
      }
    }
  }

  getSingleProduct(int productId, int variationId) async {
    if(productId > 0) {
      dynamic response = await RestSerice().getData("/get-combo-product-entry-row?product_id=$productId&variation_id=$variationId");

      setState(() {
        prodId = response['data']['product']['id'];
        variId = response['data']['product']['variation']['id'];
        prodName = '${response['data']['product']['name']} (${response['data']['product']['variation']['name']}) - ${response['data']['product']['variation']['sub_sku']}';
        qtyController.text = "1";
        prodQty = 1;
        unitName = '${response['data']['product']['unit']['actual_name']}';
        unitId = response['data']['product']['unit']['id'];
        defaultPurchasePriceExcTax = double.parse(response['data']['product']['variation']['default_purchase_price']);
        // totalPurchasePriceExcTax = defaultPurchasePriceExcTax;
        defaultPurchasePriceIncTax = double.parse(response['data']['product']['variation']['dpp_inc_tax']);
        defaultSellingPriceExcTax = double.parse(response['data']['product']['variation']['default_sell_price']);
        defaultSellingPriceIncTax = double.parse(response['data']['product']['variation']['sell_price_inc_tax']);
      });

    }
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


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double bottom = MediaQuery
              .of(context)
              .viewInsets
              .bottom;
          return Scaffold(
              appBar: AppBar(
                title: const Text('Add Combo Product'),
              ),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, top: 16.0, right: 16.0, bottom: bottom),
                      child: Column(
                          children: <Widget>[

                            const SizedBox(height: 16),

                            Autocomplete<ComboProducts>(
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController controller,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted) {
                                  return allComponents.buildTextFormField(
                                      labelText: 'Enter Product name / SKU / Scan bar code to search',
                                      controller: controller,
                                      focusNode: focusNode,
                                      maxLines: 1
                                  );
                                },
                                optionsBuilder: (
                                    TextEditingValue textEditingValue) async {
                                  await getSearchedProducts(
                                      textEditingValue.text);
                                  return searchProducts;
                                },
                                onSelected: (ComboProducts selection) async {
                                  await getSingleProduct(selection.productId, selection.variationId);
                                }
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      SelectionContainer.disabled(
                                        child: Row(
                                            children: [
                                              const Text('Product Name:',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold),),
                                              Text(' $prodName',
                                                  style: const TextStyle(
                                                      fontSize: 22))
                                            ]),
                                      ),
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      allComponents.buildTextFormField(
                                          controller: qtyController,
                                          labelText: 'Quantity:*',
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          onChanged: (String value) {
                                            setState(() {
                                              prodQty = double.parse(
                                                  value.isNotEmpty
                                                      ? value
                                                      : "0");
                                              // totalPurchasePriceExcTax = prodQty * defaultPurchasePriceExcTax;
                                            });
                                          }
                                      ),
                                      SelectionContainer.disabled(child: Row(
                                          children: [
                                            const Text('Unit :',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            Text(' $unitName',
                                                style: const TextStyle(
                                                    fontSize: 22))
                                          ]
                                      )
                                      ),
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            allComponents.buildResponsiveWidget(
                                Column(
                                    children: [
                                      SelectionContainer.disabled(child: Row(
                                          children: [
                                            const Text(
                                                'Purchase Price (Excluding Tax):',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            Text(
                                                ' ${erpGlobals['currency']['symbol']} $defaultPurchasePriceExcTax',
                                                style: const TextStyle(
                                                    fontSize: 22))
                                          ])
                                      ),
                                      SelectionContainer.disabled(child: Row(
                                          children: [
                                            const Text(
                                                'Total Amount (Exc. Tax):',
                                                style: TextStyle(fontSize: 22,
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            Text(
                                                ' ${erpGlobals['currency']['symbol']} ${(prodQty *
                                                    defaultPurchasePriceExcTax)}',
                                                style: const TextStyle(
                                                    fontSize: 22))
                                          ])
                                      )
                                    ]
                                ),
                                context
                            ),

                            const SizedBox(height: 24),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                  onPressed: () {
                                    if (prodId > 0 && variId > 0 && prodName.isNotEmpty) {
                                      singleProduct = ProductCombo(
                                          pId: prodId,
                                          vId: variId,
                                          prodName: prodName,
                                          qty: prodQty,
                                          unitName: unitName,
                                          unitId: unitId,
                                          defaultPurchasePriceExcTax: defaultPurchasePriceExcTax,
                                          totalPurchasePriceExcTax: totalPurchasePriceExcTax,
                                          defaultPurchasePriceIncTax: defaultPurchasePriceIncTax,
                                          defaultSellingPriceExcTax: defaultSellingPriceExcTax,
                                          defaultSellingPriceIncTax: defaultSellingPriceIncTax);
                                      widget.addProd(singleProduct);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(10),
                                      fixedSize: const Size(200, 54),
                                      textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
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
                              ),

                            ]),

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
