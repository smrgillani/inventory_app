import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gs_erp/models/Brand.dart';
import 'package:gs_erp/services/http.service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'common/button_widget.dart';
import 'main.dart';
import 'models/Currency.dart';
import 'models/Unit.dart';

class PhotoItem {
  final String image;
  final String name;
  PhotoItem(this.image, this.name);
}

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {

  bool? checkBox;
  late bool alertQuantity;
  late AllComponents allComponents;
  Currency? selectedCurrency;
  final QuillController _controller = QuillController.basic();
  FinancialYearMonth? selectedMonth;
  File? image;
  List<XFile> images = <XFile>[];
  late List<Unit> units = [];
  late List<Brand> brands = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allComponents = AllComponents();
    checkBox = true;
    alertQuantity = false;
    selectedMonth = FinancialYearMonth.values[0];
    getUnits();
    getBrands();
  }

  getUnits() async{
    dynamic response = await RestSerice().getData("/unit");
    List<dynamic> unitList = (response['data'] as List).cast<dynamic>();
    for (dynamic unit in unitList) {
      units.add(Unit(name: unit['actual_name'] + '(' + unit['short_name'] + ')', id: unit['id']));
    }
  }

  getBrands() async{
    dynamic response = await RestSerice().getData("/brand");
    List<dynamic> brandList = (response['data'] as List).cast<dynamic>();
    for (dynamic brand in brandList) {
      brands.add(Brand(name: brand['name'], id: brand['id']));
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
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

  void _removeImage() {
    setState(() {
      image = null;
    });
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
          return Scaffold(
              appBar: AppBar(
                title: const Text('Add New Product'),
              ),
              body: SingleChildScrollView(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      children: <Widget>[
                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  allComponents.buildTextFormField(
                                    labelText: 'Product Name:*',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please specify your business name.';
                                      }
                                      return null;
                                    },
                                  ),
                                  allComponents.buildTextFormField(
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
                                  DropdownSearch<Currency>(
                                    popupProps: const PopupProps.menu(
                                        showSearchBox: true
                                    ),
                                    items: newCurrencyLabels,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select a barcode type',
                                        labelText: 'Barcode Type:*',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      print(e?.value);
                                    },
                                  ),
                                  DropdownSearch<Unit>(
                                    popupProps: const PopupProps.menu(
                                        showSearchBox: true
                                    ),
                                    items: units,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select a unit',
                                        labelText: 'Unit:*',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      print(e?.id);
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
                                  DropdownSearch<Brand>(
                                    popupProps: const PopupProps.menu(
                                        showSearchBox: true
                                    ),
                                    items: brands,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select a brand',
                                        labelText: 'Brand:',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      print(e?.id);
                                    },
                                  ),
                                  DropdownSearch<Currency>(
                                    popupProps: const PopupProps.menu(
                                        showSearchBox: true
                                    ),
                                    items: newCurrencyLabels,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select a category for product',
                                        labelText: 'Category:',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      print(e?.value);
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
                                  DropdownSearch<Currency>(
                                    popupProps: const PopupProps.menu(
                                        showSearchBox: true
                                    ),
                                    items: newCurrencyLabels,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select a sub category for product',
                                        labelText: 'Sub category:',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      print(e?.value);
                                    },
                                  ),
                                  DropdownSearch<Currency>.multiSelection(
                                    // popupProps: const PopupProps.menu(
                                    //     showSearchBox: true
                                    // ),
                                    items: newCurrencyLabels,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select a business location',
                                        labelText: 'Business Locations:',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      // print(e?.value);
                                    },
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
                                    value: checkBox,
                                    controlAffinity: ListTileControlAffinity
                                        .leading,
                                    tristate: false,
                                    title: const Text('Manage Stock ?'),
                                    subtitle: const Text(
                                        'Enable stock management at product level'),
                                    onChanged: (value) {
                                      setState(() {
                                        checkBox =
                                        checkBox == true ? false : true;
                                        alertQuantity =
                                        checkBox == true ? false : true;
                                      });
                                    },
                                  ),
                                  allComponents.buildTextFormField(
                                    labelText: 'Alert quantity:',
                                    isReadOnly: alertQuantity,
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
                            border: Border.all(color: const Color(0xffa1a0a1)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: SafeArea(
                            child: QuillProvider(
                              configurations: QuillConfigurations(
                                controller: _controller,
                                sharedConfigurations: const QuillSharedConfigurations(
                                  locale: Locale('de'),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const QuillToolbar(),
                                  Expanded(
                                    child: QuillEditor.basic(
                                      configurations: const QuillEditorConfigurations(
                                          readOnly: false,
                                          placeholder: 'Type product description here ...',
                                          scrollable: true,
                                          padding: EdgeInsets.all(16)
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  Column(
                                      children: [
                                        ButtonWidget(
                                            text: 'Select a product image',
                                            icon: Icons.attach_file,
                                            color: Colors.white,
                                            onClicked: () {
                                              _pickImage();
                                            }
                                        ),
                                        if (image != null)
                                          Stack(
                                              children: [
                                                Container(
                                                    margin: const EdgeInsets
                                                        .only(top: 16),
                                                    alignment: Alignment.center,
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    height: imagePickerSize,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
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
                                                      child: image != null
                                                          ? Image.file(image!,
                                                          fit: BoxFit.cover)
                                                          : const Text(''),
                                                    )
                                                ),
                                                Positioned(
                                                  top: 26,
                                                  right: 10,
                                                  child: InkWell(
                                                    onTap: _removeImage,
                                                    child: const Column(
                                                        children: <Widget>[
                                                          Icon(Icons.cancel,
                                                              color: Colors.red,
                                                              size: 45)
                                                        ]
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 76,
                                                  right: 10,
                                                  child: InkWell(
                                                    onTap: _pickImage,
                                                    child: const Column(
                                                        children: <Widget>[
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
                                              _pickImage();
                                            }
                                        ),
                                        if (image != null)
                                          Stack(
                                              children: [
                                                Container(
                                                    margin: const EdgeInsets
                                                        .only(top: 16),
                                                    alignment: Alignment.center,
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    height: imagePickerSize,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
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
                                                      child: image != null
                                                          ? Image.file(image!,
                                                          fit: BoxFit.cover)
                                                          : const Text(''),
                                                    )
                                                ),
                                                Positioned(
                                                  top: 26,
                                                  right: 10,
                                                  child: InkWell(
                                                    onTap: _removeImage,
                                                    child: const Column(
                                                        children: <Widget>[
                                                          Icon(Icons.cancel,
                                                              color: Colors.red,
                                                              size: 45)
                                                        ]
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 76,
                                                  right: 10,
                                                  child: InkWell(
                                                    onTap: _pickImage,
                                                    child: const Column(
                                                        children: <Widget>[
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
                                ]), context),
                        const SizedBox(height: 16.0),
                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  CheckboxListTile(
                                    value: checkBox,
                                    controlAffinity: ListTileControlAffinity
                                        .leading,
                                    tristate: false,
                                    title: const Text(
                                        'Enable Product description, IMEI or Serial Number'),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                  CheckboxListTile(
                                    value: checkBox,
                                    controlAffinity: ListTileControlAffinity
                                        .leading,
                                    tristate: false,
                                    title: const Text('Not for selling'),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ]
                            ),
                            context
                        ),
                        const SizedBox(height: 16.0),
                        allComponents.buildResponsiveWidget(
                            Column(
                                children: [
                                  allComponents.buildTextFormField(
                                    labelText: 'Weight:',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please specify your business name.';
                                      }
                                      return null;
                                    },
                                  ),
                                  allComponents.buildTextFormField(
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
                                  DropdownSearch<Currency>(
                                    popupProps: const PopupProps.menu(
                                        showSearchBox: true
                                    ),
                                    items: newCurrencyLabels,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Please select an applicable tax',
                                        labelText: 'Applicable Tax:',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    4.0))
                                        ),
                                      ),
                                    ),
                                    onChanged: (e) {
                                      print(e?.value);
                                    },
                                  ),
                                  DropdownButtonFormField<FinancialYearMonth>(
                                      value: selectedMonth,
                                      decoration: const InputDecoration(
                                        labelText: 'Selling Price Tax Type:*',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius
                                                    .circular(
                                                    4.0))
                                        ),
                                      ),
                                      items: FinancialYearMonth.values.map((
                                          financialyearmonth) {
                                        return DropdownMenuItem<
                                            FinancialYearMonth>(
                                          value: financialyearmonth,
                                          child: Text(financialyearmonth.label),
                                        );
                                      }).toList(),
                                      onChanged: (FinancialYearMonth? value) {
                                        setState(() {
                                          // widget.updateFormData(
                                          //     'fy_start_month', value?.value);
                                        });
                                      }
                                  ),
                                  DropdownButtonFormField<FinancialYearMonth>(
                                      value: selectedMonth,
                                      decoration: const InputDecoration(
                                        labelText: 'Product Type:*',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius
                                                    .circular(
                                                    4.0))
                                        ),
                                      ),
                                      items: FinancialYearMonth.values.map((
                                          financialyearmonth) {
                                        return DropdownMenuItem<
                                            FinancialYearMonth>(
                                          value: financialyearmonth,
                                          child: Text(financialyearmonth.label),
                                        );
                                      }).toList(),
                                      onChanged: (FinancialYearMonth? value) {
                                        setState(() {
                                          // widget.updateFormData(
                                          //     'fy_start_month', value?.value);
                                        });
                                      }
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
                                borderRadius: BorderRadius.circular(5),
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
                                      padding: EdgeInsets.only(left: 12,
                                          top: 5,
                                          right: 5,
                                          bottom: 5),
                                      child: Text('Default Purchase Price',
                                        style: TextStyle(
                                            color: Color(0xffffffff),
                                            fontSize: 20),),
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.all(16),
                                      child: allComponents
                                          .buildResponsiveWidget(
                                          Column(
                                              children: [
                                                allComponents
                                                    .buildTextFormField(
                                                  labelText: 'Exc. tax:*',
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please specify your business name.';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                allComponents
                                                    .buildTextFormField(
                                                  labelText: 'Inc. tax:*',
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
                                        color: const Color(0xffa1a0a1)),
                                    borderRadius: BorderRadius.circular(5),
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
                                          padding: EdgeInsets.only(left: 12,
                                              top: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text('x Margin(%)',
                                            style: TextStyle(
                                                color: Color(0xffffffff),
                                                fontSize: 20),),
                                        ),
                                      ),
                                      Padding(padding: const EdgeInsets.all(16),
                                          child: allComponents
                                              .buildTextFormField(
                                            labelText: '',
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
                                        color: const Color(0xffa1a0a1)),
                                    borderRadius: BorderRadius.circular(5),
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
                                          padding: EdgeInsets.only(left: 12,
                                              top: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text('Default Selling Price',
                                            style: TextStyle(
                                                color: Color(0xffffffff),
                                                fontSize: 20),),
                                        ),
                                      ),
                                      Padding(padding: const EdgeInsets.all(16),
                                          child: allComponents
                                              .buildTextFormField(
                                            labelText: 'Exc. Tax',
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
                                        color: const Color(0xffa1a0a1)),
                                    borderRadius: BorderRadius.circular(5),
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
                                          padding: EdgeInsets.only(left: 12,
                                              top: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text('Product image',
                                            style: TextStyle(
                                                color: Color(0xffffffff),
                                                fontSize: 20),),
                                        ),
                                      ),
                                      if(images.isNotEmpty)
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.only(
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
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {

                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: FileImage(File(images[index].path)),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: GestureDetector(
                                              onTap: pickImage,
                                              child: Container(
                                                  width: 200,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xffeeeeee),
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xffa1a0a1),
                                                      width: 1,
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .circular(5),
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
                                              ))
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ), context)
                      ]
                  )
              )
              )
          );
        }
    );
  }
}
