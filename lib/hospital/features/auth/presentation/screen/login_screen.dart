import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:vlr/hospital/features/auth/presentation/screen/signup_screen.dart';
import 'package:vlr/services/constants.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../../views/screens/dashboard/dashboard_screen.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/constants/images.dart';
import '../../../../core/network/network_helper.dart';
import '../../../../core/widgets/my_button.dart';
import '../../../../core/widgets/my_text_field.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double width;
  late double height;
  bool visible = false;
  bool _loading = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<http.Response> _login() async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData({
      'username': _usernameController.text,
      'password': _passwordController.text
    }, AppConstants.hospitalUserLoginPhp);

    print(jsonDecode(response.body));

    setState(() {
      _loading = false;
    });

    return response;
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LOGIN',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          SvgPicture.asset(
                            login_image,
                            height: height * 0.28,
                          ),
                          const SizedBox(height: 16),

                          // username
                          MyTextField(
                            controller: _usernameController,
                            hint: "Username",
                            icon: Icons.person,
                            validation: (val) {
                              if (val == null || val.isEmpty) {
                                return "Username is required";
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
                            icon: Icons.lock,
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
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DashboardScreen(
                                      // username: _usernameController.text,
                                      // userId: "1",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: MyButton(
                              text: 'LOGIN',
                              btnColor: primaryColor,
                              btnRadius: 8,
                            ),
                          ),

                          // link to sign up page
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
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
                                          builder: (BuildContext context) =>
                                              SignUp()));
                                },
                                child: Text(
                                  'Sign up',
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
