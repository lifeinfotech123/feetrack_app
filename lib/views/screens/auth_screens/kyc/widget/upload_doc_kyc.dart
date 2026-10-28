import 'package:flutter/material.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/auth_screens/kyc/widget/upload_doc_kyc_button_widget.dart';
import 'package:vlr/controllers/service_controller.dart';
import 'dart:io';

class UploadDocumentForKey extends StatelessWidget {
  final UploadDocKycModel uploadDocKycModel;
  final bool isApproved;
  const UploadDocumentForKey({
    super.key,
    required this.uploadDocKycModel,
    this.isApproved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: greyLight,
      ),
      child: Column(
        children: [
          uploadDocKycModel.isProfile
              ? Column(
                  children: [
                    CustomImage(
                      path: uploadDocKycModel.image,
                      height: 64,
                      width: 64,
                    ),
                    sizedBoxHeight(height: 16),
                    Text(
                      uploadDocKycModel.title,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: blackText1,
                          ),
                    ),
                    sizedBoxHeight(height: 4),
                    Text(
                      uploadDocKycModel.descr ?? "",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: greyText2,
                          ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    CustomImage(
                      path: uploadDocKycModel.image,
                      height: 32,
                      width: 32,
                      fit: BoxFit.cover,
                    ),
                    sizedBoxWidth(width: 12),
                    Text(
                      uploadDocKycModel.title,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: blackText1,
                          ),
                    )
                  ],
                ),
          if (!isApproved) sizedBoxHeight(height: 16),
          if (!isApproved)
            UploadDocKycButtonWidget(
              onTapCameraButton: uploadDocKycModel.onCameraTap,
              onTapGallyButton: uploadDocKycModel.onGalleryTap,
              isProfile: uploadDocKycModel.isProfile,
            ),
          if (uploadDocKycModel.file != null || uploadDocKycModel.remoteUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                uploadDocKycModel.file != null
                    ? "File Selected: ${uploadDocKycModel.file!.path.split('/').last}"
                    : "Document Uploaded",
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class UploadDocKycModel {
  final String title;
  final String? descr;
  final String image;
  final Function()? onGalleryTap;
  final Function()? onCameraTap;
  final bool isProfile;
  final File? file;
  final String? remoteUrl;

  UploadDocKycModel({
    required this.title,
    this.descr,
    this.isProfile = false,
    required this.image,
    required this.onGalleryTap,
    required this.onCameraTap,
    this.file,
    this.remoteUrl,
  });
}

List<UploadDocKycModel> uploadDocKycModelList(
        {required KycController kycController, required BuildContext context}) {
  final serviceController = ServiceController();

  Future<void> _pick(String type, ImageSource source) async {
    File? file = await serviceController.pickImage(source, context);
    if (file != null) {
      kycController.setFile(type, file);
    }
  }

  return [
    UploadDocKycModel(
      title: "Live Selfie",
      descr: "Ensure your face is clearly visible in good light",
      image: Assets.imagesProfileKyc,
      onCameraTap: () => _pick('live_photo', ImageSource.camera),
      onGalleryTap: () => _pick('live_photo', ImageSource.gallery),
      isProfile: true,
      file: kycController.livePhoto,
      remoteUrl: kycController.kycProfile?.livePhoto,
    ),
    UploadDocKycModel(
      title: "PAN Card Front",
      image: Assets.imagesPan,
      onCameraTap: () => _pick('pan_front', ImageSource.camera),
      onGalleryTap: () => _pick('pan_front', ImageSource.gallery),
      file: kycController.panFrontImage,
      remoteUrl: kycController.kycProfile?.panFront,
    ),
    UploadDocKycModel(
      title: "PAN Card Back",
      image: Assets.imagesPan,
      onCameraTap: () => _pick('pan_back', ImageSource.camera),
      onGalleryTap: () => _pick('pan_back', ImageSource.gallery),
      file: kycController.panBackImage,
      remoteUrl: kycController.kycProfile?.panBack,
    ),
    UploadDocKycModel(
      title: "Aadhaar Card Front",
      image: Assets.imagesAadhaar,
      onCameraTap: () => _pick('aadhaar_front', ImageSource.camera),
      onGalleryTap: () => _pick('aadhaar_front', ImageSource.gallery),
      file: kycController.aadhaarFrontImage,
      remoteUrl: kycController.kycProfile?.aadhaarFront,
    ),
    UploadDocKycModel(
      title: "Aadhaar Card Back",
      image: Assets.imagesAadhaar,
      onCameraTap: () => _pick('aadhaar_back', ImageSource.camera),
      onGalleryTap: () => _pick('aadhaar_back', ImageSource.gallery),
      file: kycController.aadhaarBackImage,
      remoteUrl: kycController.kycProfile?.aadhaarBack,
    ),
    UploadDocKycModel(
      title: "Bank Statement",
      image: Assets.imagesCashCirlce,
      onCameraTap: () => _pick('bank_statement', ImageSource.camera),
      onGalleryTap: () => _pick('bank_statement', ImageSource.gallery),
      file: kycController.bankStatement,
      remoteUrl: kycController.kycProfile?.bankStatement,
    ),
    UploadDocKycModel(
      title: "Passport Front (Optional)",
      image: Assets.imagesAadhaar,
      onCameraTap: () => _pick('passport_front', ImageSource.camera),
      onGalleryTap: () => _pick('passport_front', ImageSource.gallery),
      file: kycController.passportFrontImage,
      remoteUrl: kycController.kycProfile?.passportFront,
    ),
    UploadDocKycModel(
      title: "Passport Back (Optional)",
      image: Assets.imagesAadhaar,
      onCameraTap: () => _pick('passport_back', ImageSource.camera),
      onGalleryTap: () => _pick('passport_back', ImageSource.gallery),
      file: kycController.passportBackImage,
      remoteUrl: kycController.kycProfile?.passportBack,
    ),
    UploadDocKycModel(
      title: "Driving License Front (Optional)",
      image: Assets.imagesAadhaar,
      onCameraTap: () => _pick('driving_license_front', ImageSource.camera),
      onGalleryTap: () => _pick('driving_license_front', ImageSource.gallery),
      file: kycController.drivingLicenseFrontImage,
      remoteUrl: kycController.kycProfile?.drivingLicenseFront,
    ),
    UploadDocKycModel(
      title: "Driving License Back (Optional)",
      image: Assets.imagesAadhaar,
      onCameraTap: () => _pick('driving_license_back', ImageSource.camera),
      onGalleryTap: () => _pick('driving_license_back', ImageSource.gallery),
      file: kycController.drivingLicenseBackImage,
      remoteUrl: kycController.kycProfile?.drivingLicenseBack,
    ),
  ];
}
