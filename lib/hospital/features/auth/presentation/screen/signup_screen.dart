import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;

import '../../../../../services/constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/images.dart';
import '../../../../core/network/network_helper.dart';
import '../../../../core/widgets/my_button.dart';
import '../../../../core/widgets/my_text_field.dart';
import 'login_screen.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late double width;
  late double height;
  bool visible = false;
  bool _loading = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<http.Response> _register() async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData({
      'full_name': _nameController.text,
      'username': _usernameController.text,
      'email': _emailController.text,
      'contact': _contactController.text,
      'address': _addressController.text,
      'password': _passwordController.text
    }, AppConstants.hospitalRegisterUserPhp);

    print(jsonDecode(response.body));

    setState(() {
      _loading = false;
    });

    return response;
  }

  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = new RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Email address is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

    String? validateMobile(String? value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);

    if (value == null || value.length == 0) {
      return 'Mobile number is required';
    }
    else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'REGISTER',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          SvgPicture.asset(
                            signup_image,
                            height: width * 0.40,
                          ),
                          const SizedBox(height: 8),

                          // full name
                          MyTextField(
                            controller: _nameController,
                            hint: "Name",
                            // icon: FlutterIcons.account_card_details_mco,
                            validation: (val) {
                              if (val == null || val.isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),

                          // username
                          MyTextField(
                            controller: _usernameController,
                            hint: "Username",
                            // icon: FlutterIcons.account_badge_horizontal_mco,
                            validation: (val) {
                              if (val == null || val.isEmpty) {
                                return "Username is required";
                              }
                              return null;
                            },
                          ),

                          // email
                          MyTextField(
                            controller: _emailController,
                            hint: "Email",
                            isEmail: true,
                            icon: Icons.contact_mail,
                            validation: (val) {
                              return validateEmail(val);
                            },
                          ),

                          // contact
                          MyTextField(
                            controller: _contactController,
                            hint: "Contact",
                            isNumber: true,
                            maxLength: 10,
                            icon: Icons.contact_phone,
                            validation: (val) {
                              return validateMobile(val);
                            },
                          ),

                          // address
                          MyTextField(
                            controller: _addressController,
                            hint: "Address",
                            isMultiline: true,
                            maxLines: 3,
                            // icon: FlutterIcons.location_city_mdi,
                            validation: (val) {
                              if (val == null || val.isEmpty) {
                                return "Address is required";
                              }
                              return null;
                            },
                          ),

                          // password
                          MyTextField(
                            controller: _passwordController,
                            hint: "Password",
                            isPassword: true,
                            isSecure: true,
                            // icon: FlutterIcons.account_key_mco,
                            validation: (val) {
                              if (val == null || val.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),

                          // login button
                          GestureDetector(
                            onTap: () {

                            },
                            child: MyButton(
                              text: 'SIGNUP',
                              btnColor: primaryColor,
                              btnRadius: 8,
                            ),
                          ),

                          // link to sign up page
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(
                                    color: primaryColor, fontSize: 13),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LoginPage()));
                                },
                                child: Text(
                                  'Log in',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
