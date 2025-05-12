import 'package:gs_erp/models/Warranty.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/models/BusinessLocation.dart';
import 'package:gs_erp/models/Product.dart';
import 'package:gs_erp/models/ProductCombo.dart';
import 'package:gs_erp/models/ProductVariations.dart';
import 'package:gs_erp/product_cmb.dart';
import 'package:gs_erp/product_var.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart' as vscQuill;
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'dart:io';

import 'common/button_widget.dart';
import 'main.dart';
import 'models/Category.dart';
import 'models/Currency.dart';
import 'models/Global.dart';
import 'models/Tax.dart';
import 'models/Unit.dart';

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

class TaxType {
  final String name;
  final String value;
  TaxType(this.name, this.value);

  @override
  String toString() {
    return name;
  }
}

class ProductType {
  final String name;
  final String value;
  ProductType(this.name, this.value);

  @override
  String toString() {
    return name;
  }
}

class ExpiryType {
  final String name;
  final String value;
  ExpiryType(this.name, this.value);

  @override
  String toString() {
    return name;
  }
}

class ProductRRP {
  final dynamic jsonObj;
  final TextEditingController prodRack;
  final TextEditingController prodRow;
  final TextEditingController prodPosition;

  ProductRRP({required this.jsonObj, required this.prodRack, required this.prodRow, required this.prodPosition});
}

class ProductCustomLabel {
  final dynamic jsonObj;
  final TextEditingController textEditingController;
  ProductCustomLabel({required this.jsonObj, required this.textEditingController});
}

class ManageProduct extends StatefulWidget {
  final int? productId;
  const ManageProduct({super.key, this.productId});

  @override
  State<ManageProduct> createState() => ManageProductState();
}

class ManageProductState extends State<ManageProduct> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);
  bool? checkBox;
  late bool enableStock;
  late bool prodDIS;
  late bool prodNFS;
  late AllComponents allComponents;
  Currency? selectedCurrency;
  // late FocusNode _focusNode;
  // late ScrollController _scrollController;
  // late quill.QuillController _controller = quill.QuillController.basic();

  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  FinancialYearMonth? selectedMonth;
  File? productImage;
  late int productId = 0;
  File? productBrochureImage;
  List<XFile> images = <XFile>[];
  late List<Unit> units = [];
  late List<Unit> relatedSubUnits = [];
  late List<Unit> selectedRelatedSubUnits = [];
  late List<Brand> brands = [];
  final List<BarcodeType> barcodeTypes = [
    BarcodeType("Code 128 (C128)", "C128"),
    BarcodeType("Code 39 (C39)", "C39"),
    BarcodeType("EAN-13", "EAN13"),
    BarcodeType("EAN-13", "EAN13"),
    BarcodeType("EAN-8", "EAN8"),
    BarcodeType("UPC-A", "UPCA"),
    BarcodeType("UPC-E", "UPCE")
  ];
  late List<ProductCategory> categories = [];
  late List<ProductCategory> subCategories = [];
  late List<BusinessLocation> businessLocations = [];
  late List<Tax> taxes = [];
  late List<Warranty> warranties = [];
  late int categoryId;
  late int subCategoryId;
  late int selectedTaxId;
  late double selectedTaxValue = 0;
  final List<TaxType> sellingPriceTaxType = [
    TaxType("Inclusive", "inclusive"),
    TaxType("Exclusive", "exclusive")
  ];
  final List<ProductType> productType = [
    ProductType("Single", "single"),
    ProductType("Variable", "variable"),
    ProductType("Combo", "combo")
  ];
  final List<ExpiryType> expiryTypes = [
    ExpiryType("Months", "months"),
    ExpiryType("Days", "days"),
    ExpiryType("Not Applicable", "")
  ];
  late ExpiryType selectedExpiryType = expiryTypes[2];
  late TaxType selectedSellingPriceTaxType = sellingPriceTaxType[0];
  late ProductType selectedProductType = productType[0];
  late List<Product> searchProducts = [];
  late List<ProductCustomLabel> customLabels = [];
  // late List<dynamic> customLabelsLocations = [];

  late BarcodeType? selectBarCodeType = BarcodeType("Code 128 (C128)", "C128");
  late Unit? selectedUnit = Unit(id: 0, name: "None");
  late Brand? selectedBrand = Brand(id: 0, name: "None");
  late ProductCategory? selectedCategory = ProductCategory(id: 0, name: "None");
  late ProductCategory? selectedSubCategory = ProductCategory(id: 0, name: "None");
  late List<BusinessLocation> selectedBusinessLocations = [];
  late Tax? selectedTax = Tax(id: 0, name: "None");
  late Warranty? selectedWarranty = Warranty(id: 0, name: "None");

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late List<ProductCombo> comboProducts = [];
  late List<ProductVariation> varsProducts = [];

  late double comboILPPTotalExcTax = 0;
  late double comboILPPTotalIncTax = 0;
  late TextEditingController comboMrgn = TextEditingController(text:erpGlobals['default_profit_percent'].toString());
  late TextEditingController comboDSP = TextEditingController();
  late double comboDSPIncTax = 0;

  late TextEditingController productName = TextEditingController();
  late TextEditingController productSku = TextEditingController();
  late TextEditingController productAlertQty = TextEditingController();
  late TextEditingController productDescp = TextEditingController();
  late TextEditingController productExpiryDays = TextEditingController();
  late List<ProductRRP> productRRP = [];
  late TextEditingController productWeight = TextEditingController();
  late TextEditingController productPrepTime = TextEditingController();

  late TextEditingController productSinglePPExcTax = TextEditingController();
  late TextEditingController productSinglePPIncTax = TextEditingController();
  late TextEditingController productSingleMargin = TextEditingController(text:erpGlobals['default_profit_percent'].toString());
  late TextEditingController productSingleSPExcTax = TextEditingController();
  late TextEditingController productSingleSPIncTax = TextEditingController();

  Map<String, String> customFieldsPayload = {};

  late FocusNode productNameFocus = FocusNode();
  final ScrollController scrollController = ScrollController();

  late bool isLoading = true;

  late String prodImgCloud = "";
  late String prodBrcCloud = "";

  late List<MediaFiles> singleProdImgs = [];

  late int prodVariationId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = quill.QuillController.basic();
    allComponents = AllComponents();
    checkBox = true;
    enableStock = false;
    prodDIS = false;
    prodNFS = false;
    selectedMonth = FinancialYearMonth.values[0];
    productId = widget.productId ?? 0;

    getProductCL();
    getUnits();
    getBrands();
    getCategories();
    getBusinessLocations();
    getTaxes();
    getWarranties();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   // productNameFocus.requestFocus();
    //   FocusScope.of(context).unfocus();
    //   scrollController.jumpTo(0.0);
    // });
    //
    getProduct(widget.productId ?? 0);
  }

  getProduct(int productId) async {
    if(productId > 0) {
      dynamic response = await RestSerice().getData("/product/$productId");
      List<dynamic> prodList = (response['data'] as List).cast<dynamic>();

      if (prodList.isNotEmpty) {
        var prodObj = prodList[0];

        productName.text = prodObj['name'];
        productSku.text = prodObj['sku'];

        if (prodObj['product_locations_short_details'] != null) {
          for (var locationObj in prodObj['product_locations_short_details']) {
            selectedBusinessLocations.add(BusinessLocation(
                id: locationObj['id'], name: locationObj['name']));
          }
        }

        setState(() {
          if (prodObj['barcode_type'] != null)
            selectBarCodeType =
                barcodeTypes.firstWhere((barcode) => barcode.value ==
                    prodObj['barcode_type'], orElse: () => barcodeTypes[0]);

          if (prodObj['unit'] != null) {
            var unit = prodObj['unit'];
            selectedUnit = Unit(id: unit['id'],
                name: unit['actual_name'] + '(' + unit['short_name'] + ')');
          }

          if (prodObj['brand'] != null) {
            var brand = prodObj['brand'];
            selectedBrand = Brand(id: brand['id'], name: brand['name']);
          }

          if (prodObj['category'] != null) {
            var category = prodObj['category'];
            selectedCategory = ProductCategory(id: category['id'], name: category['name']);
          }

          if (prodObj['sub_category'] != null) {
            var subCat = prodObj['sub_category'];
            selectedSubCategory = ProductCategory(id: subCat['id'], name: subCat['name']);
          }

          if (prodObj['warranty'] != null) {
            var warranty = prodObj['warranty'];
            selectedWarranty =
                Warranty(id: warranty['id'], name: warranty['name']);
          }

          try {

            var delta = HtmlToDelta().convert(prodObj['product_description'] ?? "");

            _controller = quill.QuillController(
                document: quill.Document.fromJson(delta.toJson()),
                selection: const TextSelection(baseOffset: 0, extentOffset: 0)
            );

          }catch(e){ print("Error : $e"); }

          prodImgCloud = prodObj['image_url'] ?? "";

          if(prodObj['product_brochure'] != null) {
            prodBrcCloud = prodObj['product_brochure']['display_url'] ?? "";
          }

          productExpiryDays.text = "${(prodObj['expiry_period'] ?? "0")}";

          selectedExpiryType = expiryTypes.firstWhere((expiryType) => expiryType.value ==
              (prodObj['expiry_period_type'] ?? ""),
              orElse: () => expiryTypes[2]);

          enableStock = prodObj['enable_stock'] == 1 ? true : false;
          productAlertQty.text = prodObj['alert_quantity'] ?? "";

          prodDIS = prodObj['enable_sr_no'] == 1 ? true : false;
          prodNFS = prodObj['not_for_selling'] == 1 ? true : false;

          productWeight.text = prodObj['weight'] ?? "";
          productPrepTime.text = prodObj['preparation_time_in_minutes'].toString() ?? "0";

          productRRP.clear();

          for (var bLoc in prodObj['racks_detail']) {
            dynamic jsonObj = {'id': bLoc['location_id'], 'location_id': bLoc['business_locations']['location_id'], 'name': bLoc['business_locations']['name'] };
            productRRP.add(ProductRRP(
                jsonObj: jsonObj,
                prodRack: TextEditingController(text: bLoc['rack'] ?? ""),
                prodRow: TextEditingController(text: bLoc['row'] ?? ""),
                prodPosition: TextEditingController(text: bLoc['position'] ?? ""))
            );
          }

          if (prodObj['product_tax'] != null) {
            var tax = prodObj['product_tax'];
            selectedTax = Tax(
                id: tax['id'],
                name: tax['name'],
                amount: double.parse(tax['amount'].toString())
            );
          }

          for(var cl in customLabels){

            if(cl.jsonObj['label_data']['type'] == 'text' || cl.jsonObj['label_data']['type'] == 'date'){
              cl.textEditingController.text = prodObj[cl.jsonObj['label_name']] ?? "";
            }

            if(cl.jsonObj['label_data']['type'] == 'dropdown'){
              cl.jsonObj['label_data']['value'] = prodObj[cl.jsonObj['label_name']];
            }

          }

          selectedSellingPriceTaxType = sellingPriceTaxType.firstWhere((taxType) => taxType.value ==
                  (prodObj['tax_type'] ?? ""),
              orElse: () => sellingPriceTaxType[0]);
          selectedProductType = productType.firstWhere((prodType) => prodType.value ==
                  (prodObj['type'] ?? ""),
              orElse: () => productType[0]);

          if(selectedProductType.value == "single" && prodObj['product_variations'] != null && prodObj['product_variations'][0] != null && prodObj['product_variations'][0]['variations'] != null){

            prodVariationId = prodObj['product_variations'][0]['variations'][0]['id'];

            productSinglePPExcTax.text = prodObj['product_variations'][0]['variations'][0]['default_purchase_price'];
            productSinglePPIncTax.text = prodObj['product_variations'][0]['variations'][0]['dpp_inc_tax'];
            productSingleMargin.text = prodObj['product_variations'][0]['variations'][0]['profit_percent'];
            productSingleSPExcTax.text = prodObj['product_variations'][0]['variations'][0]['default_sell_price'];
            productSingleSPIncTax.text = prodObj['product_variations'][0]['variations'][0]['sell_price_inc_tax'];


            try {
              for(var imgUrl in prodObj['product_variations'][0]['variations'][0]['media']){
                singleProdImgs.add(MediaFiles(id: imgUrl['id'], imagePath: imgUrl['display_url'], isLocal: false));
              }
            }catch (ex){
              print('Manage Products -- ${ex.toString()}');
            }
          }

          if(selectedProductType.value == "variable" && prodObj['product_variations'] != null){

            for(var mainVar in prodObj['product_variations']){

              List<ProductVariations> varProds = [];

              for(var subVarsProds in mainVar['variations']){

                List<MediaFiles> medFiles = [];

                for(var subVarProdMedia in subVarsProds['media']){
                  medFiles.add(MediaFiles(id: subVarProdMedia['id'], imagePath: subVarProdMedia['display_url'], isLocal: false));
                }

                varProds.add(
                    ProductVariations(
                        id: subVarsProds['id'],
                        sku: subVarsProds['sub_sku'],
                        value: subVarsProds['name'],
                        variationValueId: subVarsProds['variation_value_id'],
                        defaultPurchasePriceExcTax: double.parse(subVarsProds['default_purchase_price']),
                        defaultPurchasePriceIncTax: double.parse(subVarsProds['dpp_inc_tax']),
                        xMargin: double.parse(subVarsProds['profit_percent']),
                        defaultSellingPriceExcTax: double.parse(subVarsProds['default_sell_price']),
                        defaultSellingPriceIncTax: double.parse(subVarsProds['sell_price_inc_tax']),
                        isUpdate: true,
                        images: medFiles
                    )
                );

              }

              addVarsProduct((mainVar['id'] ?? 0),  (mainVar['variation_template_id'] ?? 0), mainVar['name'], true, varProds);

            }

          }

          if(selectedProductType.value == "combo" && prodObj['product_variations'] != null){

            for(var mainVar in prodObj['product_variations']){

              for(var subVarsProds in mainVar['variations']){

                prodVariationId = subVarsProds['id'];

                for(var subVarsCmbProds in subVarsProds['combo_variations']) {

                  var prodCmb = ProductCombo(
                      pId: subVarsCmbProds['product_id'],
                      vId: int.parse(subVarsCmbProds['variation_id'] ?? "0"),
                      prodName: (subVarsCmbProds['product_name'] ?? ""),
                      qty: double.parse(subVarsCmbProds['quantity'].toString() ?? "0"),
                      unitName: (subVarsCmbProds['unit_name'] ?? ""),
                      unitId: int.parse(subVarsCmbProds['unit_id'] ?? "0"),
                      defaultPurchasePriceExcTax: double.parse(subVarsCmbProds['default_purchase_price'] ?? "0"),
                      totalPurchasePriceExcTax: double.parse(subVarsCmbProds['default_purchase_price'] ?? "0"),
                      defaultPurchasePriceIncTax: double.parse(subVarsCmbProds['dpp_inc_tax'] ?? "0"),
                      defaultSellingPriceExcTax: double.parse(subVarsCmbProds['default_sell_price'] ?? "0"),
                      defaultSellingPriceIncTax: double.parse(subVarsCmbProds['sell_price_inc_tax'] ?? "0")
                  );

                  addComboProduct(prodCmb);

                }

              }

            }

          }

        });

      }

    }

    await getSubCategories(selectedCategory!.id);
    await getRelatedSubUnits(selectedUnit!.id);

    setState(() {
      selectedBusinessLocations = selectedBusinessLocations.toList();
      businessLocations = businessLocations.toList();
      isLoading = false;
    });

  }

  getProductCL() async {

    dynamic response = await RestSerice().getData("/get-products-lncl");

    for (dynamic customLabel in response['data']['custom_labels']) {
      customLabels.add(ProductCustomLabel(jsonObj: customLabel, textEditingController: TextEditingController()));
    }

    for (dynamic customLabelsLocation in response['data']['locations']) {
      productRRP.add(ProductRRP(jsonObj: customLabelsLocation, prodRack: TextEditingController(), prodRow: TextEditingController(), prodPosition: TextEditingController()));
    }

    setState(() {
      customLabels = customLabels.toList();
      productRRP = productRRP.toList();
    });

  }

  getUnits() async {
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
    }

    if(units.isNotEmpty){
      selectedUnit = units[0];
    }else{
      selectedUnit = null;
    }
  }

  getRelatedSubUnits(int unitId) async {
    if(unitId > 0){
      dynamic response = await RestSerice().getData("/get_sub_units/$unitId");
      List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
      for (dynamic unit in unitList) {
        relatedSubUnits.add(Unit(name: unit['name'],id: unit['id']));
      }
    }
  }

  getBrands() async {
    dynamic response = await RestSerice().getData("/brand");
    List<dynamic> brandList = (response['data'] as List).cast<dynamic>();
    for (dynamic brand in brandList) {
      brands.add(Brand(name: brand['name'], id: brand['id']));
    }
  }

  getCategories() async {
    dynamic response = await RestSerice().getData("/taxonomy");
    List<dynamic> categoryList = (response['data'] as List).cast<dynamic>();
    for (dynamic category in categoryList) {
      categories.add(ProductCategory(name: category['name'], id: category['id']));
    }
  }

  getSubCategories(int categoryId) async {
    if(categoryId > 0){
      dynamic response = await RestSerice().getData("/taxonomy/$categoryId");
      List<
          dynamic> subCategoryList = (response['data'][0]['sub_categories'] as List)
          .cast<dynamic>();
      for (dynamic subCategory in subCategoryList) {
        subCategories.add(ProductCategory(name: subCategory['name'], id: subCategory['id']));
      }
    }
  }

  getBusinessLocations() async {
    dynamic response = await RestSerice().getData("/business-location");
    List<dynamic> businessLocationList = (response['data'] as List).cast<dynamic>();

    for (dynamic businessLocation in businessLocationList) {
      businessLocations.add(BusinessLocation(id: businessLocation['id'], name: businessLocation['name']));
    }

  }

  getTaxes() async {
    dynamic response = await RestSerice().getData("/tax");
    List<dynamic> taxList = (response['data'] as List).cast<dynamic>();
    for (dynamic tax in taxList) {
      taxes.add(Tax(id: tax['id'], name: tax['name'], amount: double.parse(tax['amount'].toString())));
    }
  }

  getWarranties() async {
    dynamic response = await RestSerice().getData("/warranty");
    List<dynamic> warrantiesList = (response['data'] as List).cast<dynamic>();
    for (dynamic warranty in warrantiesList) {
      warranties.add(Warranty(id: warranty['id'], name: '${warranty['name']} (${warranty['duration']} ${warranty['duration_type']})'));
    }
  }

  getSearchedProducts(String searchTerm) async {
    if (searchTerm.length > 1) {
      dynamic response = await RestSerice().getData("/get-products?check_enable_stock=false&term=$searchTerm");
      List<dynamic> productList = (response['data'] as List).cast<dynamic>();
      for (dynamic product in productList) {
        searchProducts.add(Product(productId: product['product_id'], productName: product['text']));
      }
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
    if(pickedFile != null) {
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
        for (XFile image in medias) {
          singleProdImgs.add(MediaFiles(imagePath: image.path, isLocal: true));
        }
      });
    }
  }

  void addComboProduct(ProductCombo p) {
    setState(() {
      comboProducts.add(p);
      sumComboDSP();
    });
  }

  void removeComboProduct(int index) {
    setState(() {
      comboProducts.removeAt(index);
      sumComboDSP();
    });
  }

  void updateComboProd(ProductCombo p, int index) {
    setState(() {
      comboProducts[index] = p;
      sumComboDSP();
    });
  }

  void sumComboDSP(){
    if(comboProducts.isNotEmpty) {
      comboDSP.text = (comboProducts.map((e) => (e.defaultSellingPriceExcTax * e.qty)).reduce((a, b) => a + b)).toString();
      comboILPPTotalExcTax = (comboProducts.map((e) => (e.defaultPurchasePriceExcTax * e.qty)).reduce((a, b) => a + b));
      comboILPPTotalIncTax = (comboProducts.map((e) => (e.defaultPurchasePriceIncTax * e.qty)).reduce((a, b) => a + b));
      onChangeComboMargin(comboMrgn.text);
    }

    if(comboProducts.isEmpty){
      comboDSP.text = "0";
      comboILPPTotalExcTax = 0;
      comboILPPTotalIncTax = 0;
    }

  }

  void addVarsProduct(int id, int mainVarId, String mainVarName, bool isUpdate, List<ProductVariations> products) {
    setState(() {
      varsProducts.add(ProductVariation(id: id, templateId: mainVarId, name: mainVarName, isUpdate: isUpdate, productVariations: products));
    });
  }

  void addSubVarsProduct(int mainIndex, ProductVariations products) {
    setState(() {
      varsProducts[mainIndex].productVariations.add(products);
    });
  }

  void updateSubVarsProduct(int mainIndex, int subIndex, ProductVariations products) {
    setState(() {
      varsProducts[mainIndex].productVariations[subIndex] = products;
    });
  }

  void removeProductImage() {
    setState(() {
      productImage = null;
    });
  }

  void removeBrochureImage() async {
    setState(() {
      productBrochureImage = null;
    });
  }

  removeProductImages(int index) async {
    if(singleProdImgs[index].isLocal) {
      setState(() {
        singleProdImgs.removeAt(index);
      });
    }else{
      bool resp = await removeSingleProductImage(singleProdImgs[index].id ?? 0);
      if(resp) {
        setState(() {
          singleProdImgs.removeAt(index);
        });
      }
    }
  }

  removeSingleProductImage(int mediaId) async{
    if(mediaId > 0) {
      try {
        dynamic response = await RestSerice().getData("/delete-media/$mediaId");
        return response['success'] ?? false;
      }catch(e){
        return false;
      }
    }
  }

  updateProductImages(int index) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        singleProdImgs[index] = MediaFiles(id: singleProdImgs[index].id, imagePath: pickedFile.path, isLocal: true);
      });
    }
  }


  onCLTBChanged(String key, String value) {
    customFieldsPayload[key] = value;
  }

  onCLDDChanged(String key, int? value) {
    customFieldsPayload[key] = '$value';
  }

  onCLDPChanged(String key, String value) {
    customFieldsPayload[key] = value;
  }

  getRate({double principal = 0, double amount = 0}) {
    if(principal == 0 || amount == 0) {
      return 0;
    }

    double interest = amount - principal;
    double div = interest/ principal;
    return div * 100;
  }

  addPercent({double amount = 0, double percentage = 0}) {
    var div = percentage / 100;
    var mul = div * amount;
    return amount + mul;
  }

  onCLDPTap(String key, TextEditingController textEditingController) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(9999, 1, 1),
    );

    if (selectedDate != null) {
      String formattedDate = '${selectedDate.year.toString()}-${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}';
      textEditingController.text = formattedDate;
      customFieldsPayload[key] = formattedDate;
    }
  }

  deleteVarItem(int mainIndex, int index) {
    setState(() {
      varsProducts[mainIndex].productVariations.removeAt(index);
      if(varsProducts[mainIndex].productVariations.isEmpty){
        varsProducts.removeAt(mainIndex);
      }
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

  onChangeSinglePPExcTax(String value){
    setState(() {
      double dppet = double.parse(value.isNotEmpty ? value : "0");

      double taxValue = selectedTaxValue / 100;

      double ppit = (dppet *
          taxValue) +
          dppet;

      productSinglePPIncTax.text = ppit
          .toString();

      String mrgnTxtVal = productSingleMargin.text;

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

      productSingleSPExcTax.text =
          dspet
              .toString();

      double dspit = (dspet *
          taxValue) +
          dspet;

      productSingleSPIncTax.text =
          dspit
              .toString();
    });
  }

  onChangeSinglePPIncTax(String value){
    var purchaseIncTax = double.parse(value.isNotEmpty ? value : "0");

    var purchaseExcTax = getPrinciple(amount: purchaseIncTax, percentage: selectedTaxValue);
    productSinglePPExcTax.text = purchaseExcTax;

    var profitPercent = double.parse(productSingleMargin.text.isNotEmpty ? productSingleMargin.text : "0");
    var sellingPrice = addPercent(amount: purchaseExcTax, percentage: profitPercent);
    productSingleSPExcTax.text = sellingPrice;

    var sellingPriceIncTax = addPercent(amount:sellingPrice, percentage: selectedTaxValue);
    productSingleSPIncTax.text = sellingPriceIncTax;
  }

  onChangeSingleMargin(String value){
    setState(() {
      String dppetTxt =productSinglePPExcTax.text;

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

      productSingleSPExcTax.text = dspet
          .toString();

      double taxVal = selectedTaxValue / 100;

      double dspit = (dspet *
          taxVal) +
          dspet;

      productSingleSPIncTax.text = dspit
          .toString();
    });
  }

  onChangeSingleSPExcTax(String value){
    double sellingPrice = double
        .parse(value
        .isNotEmpty
        ? value
        : "0");

    // var sellingPrice = getPrinciple(amount: sellingPriceIncTax, percentage: widget.taxVal);

    String dppetTxt =productSinglePPExcTax.text;

    double purchaseExcTax = double
        .parse(
        dppetTxt
            .isNotEmpty
            ? dppetTxt
            : "0");

    var ppTxt = productSingleMargin.text;

    double profitPercent = double
        .parse(ppTxt
        .isNotEmpty
        ? ppTxt
        : "0");

    if (purchaseExcTax == 0) {
      profitPercent = 0;
    } else {
      profitPercent =
          getRate(
              principal: purchaseExcTax,
              amount: sellingPrice);
    }

    double taxVal = selectedTaxValue / 100;

    var sellingPriceIncTax = ((sellingPrice *
        taxVal) +
        sellingPrice);

    setState(() {
      productSingleMargin.text =
          (profitPercent)
              .toString();
      productSingleSPIncTax.text =
          (sellingPriceIncTax)
              .toString();
    });
  }

  onChangeSingleSPIncTax(String value){
    double sellingPriceIncTax = double
        .parse(value
        .isNotEmpty
        ? value
        : "0");

    var sellingPrice = getPrinciple(
        amount: sellingPriceIncTax,
        percentage: selectedTaxValue);

    String dppetTxt =  productSinglePPExcTax.text;

    double purchaseExcTax = double
        .parse(
        dppetTxt
            .isNotEmpty
            ? dppetTxt
            : "0");

    var ppTxt = productSingleMargin.text;

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
      productSingleMargin.text = (profitPercent).toString();
    });
  }

  onChangeComboMargin(String value){
    double itemLevelPurchasePriceTotal = 0;
    double purchasePriceIncTax = 0;

    itemLevelPurchasePriceTotal = comboProducts.map((e) => (e.defaultPurchasePriceExcTax * e.qty)).reduce((a, b) => (a + b));

    purchasePriceIncTax =
        addPercent(
            amount: itemLevelPurchasePriceTotal,
            percentage: selectedTaxValue);

    //Set selling price.
    double margin = double
        .parse(value.isNotEmpty
        ? value
        : "0");
    var sellingPrice = addPercent(
        amount: itemLevelPurchasePriceTotal,
        percentage: margin);
    var sellingPriceIncTax = addPercent(
        amount: sellingPrice,
        percentage: selectedTaxValue);

    comboDSP.text = sellingPrice.toString();
    setState(() {
      comboDSPIncTax = sellingPriceIncTax;
    });
  }

  onChangeComboSPExcTax(String value){
    var amount = double.parse(value.isNotEmpty ? value : "0");

    var margin = getRate(principal: comboILPPTotalExcTax, amount: amount);

    comboMrgn.text = margin.toString();

    setState(() {
      comboDSPIncTax = addPercent(amount: amount, percentage: selectedTaxValue);
    });
  }

  setValueIfPresent(Map<String, String> payload, String key, String value){
    if(value.isNotEmpty && value != "0"){
      payload[key] = value;
    }
  }

  genericMessage({bool isError = false, required String message}){
    final buildContext = formKey.currentContext!;
    if(buildContext != null && buildContext.mounted) {
      showDialog(context: buildContext, builder: (context) {
        return AlertDialog(
          title: Text(isError ? "Error Message" : "Message"),
          content: Text(message),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
              if (isError == false) {
                Navigator.pop(context);
              }
            }, child: const Text("OK"))
          ],
        );
      });
    }
  }


  @override
  void dispose() {
    _controller.dispose();
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

          //this bottom variable used to bring extra spacing between keyboard and input widget
          double bottom = MediaQuery.of(context).viewInsets.bottom;

          return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title:  Text(productId > 0 ? 'Update Product' : 'Add New Product'),
              ),
              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                  controller: scrollController,
                  // reverse: true,
                  child: Form(
                      key: formKey,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 16.0,
                              top: 16.0,
                              right: 16.0,
                              bottom: bottom),
                          child: Column(
                              children: <Widget>[
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          allComponents.buildTextFormField(
                                            controller: productName,
                                            // focusNode: productNameFocus,
                                            labelText: 'Product Name:*',
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please specify your product name.';
                                              }
                                              return null;
                                            },
                                          ),
                                          allComponents.buildTextFormField(
                                            controller: productSku,
                                            labelText: 'SKU:',
                                          )
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          DropdownSearch<BarcodeType>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            selectedItem: selectBarCodeType,
                                            items: barcodeTypes,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a barcode type',
                                                labelText: 'Barcode Type:*',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectBarCodeType = e!;
                                              });
                                            },
                                          ),
                                          DropdownSearch<Unit>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            items: units,
                                            selectedItem: selectedUnit,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a unit',
                                                labelText: 'Unit:*',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Please select a unit of your product.';
                                              }
                                              return null;
                                            },
                                            onChanged: (e) {
                                              setState(() {
                                                selectedUnit = e!;
                                                getRelatedSubUnits(e!.id);
                                              });
                                            },
                                          )
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          DropdownSearch<Unit>.multiSelection(
                                            // popupProps: PopupProps.menu(
                                            //     showSearchBox: true
                                            // ),
                                            items: relatedSubUnits,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a related sub units',
                                                labelText: 'Related Sub Units:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (List<Unit> units) {

                                              setState(() {
                                                selectedRelatedSubUnits = [];
                                                selectedRelatedSubUnits.addAll(units);
                                              });

                                            },
                                          ),
                                          DropdownSearch<Brand>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            items: brands,
                                            selectedItem: selectedBrand,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a brand',
                                                labelText: 'Brand:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedBrand = e!;
                                              });
                                            },
                                          )
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          DropdownSearch<ProductCategory>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            items: categories,
                                            selectedItem: selectedCategory,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a category for product',
                                                labelText: 'Category:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedCategory = e!;
                                                getSubCategories(e!.id);
                                              });
                                            },
                                          ),
                                          DropdownSearch<ProductCategory>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            items: subCategories,
                                            selectedItem: selectedSubCategory,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a sub category for product',
                                                labelText: 'Sub category:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedSubCategory = e!;
                                              });
                                            },
                                          )
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                            DropdownSearch<BusinessLocation>.multiSelection(
                                                // popupProps: PopupProps.menu(
                                                //     showSearchBox: true
                                                // ),
                                                items: businessLocations,
                                                selectedItems: selectedBusinessLocations,
                                                dropdownDecoratorProps: const DropDownDecoratorProps(
                                                  dropdownSearchDecoration: InputDecoration(
                                                    hintText: 'Please select a business location',
                                                    labelText: 'Business Locations:',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .all(
                                                            Radius.circular(
                                                                4.0))
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (List<BusinessLocation> locations) {

                                                  setState(() {
                                                    selectedBusinessLocations = locations;
                                                  });
                                                  // setState(() {
                                                  //   payload["product_locations"] = "[${locations.map((e) => e.id).join(',')}]";
                                                  // });
                                                  // int i = 0;
                                                  // for (var location in locations) {
                                                  //   // selectedBusinessLocations = [];
                                                  //   setState(() {
                                                  //     payload["product_locations[$i]"] = location.id.toString();
                                                  //     // selectedBusinessLocations.add(location);
                                                  //   });
                                                  //   i++;
                                                  // }
                                               },
                                            ),
                                          DropdownSearch<Warranty>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            items: warranties,
                                            selectedItem: selectedWarranty,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select a warranty for product',
                                                labelText: 'Warranty:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedWarranty = e!;
                                              });
                                            },
                                          )
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          CheckboxListTile(
                                            value: enableStock,
                                            controlAffinity: ListTileControlAffinity
                                                .leading,
                                            tristate: false,
                                            title: const Text('Manage Stock ?'),
                                            subtitle: const Text(
                                                'Enable stock management at product level'),
                                            onChanged: (value) {
                                              setState(() {
                                                enableStock = value!;
                                              });
                                            },
                                          ),
                                          allComponents.buildTextFormField(
                                            labelText: 'Alert quantity:',
                                            controller: productAlertQty,
                                            isReadOnly: !enableStock,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d*')),
                                            ],
                                          ),
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xffa1a0a1)),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: SafeArea(
                                    // child: Text(""),
                                    // child: quill.QuillProvider(
                                    //   configurations: QuillConfigurations(
                                    //     controller: _controller,
                                    //     sharedConfigurations: const QuillSharedConfigurations(
                                    //       locale: Locale('de'),
                                    //     ),
                                    //   ),
                                      child: Column(
                                        children: [
                                          quill.QuillToolbar.simple(
                                            controller: _controller,
                                          ),
                                          Expanded(
                                            child: quill.QuillEditor(
                                              controller: _controller,
                                              focusNode: _focusNode,
                                              scrollController: _scrollController,
                                              configurations: const quill.QuillEditorConfigurations(
                                                  // readOnly: false,
                                                  placeholder: 'Type product description here ...',
                                                  scrollable: true,
                                                  padding: EdgeInsets.all(16)
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    // ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          Column(
                                              children: [
                                                FormField<bool>(
                                                    builder: (state) {
                                                      return Column(children: [
                                                        ButtonWidget(
                                                            text: 'Select a product image',
                                                            icon: Icons
                                                                .attach_file,
                                                            color: Colors.white,
                                                            onClicked: () {
                                                              pickProductImage();
                                                            }
                                                        ),
                                                        if(state.errorText !=
                                                            null)
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 16),
                                                              child: Text(
                                                                state
                                                                    .errorText!,
                                                                style: TextStyle(
                                                                    color: Theme
                                                                        .of(
                                                                        context)
                                                                        .colorScheme
                                                                        .error
                                                                ),
                                                              )
                                                          )
                                                      ]);
                                                    },
                                                    validator: (value) {
                                                      if (productImage == null && productId == 0) {
                                                        return "Please select an image for your product.";
                                                      } else {
                                                        return null;
                                                      }
                                                    }),
                                                if (productImage == null && prodImgCloud.isNotEmpty)
                                                  Stack(
                                                      children: [
                                                        Container(
                                                            margin: const EdgeInsets
                                                                .only(top: 16),
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery
                                                                .of(context)
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
                                                                  .circular(5),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .all(16),
                                                              child: prodImgCloud.isNotEmpty
                                                                  ? Image.network(
                                                                  prodImgCloud!,
                                                                  fit: BoxFit.cover)
                                                                  : const Text(
                                                                  ''),
                                                            )
                                                        ),
                                                        Positioned(
                                                          top: 26,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: removeProductImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
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
                                                            onTap: pickProductImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .border_color,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 45)
                                                                ]
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                if (productImage != null)
                                                  Stack(
                                                      children: [
                                                        Container(
                                                            margin: const EdgeInsets
                                                                .only(top: 16),
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery
                                                                .of(context)
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
                                                                  .circular(5),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .all(16),
                                                              child: productImage !=
                                                                  null
                                                                  ? Image.file(
                                                                  productImage!,
                                                                  fit: BoxFit
                                                                      .cover)
                                                                  : const Text(
                                                                  ''),
                                                            )
                                                        ),
                                                        Positioned(
                                                          top: 26,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: removeProductImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
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
                                                            onTap: pickProductImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .border_color,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 45)
                                                                ]
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                  )
                                              ]
                                          ),
                                          Column(
                                              children: [
                                                ButtonWidget(
                                                    text: 'Select a product brochure',
                                                    icon: Icons.attach_file,
                                                    color: Colors.white,
                                                    onClicked: () {
                                                      pickBrochureImage();
                                                    }
                                                ),
                                                if (productBrochureImage == null && prodBrcCloud.isNotEmpty)
                                                  Stack(
                                                      children: [
                                                        Container(
                                                            margin: const EdgeInsets
                                                                .only(top: 16),
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery
                                                                .of(context)
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
                                                                  .circular(5),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .all(16),
                                                              child: prodBrcCloud.isNotEmpty
                                                                  ? Image.network(
                                                                  prodBrcCloud!,
                                                                  fit: BoxFit
                                                                      .cover)
                                                                  : const Text(
                                                                  ''),
                                                            )
                                                        ),
                                                        Positioned(
                                                          top: 26,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: removeBrochureImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
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
                                                            onTap: pickBrochureImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .border_color,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 45)
                                                                ]
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                  if (productBrochureImage != null)
                                                    Stack(
                                                      children: [
                                                        Container(
                                                            margin: const EdgeInsets
                                                                .only(top: 16),
                                                            alignment: Alignment
                                                                .center,
                                                            width: MediaQuery
                                                                .of(context)
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
                                                                  .circular(5),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .all(16),
                                                              child: productBrochureImage !=
                                                                  null
                                                                  ? Image.file(
                                                                  productBrochureImage!,
                                                                  fit: BoxFit
                                                                      .cover)
                                                                  : const Text(
                                                                  ''),
                                                            )
                                                        ),
                                                        Positioned(
                                                          top: 26,
                                                          right: 10,
                                                          child: InkWell(
                                                            onTap: removeBrochureImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
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
                                                            onTap: pickBrochureImage,
                                                            child: const Column(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .border_color,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 45)
                                                                ]
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                  )
                                              ]
                                          )
                                        ]),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          allComponents.buildTextFormField(
                                            controller: productExpiryDays,
                                            labelText: 'Expiry Days:',
                                          ),
                                          DropdownButtonFormField<ExpiryType>(
                                              value: selectedExpiryType,
                                              decoration: const InputDecoration(
                                                labelText: 'Expiry Type:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                              ),
                                              items: expiryTypes.map((expiryType) {
                                                return DropdownMenuItem<ExpiryType>(
                                                  value: expiryType,
                                                  child: Text(expiryType.name),
                                                );
                                              }).toList(),
                                              onChanged: (ExpiryType? value) {
                                                setState(() {
                                                  selectedExpiryType = value!;
                                                });
                                              }
                                          ),
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          CheckboxListTile(
                                            value: prodDIS,
                                            controlAffinity: ListTileControlAffinity
                                                .leading,
                                            tristate: false,
                                            title: const Text(
                                                'Enable Product description, IMEI or Serial Number'),
                                            onChanged: (value) {
                                              setState(() {
                                                prodDIS = value!;
                                              });
                                            },
                                          ),
                                          CheckboxListTile(
                                            value: prodNFS,
                                            controlAffinity: ListTileControlAffinity
                                                .leading,
                                            tristate: false,
                                            title: const Text(
                                                'Not for selling'),
                                            onChanged: (value) {
                                              setState(() {
                                                prodNFS = value!;
                                              });
                                            },
                                          ),
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xffa1a0a1)),
                                        borderRadius: BorderRadius.circular(
                                            5),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12,
                                                  top: 5,
                                                  right: 5,
                                                  bottom: 5),
                                              child: Text(
                                                'Custom Labels',
                                                style: TextStyle(
                                                    color: Color(
                                                        0xffffffff),
                                                    fontSize: 20),),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, top: 16, right: 16),
                                            child: ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: customLabels.length,
                                                separatorBuilder: (
                                                    BuildContext context,
                                                    int index) {
                                                  return Container();
                                                },
                                                itemBuilder: (context, index) {
                                                  //left it here unfinished as the responsiveness will be taken care later when I will be covering mobile version

                                                  final displayIndex = index * 2;

                                                  if (displayIndex >= customLabels.length) {
                                                    return Container();
                                                  } else {
                                                    return Column(
                                                        children: [
                                                          allComponents
                                                              .buildResponsiveWidget(
                                                              Column(
                                                                  children: [
                                                                    allComponents.buildCLFormField(
                                                                        controller: customLabels[displayIndex].textEditingController,
                                                                        dataObj: customLabels[displayIndex].jsonObj,
                                                                        onTBChanged: (value){ onCLTBChanged(customLabels[displayIndex].jsonObj['label_name'], value);},
                                                                        onDPChanged: (value){ onCLDPChanged(customLabels[displayIndex].jsonObj['label_name'], value);},
                                                                        onDDChanged: (value){ onCLDDChanged(customLabels[displayIndex].jsonObj['label_name'], value);},
                                                                        onDPTap: () async{ await onCLDPTap(customLabels[displayIndex].jsonObj['label_name'], customLabels[displayIndex].textEditingController);}
                                                                    ),
                                                                    if((displayIndex + 1) < customLabels.length)
                                                                      allComponents.buildCLFormField(
                                                                          controller: customLabels[displayIndex + 1].textEditingController,
                                                                          dataObj: customLabels[displayIndex + 1].jsonObj,
                                                                          onTBChanged: (value){ onCLTBChanged(customLabels[displayIndex + 1].jsonObj['label_name'], value);},
                                                                          onDPChanged: (value){ onCLDPChanged(customLabels[displayIndex + 1].jsonObj['label_name'], value);},
                                                                          onDDChanged: (value){ onCLDDChanged(customLabels[displayIndex + 1].jsonObj['label_name'], value);},
                                                                          onDPTap: () async{ await onCLDPTap(customLabels[displayIndex + 1].jsonObj['label_name'], customLabels[displayIndex + 1].textEditingController);}
                                                                      )
                                                                  ]
                                                              ),
                                                              context
                                                          ),
                                                          const SizedBox(height: 16.0),
                                                        ]
                                                    );
                                                  }
                                                }
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 16.0),

                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color(0xffa1a0a1)),
                                        borderRadius: BorderRadius.circular(
                                            5),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12,
                                                  top: 5,
                                                  right: 5,
                                                  bottom: 5),
                                              child: Text(
                                                'Rack/Row/Position Details',
                                                style: TextStyle(
                                                    color: Color(
                                                        0xffffffff),
                                                    fontSize: 20),),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, top: 16, right: 16),
                                            child: ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: productRRP.length,
                                                separatorBuilder: (
                                                    BuildContext context,
                                                    int index) {
                                                  return Container();
                                                },
                                                itemBuilder: (context, index) {
                                                  //left it here unfinished as the responsiveness will be taken care later
                                                  final displayIndex = index * 2;
                                                  if (displayIndex >= productRRP.length) {
                                                    return Container();
                                                  } else {
                                                    return Column(
                                                        children: [
                                                          allComponents
                                                              .buildResponsiveWidget(
                                                              Column(
                                                                  children: [
                                                                    Column(
                                                                        children: [
                                                                          Text(
                                                                              '${productRRP[displayIndex].jsonObj['name']} (${productRRP[displayIndex].jsonObj['location_id']})',
                                                                              style: const TextStyle(
                                                                                  fontSize: 20)),
                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          allComponents.buildTextFormField(
                                                                            controller: productRRP[displayIndex].prodRack,
                                                                            labelText: 'Rack',
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          allComponents.buildTextFormField(
                                                                            controller: productRRP[displayIndex].prodRow,
                                                                            labelText: 'Row',
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          allComponents.buildTextFormField(
                                                                            controller: productRRP[displayIndex].prodPosition,
                                                                            labelText: 'Position',
                                                                          )
                                                                        ]
                                                                    ),
                                                                    if((displayIndex + 1) < productRRP.length)
                                                                      Column(
                                                                          children: [
                                                                            Text(
                                                                                '${productRRP[displayIndex + 1].jsonObj['name']} (${productRRP[displayIndex +
                                                                                    1].jsonObj['location_id']})',
                                                                                style: const TextStyle(fontSize: 20)),
                                                                            const SizedBox(height: 8.0),
                                                                            allComponents.buildTextFormField(
                                                                              controller: productRRP[displayIndex + 1].prodRack,
                                                                              labelText: 'Rack',
                                                                            ),
                                                                            const SizedBox(height: 8.0),
                                                                            allComponents.buildTextFormField(
                                                                              controller: productRRP[displayIndex + 1].prodRow,
                                                                              labelText: 'Row',
                                                                            ),
                                                                            const SizedBox(height: 8.0),
                                                                            allComponents.buildTextFormField(
                                                                              controller: productRRP[displayIndex + 1].prodPosition,
                                                                              labelText: 'Position',
                                                                            )
                                                                          ]
                                                                      ),
                                                                  ]
                                                              ),
                                                              context
                                                          ),
                                                          const SizedBox(
                                                              height: 16.0)
                                                        ]
                                                    );
                                                  }
                                                }
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 16.0),

                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          allComponents.buildTextFormField(
                                            controller: productWeight,
                                            labelText: 'Weight:',
                                          ),
                                          allComponents.buildTextFormField(
                                            controller: productPrepTime,
                                            labelText: 'Service staff timer/Preparation time (In minutes):',
                                          )
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                allComponents.buildResponsiveWidget(
                                    Column(
                                        children: [
                                          DropdownSearch<Tax>(
                                            popupProps: const PopupProps.menu(
                                                showSearchBox: true
                                            ),
                                            items: taxes,
                                            selectedItem: selectedTax,
                                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                              dropdownSearchDecoration: InputDecoration(
                                                hintText: 'Please select an applicable tax',
                                                labelText: 'Applicable Tax:',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(
                                                            4.0))
                                                ),
                                              ),
                                            ),
                                            onChanged: (e) {
                                              setState(() {
                                                selectedTaxId = e!.id;
                                                selectedTaxValue = e!.amount ?? 0;
                                                selectedTax = e!;
                                              });
                                            },
                                          ),
                                          DropdownButtonFormField<TaxType>(
                                              value: selectedSellingPriceTaxType,
                                              decoration: const InputDecoration(
                                                labelText: 'Selling Price Tax Type:*',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                              ),
                                              items: sellingPriceTaxType.map((taxType) {
                                                return DropdownMenuItem<TaxType>(
                                                  value: taxType,
                                                  child: Text(taxType.name),
                                                );
                                              }).toList(),
                                              onChanged: (TaxType? value) {
                                                setState(() {
                                                  selectedSellingPriceTaxType = value!;
                                                });
                                              }
                                          ),
                                          DropdownButtonFormField<ProductType>(
                                              value: selectedProductType,
                                              decoration: const InputDecoration(
                                                labelText: 'Product Type:*',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius
                                                            .circular(
                                                            4.0))
                                                ),
                                              ),
                                              items: productType.map((
                                                  prodType) {
                                                return DropdownMenuItem<ProductType>(
                                                  value: prodType,
                                                  child: Text(prodType.name),
                                                );
                                              }).toList(),
                                              onChanged: (ProductType? value) {
                                                setState(() {
                                                  selectedProductType = value!;
                                                });
                                              }
                                          ),
                                        ]
                                    ),
                                    context
                                ),
                                const SizedBox(height: 16.0),
                                if(selectedProductType.value == 'single')
                                  Column(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xffa1a0a1)),
                                                borderRadius: BorderRadius
                                                    .circular(
                                                    5),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.green,
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 12,
                                                          top: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        'Default Purchase Price',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffffffff),
                                                            fontSize: 20),),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .all(
                                                          16),
                                                      child: allComponents
                                                          .buildResponsiveWidget(
                                                          Column(
                                                              children: [
                                                                allComponents
                                                                    .buildTextFormField(
                                                                    controller: productSinglePPExcTax,
                                                                    labelText: 'Exc. tax:*',
                                                                    keyboardType: TextInputType.number,
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.allow(
                                                                          RegExp(r'^\d*\.?\d*')),
                                                                    ],
                                                                    validator: (value) {
                                                                      if (value ==
                                                                          null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return "Please enter purchase price (Exc. tax).";
                                                                      } else {
                                                                        return null;
                                                                      }
                                                                    },
                                                                  onChanged: (value){
                                                                    onChangeSinglePPExcTax(value);
                                                                  }
                                                                ),
                                                                allComponents
                                                                    .buildTextFormField(
                                                                    controller: productSinglePPIncTax,
                                                                    labelText: 'Inc. tax:*',
                                                                    keyboardType: TextInputType.number,
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.allow(
                                                                          RegExp(r'^\d*\.?\d*')),
                                                                    ],
                                                                    validator: (
                                                                        value) {
                                                                      if (value ==
                                                                          null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return "Please enter purchase price (Inc. tax).";
                                                                      } else {
                                                                        return null;
                                                                      }
                                                                    },
                                                                  onChanged: (value){
                                                                    onChangeSinglePPIncTax(value);
                                                                  }
                                                                )
                                                              ]), context)
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 16.0),
                                        allComponents
                                            .buildResponsiveWidget(
                                            Column(
                                              children: [
                                                Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xffa1a0a1)),
                                                    borderRadius: BorderRadius
                                                        .circular(
                                                        5),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.green,
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                              left: 12,
                                                              top: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            'x Margin(%)',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffffffff),
                                                                fontSize: 20),),
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding: const EdgeInsets
                                                              .all(
                                                              16),
                                                          child: allComponents
                                                              .buildTextFormField(
                                                              controller: productSingleMargin,
                                                              labelText: '',
                                                              keyboardType: TextInputType.number,
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter.allow(
                                                                    RegExp(r'^\d*\.?\d*')),
                                                              ],
                                                              validator: (
                                                                  value) {
                                                                if (value ==
                                                                    null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return "Please enter margin value.";
                                                                } else {
                                                                  return null;
                                                                }
                                                              },
                                                            onChanged: (value){
                                                              onChangeSingleMargin(value);
                                                            }
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xffa1a0a1)),
                                                    borderRadius: BorderRadius
                                                        .circular(
                                                        5),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.green,
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                              left: 12,
                                                              top: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            'Default Selling Price',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffffffff),
                                                                fontSize: 20),),
                                                        ),
                                                      ),
                                                      if(selectedSellingPriceTaxType.value == "exclusive")
                                                        Padding(
                                                            padding: const EdgeInsets
                                                                .all(16),
                                                            child: allComponents
                                                                .buildTextFormField(
                                                                controller: productSingleSPExcTax,
                                                                labelText: 'Exc. Tax',
                                                                keyboardType: TextInputType.number,
                                                                inputFormatters: <TextInputFormatter>[
                                                                  FilteringTextInputFormatter.allow(
                                                                      RegExp(r'^\d*\.?\d*')),
                                                                ],
                                                                validator: (value) {
                                                                  if (value ==
                                                                      null ||
                                                                      value
                                                                          .isEmpty) {
                                                                    return "Please enter product selling price (Exc. Tax).";
                                                                  } else {
                                                                    return null;
                                                                  }
                                                                },
                                                              onChanged: (value){
                                                                onChangeSingleSPExcTax(value);
                                                              }
                                                            )
                                                        ),
                                                      if(selectedSellingPriceTaxType.value == "inclusive")
                                                        Padding(
                                                            padding: const EdgeInsets
                                                                .all(16),
                                                            child: allComponents
                                                                .buildTextFormField(
                                                                controller: productSingleSPIncTax,
                                                                labelText: 'Inc. Tax',
                                                                keyboardType: TextInputType.number,
                                                                inputFormatters: <TextInputFormatter>[
                                                                  FilteringTextInputFormatter.allow(
                                                                      RegExp(r'^\d*\.?\d*')),
                                                                ],
                                                                validator: (value) {
                                                                  if (value == null || value.isEmpty) {
                                                                    return "Please enter product selling price (Inc. Tax).";
                                                                  } else {
                                                                    return null;
                                                                  }
                                                                },
                                                              onChanged: (value){
                                                                onChangeSingleSPIncTax(value);
                                                              }
                                                            )
                                                        )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ), context),
                                        const SizedBox(height: 16.0),
                                        allComponents
                                            .buildResponsiveWidget(
                                            Column(
                                              children: [
                                                Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xffa1a0a1)),
                                                    borderRadius: BorderRadius
                                                        .circular(
                                                        5),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.green,
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .only(
                                                              left: 12,
                                                              top: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            'Product image',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffffffff),
                                                                fontSize: 20),),
                                                        ),
                                                      ),
                                                      if(singleProdImgs.isNotEmpty)
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
                                                                itemCount: singleProdImgs.length,
                                                                itemBuilder: (
                                                                    context,
                                                                    index) {
                                                                  return Stack(
                                                                      children: [
                                                                        Container(
                                                                            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
                                                                            alignment: Alignment
                                                                                .center,
                                                                            width: MediaQuery.of(context).size.width,
                                                                            height: double.infinity,
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(
                                                                                color: const Color(0xffa1a0a1),
                                                                                width: 1, // 20-pixel border
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(5),
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(0),
                                                                              child: singleProdImgs[index].isLocal ? Image.file(File(singleProdImgs[index].imagePath), fit: BoxFit.cover) : Image.network(singleProdImgs[index].imagePath, fit: BoxFit.cover),
                                                                            )
                                                                        ),
                                                                        Positioned(
                                                                          top: 14,
                                                                          right: 10,
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              await removeProductImages(index);
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
                                                                        if((singleProdImgs[index].id ?? 0) == 0)
                                                                          Positioned(
                                                                            top: 64,
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
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ), context)
                                      ]
                                  ),
                                const SizedBox(height: 16.0),
                                if(selectedProductType.value == 'variable')
                                  Column(children: [
                                    allComponents.buildResponsiveWidget(
                                        Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    const Text(
                                                        'Add Variation:*',
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight
                                                                .bold)
                                                    ),
                                                    const SizedBox(width: 16),
                                                    OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      ProductVar(
                                                                          addProd: addVarsProduct,
                                                                          taxVal: selectedTaxValue,
                                                                          taxType: selectedSellingPriceTaxType.name)));
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
                                                                      .all(4),
                                                                  child: Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 50)
                                                              )
                                                            ]
                                                        ) // Set a tooltip for long-press
                                                    ),
                                                  ]
                                              )
                                            ]
                                        ),
                                        context
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          FormField<bool>(
                                              builder: (state) {
                                                return Column(
                                                  children: [
                                                    const SizedBox(),
                                                    if(state.errorText != null)
                                                      Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 24),
                                                          child: Text(
                                                              state.errorText!,
                                                              style: TextStyle(
                                                                  color: Theme
                                                                      .of(
                                                                      context)
                                                                      .colorScheme
                                                                      .error
                                                              )
                                                          )
                                                      )
                                                  ],
                                                );
                                              },
                                              validator: (value) {
                                                if (varsProducts.isEmpty) {
                                                  return "Please add variation for your product.";
                                                } else {
                                                  return null;
                                                }
                                              })
                                        ]),
                                    const SizedBox(height: 16.0),
                                    Table(
                                        border: TableBorder.all(),
                                        columnWidths: const <
                                            int,
                                            TableColumnWidth>{
                                          0: IntrinsicColumnWidth(),
                                          1: IntrinsicColumnWidth(),
                                          2: FlexColumnWidth(),
                                          3: IntrinsicColumnWidth(),
                                          4: IntrinsicColumnWidth(),
                                          5: IntrinsicColumnWidth(),
                                          6: IntrinsicColumnWidth(),
                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        children: <TableRow>[
                                          TableRow(
                                            children: <Widget>[
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 28,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('SKU',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 28,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('Value',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 54,
                                                  child: Column(
                                                      children: [
                                                        const Center(
                                                            child: Text(
                                                                'Default Purchase Price',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold)
                                                            )),
                                                        const SizedBox(
                                                            height: 5.0),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              const Flexible(
                                                                  child: Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          left: 10),
                                                                      child: Text(
                                                                          ' Exc. tax',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold)
                                                                      )
                                                                  )
                                                              ),
                                                              Container(
                                                                width: 1,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              const Flexible(
                                                                  child: Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          right: 10),
                                                                      child: Text(
                                                                          'Inc. tax ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold)
                                                                      )
                                                                  )
                                                              )
                                                            ]
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 90,
                                                    child: Center(
                                                        child: Text(
                                                            'x Margin(%)',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 110,
                                                    child: Center(
                                                        child: Text(
                                                            ' Default Selling \n Price \n ${(selectedSellingPriceTaxType.value == "inclusive"
                                                                ? "Inc."
                                                                : "Exc.")} Tax',
                                                            style: const TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 70,
                                                    child: Center(
                                                        child: Text('Images',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              const TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    width: 80,
                                                  )
                                              ),
                                            ],
                                          )
                                        ]),

                                    ...varsProducts
                                        .asMap()
                                        .entries
                                        .expand((entryVal) {
                                      int mainIndex = entryVal.key;
                                      List<
                                          ProductVariations> mainEntry = entryVal
                                          .value.productVariations;

                                      List<TableRow> rows = [];

                                      var mtr = TableRow(
                                          decoration: const BoxDecoration(
                                            // color: Colors.light,
                                          ),
                                          children: <Widget>[
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 60,
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: 16),
                                                    child: Text(
                                                      entryVal.value.name,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold),)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 60,
                                                width: 79,
                                                child: Center(
                                                    child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(left: 5,
                                                            top: 0,
                                                            right: 5,
                                                            bottom: 0),
                                                        child: OutlinedButton(
                                                            onPressed: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Add Variation'),
                                                                      content: VariationItem(
                                                                          taxVal: selectedTaxValue,
                                                                          taxType: selectedSellingPriceTaxType.name,
                                                                          prodVarName: entryVal.value.name,
                                                                          mainIndex: mainIndex,
                                                                          subIndex: 0,
                                                                          isUpdate: false,
                                                                          addSubProd: addSubVarsProduct,
                                                                          isTablet: isTablet),
                                                                    );
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
                                                                    .circular(
                                                                    12),
                                                              ),
                                                            ),
                                                            child: const Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          top: 2,
                                                                          bottom: 2,
                                                                          left: 2,
                                                                          right: 2
                                                                      ),
                                                                      child: Icon(
                                                                          Icons
                                                                              .add,
                                                                          color: Colors
                                                                              .white,
                                                                          size: 45
                                                                      )
                                                                  )
                                                                ]
                                                            ) // Set a tooltip for long-press
                                                        )
                                                    )
                                                ),
                                              ),
                                            )
                                          ]
                                      );

                                      Table mainTable = Table(
                                          border: TableBorder.symmetric(
                                              inside: const BorderSide(
                                                  color: Colors.black)),
                                          columnWidths: const <int,
                                              TableColumnWidth>{
                                            0: FlexColumnWidth(),
                                            1: IntrinsicColumnWidth(),
                                          },
                                          defaultVerticalAlignment: TableCellVerticalAlignment
                                              .middle, children: [mtr]
                                      );

                                      Container mainContainer = Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                            )
                                        ),
                                        child: mainTable,
                                      );

                                      for (var subEntry in mainEntry
                                          .asMap()
                                          .entries) {
                                        int index = subEntry.key;
                                        ProductVariations entry = subEntry
                                            .value;

                                        var tr = TableRow(
                                          decoration: const BoxDecoration(
                                            // color: Colors.light,
                                          ),
                                          children: <Widget>[
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 90,
                                                width: 128,
                                                child: Center(
                                                    child: Text(entry.sku)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 32,
                                                width: 128,
                                                child: Center(
                                                    child: Text(entry.value)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                          child: Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                              child: Text(
                                                                  '${entry
                                                                      .defaultPurchasePriceExcTax}')
                                                          )
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                      Flexible(
                                                          child: Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  right: 10),
                                                              child: Text(
                                                                  '${entry
                                                                      .defaultPurchasePriceIncTax}'
                                                              )
                                                          )
                                                      )
                                                    ]
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                width: 90,
                                                child: Center(child: Text(
                                                    '${entry.xMargin}')),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                width: 110,
                                                child: Center(
                                                    child: Text(
                                                        '${(selectedSellingPriceTaxType.value ==
                                                            "inclusive"
                                                            ? entry
                                                            .defaultSellingPriceIncTax
                                                            : entry
                                                            .defaultSellingPriceExcTax)}')),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                height: 64,
                                                width: 70,
                                                child: Center(
                                                    child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(left: 8,
                                                            top: 8,
                                                            right: 8,
                                                            bottom: 8),
                                                        child: OutlinedButton(
                                                            onPressed: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Variation - (${entry
                                                                              .sku} - ${entry
                                                                              .value}) - Images'),
                                                                      content: VariationImgsGallery(
                                                                          images: entry
                                                                              .images,
                                                                          isTablet: isTablet),
                                                                    );
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
                                                                    .circular(
                                                                    12),
                                                              ),
                                                            ),
                                                            child: const Row(
                                                                mainAxisAlignment: MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          top: 7,
                                                                          bottom: 7,
                                                                          left: 2,
                                                                          right: 2
                                                                      ),
                                                                      child: Icon(
                                                                          Icons
                                                                              .image,
                                                                          color: Colors
                                                                              .white,
                                                                          size: 35
                                                                      )
                                                                  )
                                                                ]
                                                            ) // Set a tooltip for long-press
                                                        ))),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment: TableCellVerticalAlignment
                                                  .middle,
                                              child: SizedBox(
                                                  height: 95,
                                                  width: 80,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 5.0),
                                                      InkWell(
                                                        onTap: () async {
                                                          await showDialog(
                                                              context: context,
                                                              barrierDismissible: false,
                                                              builder: (
                                                                  BuildContext context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Update Variation'),
                                                                  content: VariationItem(
                                                                      prodVar: entry,
                                                                      taxVal: selectedTaxValue,
                                                                      taxType: selectedSellingPriceTaxType.name,
                                                                      prodVarName: entryVal
                                                                          .value
                                                                          .name,
                                                                      mainIndex: mainIndex,
                                                                      subIndex: index,
                                                                      isUpdate: true,
                                                                      updateSubProd: updateSubVarsProduct,
                                                                      isTablet: isTablet
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        child: const Column(
                                                            children: <
                                                                Widget>[
                                                              Icon(
                                                                  Icons
                                                                      .border_color,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  size: 40)
                                                            ]
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      InkWell(
                                                        onTap: () {
                                                          deleteVarItem(
                                                              mainIndex, index);
                                                        },
                                                        child: const Column(
                                                            children: <
                                                                Widget>[
                                                              Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 40)
                                                            ]
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                    ],
                                                  )
                                              ),
                                            ),
                                          ],
                                        );

                                        rows.add(tr);
                                      }

                                      Table subTable = Table(
                                          border: TableBorder.all(),
                                          columnWidths: const <int,
                                              TableColumnWidth>{
                                            0: IntrinsicColumnWidth(),
                                            1: IntrinsicColumnWidth(),
                                            2: FlexColumnWidth(),
                                            3: IntrinsicColumnWidth(),
                                            4: IntrinsicColumnWidth(),
                                            5: IntrinsicColumnWidth(),
                                            6: IntrinsicColumnWidth(),
                                          },
                                          defaultVerticalAlignment: TableCellVerticalAlignment
                                              .middle,
                                          children: rows);

                                      return [mainContainer, subTable];
                                    },
                                    ),
                                  ],
                                  ),
                                if(selectedProductType.value == 'combo')
                                  Column(children: [
                                    allComponents.buildResponsiveWidget(
                                        Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    const Text(
                                                        'Add Combo Product:*',
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight
                                                                .bold)
                                                    ),
                                                    const SizedBox(width: 16),
                                                    OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      ProductCmb(
                                                                          addProd: addComboProduct)));
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
                                                                      .all(4),
                                                                  child: Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 50)
                                                              )
                                                            ]
                                                        ) // Set a tooltip for long-press
                                                    ),
                                                  ]
                                              )
                                            ]
                                        ),
                                        context
                                    ),
                                    const SizedBox(height: 16.0),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          FormField<bool>(
                                              builder: (state) {
                                                return Column(
                                                  children: [
                                                    const SizedBox(),
                                                    if(state.errorText != null)
                                                      Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 24),
                                                          child: Text(
                                                              state.errorText!,
                                                              style: TextStyle(
                                                                  color: Theme
                                                                      .of(
                                                                      context)
                                                                      .colorScheme
                                                                      .error
                                                              )
                                                          )
                                                      )
                                                  ],
                                                );
                                              },
                                              validator: (value) {
                                                if (comboProducts.isEmpty) {
                                                  return "Please add combo product for your product.";
                                                } else {
                                                  return null;
                                                }
                                              })
                                        ]),
                                    const SizedBox(height: 16.0),
                                    Table(
                                        border: TableBorder.all(),
                                        columnWidths: const <
                                            int,
                                            TableColumnWidth>{
                                          0: FlexColumnWidth(),
                                          1: IntrinsicColumnWidth(),
                                          2: IntrinsicColumnWidth(),
                                          3: IntrinsicColumnWidth(),
                                          4: IntrinsicColumnWidth(),
                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment
                                            .middle,
                                        children: <TableRow>[
                                          const TableRow(
                                            children: <Widget>[
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 65,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text(
                                                            'Product Name',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 65,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('Quantity',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 65,
                                                  width: 120,
                                                  child: Center(
                                                      child: Text(
                                                          'Purchase Price \n(Excluding Tax)',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight
                                                                  .bold
                                                          )
                                                      )
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 65,
                                                    width: 90,
                                                    child: Center(
                                                        child: Text(
                                                            'Total Amount \n(Exc. Tax)',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold))),
                                                  )
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 65,
                                                  width: 80,
                                                  child: Column(
                                                      children: [
                                                        SizedBox(height: 5),
                                                        Icon(
                                                            Icons.border_color,
                                                            color: Colors.grey,
                                                            size: 25
                                                        ),
                                                        SizedBox(height: 5),
                                                        Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.grey,
                                                            size: 25
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          ...comboProducts
                                              .asMap()
                                              .entries
                                              .map((entryVal) {
                                            int index = entryVal.key;
                                            var entry = entryVal.value;

                                            var tr = TableRow(
                                              decoration: const BoxDecoration(
                                                // color: Colors.light,
                                              ),
                                              children: <Widget>[
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text(
                                                            entry.prodName)),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 128,
                                                    child: Center(
                                                        child: Text('${entry
                                                            .qty} \n${entry
                                                            .unitName}')),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 120,
                                                    child: Center(
                                                        child: Text('${entry
                                                            .defaultPurchasePriceExcTax}')
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                    height: 95,
                                                    width: 110,
                                                    child: Center(
                                                        child: Text(
                                                            '${(entry.qty *
                                                                entry
                                                                    .defaultPurchasePriceExcTax)}')),
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment
                                                      .middle,
                                                  child: SizedBox(
                                                      height: 95,
                                                      width: 80,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 5.0),
                                                          InkWell(
                                                            onTap: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  barrierDismissible: false,
                                                                  builder: (
                                                                      BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Update Combo'),
                                                                      content: ComboItem(
                                                                          prodCombo: entry,
                                                                          index: index,
                                                                          updateComboProd: updateComboProd,
                                                                          isTablet: isTablet
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child: const Column(
                                                                children: <Widget>[
                                                                  Icon(
                                                                      Icons
                                                                          .border_color,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 40)
                                                                ]
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                          InkWell(
                                                            onTap: () {
                                                              removeComboProduct(
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
                                                                      size: 40)
                                                                ]
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5.0),
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              ],
                                            );

                                            return tr;
                                          }),
                                          TableRow(
                                            decoration: const BoxDecoration(
                                              // color: Colors.light,
                                            ),
                                            children: <Widget>[
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(),
                                              ),
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 95,
                                                  width: 130,
                                                  child: Center(
                                                      child: Text(
                                                          'Net Total \n Amount',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight
                                                                  .bold))),
                                                ),
                                              ),
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(),
                                              ),
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(
                                                  height: 95,
                                                  width: 110,
                                                  child: Center(
                                                      child: Text(
                                                          '$comboILPPTotalExcTax',
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight
                                                                  .bold))),
                                                ),
                                              ),
                                              const TableCell(
                                                verticalAlignment: TableCellVerticalAlignment
                                                    .middle,
                                                child: SizedBox(),
                                              ),
                                            ],
                                          )
                                        ]
                                    ),
                                    const SizedBox(height: 16.0),
                                    allComponents.buildResponsiveWidget(
                                        Column(
                                            children: [
                                              allComponents.buildTextFormField(
                                                  controller: comboMrgn,
                                                  labelText: 'x Margin(%):',
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter.allow(
                                                        RegExp(r'^\d*\.?\d*')),
                                                  ],
                                                  onChanged: (String value) {
                                                    onChangeComboMargin(value);
                                                  }
                                              ),
                                              allComponents.buildTextFormField(
                                                  labelText: 'Default Selling Price:',
                                                  controller: comboDSP,
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter.allow(
                                                        RegExp(r'^\d*\.?\d*')),
                                                  ],
                                                  onChanged: (String value) {
                                                    onChangeComboSPExcTax(value);
                                                  }
                                              )
                                            ]
                                        ),
                                        context
                                    ),
                                  ]),
                                const SizedBox(height: 16.0),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                          onPressed: () async {
                                            if (formKey.currentState!.validate()) {

                                              Map<String, String> payload = {};

                                              payload["name"] = productName.text;

                                              setValueIfPresent(payload, "sku", productSku.text);

                                              setValueIfPresent(payload, "barcode_type", selectBarCodeType!.value);

                                              setValueIfPresent(payload, "unit_id", "${selectedUnit!.id}");

                                              int subUnitCntr = 0;

                                              for (var unit in selectedRelatedSubUnits) {
                                                payload["sub_unit_ids[$subUnitCntr]"] = unit.id.toString();
                                                subUnitCntr++;
                                              }

                                              setValueIfPresent(payload, "brand_id", "${selectedBrand!.id}");

                                              setValueIfPresent(payload, "category_id", "${selectedCategory!.id}");

                                              setValueIfPresent(payload, "sub_category_id", "${selectedSubCategory!.id}");

                                              int locs = 0;
                                              for (var location in selectedBusinessLocations) {
                                                payload["product_locations[$locs]"] = "${location.id}";
                                                locs++;
                                              }

                                              setValueIfPresent(payload, "warranty_id", "${selectedWarranty!.id}");

                                              payload["enable_stock"] = "${(enableStock ? 1 : 0)}";

                                              payload["alert_quantity"] = productAlertQty.text;

                                              final converter = vscQuill.QuillDeltaToHtmlConverter(
                                                List.castFrom(_controller.document.toDelta().toJson()),
                                                vscQuill.ConverterOptions.forEmail(),
                                              );

                                              payload["product_description"] = converter.convert();
                                              // payload["product_description"] = jsonEncode(_controller.document.toDelta().toJson());

                                              // payload["product_description"] = _controller.document.toPlainText();

                                              setValueIfPresent(payload, "expiry_period", productExpiryDays.text);

                                              setValueIfPresent(payload, "expiry_period_type", selectedExpiryType.value);

                                              payload["not_for_selling"] = "${(prodNFS ? 1 : 0)}";
                                              payload["enable_sr_no"] = "${(prodDIS ? 1 : 0)}";

                                              for(String key in customFieldsPayload.keys){
                                                payload[key] = customFieldsPayload[key] ?? "";
                                              }

                                              String prodRacks = productId > 0 ? "product_racks_update" : "product_racks";

                                              for(var prodRRP in productRRP){
                                                payload["$prodRacks[${prodRRP.jsonObj['id']}][rack]"] = prodRRP.prodRack.text;
                                                payload["$prodRacks[${prodRRP.jsonObj['id']}][row]"] = prodRRP.prodRow.text;
                                                payload["$prodRacks[${prodRRP.jsonObj['id']}][position]"] = prodRRP.prodPosition.text;
                                              }

                                              payload["weight"] = productWeight.text;
                                              payload["preparation_time_in_minutes"] = productPrepTime.text;

                                              setValueIfPresent(payload, "tax", "${selectedTax!.id}");

                                              payload["tax_type"] = selectedSellingPriceTaxType.value;
                                              payload["type"] = selectedProductType.value;

                                              List<http.MultipartFile> files = [];

                                              if(selectedProductType.value == "single") {

                                                setValueIfPresent(payload, "single_variation_id", "$prodVariationId");

                                                payload["single_dpp"] = productSinglePPExcTax.text;
                                                payload["single_dpp_inc_tax"] = productSinglePPIncTax.text;
                                                payload["profit_percent"] = productSingleMargin.text;
                                                payload["single_dsp"] = productSingleSPExcTax.text;
                                                payload["single_dsp_inc_tax"] = productSingleSPIncTax.text;

                                                for (var element in singleProdImgs) {
                                                  if(element.isLocal){
                                                    files.add(await http.MultipartFile.fromPath('variation_images[]',element.imagePath));
                                                  }
                                                }
                                              }

                                              if(selectedProductType.value == "variable"){
                                                int mv = 0;
                                                int condMv = 0;
                                                int condSv = 0;
                                                for(var mainVar in varsProducts){

                                                  condMv = mainVar.isUpdate ? ((mainVar.id ?? 0) > 0 ? mainVar.id! : mv): mv;

                                                  if(mainVar.isUpdate && (mainVar.id ?? 0) > 0) {
                                                    payload["product_variation_edit[$condMv][name]"] = mainVar.name;
                                                    payload["product_variation_edit[$condMv][variation_template_id]"] = "${mainVar.templateId}";
                                                  }else{
                                                    payload["product_variation[$mv][variation_template_id]"] = "${mainVar.templateId}";
                                                    payload["product_variation[$mv][variation_template_values][]"] = "${mainVar.templateId}";
                                                  }

                                                  int sv = 0;

                                                  for(var subVar in mainVar.productVariations){
                                                    condSv = subVar.isUpdate ? ((subVar.id ?? 0) > 0 ? subVar.id! : sv): sv;
                                                    String updateOrAddProdVar = (mainVar.isUpdate && (mainVar.id ?? 0) > 0) ? 'product_variation_edit' : 'product_variation';
                                                    String updateOrAddProdMedia = (mainVar.isUpdate && (subVar.id ?? 0) > 0) ? 'edit_variation_images_' : 'variation_images_';
                                                    String updateOrAdd = subVar.isUpdate ? ((subVar.id ?? 0) > 0 ? '[variations_edit][${subVar.id}]' : '[variations][$sv]') : '[variations][$sv]';

                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[sub_sku]"] = subVar.sku;
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[is_hidden]"] = "0";
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[variation_value_id]"] = "${subVar.variationValueId}";
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[value]"] = subVar.value;
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[default_purchase_price]"] = "${subVar.defaultPurchasePriceExcTax}";
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[dpp_inc_tax]"] = "${subVar.defaultPurchasePriceIncTax}";
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[profit_percent]"] = "${subVar.xMargin}";
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[default_sell_price]"] = "${subVar.defaultSellingPriceExcTax}";
                                                    payload["$updateOrAddProdVar[$condMv]$updateOrAdd[sell_price_inc_tax]"] = "${subVar.defaultSellingPriceIncTax}";

                                                    for(var filePath in subVar.images){
                                                      if(filePath.isLocal) {
                                                        files.add(await http.MultipartFile.fromPath('$updateOrAddProdMedia${condMv}_$condSv[]', filePath.imagePath));
                                                      }
                                                    }

                                                    sv++;
                                                  }
                                                  mv++;
                                                  condMv = 0;
                                                  condSv = 0;
                                                }

                                              }

                                              if(selectedProductType.value == "combo"){

                                                int i = 0;
                                                
                                                setValueIfPresent(payload, "combo_variation_id", "$prodVariationId");
                                                
                                                for(var mainCmb in comboProducts){
                                                  payload["composition_variation_id[$i]"] = "${mainCmb.vId}";
                                                  payload["quantity[$i]"] = "${mainCmb.qty}";
                                                  payload["unit[$i]"] = "${mainCmb.unitId}";
                                                  i++;
                                                }

                                                payload["item_level_purchase_price_total"] = "$comboILPPTotalExcTax";
                                                payload["purchase_price_inc_tax"] = productSinglePPExcTax.text;
                                                payload["profit_percent"] = comboMrgn.text;
                                                payload["selling_price"] = comboDSP.text;
                                                payload["selling_price_inc_tax"] = "$comboDSPIncTax";

                                              }

                                              if(productImage != null) {
                                                files.add(await http.MultipartFile.fromPath('image', productImage!.path));
                                              }

                                              if(productBrochureImage != null) {
                                                files.add(await http.MultipartFile.fromPath('product_brochure', productBrochureImage!.path));
                                              }

                                              for(String key in payload.keys){
                                                print(" $key => ${payload[key]}");
                                              }

                                              dynamic response = productId > 0 ?
                                              await RestSerice().putMultipartData("/product/$productId",payload, files) :
                                              await RestSerice().postMultipartData("/product", payload, files);

                                              if (response.containsKey('success')) {
                                                if (response['success'] == 1) {
                                                  genericMessage(message: (response.containsKey('msg') ? response['msg'] : "Product"));
                                                } else {
                                                  genericMessage(isError: true, message: (response.containsKey('msg') ? response['msg'] : "Unknown Error"));
                                                }
                                              } else {
                                                genericMessage(isError: true, message: (response.containsKey('msg') ? response['msg'] : "Unknown Error"));
                                              }

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
                                                Text(' Save ')
                                              ]
                                          )
                                      ),

                                    ]
                                ),
                                const SizedBox(height: 16.0),
                                const SizedBox(height: 16.0),


                                // Autocomplete<Product>(
                                //     fieldViewBuilder: (BuildContext context,
                                //         TextEditingController controller,
                                //         FocusNode focusNode,
                                //         VoidCallback onFieldSubmitted) {
                                //       return allComponents.buildTextFormField(
                                //           labelText: 'Enter Product name / SKU / Scan bar code',
                                //           controller: controller,
                                //           focusNode: focusNode,
                                //           maxLines: 1
                                //       );
                                //       // return TextFormField(
                                //       //   // decoration: InputDecoration(
                                //       //   //   errorText: _networkError ? 'Network error, please try again.' : null,
                                //       //   // ),
                                //       //   controller: controller,
                                //       //   focusNode: focusNode,
                                //       //   onFieldSubmitted: (String value) {
                                //       //     onFieldSubmitted();
                                //       //   },
                                //       // );
                                //     },
                                //     optionsBuilder: (
                                //         TextEditingValue textEditingValue) async {
                                //       // setState(() {
                                //       //   // _networkError = false;
                                //       // });
                                //       // final Iterable<String>? options =
                                //       // await _debouncedSearch(textEditingValue.text);
                                //       // if (options == null) {
                                //       //   return _lastOptions;
                                //       // }
                                //       // _lastOptions = options;
                                //       // return options;
                                //       await getSearchedProducts(
                                //           textEditingValue.text);
                                //       return searchProducts;
                                //     },
                                //     onSelected: (Product selection) {
                                //       debugPrint(
                                //           'You just selected ${selection
                                //               .productId}');
                                //     }
                                // ),
                              ]
                          )
                      )
                  )
              )
          );
        }
    );
  }
}

class VariationImgsGallery extends StatefulWidget {
  final List<MediaFiles>? images;
  final bool? isTablet;

  const VariationImgsGallery({Key? key, this.images, this.isTablet})
      : super(key: key);

  @override
  VariationImgsGalleryState createState() => VariationImgsGalleryState();
}

class VariationImgsGalleryState extends State<VariationImgsGallery> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = widget.isTablet ?? false;
    double imagePickerSize = isTablet ? 200 : 120;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: 3,
              ),
              itemCount: widget.images?.length,
              itemBuilder: (context,
                  index) {
                return Stack(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 16),
                          alignment: Alignment.center,
                          width: MediaQuery
                              .of(context)
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
                            child: widget.images![index].isLocal ? Image.file(
                                File(
                                    widget.images![index].imagePath
                                ),
                                fit: BoxFit.cover
                            ) : Image.network(
                                    widget.images![index].imagePath,
                                fit: BoxFit.cover
                            ) ,
                          )
                      )
                    ]
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  child: const Text('Close'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class VariationItem extends StatefulWidget {
  final ProductVariations? prodVar;
  final double taxVal;
  final String taxType;
  final String prodVarName;
  final int mainIndex;
  final int subIndex;
  final bool isUpdate;
  final bool? isTablet;
  final Function(int mainIndex, ProductVariations products)? addSubProd;
  final Function(int mainIndex, int subIndex, ProductVariations products)? updateSubProd;

  const VariationItem({Key? key, this.prodVar, required this.taxVal, required this.taxType, required this.prodVarName,required this.mainIndex, required this.subIndex, required this.isUpdate, this.addSubProd, this.updateSubProd, this.isTablet})
      : super(key: key);

  @override
  VariationItemState createState() => VariationItemState();
}

class VariationItemState extends State<VariationItem> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AllComponents allComponents = AllComponents();
  late ProductVariations? ssVars = widget.prodVar;

  late TextEditingController skusCntrlr = TextEditingController(text: ssVars?.sku ?? "");
  late TextEditingController skusValCntrlr = TextEditingController(text: ssVars?.value ?? "");
  late TextEditingController ppExcTaxValCntrlr = TextEditingController(text: ssVars?.defaultPurchasePriceExcTax.toString());
  late TextEditingController ppIncTaxValCntrlr = TextEditingController(text: ssVars?.defaultPurchasePriceIncTax.toString());
  late TextEditingController mrgnValCntrlr = TextEditingController(text: ssVars?.xMargin.toString());
  late TextEditingController spExcTaxValCntrlr = TextEditingController(text: ssVars?.defaultSellingPriceExcTax.toString());
  late TextEditingController spIncTaxValCntrlr = TextEditingController(text: ssVars?.defaultSellingPriceIncTax.toString());

  late List<MediaFiles> images = <MediaFiles>[];

  late List<XFile> files;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    images = ssVars?.images ?? [];

    if(mrgnValCntrlr.text.isEmpty){
      mrgnValCntrlr.text = erpGlobals['default_profit_percent'].toString();
    }

  }

  removeProductImages(int index) async {
    if(images[index].isLocal) {
      setState(() {
        images.removeAt(index);
      });
    }else{
      bool resp = await removeProductImage(images[index].id ?? 0);
      if(resp) {
        setState(() {
          images.removeAt(index);
        });
      }
    }
  }

  removeProductImage(int mediaId) async{
    if(mediaId > 0) {
      try {
        dynamic response = await RestSerice().getData("/delete-media/$mediaId");
        return response['success'] ?? false;
      }catch(e){
        return false;
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final List<XFile> medias = await picker.pickMultiImage();
    if (medias != null) {
      setState(() {
        for(XFile image in medias) {
          images.add(MediaFiles(imagePath: image.path, isLocal: true));
        }
      });
    }
  }

  updateProductImages(int index) async {

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        images[index] = MediaFiles(id: images[index].id, imagePath: pickedFile.path, isLocal: true);
      });
    }

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
  Widget build(BuildContext context) {
    bool isTablet = widget.isTablet ?? false;
    double imagePickerSize = isTablet ? 200 : 120;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
                key: formKey,
                child: Column(children: [

                  Column(
                      children: [

                        const SizedBox(height: 24),

                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  Text(
                                      'Variation Name: ${widget.prodVarName}',
                                      style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight
                                              .bold))

                                ]
                            ),
                            context
                        ),


                        const SizedBox(height: 12),
                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  allComponents.buildTextFormField(
                                      labelText: 'SKU: (keep it blank to automatically generate SKU)',
                                      controller: skusCntrlr
                                  ),

                                  allComponents.buildTextFormField(
                                    labelText: 'Value:',
                                    controller: skusValCntrlr,
                                    isReadOnly: ssVars != null && ssVars!.value.isNotEmpty,
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
                                      controller: ppExcTaxValCntrlr,
                                      validator: (value) {
                                        if (value ==
                                            null ||
                                            value
                                                .isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      },
                                      onChanged: (String value) {
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

                                          ppIncTaxValCntrlr
                                              .text = ppit
                                              .toString();

                                          String mrgnTxtVal = mrgnValCntrlr
                                              .text;

                                          double marginVal = (double.parse(
                                              mrgnTxtVal.isNotEmpty
                                                  ? mrgnTxtVal
                                                  : "0") / 100);

                                          double dspet = (dppet * marginVal) +
                                              dppet;

                                          spExcTaxValCntrlr.text =
                                              dspet.toString();

                                          double dspit = (dspet * taxValue) +
                                              dspet;

                                          spIncTaxValCntrlr.text =
                                              dspit.toString();
                                        });
                                      }
                                  ),

                                  allComponents
                                      .buildTextFormField(
                                    labelText: 'Default Purchase Price (Inc. tax):',
                                    controller: ppIncTaxValCntrlr,
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
                                    controller: mrgnValCntrlr,
                                    onChanged: (String value) {
                                      setState(() {
                                        String dppetTxt = ppExcTaxValCntrlr
                                            .text;

                                        double dppet = double.parse(
                                            dppetTxt.isNotEmpty
                                                ? dppetTxt
                                                : "0");

                                        double marginVal = (double.parse(
                                            value.isNotEmpty ? value : "0") /
                                            100);

                                        double dspet = (dppet * marginVal) +
                                            dppet;

                                        spExcTaxValCntrlr.text =
                                            dspet.toString();

                                        double taxVal = widget.taxVal / 100;

                                        double dspit = (dspet * taxVal) + dspet;

                                        spIncTaxValCntrlr.text =
                                            dspit.toString();
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

                                  if(widget.taxType.toLowerCase() ==
                                      "inclusive")
                                    allComponents
                                        .buildTextFormField(
                                        labelText: 'Default Selling Price (Inc. Tax):',
                                        controller: spIncTaxValCntrlr,
                                        validator: (value) {
                                          if (value ==
                                              null ||
                                              value
                                                  .isEmpty) {
                                            return 'This field is required.';
                                          }
                                          return null;
                                        },
                                        onChanged: (String value) {
                                          double sellingPriceIncTax = double
                                              .parse(
                                              value.isNotEmpty ? value : "0");

                                          var sellingPrice = getPrinciple(
                                              amount: sellingPriceIncTax,
                                              percentage: widget.taxVal);

                                          String dppetTxt = ppExcTaxValCntrlr
                                              .text;

                                          double purchaseExcTax = double.parse(
                                              dppetTxt.isNotEmpty
                                                  ? dppetTxt
                                                  : "0");

                                          var ppTxt = mrgnValCntrlr.text;

                                          double profitPercent = double.parse(
                                              ppTxt.isNotEmpty ? ppTxt : "0");

                                          if (purchaseExcTax == 0) {
                                            profitPercent = 0;
                                          } else {
                                            profitPercent = getRate(
                                                principal: purchaseExcTax,
                                                amount: sellingPrice);
                                          }

                                          setState(() {
                                            mrgnValCntrlr.text =
                                                (profitPercent).toString();
                                          });
                                        }
                                    ),

                                  if(widget.taxType.toLowerCase() ==
                                      "exclusive")
                                    allComponents
                                        .buildTextFormField(
                                        labelText: 'Default Selling Price (Exc. Tax):',
                                        controller: spExcTaxValCntrlr,
                                        validator: (value) {
                                          if (value ==
                                              null ||
                                              value
                                                  .isEmpty) {
                                            return 'This field is required.';
                                          }
                                          return null;
                                        },
                                        onChanged: (String value) {
                                          double sellingPrice = double.parse(
                                              value.isNotEmpty ? value : "0");

                                          // var sellingPrice = getPrinciple(amount: sellingPriceIncTax, percentage: widget.taxVal);

                                          String dppetTxt = ppExcTaxValCntrlr
                                              .text;

                                          double purchaseExcTax = double.parse(
                                              dppetTxt.isNotEmpty
                                                  ? dppetTxt
                                                  : "0");

                                          var ppTxt = mrgnValCntrlr.text;

                                          double profitPercent = double.parse(
                                              ppTxt.isNotEmpty ? ppTxt : "0");

                                          if (purchaseExcTax == 0) {
                                            profitPercent = 0;
                                          } else {
                                            profitPercent = getRate(
                                                principal: purchaseExcTax,
                                                amount: sellingPrice);
                                          }

                                          double taxVal = widget.taxVal / 100;

                                          var sellingPriceIncTax = ((sellingPrice *
                                              taxVal) + sellingPrice);

                                          setState(() {
                                            mrgnValCntrlr.text =
                                                (profitPercent).toString();
                                            spIncTaxValCntrlr.text =
                                                (sellingPriceIncTax).toString();
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
                                  itemCount: images.length,
                                  itemBuilder: (context,
                                      index) {
                                    return Stack(
                                        children: [
                                          Container(
                                              margin: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
                                              alignment: Alignment
                                                  .center,
                                              width: MediaQuery.of(context).size.width,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(0xffa1a0a1),
                                                  width: 1, // 20-pixel border
                                                ),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: images[index].isLocal ? Image.file(
                                                    File(images[index].imagePath),
                                                    fit: BoxFit.cover
                                                ) : Image.network(images[index].imagePath,
                                                    fit: BoxFit.cover
                                                ),
                                              )
                                          ),
                                          Positioned(
                                            top: 14,
                                            right: 10,
                                            child: InkWell(
                                              onTap: () async {
                                                await removeProductImages(index);
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
                                          if((images[index].id ?? 0) == 0)
                                            Positioned(
                                              top: 64,
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
                                          Icon(Icons.add_photo_alternate,
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
                  ),


                  const SizedBox(height: 24),

                ]
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {

                        try {

                          var prod = ProductVariations(
                              id: widget.prodVar != null ? (widget.prodVar!.id ?? 0) : 0,
                              sku: skusCntrlr.text,
                              value: skusValCntrlr.text,
                              variationValueId: widget.isUpdate ? widget.prodVar!.variationValueId : 0,
                              defaultPurchasePriceExcTax: double.parse(ppExcTaxValCntrlr.text),
                              defaultPurchasePriceIncTax: double.parse(ppIncTaxValCntrlr.text),
                              xMargin: double.parse(mrgnValCntrlr.text),
                              defaultSellingPriceExcTax: double.parse(spExcTaxValCntrlr.text),
                              defaultSellingPriceIncTax: double.parse(spIncTaxValCntrlr.text),
                              isUpdate: widget.prodVar != null ? widget.prodVar!.isUpdate : false,
                              images: images
                          );

                          if (widget.isUpdate) {
                            widget.updateSubProd!(widget.mainIndex, widget.subIndex, prod);
                          } else {
                            widget.addSubProd!(widget.mainIndex, prod);
                          }

                          Navigator.pop(context);

                        }catch(e){
                          print("Message: ${e}");
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  child: const Text('Close'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ComboItem extends StatefulWidget {
  final ProductCombo prodCombo;
  final int index;
  final bool? isTablet;
  final Function(ProductCombo products, int index)? updateComboProd;

  const ComboItem({Key? key, required this.prodCombo, required this.index, this.updateComboProd, this.isTablet})
      : super(key: key);

  @override
  ComboItemState createState() => ComboItemState();
}

class ComboItemState extends State<ComboItem> {

  late TextStyle buttonTextStyle = const TextStyle(
      fontSize: 15, fontWeight: FontWeight.bold);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AllComponents allComponents = AllComponents();

  final TextEditingController qtyController = TextEditingController();
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
    prodId = widget.prodCombo.pId;
    variId = widget.prodCombo.vId;
    prodName = widget.prodCombo.prodName;
    prodQty = widget.prodCombo.qty;
    unitName = widget.prodCombo.unitName;
    unitId = widget.prodCombo.unitId;
    defaultPurchasePriceExcTax = widget.prodCombo.defaultPurchasePriceExcTax;
    defaultPurchasePriceIncTax = widget.prodCombo.defaultPurchasePriceIncTax;
    defaultSellingPriceExcTax = widget.prodCombo.defaultSellingPriceExcTax;
    defaultSellingPriceIncTax = widget.prodCombo.defaultSellingPriceIncTax;
    qtyController.text = "$prodQty";
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
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
                key: formKey,
                child: Column(children: [

                  Column(
                      children: [

                        const SizedBox(height: 24),

                        allComponents
                            .buildResponsiveWidget(
                            Column(
                                children: [

                                  Text(
                                      'Variation Name: $prodName',
                                      style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight
                                              .bold))

                                ]
                            ),
                            context
                        ),


                        const SizedBox(height: 12),
                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  allComponents.buildTextFormField(
                                      controller: qtyController,
                                      labelText: 'Quantity:*',
                                      onChanged: (String value){
                                        setState(() {
                                          prodQty = double.parse(value.isNotEmpty ? value : "0");
                                          // totalPurchasePriceExcTax = prodQty * defaultPurchasePriceExcTax;
                                        });
                                      }
                                  ),
                                  SelectionContainer.disabled(child: Row(
                                      children: [
                                        const Text('Unit :', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(' $unitName', style: const TextStyle(fontSize: 22))
                                      ]
                                  )),
                                ]
                            ),
                            context
                        ),

                        const SizedBox(height: 24),

                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  SelectionContainer.disabled(child: Column(
                                      children: [
                                        const Text('Purchase Price (Excluding Tax)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(' ${erpGlobals['currency']['symbol']} $defaultPurchasePriceExcTax', style: const TextStyle(fontSize: 22))
                                      ])
                                  ),
                                  SelectionContainer.disabled(child: Column(
                                      children: [
                                        const Text('Total Amount (Exc. Tax)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(' ${erpGlobals['currency']['symbol']} ${(defaultPurchasePriceExcTax * prodQty)}', style: const TextStyle(fontSize: 22))
                                      ])
                                  )
                                ]
                            ),
                            context
                        ),
                        const SizedBox(height: 24),
                      ]
                  ),

                  const SizedBox(height: 24),

                ])
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  ElevatedButton(
                    onPressed: () {
                      if(prodId > 0 && prodName.isNotEmpty) {
                        singleProduct = ProductCombo(pId: prodId, vId: variId, prodName: prodName, qty: prodQty, unitName: unitName, unitId: unitId, defaultPurchasePriceExcTax: defaultPurchasePriceExcTax, totalPurchasePriceExcTax: totalPurchasePriceExcTax, defaultPurchasePriceIncTax: defaultPurchasePriceIncTax, defaultSellingPriceExcTax: defaultSellingPriceExcTax, defaultSellingPriceIncTax: defaultSellingPriceIncTax);
                        widget.updateComboProd!(singleProduct, widget.index);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  child: const Text('Close'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
