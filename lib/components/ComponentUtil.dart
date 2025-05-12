
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComponentUtil {
  TextFormField buildTextFormField({
    Key? key,
    TextEditingController? controller,
    bool isPassword = false,
    String labelText = '',
    bool filled = false,
    Color? fillColor,
    Icon? suffixIcon,
    OutlineInputBorder? outlineInputBorder,
    int? maxLines,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    void Function()? onTap,
    bool isReadOnly = false,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      key: key,
      style: const TextStyle(fontSize: 16),
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        // labelText: labelText,
        hintText: labelText,
        filled: filled,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
        enabledBorder: outlineInputBorder ?? OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0XFFD0D5DD), width: 1),
          borderRadius: BorderRadius.circular(8.0)
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        isDense: true
      ),
      maxLines: maxLines ?? 1,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      readOnly: isReadOnly,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  OutlinedButton buildOutlinedButton({
    Function()? onPressed,
    FocusNode? focusNode,
    ButtonStyle? style,
    EdgeInsetsGeometry? padding,
    Size? fixedSize,
    TextStyle? textStyle,
    Color? foregroundColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    Color? backgroundColor,
    Widget? leftIcon,
    required Widget buttonContent,
    Widget? rightIcon
  }) {
    return OutlinedButton(
        onPressed: onPressed,
        focusNode: focusNode,
        style: style ?? ElevatedButton.styleFrom(
            padding: padding ?? const EdgeInsets.all(0),
            fixedSize: fixedSize ?? const Size(200, 36),
            textStyle: textStyle ?? const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
            foregroundColor: foregroundColor ?? Colors.white,
            shadowColor: shadowColor ?? Colors.yellow,
            shape: shape ?? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                    color: Color(0xFF16A085),
                    width: 1
                )
            ),
            backgroundColor: backgroundColor ?? const Color(0xFF16A085)
        ),
        child: buttonContent
    );
  }

  Widget textWithBM({required String text, double fontSize = 14, FontWeight fontWeight = FontWeight.w500, double marginBottom = 8}){
    return Column(children: [
      Align(alignment: Alignment.centerLeft, child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight))),
      SizedBox(height: marginBottom),
    ]);
  }

  Widget buildCLFormField({
    TextEditingController? controller,
    void Function(String)? onTBChanged,
    void Function(String)? onDPChanged,
    void Function(int?)? onDDChanged,
    String? Function(String?)? validator,
    void Function()? onDPTap,
    void Function()? onTBTap,
    dynamic dataObj
  }) {

    if (dataObj["label_data"]["type"] == "dropdown") {

      String input = dataObj["label_data"]["dropdown_options"];

      List<String> result = input.split("\r\n");
      int selectedVal = 0;
      try {
        selectedVal = int.parse(dataObj["label_data"]['value'] ?? "0");
      }catch(e){}

      return DropdownButtonFormField<int>(
          value: selectedVal,
          decoration: InputDecoration(
            labelText: dataObj["label_text"],
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius
                        .circular(4.0)
                )
            ),
          ),
          items: List.generate(result.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(result[index]),
            );
          }).toList(),
          onChanged: onDDChanged
      );

    }

    if (dataObj["label_data"]["type"] == "date") {

      return ComponentUtil().buildTextFormField(
          labelText: 'Start Date',
          isReadOnly: true,
          controller: controller,
          suffixIcon: const Icon(
              Icons.calendar_month, size: 40),
          onChanged: onDPChanged,
          onTap: onDPTap
      );

    }

    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
          border: OutlineInputBorder()
      ),
      onChanged: onTBChanged,
      validator: validator,
      onTap: onTBTap,
    );

  }

  TextFormField buildTextFormFieldForPassword({
    Key? key,
    TextEditingController? controller,
    String labelText = '',
    bool isPassword = false,
    bool isReadOnly = false,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    void Function()? onTap,
    Icon? suffixIcon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool filled = false,
    Color? fillColor,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        filled: filled,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      readOnly: isReadOnly,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  Widget getTopBox(int currentScreen, int boxIndex, String text){
    return Container(
      width: 266,
      height: 60,
      decoration: BoxDecoration(
        color: (currentScreen == boxIndex ? const Color.fromRGBO(33, 132, 190, 1) : const Color.fromRGBO(200, 200, 200, 1)),
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 15, right: 0, bottom: 15),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18,color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget getTopBoxes(int currentScreen, bool isTablet) {
    if (isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getTopBox(currentScreen, 1, "1. Business"),
          const SizedBox(width: 16),
          getTopBox(currentScreen, 2, "2. Business Settings"),
          const SizedBox(width: 16.0),
          getTopBox(currentScreen, 3, "3. Owner")
        ],
      );
    }else {
      return Column(
        children: [
          if(currentScreen == 1)
            getTopBox(currentScreen, 1, "1. Business"),
          if(currentScreen == 2)
            getTopBox(currentScreen, 2, "2. Business Settings"),
          if (currentScreen == 3)
            getTopBox(currentScreen, 3, "3. Owner")
        ],
      );
    }
  }

  Widget ddSearch<T>({
    T? selectedItem,
    required List<T> items,
    String hintText = '',
    String? labelText,
    OutlineInputBorder? outlineInputBorder,
    String? Function(T?)? validator,
    Function(T?)? onChanged
  }){
    return DropdownSearch<T>(
      popupProps: const PopupProps.menu(
          showSearchBox: true,
      ),
      selectedItem: selectedItem,
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(4.0)
              )
          ),
          enabledBorder: outlineInputBorder ?? OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFFD0D5DD), width: 1),
              borderRadius: BorderRadius.circular(8.0)
          ),
          // constraints: const BoxConstraints(maxHeight: 44),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
      validator: validator,
      onChanged: onChanged
    );
  }

  Widget ddButtonFormField<T>({
    T? selectedItem,
    required List<DropdownMenuItem<T>>? items,
    String hintText = '',
    String? labelText,
    OutlineInputBorder? outlineInputBorder,
    String? Function(T?)? validator,
    Function(T?)? onChanged
  }){
    return DropdownButtonFormField<T>(
        value: selectedItem,
        items: items,
        decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(4.0)
                )
            ),
            enabledBorder: outlineInputBorder ?? OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0XFFD0D5DD), width: 1),
                borderRadius: BorderRadius.circular(8.0)
            ),
            // constraints: const BoxConstraints(maxHeight: 44),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        validator: validator,
        onChanged: onChanged
    );
  }

  Widget buildResponsiveWidget(Widget widget, BuildContext context) {
    bool tabletScreen = MediaQuery.of(context).size.shortestSide > 600;
    List<Widget> widgets = getWidgets(tabletScreen, (widget as Column).children, context);

    if (tabletScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgets,
      );
    } else {
      return Column(
        children: widgets,
      );
    }
  }

  List<Widget> getWidgets(bool tabletScreen, List<Widget> widgets, BuildContext context){
    List<Widget> widgetsList = [];

    for (int i = 0; i < widgets.length; i++) {
      widgetsList.add(
          tabletScreen ?
          Flexible(
            flex: 1,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: widgets[i],
            ),
          ): widgets[i]
      );

      if (i < widgets.length - 1) {
        widgetsList.add( tabletScreen ? const SizedBox(width: 16) : const SizedBox(height: 16));
      }
    }

    return widgetsList;
  }

  @override
  Widget getBulletPoint(String text, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 10.0,
          height: 10.0,
          margin: (isTablet ? const EdgeInsets.only(top: 9.0) : const EdgeInsets.only(top: 6.0)),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10.0),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: (isTablet ? const TextStyle(fontSize: 20, color: Colors.white) : const TextStyle(color: Colors.white)),
                // overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}