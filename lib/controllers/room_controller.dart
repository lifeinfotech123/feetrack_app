import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/data/models/category_model/package_model.dart';
import 'package:vlr/data/models/rooom/pg_category_model.dart';
import 'package:vlr/data/models/rooom/pg_floor_model.dart';
import 'package:vlr/data/models/rooom/pg_room_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/models/rooom/pg_customer_attendance_model.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/data/models/rooom/pg_customer_invoice_detail_model.dart';
import 'package:vlr/data/repositories/room_repo.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/file_download_helper.dart';

class RoomController extends GetxController implements GetxService {
  final RoomRepo roomRepo;

  RoomController({required this.roomRepo});

  // ── Customer Dashboard, Bookings, Wallet, Profile State ──────────
  bool isCustomerDashboardLoading = false;
  PgCustomerDashboardData? customerDashboardData;

  bool isCustomerBookingsLoading = false;
  List<PgCustomerBookingItem> customerBookingsList = [];
  Map<String, int> customerBookingsTabs = {};
  String activeBookingTab = 'all';

  bool isCustomerBookingDetailsLoading = false;
  PgCustomerBookingItem? selectedCustomerBookingDetails;

  bool isCustomerWalletLoading = false;
  PgCustomerWalletModel? customerWalletData;

  bool isCustomerProfileLoading = false;
  PgCustomerProfileModel? customerProfileData;

  bool isPaymentProcessing = false;
  bool isInvoiceDownloading = false;
  String? downloadingInvoiceId;

  // ── Customer Invoices & Subscriptions State ──────────────────────
  bool isCustomerInvoicesLoading = false;
  List<PgCustomerInvoiceItem> customerInvoicesList = [];
  bool isCustomerInvoiceDetailLoading = false;
  PgCustomerInvoiceDetailData? selectedCustomerInvoiceDetail;

  bool isCustomerSubscriptionsLoading = false;
  List<PgCustomerSubscriptionItem> customerSubscriptionsList = [];
  bool isCustomerSubscriptionDetailLoading = false;
  PgCustomerSubscriptionItem? selectedCustomerSubscription;

  // ── Saved Listings (Favorites) State ─────────────────────────────
  bool isSavedListingsLoading = false;
  List<PgSavedListingItem> savedListingsList = [];
  bool isRemovingSavedListing = false;

  // ── Customer Payments State ──────────────────────────────────────
  bool isCustomerPaymentsLoading = false;
  List<PgPaymentItem> customerPaymentsList = [];

  // ── Action Loading States ─────────────────────────────────────────
  bool isVerifyingOtp = false;
  bool isCancellingBooking = false;
  bool isRechargingWallet = false;
  bool isUpdatingProfile = false;
  bool isPayingInvoice = false;

  // ── Customer Attendance State ────────────────────────────────────
  bool isCustomerAttendanceLoading = false;
  bool isAttendancePunching = false;
  PgCustomerAttendanceData? customerAttendanceData;

  // ── PG Categories State ─────────────────────────────────────────
  bool isCategoriesLoading = false;
  List<PgCategoryModel> pgCategoryList = [];
  PgCategoryModel? selectedCategory;

  // ── PG Listings State ───────────────────────────────────────────
  bool isListingsLoading = false;
  List<ListingModel> pgListingList = [];
  List<ListingModel> filteredListingList = [];
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  // ── PG Listing Details State ─────────────────────────────────────
  bool isDetailsLoading = false;
  ListingModel? selectedListingDetails;

  // ── Floors & Rooms State (api/v1/pg/floors) ──────────────────────
  bool isLoading = false;
  bool isFloorsLoading = false;
  bool isFloorDetailsLoading = false;
  bool isAddFavorite = false;
  List<PgFloorModel> pgFloorModelList = [];
  PgFloorModel? selectedFloor;
  List<PgRoomModel> pgRoomModelList = [];
  PgRoomModel? selectedRoomDetails;

  // ── PG Packages State (api/v1/pg/packages & api/v1/pg/listings/{id}/packages) ───
  bool isPackagesLoading = false;
  List<PackageModel> listingPackagesList = [];
  bool isSinglePackageLoading = false;
  PackageModel? selectedPackageDetails;

  // ── All PG Rooms State (api/v1/pg/rooms) ─────────────────────────
  bool isAllRoomsLoading = false;
  List<PgRoomModel> allRoomsList = [];
  List<PgRoomModel> filteredAllRoomsList = [];
  String roomSearchQuery = "";
  final TextEditingController roomSearchController = TextEditingController();

  // ── Listing Rooms & Room Details Loading ─────────────────────────
  bool isListingRoomsLoading = false;
  bool isSingleRoomLoading = false;

  // ══════════════════════════════════════════════════════════════════
  // 1. FETCH PG CATEGORIES (api/v1/pg/categories)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgCategories() async {
    log("RoomController: fetchPgCategories called");
    isCategoriesLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCategories();
      log("fetchPgCategories status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          pgCategoryList = data
              .map((e) => PgCategoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          log("Fetched ${pgCategoryList.length} PG categories");
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCategories: $e");
    } finally {
      isCategoriesLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SELECT PG CATEGORY (Chip selection)
  // ══════════════════════════════════════════════════════════════════
  Future<void> selectCategory(PgCategoryModel? category) async {
    if (category == null ||
        (selectedCategory != null && selectedCategory?.slug == category.slug)) {
      // Deselect -> show all
      selectedCategory = null;
      for (var c in pgCategoryList) {
        c.isSelected = false;
      }
      await fetchPgListings();
    } else {
      selectedCategory = category;
      for (var c in pgCategoryList) {
        c.isSelected = (c.slug == category.slug);
      }
      if (category.slug != null && category.slug!.isNotEmpty) {
        await fetchPgByType(category.slug!);
      } else {
        await fetchPgListings(category: category.name);
      }
    }
    update();
  }

  // ══════════════════════════════════════════════════════════════════
  // 2. FETCH ALL PG LISTINGS (api/v1/pg/listings)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgListings({
    String? city,
    String? tenant,
    String? search,
    String? category,
    dynamic minPrice,
    dynamic maxPrice,
    dynamic latitude,
    dynamic longitude,
  }) async {
    log("RoomController: fetchPgListings called");
    isListingsLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgListings(
        city: city,
        tenant: tenant,
        search: search,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        latitude: latitude,
        longitude: longitude,
      );

      log("fetchPgListings status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          pgListingList = data
              .map((e) => ListingModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          filteredListingList = List.from(pgListingList);
          log("Fetched ${pgListingList.length} PG listings");

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().listingModelList = pgListingList;
            Get.find<HomeController>().update();
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgListings: $e");
    } finally {
      isListingsLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // 3. FETCH PG LISTINGS BY TYPE / SLUG (api/v1/pg/by-type/{slug})
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgByType(String slug) async {
    log("RoomController: fetchPgByType called for slug '$slug'");
    isListingsLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgByType(slug);
      log("fetchPgByType status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          pgListingList = data
              .map((e) => ListingModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          filteredListingList = List.from(pgListingList);
          log("Fetched ${pgListingList.length} listings for type '$slug'");

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().listingModelList = pgListingList;
            Get.find<HomeController>().update();
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgByType: $e");
    } finally {
      isListingsLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // 4. FETCH PG LISTING DETAILS (api/v1/pg/listings/{id})
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgListingDetails(String id) async {
    log("RoomController: fetchPgListingDetails called for ID '$id'");
    isDetailsLoading = true;
    update();

    try {
      // Also fetch specialized packages & rooms in parallel
      fetchPgListingPackages(id);
      fetchPgListingRooms(id);

      final Response response = await roomRepo.fetchPgListingDetails(id);
      log("fetchPgListingDetails status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final dynamic rawData = response.body['data'];
        if (rawData is Map) {
          selectedListingDetails =
              ListingModel.fromJson(Map<String, dynamic>.from(rawData));

          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().updateSelectListingModel(
              value: selectedListingDetails!,
            );
          }

          // Populate floors if available directly inside data.floors
          if (selectedListingDetails?.floors != null &&
              selectedListingDetails!.floors!.isNotEmpty) {
            pgFloorModelList = List.from(selectedListingDetails!.floors!);
            for (var f in pgFloorModelList) {
              f.isSelect = false;
            }
            pgFloorModelList.first.isSelect = true;

            if (pgFloorModelList.first.rooms != null &&
                pgFloorModelList.first.rooms!.isNotEmpty) {
              pgRoomModelList = List.from(pgFloorModelList.first.rooms!);
              for (var r in pgRoomModelList) {
                r.isSelect = false;
              }
              pgRoomModelList.first.isSelect = true;
              selectedRoomDetails = pgRoomModelList.first;
            }
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgListingDetails: $e");
    } finally {
      isDetailsLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // 5. FETCH PG LISTING PACKAGES (api/v1/pg/listings/{listing_id}/packages)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgListingPackages(String listingId) async {
    log("RoomController: fetchPgListingPackages called for listing '$listingId'");
    isPackagesLoading = true;
    update();

    try {
      final Response response =
          await roomRepo.fetchPgListingPackages(listingId);
      log("fetchPgListingPackages status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          listingPackagesList = data
              .map((e) => PackageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          log("Fetched ${listingPackagesList.length} packages for listing '$listingId'");
        }
      }
    } catch (e) {
      log("ERROR in fetchPgListingPackages: $e");
    } finally {
      isPackagesLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // 6. FETCH SINGLE PG PACKAGE DETAILS (api/v1/pg/packages/{id})
  // ══════════════════════════════════════════════════════════════════
  Future<PackageModel?> fetchPgPackageDetails(String packageId) async {
    log("RoomController: fetchPgPackageDetails called for '$packageId'");
    isSinglePackageLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgPackageDetails(packageId);
      log("fetchPgPackageDetails status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          selectedPackageDetails =
              PackageModel.fromJson(Map<String, dynamic>.from(data));
          log("Fetched package details: ${selectedPackageDetails?.name}");
          return selectedPackageDetails;
        }
      }
    } catch (e) {
      log("ERROR in fetchPgPackageDetails: $e");
    } finally {
      isSinglePackageLoading = false;
      update();
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════════
  // 7. FETCH ALL PG ROOMS (api/v1/pg/rooms)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchAllPgRooms() async {
    log("RoomController: fetchAllPgRooms called");
    isAllRoomsLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchAllPgRooms();
      log("fetchAllPgRooms status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          allRoomsList = data
              .map((e) => PgRoomModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          filteredAllRoomsList = List.from(allRoomsList);
          log("Fetched ${allRoomsList.length} all PG rooms");
        }
      }
    } catch (e) {
      log("ERROR in fetchAllPgRooms: $e");
    } finally {
      isAllRoomsLoading = false;
      update();
    }
  }

  void searchAllRooms(String query) {
    roomSearchQuery = query.trim().toLowerCase();
    if (roomSearchQuery.isEmpty) {
      filteredAllRoomsList = List.from(allRoomsList);
    } else {
      filteredAllRoomsList = allRoomsList.where((room) {
        final roomNo = room.roomNumber?.toLowerCase() ?? "";
        final roomType = room.roomType?.toLowerCase() ?? "";
        final floorName = room.floorName?.toLowerCase() ?? "";
        final listingTitle = room.listing?.title?.toLowerCase() ?? "";
        final city = room.listing?.city?.toLowerCase() ?? "";
        return roomNo.contains(roomSearchQuery) ||
            roomType.contains(roomSearchQuery) ||
            floorName.contains(roomSearchQuery) ||
            listingTitle.contains(roomSearchQuery) ||
            city.contains(roomSearchQuery);
      }).toList();
    }
    update();
  }

  // ══════════════════════════════════════════════════════════════════
  // 8. FETCH ROOMS FOR SPECIFIC LISTING (api/v1/pg/listings/{id}/rooms)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgListingRooms(String listingId) async {
    log("RoomController: fetchPgListingRooms called for listing '$listingId'");
    isListingRoomsLoading = true;
    isLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgListingRooms(listingId);
      log("fetchPgListingRooms status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          pgRoomModelList = data
              .map((e) => PgRoomModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          log("Fetched ${pgRoomModelList.length} rooms for listing '$listingId'");

          // Dynamically build/group floors from rooms if pgFloorModelList is empty
          if (pgRoomModelList.isNotEmpty && pgFloorModelList.isEmpty) {
            final Map<String, List<PgRoomModel>> floorGroup = {};
            final Map<String, String> floorNames = {};

            for (var r in pgRoomModelList) {
              final fId = r.floorId ?? "1";
              floorGroup.putIfAbsent(fId, () => []).add(r);
              if (r.floorName != null) {
                floorNames[fId] = r.floorName!;
              }
            }

            pgFloorModelList = floorGroup.entries.map((entry) {
              final String? fName = floorNames[entry.key];
              String? fNum;
              if (fName != null) {
                if (fName.toLowerCase().contains('ground')) {
                  fNum = '0';
                } else {
                  final match = RegExp(r'(\d+)').firstMatch(fName);
                  if (match != null) fNum = match.group(1);
                }
              }
              return PgFloorModel(
                id: entry.key,
                floorNumber: fNum ?? entry.key,
                name: fName ?? "Floor ${fNum ?? entry.key}",
                rooms: entry.value,
                isSelect: false,
              );
            }).toList();

            if (pgFloorModelList.isNotEmpty) {
              pgFloorModelList.first.isSelect = true;
            }
          }

          if (pgRoomModelList.isNotEmpty) {
            pgRoomModelList.first.isSelect = true;
            selectedRoomDetails = pgRoomModelList.first;
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgListingRooms: $e");
    } finally {
      isListingRoomsLoading = false;
      isLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // 9. FETCH SINGLE PG ROOM DETAILS (api/v1/pg/rooms/{id})
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgRoomDetails(String roomId) async {
    log("RoomController: fetchPgRoomDetails called for '$roomId'");
    isSingleRoomLoading = true;
    isLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgRoomDetails(roomId);
      log("fetchPgRoomDetails status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          selectedRoomDetails =
              PgRoomModel.fromJson(Map<String, dynamic>.from(data));
          log("Fetched room details for Room: ${selectedRoomDetails?.roomNumber}");
        }
      }
    } catch (e) {
      log("ERROR in fetchPgRoomDetails: $e");
    } finally {
      isSingleRoomLoading = false;
      isLoading = false;
      update();
    }
  }

  // ── Client-side Filter / Search ───────────────────────────────────
  void searchListings(String query) {
    searchQuery = query.trim().toLowerCase();
    if (searchQuery.isEmpty) {
      filteredListingList = List.from(pgListingList);
    } else {
      filteredListingList = pgListingList.where((item) {
        final title = item.title?.toLowerCase() ?? "";
        final address = item.address?.toLowerCase() ?? "";
        final landmark = item.landmark?.toLowerCase() ?? "";
        final city = item.city?.toLowerCase() ?? "";
        final gender = item.genderType?.toLowerCase() ?? "";
        return title.contains(searchQuery) ||
            address.contains(searchQuery) ||
            landmark.contains(searchQuery) ||
            city.contains(searchQuery) ||
            gender.contains(searchQuery);
      }).toList();
    }
    update();
  }

  // ══════════════════════════════════════════════════════════════════
  // FLOORS & ROOMS LEGACY / COMPATIBILITY METHODS
  // ══════════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════════
  // 10. FETCH PG FLOORS (api/v1/pg/floors)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchPgFloors({String? listingId}) async {
    final String? effectiveListingId = (listingId != null && listingId.isNotEmpty)
        ? listingId
        : selectedListingDetails?.id;
    log("RoomController: fetchPgFloors called with listingId: $effectiveListingId");
    isFloorsLoading = true;
    isLoading = true;
    update();

    try {
      final Response response =
          await roomRepo.fetchPgFloors(listingId: effectiveListingId);
      log("RoomController: fetchPgFloors response status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is List) {
          List<PgFloorModel> fetchedList = data
              .map((v) => PgFloorModel.fromJson(Map<String, dynamic>.from(v)))
              .toList();

          if (effectiveListingId != null && effectiveListingId.isNotEmpty) {
            final filtered = fetchedList
                .where((f) =>
                    f.listingId != null &&
                    f.listingId.toString().toLowerCase() ==
                        effectiveListingId.toLowerCase())
                .toList();
            if (filtered.isNotEmpty) {
              fetchedList = filtered;
            }
          }

          if (fetchedList.isNotEmpty) {
            pgFloorModelList = fetchedList;
          } else if (selectedListingDetails?.floors != null &&
              selectedListingDetails!.floors!.isNotEmpty) {
            pgFloorModelList = List.from(selectedListingDetails!.floors!);
          }

          log("Fetched ${pgFloorModelList.length} floors for listing '$effectiveListingId'");

          if (pgFloorModelList.isNotEmpty) {
            PgFloorModel? currentSel;
            if (selectedFloor != null) {
              final matches = pgFloorModelList.where((f) =>
                  f.id != null &&
                  selectedFloor!.id != null &&
                  f.id.toString() == selectedFloor!.id.toString());
              if (matches.isNotEmpty) {
                currentSel = matches.first;
              }
            }

            for (var f in pgFloorModelList) {
              f.isSelect = false;
            }

            if (currentSel != null) {
              currentSel.isSelect = true;
              selectedFloor = currentSel;
            } else {
              pgFloorModelList.first.isSelect = true;
              selectedFloor = pgFloorModelList.first;
            }

            await fetchFloorRoomsAndDetails(selectedFloor!.id);
          } else {
            selectedFloor = null;
            pgRoomModelList = [];
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgFloors: $e");
    } finally {
      isFloorsLoading = false;
      isLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // 11. FETCH FLOOR DETAILS & ROOMS (api/v1/pg/floors/{id} & /rooms)
  // ══════════════════════════════════════════════════════════════════
  Future<void> fetchFloorRoomsAndDetails(dynamic floorId) async {
    if (floorId == null) return;
    log("RoomController: fetchFloorRoomsAndDetails called for floor ID: $floorId");
    isFloorDetailsLoading = true;
    isLoading = true;
    update();

    try {
      // 1. Call API 2: api/v1/pg/floors/{id} (Floor details)
      final Response detailsResponse =
          await roomRepo.fetchPgFloorDetails(floorId);
      log("fetchPgFloorDetails status: ${detailsResponse.statusCode}");
      if (detailsResponse.statusCode == 200 && detailsResponse.body != null) {
        final dynamic rawData = detailsResponse.body['data'];
        if (rawData is Map) {
          final floorDetails =
              PgFloorModel.fromJson(Map<String, dynamic>.from(rawData));
          floorDetails.isSelect = true;
          selectedFloor = floorDetails;

          // Update in pgFloorModelList so All Floors List has full updated data!
          final idx = pgFloorModelList.indexWhere((f) =>
              f.id != null && f.id.toString() == floorId.toString());
          if (idx != -1) {
            pgFloorModelList[idx] = floorDetails;
          }

          if (floorDetails.rooms != null && floorDetails.rooms!.isNotEmpty) {
            pgRoomModelList = List.from(floorDetails.rooms!);
          }
        }
      }

      // 2. Call API 3: api/v1/pg/floors/{id}/rooms (Floor rooms)
      final Response roomsResponse = await roomRepo.fetchPgFloorRooms(floorId);
      log("fetchPgFloorRooms status: ${roomsResponse.statusCode}");
      if (roomsResponse.statusCode == 200 && roomsResponse.body != null) {
        final dynamic rawData = roomsResponse.body['data'];
        if (rawData is Map) {
          final listingMap = rawData['listing'] is Map
              ? Map<String, dynamic>.from(rawData['listing'])
              : (selectedFloor?.listing != null ? selectedFloor!.listing!.toJson() : null);
          final floorMap = rawData['floor'] is Map
              ? Map<String, dynamic>.from(rawData['floor'])
              : {
                  'id': selectedFloor?.id,
                  'name': selectedFloor?.name,
                  'floor_number': selectedFloor?.floorNumber,
                };

          if (rawData['rooms'] is List) {
            pgRoomModelList = (rawData['rooms'] as List).whereType<Map>().map((x) {
              final Map<String, dynamic> roomJson = Map<String, dynamic>.from(x);
              if (!roomJson.containsKey('listing') && listingMap != null) {
                roomJson['listing'] = listingMap;
              }
              if (!roomJson.containsKey('floor') && floorMap != null) {
                roomJson['floor'] = floorMap;
              }
              return PgRoomModel.fromJson(roomJson);
            }).toList();
            log("Fetched ${pgRoomModelList.length} rooms from floor rooms API");
          }
        } else if (rawData is List) {
          pgRoomModelList = rawData
              .whereType<Map>()
              .map((x) => PgRoomModel.fromJson(Map<String, dynamic>.from(x)))
              .toList();
        }
      }

      // Sync rooms into selectedFloor and pgFloorModelList
      if (selectedFloor != null) {
        selectedFloor = PgFloorModel(
          id: selectedFloor!.id,
          floorNumber: selectedFloor!.floorNumber,
          name: selectedFloor!.name,
          listingId: selectedFloor!.listingId,
          totalRooms: selectedFloor!.totalRooms ?? pgRoomModelList.length,
          totalCapacity: selectedFloor!.totalCapacity,
          availableBeds: selectedFloor!.availableBeds,
          listing: selectedFloor!.listing,
          website: selectedFloor!.website,
          rooms: pgRoomModelList,
          isSelect: true,
        );
        final idx = pgFloorModelList.indexWhere((f) =>
            f.id != null && f.id.toString() == floorId.toString());
        if (idx != -1) {
          pgFloorModelList[idx] = selectedFloor!;
        }
      }

      // Select first room if list is non-empty
      if (pgRoomModelList.isNotEmpty) {
        for (var r in pgRoomModelList) {
          r.isSelect = false;
        }
        pgRoomModelList.first.isSelect = true;
        selectedRoomDetails = pgRoomModelList.first;
      } else {
        selectedRoomDetails = null;
      }
    } catch (e) {
      log("ERROR in fetchFloorRoomsAndDetails: $e");
    } finally {
      isFloorDetailsLoading = false;
      isLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SELECT FLOOR
  // ══════════════════════════════════════════════════════════════════
  void selectFloor(PgFloorModel floor) {
    for (var f in pgFloorModelList) {
      f.isSelect = (f.id != null && floor.id != null
          ? f.id.toString() == floor.id.toString()
          : f == floor);
    }
    selectedFloor = floor;

    // Immediately show cached rooms if available
    if (floor.rooms != null && floor.rooms!.isNotEmpty) {
      pgRoomModelList = List.from(floor.rooms!);
      if (pgRoomModelList.isNotEmpty) {
        for (var r in pgRoomModelList) {
          r.isSelect = false;
        }
        pgRoomModelList.first.isSelect = true;
        selectedRoomDetails = pgRoomModelList.first;
      }
    } else {
      pgRoomModelList = [];
    }

    update();

    if (floor.id != null) {
      fetchFloorRoomsAndDetails(floor.id);
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SELECT ROOM
  // ══════════════════════════════════════════════════════════════════
  void selectRoom(PgRoomModel room) {
    for (var r in pgRoomModelList) {
      r.isSelect = (r.id.toString() == room.id.toString());
    }
    selectedRoomDetails = room;
    update();

    if (room.id != null) {
      fetchPgRoomDetails(room.id!);
    }
  }

  // Backward compatibility methods
  Future<void> fetchFloors(String listingId) async {
    await fetchPgFloors(listingId: listingId);
  }

  Future<void> fetchRooms(String listingId, dynamic floorId) async {
    await fetchFloorRoomsAndDetails(floorId);
  }

  Future<void> fetchRoomDetails(String listingId, String roomId) async {
    await fetchPgRoomDetails(roomId);
  }

  void updateSelectPgFloor(PgFloorModel value, [String? listingId]) {
    selectFloor(value);
  }

  void updateSelectPgRoomModel(PgRoomModel value) {
    selectRoom(value);
  }

  // ══════════════════════════════════════════════════════════════════
  // CUSTOMER DASHBOARD, BOOKINGS, WALLET, PROFILE METHODS
  // ══════════════════════════════════════════════════════════════════

  /// 1. Fetch PG Customer Dashboard (/api/v1/pg/customer/dashboard)
  Future<void> fetchPgCustomerDashboard() async {
    log("RoomController: fetchPgCustomerDashboard called");
    isCustomerDashboardLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerDashboard();
      log("fetchPgCustomerDashboard status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          customerDashboardData = PgCustomerDashboardData.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerDashboard: $e");
    } finally {
      isCustomerDashboardLoading = false;
      update();
    }
  }

  /// 2. Fetch PG Customer Bookings (/api/pg/bookings)
  Future<void> fetchPgCustomerBookings({String? status}) async {
    log("RoomController: fetchPgCustomerBookings called (status: $status)");
    isCustomerBookingsLoading = true;
    if (status != null) {
      activeBookingTab = status;
    }
    update();

    try {
      final Response response =
          await roomRepo.fetchPgCustomerBookings(status: status);
      log("fetchPgCustomerBookings status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];

        // ── New API format: data is a direct List of bookings ──
        if (data is List) {
          customerBookingsList = data
              .whereType<Map>()
              .map((b) =>
                  PgCustomerBookingItem.fromJson(Map<String, dynamic>.from(b)))
              .toList();

          // Build tabs from the list counts
          final total = response.body['total'] ?? customerBookingsList.length;
          int confirmed = 0, pendingOtp = 0, pendingPayment = 0, completed = 0, cancelled = 0;
          for (final b in customerBookingsList) {
            final s = (b.status ?? '').toLowerCase();
            if (s == 'confirmed') confirmed++;
            else if (s == 'pending_otp') pendingOtp++;
            else if (s == 'pending_payment') pendingPayment++;
            else if (s == 'completed') completed++;
            else if (s == 'cancelled') cancelled++;
          }
          customerBookingsTabs = {
            'all': total is int ? total : customerBookingsList.length,
            'confirmed': confirmed,
            'pending_otp': pendingOtp,
            'pending_payment': pendingPayment,
            'completed': completed,
            'cancelled': cancelled,
          };

          log("Parsed ${customerBookingsList.length} bookings from direct list format");
        }
        // ── Old API format: data is a Map with tabs/bookings ──
        else if (data is Map) {
          if (data['tabs'] is Map) {
            customerBookingsTabs = Map<String, int>.from(
              (data['tabs'] as Map).map(
                (k, v) =>
                    MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0),
              ),
            );
          }
          if (data['active_tab'] != null) {
            activeBookingTab = data['active_tab'].toString();
          }
          if (data['bookings'] is List) {
            customerBookingsList = (data['bookings'] as List)
                .whereType<Map>()
                .map((b) =>
                    PgCustomerBookingItem.fromJson(Map<String, dynamic>.from(b)))
                .toList();
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerBookings: $e");
    } finally {
      isCustomerBookingsLoading = false;
      update();
    }
  }

  /// 2b. Create PG Booking via /api/v1/pg/bookings
  Future<ResponseModel> createPgBooking({
    required String listingId,
    String? packageId,
    String? roomId,
    int? bedsBooked,
    required String paymentMethod,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
  }) async {
    log("RoomController: createPgBooking called");
    isCustomerBookingsLoading = true;
    update();

    ResponseModel responseModel;
    try {
      final Map<String, dynamic> body = {
        'listing_id': listingId,
        'payment_method': paymentMethod,
      };
      if (packageId != null && packageId.isNotEmpty) {
        body['package_id'] = packageId;
      }
      if (roomId != null && roomId.isNotEmpty) {
        body['room_id'] = roomId;
      }
      if (bedsBooked != null) {
        body['beds_booked'] = bedsBooked.toString();
      }
      body['occupancy_type'] = 'per_bed';

      if (customerName != null && customerName.isNotEmpty) {
        body['customer_name'] = customerName;
      }
      if (customerPhone != null && customerPhone.isNotEmpty) {
        body['customer_phone'] = customerPhone;
      }
      if (customerEmail != null && customerEmail.isNotEmpty) {
        body['customer_email'] = customerEmail;
      }

      log("createPgBooking body: $body");
      final Response response = await roomRepo.createPgBooking(body);
      log("createPgBooking status: ${response.statusCode}, body: ${response.body}");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        final isSuccess = response.body['status'] == true ||
            response.body['status'] == 'success';
        if (isSuccess) {
          // Refresh bookings list after creation
          await fetchPgCustomerBookings();
          fetchPgCustomerDashboard();
          responseModel = ResponseModel(
            true,
            response.body['message'] ?? "Booking created successfully!",
            response.body['data'],
          );
        } else {
          responseModel = ResponseModel(
            false,
            response.body['message'] ?? "Failed to create booking.",
            response.body['data'],
          );
        }
      } else {
        responseModel = ResponseModel(
          false,
          response.body?['message'] ?? "Error creating booking. Please try again.",
        );
      }
    } catch (e) {
      log("ERROR in createPgBooking: $e");
      responseModel = ResponseModel(false, "Error creating booking: $e");
    } finally {
      isCustomerBookingsLoading = false;
      update();
    }
    return responseModel;
  }

  /// 3. Fetch PG Customer Booking Details (/api/v1/pg/customer/bookings/{id})
  Future<PgCustomerBookingItem?> fetchPgCustomerBookingDetails(
      String bookingId) async {
    log("RoomController: fetchPgCustomerBookingDetails for $bookingId");
    isCustomerBookingDetailsLoading = true;
    update();

    try {
      final Response response =
          await roomRepo.fetchPgCustomerBookingDetails(bookingId);
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          selectedCustomerBookingDetails = PgCustomerBookingItem.fromJson(
            Map<String, dynamic>.from(data),
          );
          return selectedCustomerBookingDetails;
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerBookingDetails: $e");
    } finally {
      isCustomerBookingDetailsLoading = false;
      update();
    }
    return null;
  }

  /// 4. Pay for PG Booking (/api/v1/pg/customer/bookings/{id}/pay)
  Future<bool> payPgCustomerBooking(String bookingId) async {
    log("RoomController: payPgCustomerBooking for $bookingId");
    isPaymentProcessing = true;
    update();

    try {
      final Response response =
          await roomRepo.payPgCustomerBooking(bookingId);
      log("payPgCustomerBooking status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        if (isSuccess) {
          Get.snackbar(
            "Payment Successful",
            response.body['message'] ?? "Booking confirmed.",
            backgroundColor: const Color(0xFF16A34A),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          // Refresh dashboard & bookings
          fetchPgCustomerDashboard();
          fetchPgCustomerBookings();
          return true;
        } else {
          Get.snackbar(
            "Payment Failed",
            response.body['message'] ?? "Payment could not be processed.",
            backgroundColor: const Color(0xFFDC2626),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "Payment Error",
          response.body?['message'] ?? "Something went wrong.",
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log("ERROR in payPgCustomerBooking: $e");
      Get.snackbar(
        "Error",
        "Failed to process payment: $e",
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPaymentProcessing = false;
      update();
    }
    return false;
  }

  /// 5. Fetch Customer Wallet (/api/v1/pg/customer/wallet)
  Future<void> fetchPgCustomerWallet() async {
    log("RoomController: fetchPgCustomerWallet called");
    isCustomerWalletLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerWallet();
      log("fetchPgCustomerWallet status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          customerWalletData = PgCustomerWalletModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerWallet: $e");
    } finally {
      isCustomerWalletLoading = false;
      update();
    }
  }

  /// 6. Fetch Customer Profile (/api/v1/pg/customer/profile)
  Future<void> fetchPgCustomerProfile() async {
    log("RoomController: fetchPgCustomerProfile called");
    isCustomerProfileLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerProfile();
      log("fetchPgCustomerProfile status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          customerProfileData = PgCustomerProfileModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerProfile: $e");
    } finally {
      isCustomerProfileLoading = false;
      update();
    }
  }

  /// 7. Fetch Customer Invoices (/api/v1/pg/customer/invoices)
  Future<void> fetchPgCustomerInvoices() async {
    log("RoomController: fetchPgCustomerInvoices called");
    isCustomerInvoicesLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerInvoices();
      log("fetchPgCustomerInvoices status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        List list = [];
        if (data is Map && data['invoices'] is List) {
          list = data['invoices'];
        } else if (data is List) {
          list = data;
        }
        customerInvoicesList = list
            .map((e) =>
                PgCustomerInvoiceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerInvoices: $e");
    } finally {
      isCustomerInvoicesLoading = false;
      update();
    }
  }

  /// 7b. Fetch Single Customer Invoice Detail (/api/v1/pg/customer/invoices/{id})
  Future<PgCustomerInvoiceDetailData?> fetchPgCustomerInvoiceDetail(
      String id) async {
    log("RoomController: fetchPgCustomerInvoiceDetail called for $id");
    isCustomerInvoiceDetailLoading = true;
    selectedCustomerInvoiceDetail = null;
    update();

    try {
      final Response response =
          await roomRepo.fetchPgCustomerInvoiceDetail(id);
      log("fetchPgCustomerInvoiceDetail status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        dynamic bodyData = response.body;
        if (bodyData is Map && bodyData.containsKey('data')) {
          bodyData = bodyData['data'];
        }
        Map<String, dynamic>? invoiceMap;
        if (bodyData is Map) {
          if (bodyData.containsKey('invoice') && bodyData['invoice'] is Map) {
            invoiceMap = Map<String, dynamic>.from(bodyData['invoice']);
          } else {
            invoiceMap = Map<String, dynamic>.from(bodyData);
          }
        }
        if (invoiceMap != null) {
          selectedCustomerInvoiceDetail = PgCustomerInvoiceDetailData.fromJson(
            invoiceMap,
          );
          return selectedCustomerInvoiceDetail;
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerInvoiceDetail: $e");
    } finally {
      isCustomerInvoiceDetailLoading = false;
      update();
    }
    return null;
  }

  /// 8. Fetch Customer Subscriptions (/api/v1/pg/customer/subscriptions)
  Future<void> fetchPgCustomerSubscriptions() async {
    log("RoomController: fetchPgCustomerSubscriptions called");
    isCustomerSubscriptionsLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerSubscriptions();
      log("fetchPgCustomerSubscriptions status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        List list = [];
        if (data is Map && data['subscriptions'] is List) {
          list = data['subscriptions'];
        } else if (data is List) {
          list = data;
        }
        customerSubscriptionsList = list
            .map((e) => PgCustomerSubscriptionItem.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerSubscriptions: $e");
    } finally {
      isCustomerSubscriptionsLoading = false;
      update();
    }
  }

  /// 9. Fetch Single Subscription Detail (/api/v1/pg/customer/subscriptions/{id})
  Future<void> fetchPgCustomerSubscriptionDetail(String id) async {
    log("RoomController: fetchPgCustomerSubscriptionDetail called for $id");
    isCustomerSubscriptionDetailLoading = true;
    selectedCustomerSubscription = null;
    update();

    try {
      final Response response =
          await roomRepo.fetchPgCustomerSubscriptionDetail(id);
      log("fetchPgCustomerSubscriptionDetail status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          if (data['subscriptions'] is List &&
              (data['subscriptions'] as List).isNotEmpty) {
            selectedCustomerSubscription = PgCustomerSubscriptionItem.fromJson(
              Map<String, dynamic>.from(data['subscriptions'].first),
            );
          } else if (data['subscription'] is Map) {
            selectedCustomerSubscription = PgCustomerSubscriptionItem.fromJson(
              Map<String, dynamic>.from(data['subscription']),
            );
          } else {
            selectedCustomerSubscription = PgCustomerSubscriptionItem.fromJson(
              Map<String, dynamic>.from(data),
            );
          }
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerSubscriptionDetail: $e");
    } finally {
      isCustomerSubscriptionDetailLoading = false;
      update();
    }
  }

  /// 10. Download or Open Invoice PDF
  Future<void> downloadOrOpenInvoicePdf({
    required String invoiceId,
    String? invoiceNumber,
    String? downloadUrl,
  }) async {
    final invNum = (invoiceNumber != null && invoiceNumber.isNotEmpty)
        ? invoiceNumber
        : invoiceId;
    final String url = (downloadUrl != null && downloadUrl.isNotEmpty)
        ? downloadUrl
        : "${AppConstants.baseUrl}${AppConstants.downloadReceipt(type: 'invoice', id: invoiceId)}";

    final Map<String, String> headers = {
      'Authorization': 'Bearer ${roomRepo.apiClient.token}',
      'Accept': 'application/pdf',
    };

    isInvoiceDownloading = true;
    downloadingInvoiceId = invoiceId;
    update();

    try {
      await FileDownloadHelper.downloadAndShareFile(
        url,
        "Invoice_$invNum.pdf",
        headers,
      );
    } catch (e) {
      log("Error downloading invoice: $e");
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    } finally {
      isInvoiceDownloading = false;
      downloadingInvoiceId = null;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // CUSTOMER ATTENDANCE METHODS (/api/v1/pg/customer/attendance)
  // ══════════════════════════════════════════════════════════════════

  /// Fetch PG Customer Attendance records & monthly stats
  Future<void> fetchPgCustomerAttendance({
    int? month,
    int? year,
    String? fromDate,
    String? toDate,
  }) async {
    log("RoomController: fetchPgCustomerAttendance called (month: $month, year: $year, fromDate: $fromDate, toDate: $toDate)");
    isCustomerAttendanceLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerAttendance(
        month: month,
        year: year,
        fromDate: fromDate,
        toDate: toDate,
      );
      log("fetchPgCustomerAttendance status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data is Map) {
          customerAttendanceData = PgCustomerAttendanceData.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerAttendance: $e");
    } finally {
      isCustomerAttendanceLoading = false;
      update();
    }
  }

  /// Mark Punch In (/api/v1/pg/customer/attendance/punch-in)
  Future<ResponseModel> punchInPgAttendance({
    double? latitude,
    double? longitude,
  }) async {
    log("RoomController: punchInPgAttendance called");
    isAttendancePunching = true;
    update();

    try {
      final Map<String, dynamic> body = {};
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final Response response =
          await roomRepo.punchInPgCustomerAttendance(data: body);
      log("punchInPgCustomerAttendance status: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true ||
            response.body['status'] == 'true';
        final message = response.body['message']?.toString() ??
            "Punch In marked successfully.";

        // Refresh attendance records immediately
        await fetchPgCustomerAttendance();

        return ResponseModel(isSuccess, message);
      } else {
        final message =
            response.body?['message']?.toString() ?? "Failed to mark Punch In.";
        return ResponseModel(false, message);
      }
    } catch (e) {
      log("ERROR in punchInPgAttendance: $e");
      return ResponseModel(false, "Punch In error: $e");
    } finally {
      isAttendancePunching = false;
      update();
    }
  }

  /// Mark Punch Out (/api/v1/pg/customer/attendance/punch-out)
  Future<ResponseModel> punchOutPgAttendance({
    double? latitude,
    double? longitude,
  }) async {
    log("RoomController: punchOutPgAttendance called");
    isAttendancePunching = true;
    update();

    try {
      final Map<String, dynamic> body = {};
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final Response response =
          await roomRepo.punchOutPgCustomerAttendance(data: body);
      log("punchOutPgCustomerAttendance status: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true ||
            response.body['status'] == 'true';
        final message = response.body['message']?.toString() ??
            "Punch Out marked successfully.";

        // Refresh attendance records immediately
        await fetchPgCustomerAttendance();

        return ResponseModel(isSuccess, message);
      } else {
        final message = response.body?['message']?.toString() ??
            "Failed to mark Punch Out.";
        return ResponseModel(false, message);
      }
    } catch (e) {
      log("ERROR in punchOutPgAttendance: $e");
      return ResponseModel(false, "Punch Out error: $e");
    } finally {
      isAttendancePunching = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // CUSTOMER SAVED LISTINGS / FAVORITES (/api/v1/pg/customer/saved-listings)
  // ══════════════════════════════════════════════════════════════════

  /// Fetch Saved Listings
  Future<void> fetchPgSavedListings() async {
    log("RoomController: fetchPgSavedListings called");
    isSavedListingsLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgSavedListings();
      log("fetchPgSavedListings status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        List list = [];
        if (data is Map && data['saved_listings'] is List) {
          list = data['saved_listings'];
        } else if (data is List) {
          list = data;
        }
        savedListingsList = list
            .whereType<Map>()
            .map((e) =>
                PgSavedListingItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      log("ERROR in fetchPgSavedListings: $e");
    } finally {
      isSavedListingsLoading = false;
      update();
    }
  }

  /// Remove Saved Listing (/api/v1/pg/customer/saved-listings/{id})
  Future<ResponseModel> removePgSavedListing(String favoriteId) async {
    isRemovingSavedListing = true;
    update();

    try {
      final Response response = await roomRepo.removePgSavedListing(favoriteId);
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg = response.body['message'] ??
            "Listing removed from saved listings.";
        savedListingsList.removeWhere((item) =>
            item.favoriteId == favoriteId || item.listingId == favoriteId);
        update();
        return ResponseModel(isSuccess, msg);
      } else {
        return ResponseModel(false,
            response.body?['message'] ?? "Failed to remove saved listing.");
      }
    } catch (e) {
      return ResponseModel(false, "Error removing: $e");
    } finally {
      isRemovingSavedListing = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // CUSTOMER PAYMENT TRANSACTIONS (/api/v1/pg/customer/payment)
  // ══════════════════════════════════════════════════════════════════

  Future<void> fetchPgCustomerPayments() async {
    log("RoomController: fetchPgCustomerPayments called");
    isCustomerPaymentsLoading = true;
    update();

    try {
      final Response response = await roomRepo.fetchPgCustomerPayments();
      log("fetchPgCustomerPayments status: ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        List list = [];
        if (data is Map && data['payments'] is List) {
          list = data['payments'];
        } else if (data is List) {
          list = data;
        }
        customerPaymentsList = list
            .whereType<Map>()
            .map((e) => PgPaymentItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      log("ERROR in fetchPgCustomerPayments: $e");
    } finally {
      isCustomerPaymentsLoading = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // BOOKING ACTIONS (VERIFY OTP, CANCEL)
  // ══════════════════════════════════════════════════════════════════

  /// Verify Check-in OTP (/api/v1/pg/customer/bookings/{id}/verify-otp)
  Future<ResponseModel> verifyPgBookingOtp({
    required String bookingId,
    required String otp,
  }) async {
    isVerifyingOtp = true;
    update();

    try {
      final Response response =
          await roomRepo.verifyPgBookingOtp(bookingId, otp);
      log("verifyPgBookingOtp status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg = response.body['message'] ??
            "Check-in OTP verified successfully. Booking is now Confirmed.";
        // Refresh bookings and dashboard
        await fetchPgCustomerBookings();
        await fetchPgCustomerDashboard();
        return ResponseModel(isSuccess, msg);
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Failed to verify OTP.");
      }
    } catch (e) {
      return ResponseModel(false, "OTP verification error: $e");
    } finally {
      isVerifyingOtp = false;
      update();
    }
  }

  /// Cancel PG Booking (/api/v1/pg/customer/bookings/{id}/cancel)
  Future<ResponseModel> cancelPgBooking(String bookingId) async {
    isCancellingBooking = true;
    update();

    try {
      final Response response = await roomRepo.cancelPgBooking(bookingId);
      log("cancelPgBooking status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg = response.body['message'] ?? "Booking has been cancelled.";
        await fetchPgCustomerBookings();
        await fetchPgCustomerDashboard();
        return ResponseModel(isSuccess, msg);
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Failed to cancel booking.");
      }
    } catch (e) {
      return ResponseModel(false, "Cancellation error: $e");
    } finally {
      isCancellingBooking = false;
      update();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // INVOICE PAYMENT & WALLET RECHARGE
  // ══════════════════════════════════════════════════════════════════

  /// Pay PG Customer Invoice (/api/v1/pg/customer/invoice/{id}/pay)
  Future<ResponseModel> payPgCustomerInvoice(String invoiceId) async {
    isPayingInvoice = true;
    update();

    try {
      final Response response = await roomRepo.payPgCustomerInvoice(invoiceId);
      log("payPgCustomerInvoice status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg = response.body['message'] ??
            "Payment completed successfully. Booking confirmed.";
        await fetchPgCustomerInvoices();
        await fetchPgCustomerDashboard();
        return ResponseModel(isSuccess, msg);
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Payment failed.");
      }
    } catch (e) {
      return ResponseModel(false, "Payment error: $e");
    } finally {
      isPayingInvoice = false;
      update();
    }
  }

  /// Recharge PG Customer Wallet (/api/v1/pg/customer/wallet/recharge)
  Future<ResponseModel> rechargePgCustomerWallet(num amount) async {
    isRechargingWallet = true;
    update();

    try {
      final Response response =
          await roomRepo.rechargePgCustomerWallet(amount);
      log("rechargePgCustomerWallet status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg = response.body['message'] ??
            "Recharge order generated successfully.";
        await fetchPgCustomerWallet();
        await fetchPgCustomerDashboard();
        return ResponseModel(isSuccess, msg, response.body['data']);
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Recharge failed.");
      }
    } catch (e) {
      return ResponseModel(false, "Recharge error: $e");
    } finally {
      isRechargingWallet = false;
      update();
    }
  }

  /// Update PG Customer Profile (/api/v1/pg/customer/profile)
  Future<ResponseModel> updatePgCustomerProfile(
      Map<String, dynamic> data) async {
    isUpdatingProfile = true;
    update();

    try {
      final Response response = await roomRepo.updatePgCustomerProfile(data);
      log("updatePgCustomerProfile status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg = response.body['message'] ??
            "Customer profile updated successfully.";
        await fetchPgCustomerProfile();
        await fetchPgCustomerDashboard();
        return ResponseModel(isSuccess, msg);
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Profile update failed.");
      }
    } catch (e) {
      return ResponseModel(false, "Profile update error: $e");
    } finally {
      isUpdatingProfile = false;
      update();
    }
  }

  /// Cancel PG Customer Visit (/api/v1/pg/customer/visits/{id}/cancel)
  Future<ResponseModel> cancelPgCustomerVisit(String visitId) async {
    try {
      final Response response = await roomRepo.cancelPgCustomerVisit(visitId);
      log("cancelPgCustomerVisit status: ${response.statusCode}, body: ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final isSuccess = response.body['status'] == true;
        final msg =
            response.body['message'] ?? "Visit request has been cancelled.";
        await fetchPgCustomerDashboard();
        return ResponseModel(isSuccess, msg);
      } else {
        return ResponseModel(
            false, response.body?['message'] ?? "Failed to cancel visit.");
      }
    } catch (e) {
      return ResponseModel(false, "Cancel visit error: $e");
    }
  }
}
