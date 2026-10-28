import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/custom_dropdown.dart';
import 'package:vlr/views/widget/text_box/app_text_box.dart';

class AddressInforKycSection extends StatelessWidget {
  const AddressInforKycSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(builder: (kycController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Address Information",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800, fontSize: 24, color: primaryText1),
          ),
          sizedBoxHeight(height: 24),
          AppTextFieldWithHeading(
            controller: kycController.address1Controller,
            borderRadius: 999,
            heading: "ADDRESS LINE 1",
            maxLines: 2,
            hindText: "House No, Building, Area",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your address";
              }
              return null;
            },
          ),
          sizedBoxHeight(height: 24),
          AppTextFieldWithHeading(
            controller: kycController.address2Controller,
            borderRadius: 999,
            heading: "ADDRESS LINE 2",
            maxLines: 2,
            hindText: "Landmark, Locality",
          ),
          sizedBoxHeight(height: 16),
          GetBuilder<BasicController>(builder: (basicController) {
            return Row(
              children: [
                Expanded(
                  child: CustomDropDownList(
                    heading: "STATE",
                    hintText: "State",
                    borderRadius: 999,
                    items: basicController.stateList
                        .map((e) => e.toString())
                        .toList(),
                    value: kycController.state,
                    onChanged: (value) {
                      value = kycController.state;
                      kycController.update();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Select a State";
                      }
                      return null;
                    },
                  ),
                ),
                sizedBoxWidth(width: 16),
                Expanded(
                  child: CustomDropDownList(
                    heading: "CITY",
                    hintText: "City",
                    borderRadius: 999,
                    items: basicController.cityList
                        .map((e) => e.toString())
                        .toList(),
                    value: kycController.city,
                    onChanged: (value) {
                      value = kycController.city;
                      kycController.update();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Select a city";
                      }
                      return null;
                    },
                  ),
                )
              ],
            );
          }),
          sizedBoxHeight(height: 24),
          AppTextFieldWithHeading(
            controller: kycController.pinCodeController,
            borderRadius: 999,
            heading: "PIN CODE",
            hindText: "111 111",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter a pin code";
              }
              if (value.length != 6) {
                return "Enter a valid pin code";
              }
              return null;
            },
          ),
          sizedBoxHeight(height: 40),
        ],
      );
    });
  }
}
