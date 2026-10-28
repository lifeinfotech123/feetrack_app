import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/route/route_constants.dart';

import '../../views/screens/auth_screens/login/login_screen.dart';
import '../../views/screens/auth_screens/signup_screen.dart';
import '../../views/screens/dashboard/profile/profile_screen/profile_screen.dart';
import '../../views/screens/dashboard/wallet_screen/wallet_screen.dart';
import '../entry_point.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../screens/address/presentation/views/addresses_screen.dart';
import '../screens/address/presentation/views/add_new_address_screen.dart';
import '../screens/auth/views/password_recovery_screen.dart';
import '../screens/bookmark/views/bookmark_screen.dart';
import '../screens/checkout/views/cart_screen.dart';
import '../screens/checkout/views/payment_method_screen.dart';
import '../screens/checkout/views/thanks_for_order_screen.dart';
import '../screens/discover/views/discover_screen.dart';
import '../screens/product/views/category_products_screen.dart';
import '../screens/coupon/views/coupon_screen.dart';
import '../screens/home/views/brand_detail_screen.dart';
import '../screens/home/views/home_screen.dart';
import '../screens/instant_delivery/Presention/screen/instant_product_.dart';
import '../screens/kids/views/kids_screen.dart';
import '../screens/notification/view/enable_notification_screen.dart';
import '../screens/notification/view/no_notification_screen.dart';
import '../screens/notification/view/notification_ontions_screen.dart';
import '../screens/notification/view/notificatios_screen.dart';
import '../screens/on_sale/views/on_sale_screen.dart';
import '../models/order_model.dart';
import '../screens/onbording/views/onbording_screnn.dart';
import '../screens/order/views/orders_screen.dart';
import '../screens/order/views/order_details_screen.dart';
import '../screens/preferences/views/preferences_screen.dart';
import '../screens/product/views/product_details_screen.dart';
import '../models/restaurant_model.dart';
import '../screens/restaurant/views/restaurant_detail_screen.dart';
import '../screens/restaurant/views/dining/my_table_bookings_screen.dart';
import '../screens/restaurant/views/dining/booking_confirm_screen.dart';
import '../screens/restaurant/views/dining/table_selection_screen.dart';
import '../screens/restaurant/views/dining/table_booking_screen.dart';
import '../screens/restaurant/views/restaurant_table_list_screen.dart';
import '../screens/reviews/view/product_reviews_screen.dart';
import '../screens/search/views/search_screen.dart';
import '../screens/user_info/views/user_info_screen.dart';
import '../screens/wallet/views/empty_wallet_screen.dart';

// ℹ️ All the comments screen are included in the full template
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    // case preferredLanuageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const PreferredLanguageScreen(),
    //   );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    // case profileSetupScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ProfileSetupScreen(),
    //   );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );

    case productDetailsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          if (settings.arguments is ProductModel) {
            return ProductDetailsScreen(
              product: settings.arguments as ProductModel,
              isProductAvailable: true,
            );
          } else if (settings.arguments is bool) {
            return ProductDetailsScreen(
              isProductAvailable: settings.arguments as bool,
            );
          }
          return const ProductDetailsScreen();
        },
      );
    case productReviewsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ProductReviewsScreen(),
      );

    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case brandScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          if (settings.arguments is String) {
            return BrandDetailScreen(
              brandSlug: settings.arguments as String,
            );
          }
          return const BrandDetailScreen();
        },
      );
    case discoverScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const DiscoverScreen(),
      );
    case categoryProductsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          if (settings.arguments is CategoryModel) {
            final cat = settings.arguments as CategoryModel;
            return CategoryProductsScreen(
              category: cat,
              categoryTitle: cat.name,
              categoryImage: cat.icon,
            );
          } else if (settings.arguments is Map<String, dynamic>) {
            final args = settings.arguments as Map<String, dynamic>;
            return CategoryProductsScreen(
              category: args['category'] as CategoryModel?,
              categoryTitle: args['title'] as String?,
              categorySlug: args['slug'] as String?,
              categoryId: args['id'] as int?,
              categoryImage: args['image'] as String?,
              categoryType: args['categoryType'] as String?,
            );
          } else if (settings.arguments is String) {
            return CategoryProductsScreen(
              categoryTitle: settings.arguments as String,
            );
          }
          return const CategoryProductsScreen();
        },
      );

    case onSaleScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnSaleScreen(),
      );
    case kidsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const KidsScreen(),
      );
    case searchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      );

    case bookmarkScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const BookmarkScreen(),
      );
    case instantDeliveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const InstantProduct(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );

    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );

    case notificationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      );
    case noNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NoNotificationScreen(),
      );
    case enableNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EnableNotificationScreen(),
      );
    case notificationOptionsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationOptionsScreen(),
      );

    case addressesScreenRoute:
      final selectAndReturn =
          settings.arguments is bool ? (settings.arguments as bool) : false;
      return MaterialPageRoute(
        builder: (context) => AddressesScreen(selectAndReturn: selectAndReturn),
      );
    case addNewAddressesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AddNewAddressScreen(),
      );
    case ordersScreenRoute:
      final filter =
          settings.arguments is String ? settings.arguments as String : null;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => OrdersScreen(initialFilter: filter),
      );
    case orderDetailsScreenRoute:
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OrderDetailsScreen(
            orderId: args['orderId'] as int,
            storeDomain: args['storeDomain'] as String? ??
                (args['initialOrder'] as OrderListItemModel?)?.domain,
            initialOrder: args['initialOrder'] as OrderListItemModel?,
          ),
        );
      } else if (settings.arguments is int) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OrderDetailsScreen(
            orderId: settings.arguments as int,
          ),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OrdersScreen(),
      );
    // case cancleOrderScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CancleOrderScreen(),
    //   );
    // case deliveredOrdersScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DelivereOrdersdScreen(),
    //   );
    // case cancledOrdersScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CancledOrdersScreen(),
    //   );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );

    case emptyWalletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EmptyWalletScreen(),
      );
    case walletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      );
    case cartScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CartScreen(),
      );
    case couponScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CouponScreen(),
      );
    case paymentMethodScreenRoute:
      final args = settings.arguments;
      if (args is Map<String, dynamic>) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PaymentMethodScreen(
            storeDomain: args['storeDomain'] as String?,
            addressId: args['addressId'] as int?,
          ),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const PaymentMethodScreen(),
      );
    case thanksForOrderScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ThanksForOrderScreen(),
      );
    case restaurantDetailsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          if (settings.arguments is RestaurantModel) {
            final model = settings.arguments as RestaurantModel;
            return RestaurantDetailScreen(
              restaurantId: model.id,
              initialRestaurant: model,
            );
          } else if (settings.arguments is int) {
            return RestaurantDetailScreen(
              restaurantId: settings.arguments as int,
            );
          }
          return const RestaurantDetailScreen(restaurantId: 28);
        },
      );

    case restaurantTableListScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => RestaurantTableListScreen(
          domain: settings.arguments is String ? settings.arguments as String : 'e-team-12',
        ),
      );
    case tableBookingScreenRoute:
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => TableBookingScreen(
            restaurant: args['restaurant'],
            domain: args['domain'] ?? 'e-team-12',
            shopId: args['shopId'] ?? args['restaurant']?.shopId ?? args['restaurant']?.id,
          ),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const RestaurantTableListScreen(),
      );
    case myTableBookingsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => MyTableBookingsScreen(
          domain: settings.arguments is String ? settings.arguments as String : 'e-team-12',
        ),
      );

    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const OnBordingScreen(),
      );
  }
}
