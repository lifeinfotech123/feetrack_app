import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vlr/ecomerce/models/banner_model.dart';
import '../../../../components/Banner/M/banner_m.dart';
import '../../../../components/skleton/banner/banner_m_skelton.dart';
import '../../../../constants.dart';
import '../../../../controllers/banner_controller.dart';
import '../../../../controllers/store_controller.dart';
import '../../../../models/product_model.dart';
import '../../../../models/store_model.dart';
import '../../../../route/app_text_constants.dart';
import '../../../store/views/store_detail_screen.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({super.key});

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  Timer? _timer;
  late final BannerController _bannerController;
  late final StoreController _storeController;

  @override
  void initState() {
    super.initState();
    _bannerController = Get.put(BannerController());
    _storeController = Get.put(StoreController());
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      final count = _getItemCount();
      if (count <= 1) return;

      if (_selectedIndex < count - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _selectedIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  List<StoreModel> _getStoresWithBanners() {
    return _storeController.stores
        .where((s) => s.banner != null && s.banner!.isNotEmpty)
        .toList();
  }

  int _getItemCount() {
    if (_bannerController.mainBanners.isNotEmpty) {
      return _bannerController.mainBanners.length;
    }
    final storeBanners = _getStoresWithBanners();
    return storeBanners.length;
  }

  Widget _buildApiBanner(BuildContext context, BannerModel banner) {
    return BannerM(
      image: banner.image,
      press: () {
        if (banner.resourceType == 'product' && banner.resource != null) {
          final productModel = ProductModel(
            image: banner.resource!.thumbnail ?? banner.image,
            brandName: banner.title ?? "Featured",
            title: banner.resource!.name ?? "Product",
            price: banner.resource!.price ?? 0,
          );
          Navigator.pushNamed(
            context,
            productDetailsScreenRoute,
            arguments: productModel,
          );
        } else if (banner.resourceSlug != null &&
            banner.resourceSlug!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            brandScreenRoute,
            arguments: banner.resourceSlug,
          );
        } else {
          Navigator.pushNamed(context, onSaleScreenRoute);
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              if (banner.title != null && banner.title!.isNotEmpty) ...[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    banner.title!,
                    style: const TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else if (banner.resource?.name != null) ...[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    banner.resource!.name!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: grandisExtendedFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                banner.buttonText ?? "Shop now",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 64,
                child: Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoreBanner(BuildContext context, StoreModel store) {
    return BannerM(
      image: store.banner!,
      press: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailScreen(store: store),
          ),
        );
      },
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "OFFICIAL STORE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                store.name,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Visit Store",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(
                width: 50,
                child: Divider(
                  color: Colors.white,
                  thickness: 1.5,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_bannerController.isMainLoading.value) {
        return const BannerMSkelton();
      }

      final hasApiBanners = _bannerController.mainBanners.isNotEmpty;
      final storeBanners = _getStoresWithBanners();

      final itemCount =
          hasApiBanners ? _bannerController.mainBanners.length : storeBanners.length;

      if (itemCount == 0) {
        return const SizedBox.shrink();
      }

      return AspectRatio(
        aspectRatio: 2.0,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: itemCount,
              onPageChanged: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (hasApiBanners) {
                  return _buildApiBanner(
                      context, _bannerController.mainBanners[index]);
                }
                return _buildStoreBanner(context, storeBanners[index]);
              },
            ),
            if (itemCount > 1)
              Positioned(
                bottom: defaultPadding * 0.7,
                right: defaultPadding * 1.8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      itemCount,
                      (index) {
                        final isSelected = index == _selectedIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          height: 5,
                          width: isSelected ? 18 : 5,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
