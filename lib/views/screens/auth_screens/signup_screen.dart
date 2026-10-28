import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../services/constants.dart';
import '../../../services/theme.dart';
import '../../base/common_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  title: 'What\'s your name?',
                  controller: _nameController,
                  hintText: 'What\'s your name?',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  title: "Email",
                  controller: _emailController,
                  hintText: 'Enter your Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  title: "Mobile Number",
                  controller: _mobileController,
                  hintText: 'Enter your Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (value.length != 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: AppConstants.screenPadding,
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  elevation: 0,
                  radius: 45,
                  color: primaryColor,
                  onTap: () {
                    if (!_formKey.currentState!.validate()) return;

                    Get.find<DashBoardController>().dashPage = 0;
                    // Get.find<AuthController>().signUp(
                    //   name: _nameController.text,
                    //   email: _emailController.text,
                    //   mobile: _mobileController.text,
                    // ).then((value) {
                    //   if (value.isSuccess) {
                    //     // Todo: GetProfile...
                    //     Navigator.pushAndRemoveUntil(
                    //       context,
                    //       getCustomRoute(child: const DashboardScreen()),
                    //           (route) => false,
                    //     );
                    //   }
                    // });
                  },
                  child: const Icon(
                    Icons.arrow_forward_outlined,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String title,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black26),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }
}
