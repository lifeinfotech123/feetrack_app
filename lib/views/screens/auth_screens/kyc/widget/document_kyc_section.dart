import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/auth_screens/kyc/widget/upload_doc_kyc.dart';

class DocumentUpdateKycSection extends StatelessWidget {
  const DocumentUpdateKycSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(builder: (kycController) {
      final uploadDocKycModelListItems =
          uploadDocKycModelList(kycController: kycController, context: context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Document Uploads",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800, fontSize: 24, color: primaryText1),
          ),
          sizedBoxHeight(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final model = uploadDocKycModelListItems[index];
              return UploadDocumentForKey(
                uploadDocKycModel: model,
                isApproved: kycController.kycProfile?.status?.toLowerCase() ==
                    'approved',
              );
            },
            separatorBuilder: (_, __) => sizedBoxHeight(height: 30),
            itemCount: uploadDocKycModelListItems.length,
          ),
          sizedBoxHeight(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primaryText1.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: primaryText1,
                ),
                sizedBoxWidth(width: 12),
                Expanded(
                  child: Text(
                    "By submitting, you agree to feetract Privacy Policy and consent to identity verification through approved government partners.",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: greyText2),
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}
