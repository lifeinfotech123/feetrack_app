import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class KycDetailsScreen extends StatefulWidget {
  const KycDetailsScreen({super.key});

  @override
  State<KycDetailsScreen> createState() => _KycDetailsScreenState();
}

class _KycDetailsScreenState extends State<KycDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<KycController>().getKycProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "KYC Details",
          style: Helper(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: GetBuilder<KycController>(builder: (kycController) {
        if (kycController.isLoading && kycController.kycProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kycController.kycProfile != null) ...[
                _buildStatusBanner(kycController.kycProfile!.status,
                    kycController.kycProfile!.rejectionReason),
                sizedBoxHeight(height: 16),
                Text(
                  "Uploaded Documents",
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: primaryText1,
                      ),
                ),
                sizedBoxHeight(height: 16),
                _buildImageSection(
                    "Live Photo", kycController.kycProfile!.livePhoto),
                _buildImageSection(
                    "Aadhaar Front", kycController.kycProfile!.aadhaarFront),
                _buildImageSection(
                    "Aadhaar Back", kycController.kycProfile!.aadhaarBack),
                _buildImageSection(
                    "PAN Front", kycController.kycProfile!.panFront),
                _buildImageSection(
                    "PAN Back", kycController.kycProfile!.panBack),
                _buildImageSection(
                    "Bank Statement", kycController.kycProfile!.bankStatement),
                _buildImageSection(
                    "Passport Front", kycController.kycProfile!.passportFront),
                _buildImageSection(
                    "Passport Back", kycController.kycProfile!.passportBack),
                _buildImageSection("Driving License Front",
                    kycController.kycProfile!.drivingLicenseFront),
                _buildImageSection("Driving License Back",
                    kycController.kycProfile!.drivingLicenseBack),
              ] else if (!kycController.isLoading)
                const Center(child: Text("No KYC data found")),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImageSection(String label, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Helper(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
        sizedBoxHeight(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyLight2.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImage(
              path: imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        sizedBoxHeight(height: 24),
      ],
    );
  }

  Widget _buildStatusBanner(String? status, String? reason) {
    Color bannerColor;
    IconData icon;
    String statusText;

    switch (status?.toLowerCase()) {
      case 'approved':
        bannerColor = Colors.green;
        icon = Icons.check_circle;
        statusText = "KYC Approved";
        break;
      case 'pending':
        bannerColor = Colors.orange;
        icon = Icons.hourglass_empty;
        statusText = "KYC Pending Review";
        break;
      case 'rejected':
        bannerColor = Colors.red;
        icon = Icons.error;
        statusText = "KYC Rejected";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      // margin: const EdgeInsets.bottom(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: bannerColor),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: TextStyle(
                  color: bannerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (status?.toLowerCase() == 'rejected' && reason != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 36),
              child: Text(
                "Reason: $reason",
                style: TextStyle(color: bannerColor, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
