import 'package:flutter/cupertino.dart';
import 'package:gs_erp/components/ComponentUtil.dart';

class RegistrationScreenThree extends StatefulWidget {
  final Function updateFormData;
  final Function getFormData;
  final Function updateLoading;

  const RegistrationScreenThree({super.key, required this.updateFormData, required this.getFormData, required this.updateLoading});

  @override
  RegistrationScreenThreeState createState() => RegistrationScreenThreeState();
}

class RegistrationScreenThreeState extends State<RegistrationScreenThree> {

  final TextEditingController surname = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController userName = TextEditingController();
  final TextEditingController userEmail = TextEditingController();
  final TextEditingController userPassword = TextEditingController();
  final TextEditingController userConfirmPassword = TextEditingController();
  late ComponentUtil componentUtil;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeForm();
    });

    componentUtil = ComponentUtil();

  }

  initializeForm(){
    widget.updateLoading(true);
    surname.text = widget.getFormData('surname') ?? '';
    firstName.text = widget.getFormData('first_name') ?? '';
    lastName.text = widget.getFormData('last_name') ?? '';
    userName.text = widget.getFormData('username') ?? '';
    userEmail.text = widget.getFormData('email') ?? '';
    userPassword.text = widget.getFormData('password') ?? '';
    userConfirmPassword.text = widget.getFormData('password_again') ?? '';
    widget.updateLoading(false);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              componentUtil.buildResponsiveWidget(
                  Column(
                      children: [
                        componentUtil.buildTextFormField(
                            labelText: 'Prefix (Mr / Mrs / Miss)',
                            onChanged: (value) =>
                                widget.updateFormData('surname', value),
                            controller: surname),
                        componentUtil.buildTextFormField(
                            labelText: 'First Name',
                            onChanged: (value) =>
                                widget.updateFormData('first_name', value),
                            controller: firstName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            }),
                        componentUtil.buildTextFormField(
                            labelText: 'Last Name',
                            onChanged: (value) =>
                                widget.updateFormData('last_name', value),
                            controller: lastName)
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              componentUtil.buildResponsiveWidget(
                  Column(
                      children: [
                        componentUtil.buildTextFormField(
                            labelText: 'Username',
                            onChanged: (value) =>
                                widget.updateFormData('username', value),
                            controller: userName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            }),
                        componentUtil.buildTextFormField(
                            labelText: 'Email',
                            onChanged: (value) =>
                                widget.updateFormData('email', value),
                            controller: userEmail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            })
                      ]
                  ),
                  context
              ),
              const SizedBox(height: 16),
              componentUtil.buildResponsiveWidget(
                  Column(
                      children: [
                        componentUtil.buildTextFormField(
                            labelText: 'Password',
                            onChanged: (value) =>
                                widget.updateFormData('password', value),
                            controller: userPassword,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            }),
                        componentUtil.buildTextFormField(
                            labelText: 'Confirm Password',
                            onChanged: (value) =>
                                widget.updateFormData('password_again', value),
                            controller: userConfirmPassword,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }else if (userPassword.text != userConfirmPassword.text) {
                                return 'Password Mismatched.';
                              }
                              return null;
                            })
                      ]
                  ),
                  context
              )
            ]),
      ),
    );
  }
}