import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/FavouriteModel.dart';
import 'package:emartconsumer/model/ProductModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VendorCategoryModel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/theme/app_them_data.dart';
import 'package:emartconsumer/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import 'package:emartconsumer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:emartconsumer/ui/deliveryAddressScreen/DeliveryAddressScreen.dart';
import 'package:emartconsumer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
import 'package:emartconsumer/ui/home/view_all_new_arrival_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class DineInScreen extends StatefulWidget {
  final User? user;

  const DineInScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  loc.Location location = loc.Location();
  String? currentLocation = "", name = "";
  final fireStoreUtils = FireStoreUtils();

  Stream<List<VendorModel>>? lstVendor;
  Stream<List<VendorModel>>? lstAllRestaurant;
  late Future<List<FavouriteModel>> lstFavourites;
  late Future<List<VendorCategoryModel>> cuisinesFuture;
  List<String> lstFav = [];
  List<VendorModel> newArrivalLst = [];
  List<VendorModel> restaurantAllLst = [];
  List<VendorModel> popularRestaurantLst = [];
  List<VendorModel> lstNearByFood = [];
  bool showLoader = true;
  late Future<List<ProductModel>> productsFuture;
  List<VendorModel> vendors = [];
  VendorModel? popularNearFoodVendorModel;

  bool isLoading = true;

  getLocationData() async {
    await getCurrentLocation().then((value) {
      setState(() {
        AddressModel addressModel = AddressModel();
        addressModel.location = UserLocation(latitude: value.latitude, longitude: value.longitude);
        MyAppState.selectedPosotion = addressModel;
      });
      getData();
    }).onError((error, stackTrace) {
      getPermission();
    });

    await placemarkFromCoordinates(MyAppState.selectedPosotion.location!.latitude, MyAppState.selectedPosotion.location!.longitude).then((value) {
      Placemark placeMark = value[0];

      setState(() {
        currentLocation = "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
      });
    }).catchError((error) {
      debugPrint("------>${error.toString()}");
    });

    setState(() {
      isLoading = false;
    });
  }

  getPermission() async {
    setState(() {
      isLoading = false;
    });
    loc.PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        getData();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocationData();
    cuisinesFuture = fireStoreUtils.getCuisines();
  }

  void dispose() {
    super.dispose();
  }

  void getData() {
    lstVendor = fireStoreUtils.getVendors1(path: "isDineIn").asBroadcastStream();
    lstAllRestaurant = fireStoreUtils.getAllDineInRestaurants().asBroadcastStream();

    if (MyAppState.currentUser != null) {
      lstFavourites = FireStoreUtils.getFavouriteStore(MyAppState.currentUser!.userID);
      lstFavourites.then((event) {
        lstFav.clear();
        for (int a = 0; a < event.length; a++) {
          lstFav.add(event[a].store_id!);
        }
        setState(() {

        });
      });
      name = toBeginningOfSentenceCase(widget.user!.firstName);
    }
    lstVendor!.listen((event) {
      setState(() {
        vendors.addAll(event);
      });
      restaurantAllLst.clear();
      newArrivalLst.clear();
      restaurantAllLst.addAll(event);
      newArrivalLst.addAll(event);
      popularRestaurantLst.addAll(event);

      List<VendorModel> temp5 = popularRestaurantLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 5).toList();
      List<VendorModel> temp5_ = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 4 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 5)
          .toList();
      List<VendorModel> temp4 = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 3 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 4)
          .toList();
      List<VendorModel> temp3 = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 2 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 3)
          .toList();
      List<VendorModel> temp2 = popularRestaurantLst
          .where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 1 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 2)
          .toList();
      List<VendorModel> temp1 = popularRestaurantLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 1).toList();
      List<VendorModel> temp0 = popularRestaurantLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 0).toList();
      List<VendorModel> temp0_ = popularRestaurantLst.where((element) => element.reviewsSum == 0 && element.reviewsCount == 0).toList();

      popularRestaurantLst.clear();
      popularRestaurantLst.addAll(temp5);
      popularRestaurantLst.addAll(temp5_);
      popularRestaurantLst.addAll(temp4);
      popularRestaurantLst.addAll(temp3);
      popularRestaurantLst.addAll(temp2);
      popularRestaurantLst.addAll(temp1);
      popularRestaurantLst.addAll(temp0);
      popularRestaurantLst.addAll(temp0_);

      newArrivalLst.sort(
        (a, b) => (b.createdAt ?? Timestamp.now()).toDate().compareTo((a.createdAt ?? Timestamp.now()).toDate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? AppThemeData.surfaceDark : AppThemeData.surface,
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppThemeData.primary300,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Text(currentLocation.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppThemeData.primary300)).tr(),
                        ),
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliveryAddressScreen())).then((value) {
                              AddressModel addressModel = value;
                              MyAppState.selectedPosotion = addressModel;
                              currentLocation = addressModel.getFullAddress();
                              setState(() {});
                              getData();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 32,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Text("Change".tr(), style: TextStyle(fontSize: 14, color: AppThemeData.primary300)).tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10),
                    child: Text("Find your store".tr(), style: TextStyle(fontSize: 24, color: isDarkMode(context) ? Colors.white : const Color(0xFF333333))).tr(),
                  ),
                  buildDineInTitleRow(
                    titleValue: "Categories".tr(),
                    onClick: () {
                      push(
                        context,
                        const CuisinesScreen(
                          isPageCallFromHomeScreen: true,
                          isPageCallForDineIn: true,
                        ),
                      );
                    },
                  ),
                  Container(
                    color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
                    child: FutureBuilder<List<VendorCategoryModel>>(
                        future: cuisinesFuture,
                        initialData: const [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                              ),
                            );
                          }

                          if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                            return SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length >= 15 ? 15 : snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return buildCategoryItem(snapshot.data![index]);
                                  },
                                ));
                          } else {
                            return showEmptyState('No Categories'.tr(), context);
                          }
                        }),
                  ),
                  buildDineInTitleRow(
                    titleValue: "New Arrivals".tr(),
                    onClick: () {
                      push(
                          context,
                          ViewAllNewArrivalStoreScreen(
                            isPageCallForDineIn: true,
                            vendorList: newArrivalLst,
                          ));
                    },
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.32,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: newArrivalLst.length >= 15 ? 15 : newArrivalLst.length,
                          itemBuilder: (context, index) => buildNewArrivalItem(newArrivalLst[index]))),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildDineInTitleRow(
                      titleValue: "Popular Restaurants".tr(),
                      onClick: () {
                        push(
                            context,
                            ViewAllNewArrivalStoreScreen(
                              isPageCallForDineIn: true,
                              isPageCallForPopular: true,
                              vendorList: popularRestaurantLst,
                            ));
                      },
                    ),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.32,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: popularRestaurantLst.length >= 15 ? 15 : popularRestaurantLst.length,
                          itemBuilder: (context, index) => buildNewArrivalItem(popularRestaurantLst[index]))),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildDineInTitleRow(
                      titleValue: "All Restaurants around you".tr(),
                      onClick: () {},
                      isViewAll: true,
                    ),
                  ),
                  Builder(builder: (context) {
                    return StreamBuilder<List<VendorModel>>(
                        stream: lstAllRestaurant,
                        initialData: const [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                              ),
                            );
                          }

                          if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                            vendors.clear();
                            vendors.addAll(snapshot.data!);
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: vendors.length,
                                  itemBuilder: (context, index) => buildAllRestaurantsData(vendors[index])),
                            );
                          } else {
                            return showEmptyState('No Vendors'.tr(), context);
                          }
                        });
                  }),
                ],
              ),
            ),
    );
  }

  buildCategoryItem(VendorCategoryModel cuisineModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          push(
              context,
              CategoryDetailsScreen(
                category: cuisineModel,
                isDineIn: true,
              ));
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.23,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: getImageVAlidUrl(cuisineModel.photo.toString()),
                imageBuilder: (context, imageProvider) => Container(
                  height: MediaQuery.of(context).size.height * 0.11,
                  width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(border: Border.all(width: 4, color: AppThemeData.primary300), borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: isDarkMode(context) ? Colors.black : const Color(0xffE0E2EA),
                        ),
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      placeholderImage,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )),
                placeholder: (context, url) => ClipOval(
                  child: Container(
                    // padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(75 / 1)),
                      border: Border.all(
                        color: AppThemeData.primary300,
                        style: BorderStyle.solid,
                        width: 2.0,
                      ),
                    ),
                    width: 75,
                    height: 75,
                    child: Icon(
                      Icons.fastfood,
                      color: AppThemeData.primary300,
                    ),
                  ),
                ),
              ),
              // displayCircleImage(model.photo, 90, false),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(cuisineModel.title.toString(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : const Color(0xFF000000),
                    )).tr(),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildNewArrivalItem(VendorModel vendorModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GestureDetector(
        onTap: () {
          push(
            context,
            DineInRestaurantDetailsScreen(vendorModel: vendorModel),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100, width: 0.1),
                boxShadow: [
                  isDarkMode(context)
                      ? const BoxShadow()
                      : BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 8.0,
                          spreadRadius: 1.2,
                          offset: const Offset(0.2, 0.2),
                        ),
                ],
                color: Colors.white),
            child: Column(
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  width: MediaQuery.of(context).size.width * 0.75,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        placeholderImage,
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.fitWidth,
                      )),
                  fit: BoxFit.cover,
                )),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title,
                          maxLines: 1,
                          style: const TextStyle(
                            letterSpacing: 0.5,
                            color: Color(0xff000000),
                          )).tr(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ImageIcon(
                            AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: Color(0xff9091A4),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(vendorModel.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  letterSpacing: 0.5,
                                  color: Color(0xff555353),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff555353),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(getKm(vendorModel.latitude, vendorModel.longitude)! + " km".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xff555353),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: AppThemeData.primary300,
                                ),
                                const SizedBox(width: 3),
                                Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                                    style: const TextStyle(
                                      letterSpacing: 0.5,
                                      color: Color(0xff000000),
                                    )),
                                const SizedBox(width: 3),
                                Text('(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: const TextStyle(
                                      letterSpacing: 0.5,
                                      color: Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(latitude, longitude, MyAppState.selectedPosotion.location!.latitude, MyAppState.selectedPosotion.location!.longitude);
    double kilometer = distanceInMeters / 1000;

    double minutes = 1.2;
    return kilometer.toStringAsFixed(currencyData!.decimal).toString();
  }

  buildAllRestaurantsData(VendorModel vendor) {
    return GestureDetector(
      onTap: () {
        push(
          context,
          DineInRestaurantDetailsScreen(vendorModel: vendor),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendor.photo),
                height: 100,
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      vendor.photo,
                      fit: BoxFit.cover,
                    )),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff000000),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (lstFav.contains(vendor.id) == true) {
                              FavouriteModel favouriteModel = FavouriteModel(store_id: vendor.id, user_id: MyAppState.currentUser!.userID, section_id: sectionConstantModel!.id);
                              lstFav.removeWhere((item) => item == vendor.id);
                              FireStoreUtils.removeFavouriteStore(favouriteModel);
                            } else {
                              FavouriteModel favouriteModel = FavouriteModel(store_id: vendor.id, section_id: sectionConstantModel!.id, user_id: MyAppState.currentUser!.userID);
                              FireStoreUtils.setFavouriteStore(favouriteModel);
                              lstFav.add(vendor.id);
                            }
                          });
                        },
                        child: lstFav.contains(vendor.id) == true
                            ? Icon(
                                Icons.favorite,
                                color: AppThemeData.primary300,
                              )
                            : const Icon(
                                Icons.favorite_border,
                                color: Colors.black38,
                              ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.location,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xff9091A4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff555353),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(getKm(vendor.latitude, vendor.longitude)! + " km".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xff555353),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: AppThemeData.primary300,
                      ),
                      const SizedBox(width: 3),
                      Text(vendor.reviewsCount != 0 ? (vendor.reviewsSum / vendor.reviewsCount).toStringAsFixed(1) : 0.toString(),
                          style: const TextStyle(
                            letterSpacing: 0.5,
                            color: Color(0xff000000),
                          )),
                      const SizedBox(width: 3),
                      Text('(${vendor.reviewsCount.toStringAsFixed(1)})',
                          style: const TextStyle(
                            letterSpacing: 0.5,
                            color: Color(0xff666666),
                          )),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class buildDineInTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildDineInTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr(), style: TextStyle(color: isDarkMode(context) ? Colors.white : const Color(0xFF000000), fontSize: 16)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('View All'.tr(), style: TextStyle(color: AppThemeData.primary300)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}