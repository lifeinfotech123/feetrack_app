import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../generated/assets.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key, required this.skip, this.remark = ''});

  final bool skip;
  final String remark;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.white,
      child: IntrinsicHeight(
        child: SizedBox(
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image(
                    image: const AssetImage(Assets.imagesLogo),
                    height: size.height * 0.16,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Update App",
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.grey[900]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  remark,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(fontSize: 12.0, fontWeight: FontWeight.w700, color: Colors.grey[800]),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (skip)
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          height: 40,
                          width: size.width * 0.3,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: Text(
                              'Later',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (skip)
                      const SizedBox(
                        width: 10,
                      ),
                    InkWell(
                      onTap: () async {
                        //

                        // if (GetPlatform.isAndroid) {
                        //   //TODO: CHANGE ANDROID LINK
                        //   final appDownloadLink = Get.find<AuthController>().getAppLinkAndAppVersion('app_download_link');
                        //   log('$appDownloadLink');
                        //   if (appDownloadLink != null) {
                        //     ExtraMethods.launchInBrowser(appDownloadLink);
                        //   }
                        // } else {
                        //   //TODO: CHANGE IOS LINK
                        //   final iosDownloadLink = Get.find<AuthController>().getAppLinkAndAppVersion('ios_app_download_link');
                        //   log('$iosDownloadLink');
                        //   if (iosDownloadLink != null) {
                        //     ExtraMethods.launchInBrowser(iosDownloadLink);
                        //   }
                        // }
                      },
                      child: Container(
                        height: 40,
                        width: size.width * 0.3,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                        child: const Center(
                          child: Text(
                            'Update Now',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
