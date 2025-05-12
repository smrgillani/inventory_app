import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/ComponentUtil.dart';
import '../../models/Currency.dart';
import '../../models/Timezone.dart';
import '../../services/http.service.dart';
import 'dart:io';

class RegistrationScreenOne extends StatefulWidget {
  final Function updateFormData;
  final Function getFormData;
  final Function updateLoading;
  final Function focusNexButton;
  const RegistrationScreenOne({super.key, required this.updateFormData, required this.getFormData, required this.updateLoading, required this.focusNexButton});

  @override
  RegistrationScreenOneState createState() => RegistrationScreenOneState();
}

class RegistrationScreenOneState extends State<RegistrationScreenOne> {

  final TextEditingController currencyController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessWebsiteController = TextEditingController();
  TextEditingController businessStartdateController = TextEditingController();
  Currency? selectedCurrency;
  TextEditingController businessContactController = TextEditingController();
  TextEditingController businessAltContactController = TextEditingController();
  TextEditingController businessCountryController = TextEditingController();
  TextEditingController businessStateController = TextEditingController();
  TextEditingController businessCityController = TextEditingController();
  TextEditingController businessZipcodeController = TextEditingController();
  TextEditingController businessLandmarkController = TextEditingController();

  final FocusNode bcnTextField = FocusNode();

  Timezone? selectedTimezone;
  late ComponentUtil componentUtil;
  late List<Currency> currencies = [];
  late List<Timezone> timezones = [];

  List<Currency> currencyLabels = [
    Currency('Afghanistan - Afghanis(AF) ', '3'),
    Currency('Albania - Leke(ALL) ', '1'),
    Currency('Algerie - Algerian dinar(DZD) ', '135'),
    Currency('America - Dollars(USD) ', '2')
  ];

  List<Timezone> timezoneLabel = [
    Timezone('Africa/Abidjan', 'Africa/Abidjan'),
    Timezone('Africa/Accra', 'Africa/Accra'),
    Timezone('Africa/Addis_Ababa', 'Africa/Addis_Ababa'),
    Timezone('Africa/Algiers', 'Africa/Algiers')
  ];

  @override
  initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeForm();
    });

    componentUtil = ComponentUtil();

  }


  Future<void> initializeForm() async {
    widget.updateLoading(true);
    // Wait for currencies and timezones to load
    currencies = await getAllCurrencies();
    timezones = await getAllTimezones();

    if(widget.getFormData('business_logo') != null && widget.getFormData('business_logo').toString().isNotEmpty) {
      setState(() {
        _image = File(widget.getFormData('business_logo'));
      });
    }

    businessNameController.text = widget.getFormData('name') ?? '';
    businessWebsiteController.text = widget.getFormData('website') ?? '';
    businessStartdateController.text = widget.getFormData('start_date') ?? '';

    var findCurrencyItem = findItemByValue(
        currencies, widget.getFormData('currency_id') ?? '', (
        Currency currency) => currency.value);

    setState(() {
      selectedCurrency = findCurrencyItem;
    });

    businessContactController.text = widget.getFormData('mobile') ?? '';
    businessAltContactController.text =
        widget.getFormData('alternate_number') ?? '';
    businessCountryController.text = widget.getFormData('country') ?? '';
    businessStateController.text = widget.getFormData('state') ?? '';
    businessCityController.text = widget.getFormData('city') ?? '';
    businessZipcodeController.text = widget.getFormData('zip_code') ?? '';
    businessLandmarkController.text = widget.getFormData('landmark') ?? '';
    var findTimezoneItem = findItemByValue(
        timezones, widget.getFormData('time_zone') ?? '', (
        Timezone timezone) => timezone.value);

    setState(() {
      selectedTimezone = findTimezoneItem;
    });

    widget.updateLoading(false);
  }

  Future<List<Currency>> getAllCurrencies() async{
    dynamic response = await RestSerice().getData("/currencies");
    List<dynamic> currencieslist = (response['data'] as List).cast<dynamic>();

    return currencieslist.map((currency) => Currency(
      '${currency['country']} - ${currency['currency']} (${currency['code']})',
      currency['id'].toString(),
    )).toList();
  }

  Future<List<Timezone>> getAllTimezones() async{
    dynamic response = await RestSerice().getData("/timezones");
    Map<String, dynamic> timezonesList = response['data'];

    List<Timezone> localTimezones = [];
    for(var entry in timezonesList.entries){
      localTimezones.add(Timezone(entry.key, entry.value.toString()));
    }

    return localTimezones;
  }

  T? findItemByValue<T>(List<T> items, String value, Function(T) extractValue) {

    if (value.isNotEmpty) {
      for (var item in items) {
        if (extractValue(item) == value) {
          return item;
        }
      }
    }

    return null;
  }

  Future<void> selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.year.toString()}';
      businessStartdateController.text = formattedDate;
      widget.updateFormData('start_date', formattedDate);
    }
  }

  File? _image;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.updateFormData('business_logo', pickedFile.path);
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double imagePickerSize = isTablet ? 200 : 120;
          return Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: GestureDetector(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            width: imagePickerSize,
                            height: imagePickerSize,
                            // color: Colors.grey[300],
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 2.0, // 20-pixel border
                              ),
                            ),
                            child: _image != null
                                ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                    _image!, width: imagePickerSize,
                                    height: imagePickerSize,
                                    fit: BoxFit.cover)
                            )
                                : const Text(''),
                          ),
                          if (_image == null)
                            Positioned(
                              top: isTablet ? 70 : 27,
                              right: isTablet ? 65 : 23,
                              child: InkWell(
                                onTap: _pickImage,
                                child: const Column(
                                    children: <Widget>[
                                      Icon(Icons.add_a_photo,
                                          color: Colors.green,
                                          size: 45),
                                      Text('Pick a Logo')
                                    ]
                                ),
                              ),
                            ),
                          // if (_image != null)
                          //   Positioned(
                          //     top: 70,
                          //     left: -20,
                          //     child: InkWell(
                          //       onTap: _removeImage,
                          //       child: const Icon(
                          //         Icons.delete,
                          //         color: Colors.red,
                          //         size: 45,
                          //       ),
                          //     ),
                          //   ),
                          if (_image != null)
                            Positioned(
                              left: isTablet ? 69 : 40,
                              bottom: 5,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                    alignment: Alignment.center,
                                    width: isTablet ? 60 : 40,
                                    height: isTablet ? 60 : 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromRGBO(
                                          19, 144, 245, 1),
                                      border: Border.all(
                                          color: const Color.fromRGBO(
                                              19, 144, 245, 1)
                                      ),
                                    ),
                                    child: isTablet ? const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 38,
                                    ) : const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 23,
                                    )
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  componentUtil.buildResponsiveWidget(
                      Column(
                          children: [
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Business Name:*"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Business Name',
                                      controller: businessNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please specify your business name.';
                                        }
                                        return null;
                                        },
                                      onChanged: (value) => widget.updateFormData('name', value)
                                  ),
                                ]
                            ),
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Website:"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Website',
                                      onChanged: (value) =>
                                          widget.updateFormData('website', value),
                                      controller: businessWebsiteController
                                  )
                                ]
                            )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16),
                  componentUtil.buildResponsiveWidget(
                      Column(
                          children: [
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Start Date:"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Start Date',
                                      isReadOnly: true,
                                      controller: businessStartdateController,
                                      suffixIcon: const Icon(
                                          Icons.calendar_month, size: 24),
                                      onChanged: (value) =>
                                          widget.updateFormData('start_date', value),
                                      onTap: selectStartDate
                                  )
                                ]
                            ),
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Currency:*"),
                                  componentUtil.ddSearch<Currency>(
                                    selectedItem: selectedCurrency,
                                    items: currencies,
                                    hintText: 'Select a currency',
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Select a currency';
                                      }
                                      return null; // No error
                                    },
                                    onChanged: (e) {
                                      setState(() {
                                        widget.updateFormData('currency_id', e?.value);
                                      });

                                      widget.getFormData('currency_id');

                                      FocusScope.of(context).requestFocus(bcnTextField);
                                    },
                                  )
                                ]
                            )
                            // DropdownButtonFormField<Currency>(
                            //   value: selectedCurrency,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Select a currency',
                            //     border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.all(
                            //             Radius.circular(
                            //                 4.0))
                            //     ),
                            //   ),
                            //   validator: (value) {
                            //     if (value == null) {
                            //       return 'Select a currency';
                            //     }
                            //     return null; // No error
                            //   },
                            //   items: currencyLabels.map((item) {
                            //     return DropdownMenuItem<Currency>(
                            //       value: item,
                            //       child: Text(item.label),
                            //     );
                            //   }).toList(),
                            //   onChanged: (Currency? value) {
                            //     setState(() {
                            //       widget.updateFormData(
                            //           'currency_id', value?.value);
                            //     });
                            //   },
                            // )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  componentUtil.buildResponsiveWidget(
                      Column(
                          children: [
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Business contact number:"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Business contact number',
                                      focusNode: bcnTextField,
                                      onChanged: (value) =>
                                          widget.updateFormData('mobile', value),
                                      controller: businessContactController
                                  )
                                ]
                            ),
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Alternate contact number:"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Alternate contact number',
                                      onChanged: (value) =>
                                          widget.updateFormData('alternate_number', value),
                                      controller: businessAltContactController
                                  )
                                ]
                            )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  componentUtil.buildResponsiveWidget(
                      Column(
                          children: [
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Country:*"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Country',
                                      onChanged: (value) =>
                                          widget.updateFormData('country', value),
                                      controller: businessCountryController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      })
                                ]
                            ),
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "State:*"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'State',
                                      onChanged: (value) =>
                                          widget.updateFormData('state', value),
                                      controller: businessStateController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      })
                                ]
                            )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  componentUtil.buildResponsiveWidget(
                      Column(
                          children: [
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "City:*"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'City',
                                      onChanged: (value) =>
                                          widget.updateFormData('city', value),
                                      controller: businessCityController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      })
                                ]
                            ),
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Zip Code:*"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Zip Code',
                                      onChanged: (value) =>
                                          widget.updateFormData('zip_code', value),
                                      controller: businessZipcodeController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      })
                                ]
                            )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16.0),
                  componentUtil.buildResponsiveWidget(
                      Column(
                          children: [
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Landmark:*"),
                                  componentUtil.buildTextFormField(
                                      labelText: 'Landmark',
                                      onChanged: (value) =>
                                          widget.updateFormData('landmark', value),
                                      controller: businessLandmarkController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'This field is required.';
                                        }
                                        return null;
                                      })
                                ]
                            ),
                            Column(
                                children: [
                                  componentUtil.textWithBM(text: "Time zone:*"),
                                  componentUtil.ddSearch<Timezone>(
                                    selectedItem: selectedTimezone,
                                    items: timezones,
                                    hintText: 'Select a Time Zone',
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Select a Time Zone';
                                      }
                                      return null; // No error
                                    },
                                    onChanged: (e) {
                                      setState(() {
                                        widget.updateFormData('time_zone', e?.value);
                                      });
                                      widget.focusNexButton();
                                    },
                                  )
                                ]
                            )
                            // DropdownButtonFormField<Timezone>(
                            //     value: selectedTimezone,
                            //     decoration: const InputDecoration(
                            //       labelText: 'Select a Time zone',
                            //       border: OutlineInputBorder(
                            //           borderRadius: BorderRadius.all(
                            //               Radius.circular(
                            //                   4.0))
                            //       ),
                            //     ),
                            //     items: timezoneLabel.map((item) {
                            //       return DropdownMenuItem<Timezone>(
                            //         value: item,
                            //         child: Text(item.name),
                            //       );
                            //     }).toList(),
                            //     onChanged: (Timezone? value) {
                            //       setState(() {
                            //         widget.updateFormData(
                            //             'time_zone', value?.value);
                            //       }
                            //       );
                            //     }
                            // )
                          ]
                      ),
                      context
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
    );
  }
}
