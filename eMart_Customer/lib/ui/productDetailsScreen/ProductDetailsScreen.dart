import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/ecommarce_service/ecommarce_dashboard.dart';
import 'package:emartconsumer/ecommarce_service/view_all_brand_product_screen.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AttributesModel.dart';
import 'package:emartconsumer/model/BrandsModel.dart';
import 'package:emartconsumer/model/FavouriteItemModel.dart';
import 'package:emartconsumer/model/ItemAttributes.dart';
import 'package:emartconsumer/model/ProductModel.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/ReviewAttributeModel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/model/variant_info.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/Indicator.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:emartconsumer/theme/app_them_data.dart';
import 'package:emartconsumer/theme/responsive.dart';
import 'package:emartconsumer/theme/round_button_fill.dart';
import 'package:emartconsumer/ui/auth_screen/login_screen.dart';

import 'package:emartconsumer/ui/cartScreen/CartScreen.dart';
import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../vendorProductsScreen/newVendorProductsScreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  final VendorModel vendorModel;

  const ProductDetailsScreen({Key? key, required this.productModel, required this.vendorModel}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late CartDatabase cartDatabase;

  String radioItem = '';
  int id = -1;
  List<AddAddonsDemo> lstAddAddonsCustom = [];
  List<AddAddonsDemo> lstTemp = [];
  double priceTemp = 0.0, lastPrice = 0.0;
  int productQnt = 0;

  List<String> productImage = [];

  List<Attributes>? attributes = [];
  List<Variants>? variants = [];

  List<String> selectedVariants = [];
  List<String> selectedIndexVariants = [];
  List<String> selectedIndexArray = [];

  bool isOpen = false;

  statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in widget.vendorModel.workingHours) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          for (var element in element.timeslot!) {
            var start = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.from.toString());
            var end = DateFormat("dd-MM-yyyy HH:mm").parse(date + " " + element.to.toString());
            if (isCurrentDateInRange(start, end)) {
              setState(() {
                isOpen = true;
              });
            }
          }
        }
      }
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  @override
  void initState() {
    super.initState();

    print("product Id ---->${widget.productModel.id}");
    // productQnt = widget.productModel.quantity;

    getAddOnsData();
    statusCheck();
    if (widget.productModel.itemAttributes != null) {
      attributes = widget.productModel.itemAttributes!.attributes;
      variants = widget.productModel.itemAttributes!.variants;

      if (attributes!.isNotEmpty) {
        for (var element in attributes!) {
          if (element.attributeOptions!.isNotEmpty) {
            selectedVariants.add(attributes![attributes!.indexOf(element)].attributeOptions![0].toString());
            selectedIndexVariants.add('${attributes!.indexOf(element)} _${attributes![0].attributeOptions![0].toString()}');
            selectedIndexArray.add('${attributes!.indexOf(element)}_0');
          }
        }
      }

      if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
        widget.productModel.price = variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0';
        widget.productModel.disPrice = '0';
      }
    }
    getData();
  }

  List<ReviewAttributeModel> reviewAttributeList = [];

  List<ProductModel> productList = [];
  List<ProductModel> storeProductList = [];
  bool showLoader = true;
  BrandsModel? brandModel;
  List<FavouriteItemModel> lstFav = [];

  List<AttributesModel> attributesList = [];
  List<RatingModel> reviewList = [];

  getData() async {
    if (MyAppState.currentUser != null) {
      await FireStoreUtils().getFavouritesProductList(MyAppState.currentUser!.userID).then((value) {
        setState(() {
          lstFav = value;
        });
      });
    }

    if (widget.productModel.photos.isEmpty) {
      productImage.add(widget.productModel.photo);
    }
    for (var element in widget.productModel.photos) {
      productImage.add(element);
    }

    for (var element in variants!) {
      productImage.add(element.variant_image.toString());
    }

    await FireStoreUtils.getAttributes().then((value) {
      setState(() {
        attributesList = value;
      });
    });

    await FireStoreUtils.getAllReviewAttributes().then((value) {
      reviewAttributeList = value;
    });

    await FireStoreUtils().getReviewList(widget.productModel.id).then((value) {
      setState(() {
        reviewList = value;
      });
    });

    await FireStoreUtils.getProductListByCategoryId(widget.productModel.categoryID.toString()).then((value) {
      for (var element in value) {
        if (element.id != widget.productModel.id) {
          productList.add(element);
        }
      }
      setState(() {});
    });

    await FireStoreUtils.getStoreProduct(widget.productModel.vendorID.toString()).then((value) {
      for (var element in value) {
        if (element.id != widget.productModel.id) {
          storeProductList.add(element);
        }
      }
      setState(() {});
    });

    await FireStoreUtils.getBrands().then((value) {
      for (var element in value) {
        if (element.id == widget.productModel.brandID) {
          brandModel = element;
        }
      }
      setState(() {});
    });
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context, listen: true);

    cartDatabase.allCartProducts.then((value) {
      final bool _productIsInList = value.any((product) =>
          product.id ==
          widget.productModel.id +
              "~" +
              (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                  ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
                  : ""));
      if (_productIsInList) {
        CartProduct element = value.firstWhere((product) =>
            product.id ==
            widget.productModel.id +
                "~" +
                (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                    ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
                    : ""));

        setState(() {
          productQnt = element.quantity;
        });
      } else {
        setState(() {
          productQnt = 0;
        });
      }
    });
    super.didChangeDependencies();
  }

  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? AppThemeData.surfaceDark : AppThemeData.surface,
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.46,
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: PageView.builder(
                      itemCount: productImage.length,
                      scrollDirection: Axis.horizontal,
                      controller: _controller,
                      onPageChanged: (value) {
                        setState(() {});
                      },
                      allowImplicitScrolling: true,
                      itemBuilder: (context, index) => CachedNetworkImage(
                            imageUrl: getImageVAlidUrl(productImage[index]),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                            )),
                            errorWidget: (context, url, error) => Image.network(
                              placeholderImage,
                              fit: BoxFit.fitWidth,
                            ),
                            fit: BoxFit.contain,
                          )),
                )),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.036,
                left: MediaQuery.of(context).size.width * 0.03,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 25,
                  ),
                )),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.036,
              right: MediaQuery.of(context).size.width * 0.03,
              child: GestureDetector(
                onTap: () {
                  if (MyAppState.currentUser == null) {
                    push(context, const LoginScreen());
                  } else {
                    setState(() {
                      var contain = lstFav.where((element) => element.product_id == widget.productModel.id);

                      if (contain.isNotEmpty) {
                        FavouriteItemModel favouriteModel = FavouriteItemModel(
                            product_id: widget.productModel.id, section_id: sectionConstantModel!.id, store_id: widget.vendorModel.id, user_id: MyAppState.currentUser!.userID);
                        lstFav.removeWhere((item) => item.product_id == widget.productModel.id);
                        FireStoreUtils.removeFavouriteItem(favouriteModel);
                      } else {
                        FavouriteItemModel favouriteModel = FavouriteItemModel(
                            product_id: widget.productModel.id, section_id: sectionConstantModel!.id, store_id: widget.vendorModel.id, user_id: MyAppState.currentUser!.userID);
                        FireStoreUtils().setFavouriteStoreItem(favouriteModel);
                        lstFav.add(favouriteModel);
                      }
                    });
                  }
                },
                child: lstFav.where((element) => element.product_id == widget.productModel.id).isNotEmpty
                    ? Icon(
                        Icons.favorite,
                        color: AppThemeData.primary300,
                      )
                    : Icon(
                        Icons.favorite_border,
                        color: isDarkMode(context) ? Colors.white38 : Colors.black38,
                      ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Indicator(
                  controller: _controller,
                  itemCount: productImage.length,
                ),
              ),
            ),
          ]),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: isDarkMode(context) ? AppThemeData.surfaceDark : AppThemeData.surface,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.productModel.name,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      widget.productModel.disPrice == "" || widget.productModel.disPrice == "0"
                                          ? Text(
                                              "${amountShow(amount: productCommissionPrice(widget.productModel.price))}",
                                              style: TextStyle(fontSize: 16, letterSpacing: 0.5, color: AppThemeData.primary300),
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                  "${amountShow(amount: productCommissionPrice(widget.productModel.disPrice.toString()))}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppThemeData.primary300,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '${amountShow(amount: productCommissionPrice(widget.productModel.price))}',
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                                ),
                                              ],
                                            ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 18,
                                            color: AppThemeData.warning300,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "(${calculateReview(reviewCount: widget.productModel.reviewsCount.toString(), reviewSum: widget.productModel.reviewsSum.toString())})",
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: AppThemeData.medium,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                              color: isDarkMode(context) ? AppThemeData.grey400 : AppThemeData.grey500,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "${widget.productModel.reviewsSum.toString()}",
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: AppThemeData.medium,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            sectionConstantModel!.serviceTypeFlag == "ecommerce-service"
                                ? productQnt == 0
                                    ? RoundedButtonFill(
                                        title: "Add".tr(),
                                        width: 22,
                                        height: 4,
                                        color: isDarkMode(context) ? AppThemeData.grey700 : AppThemeData.grey200,
                                        textColor: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                        isRight: true,
                                        icon: Icon(
                                          Icons.add,
                                          color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                        ),
                                        onPress: () async {
                                          if (MyAppState.currentUser == null) {
                                            push(context, const LoginScreen());
                                          } else {
                                            setState(() {
                                              print("Variant---->${variants}");
                                              print("Variant---->${selectedVariants}");
                                              if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                                if (int.parse(variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_quantity.toString()) >=
                                                        1 ||
                                                    int.parse(variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_quantity.toString()) ==
                                                        -1) {
                                                  VariantInfo? variantInfo = VariantInfo();
                                                  widget.productModel.price =
                                                      variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0';
                                                  widget.productModel.disPrice = '0';

                                                  Map<String, String> mapData = Map();
                                                  for (var element in attributes!) {
                                                    mapData.addEntries([
                                                      MapEntry(attributesList.where((element1) => element.attributesId == element1.id).first.title.toString(),
                                                          selectedVariants[attributes!.indexOf(element)])
                                                    ]);
                                                    setState(() {});
                                                  }

                                                  variantInfo = VariantInfo(
                                                      variant_price: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0',
                                                      variant_sku: selectedVariants.join('-'),
                                                      variant_options: mapData,
                                                      variant_image: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_image ?? '',
                                                      variant_id: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id ?? '0');

                                                  widget.productModel.variant_info = variantInfo;

                                                  setState(() {
                                                    productQnt = 1;
                                                  });
                                                  addtocard(widget.productModel, true);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                    content: Text("Product is out of Stock"),
                                                  ));
                                                }
                                              } else {
                                                if (widget.productModel.quantity > productQnt || widget.productModel.quantity == -1) {
                                                  setState(() {
                                                    productQnt = 1;
                                                  });
                                                  addtocard(widget.productModel, true);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                    content: Text("Product is out of Stock"),
                                                  ));
                                                }
                                              }
                                            });
                                          }
                                        },
                                      )
                                    : Container(
                                        width: Responsive.width(24, context),
                                        height: Responsive.height(5, context),
                                        decoration: ShapeDecoration(
                                          color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(200),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (productQnt != 0) {
                                                      productQnt--;
                                                    }
                                                    if (productQnt >= 0) {
                                                      removetocard(widget.productModel, true);
                                                    }
                                                  });
                                                },
                                                child: const Icon(Icons.remove)),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 14),
                                              child: Text(
                                                productQnt.toString(),
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontFamily: AppThemeData.medium,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDarkMode(context) ? AppThemeData.grey100 : AppThemeData.grey800,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                                      if (int.parse(variants!
                                                                  .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                  .first
                                                                  .variant_quantity
                                                                  .toString()) >
                                                              productQnt ||
                                                          int.parse(variants!
                                                                  .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                  .first
                                                                  .variant_quantity
                                                                  .toString()) ==
                                                              -1) {
                                                        VariantInfo? variantInfo = VariantInfo();
                                                        Map<String, String> mapData = Map();
                                                        for (var element in attributes!) {
                                                          mapData.addEntries([
                                                            MapEntry(attributesList.where((element1) => element.attributesId == element1.id).first.title.toString(),
                                                                selectedVariants[attributes!.indexOf(element)])
                                                          ]);
                                                          setState(() {});
                                                        }

                                                        variantInfo = VariantInfo(
                                                            variant_price:
                                                                variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0',
                                                            variant_sku: selectedVariants.join('-'),
                                                            variant_options: mapData,
                                                            variant_image:
                                                                variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_image ?? '',
                                                            variant_id: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id ?? '0');

                                                        widget.productModel.variant_info = variantInfo;
                                                        if (productQnt != 0) {
                                                          productQnt++;
                                                        }
                                                        // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                        addtocard(widget.productModel, true);
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                          content: Text("Product is out of Stock"),
                                                        ));
                                                      }
                                                    } else {
                                                      if (widget.productModel.quantity > productQnt || widget.productModel.quantity == -1) {
                                                        if (productQnt != 0) {
                                                          productQnt++;
                                                        }
                                                        // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                        addtocard(widget.productModel, true);
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                          content: Text("Product is out of Stock"),
                                                        ));
                                                      }
                                                    }
                                                  });
                                                },
                                                child: const Icon(Icons.add)),
                                          ],
                                        ),
                                      )
                                : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                    productQnt == 0
                                        ? isOpen == false
                                            ? const Center()
                                            : RoundedButtonFill(
                                                title: "Add".tr(),
                                                width: 22,
                                                height: 4,
                                                color: isDarkMode(context) ? AppThemeData.grey700 : AppThemeData.grey200,
                                                textColor: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                                isRight: true,
                                                icon: Icon(
                                                  Icons.add,
                                                  color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                                ),
                                                onPress: () async {
                                                  if (MyAppState.currentUser == null) {
                                                    push(context, const LoginScreen());
                                                  } else {
                                                    setState(() {
                                                      print("Variant---->${variants}");
                                                      print("Variant---->${selectedVariants}");
                                                      if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                                        if (int.parse(variants!
                                                                    .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                    .first
                                                                    .variant_quantity
                                                                    .toString()) >=
                                                                1 ||
                                                            int.parse(variants!
                                                                    .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                    .first
                                                                    .variant_quantity
                                                                    .toString()) ==
                                                                -1) {
                                                          VariantInfo? variantInfo = VariantInfo();
                                                          widget.productModel.price =
                                                              variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0';
                                                          widget.productModel.disPrice = '0';

                                                          Map<String, String> mapData = Map();
                                                          for (var element in attributes!) {
                                                            mapData.addEntries([
                                                              MapEntry(attributesList.where((element1) => element.attributesId == element1.id).first.title.toString(),
                                                                  selectedVariants[attributes!.indexOf(element)])
                                                            ]);
                                                            setState(() {});
                                                          }

                                                          variantInfo = VariantInfo(
                                                              variant_price:
                                                                  variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0',
                                                              variant_sku: selectedVariants.join('-'),
                                                              variant_options: mapData,
                                                              variant_image:
                                                                  variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_image ?? '',
                                                              variant_id: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id ?? '0');

                                                          widget.productModel.variant_info = variantInfo;

                                                          setState(() {
                                                            productQnt = 1;
                                                          });
                                                          addtocard(widget.productModel, true);
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text("Product is out of Stock"),
                                                          ));
                                                        }
                                                      } else {
                                                        if (widget.productModel.quantity > productQnt || widget.productModel.quantity == -1) {
                                                          setState(() {
                                                            productQnt = 1;
                                                          });
                                                          addtocard(widget.productModel, true);
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text("Product is out of Stock"),
                                                          ));
                                                        }
                                                      }
                                                    });
                                                  }
                                                },
                                              )
                                        : isOpen == false
                                            ? Container()
                                            : Container(
                                                width: Responsive.width(24, context),
                                                height: Responsive.height(5, context),
                                                decoration: ShapeDecoration(
                                                  color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(200),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (productQnt != 0) {
                                                              productQnt--;
                                                            }
                                                            if (productQnt >= 0) {
                                                              removetocard(widget.productModel, true);
                                                            }
                                                          });
                                                        },
                                                        child: const Icon(Icons.remove)),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                                      child: Text(
                                                        productQnt.toString(),
                                                        textAlign: TextAlign.start,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          overflow: TextOverflow.ellipsis,
                                                          fontFamily: AppThemeData.medium,
                                                          fontWeight: FontWeight.w500,
                                                          color: isDarkMode(context) ? AppThemeData.grey100 : AppThemeData.grey800,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                                              if (int.parse(variants!
                                                                          .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                          .first
                                                                          .variant_quantity
                                                                          .toString()) >
                                                                      productQnt ||
                                                                  int.parse(variants!
                                                                          .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                          .first
                                                                          .variant_quantity
                                                                          .toString()) ==
                                                                      -1) {
                                                                VariantInfo? variantInfo = VariantInfo();
                                                                Map<String, String> mapData = Map();
                                                                for (var element in attributes!) {
                                                                  mapData.addEntries([
                                                                    MapEntry(attributesList.where((element1) => element.attributesId == element1.id).first.title.toString(),
                                                                        selectedVariants[attributes!.indexOf(element)])
                                                                  ]);
                                                                  setState(() {});
                                                                }

                                                                variantInfo = VariantInfo(
                                                                    variant_price:
                                                                        variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0',
                                                                    variant_sku: selectedVariants.join('-'),
                                                                    variant_options: mapData,
                                                                    variant_image:
                                                                        variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_image ?? '',
                                                                    variant_id:
                                                                        variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id ?? '0');

                                                                widget.productModel.variant_info = variantInfo;
                                                                if (productQnt != 0) {
                                                                  productQnt++;
                                                                }
                                                                // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                                addtocard(widget.productModel, true);
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                  content: Text("Product is out of Stock"),
                                                                ));
                                                              }
                                                            } else {
                                                              if (widget.productModel.quantity > productQnt || widget.productModel.quantity == -1) {
                                                                if (productQnt != 0) {
                                                                  productQnt++;
                                                                }
                                                                // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                                addtocard(widget.productModel, true);
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                  content: Text("Product is out of Stock"),
                                                                ));
                                                              }
                                                            }
                                                          });
                                                        },
                                                        child: const Icon(Icons.add)),
                                                  ],
                                                ),
                                              ),
                                  ]),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: CachedNetworkImage(
                                      height: 40,
                                      width: 40,
                                      imageUrl: getImageVAlidUrl(widget.vendorModel.photo),
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator.adaptive(
                                        valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                                      )),
                                      errorWidget: (context, url, error) => ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            placeholderImage,
                                            fit: BoxFit.cover,
                                          )),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        push(
                                          context,
                                          NewVendorProductsScreen(vendorModel: widget.vendorModel),
                                        );
                                      },
                                      child: Text(widget.vendorModel.title, style: TextStyle(color: AppThemeData.primary300))),
                                ],
                              ),
                            ),
                            brandModel == null
                                ? Container()
                                : Expanded(
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: CachedNetworkImage(
                                            height: 40,
                                            width: 40,
                                            imageUrl: getImageVAlidUrl(brandModel!.photo.toString()),
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                              ),
                                            ),
                                            placeholder: (context, url) => Center(
                                                child: CircularProgressIndicator.adaptive(
                                              valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                                            )),
                                            errorWidget: (context, url, error) => ClipRRect(
                                                borderRadius: BorderRadius.circular(15),
                                                child: Image.network(
                                                  placeholderImage,
                                                  fit: BoxFit.cover,
                                                )),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              VendorModel? vendorModel = await FireStoreUtils.getVendor(widget.vendorModel.id);
                                              if (vendorModel != null) {
                                                push(context, ViewAllBrandProductScreen(brandModel: brandModel));
                                              }
                                            },
                                            child: Text(brandModel != null ? brandModel!.title.toString() : "", style: TextStyle(color: AppThemeData.primary300))),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Details".tr(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.bold,
                            fontSize: 16,
                            color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: Responsive.width(100, context),
                          decoration: ShapeDecoration(
                            color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 32,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.productModel.description,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.regular,
                                    color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                  ),
                                ),
                                sectionConstantModel!.isProductDetails == false
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Divider(),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Calories : ",
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                    Text(
                                                      widget.productModel.calories.toString(),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.bold,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Fats : ",
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                    Text(
                                                      widget.productModel.fats.toString(),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.bold,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Proteins : ",
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                    Text(
                                                      widget.productModel.proteins.toString(),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.bold,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Grams : ",
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                    Text(
                                                      widget.productModel.grams.toString(),
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.bold,
                                                        color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  attributes!.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Variants".tr(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.bold,
                                  fontSize: 16,
                                  color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: ShapeDecoration(
                                  color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Color(0x05000000),
                                      blurRadius: 32,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListView.builder(
                                    itemCount: attributes!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      String title = "";
                                      for (var element in attributesList) {
                                        if (attributes![index].attributesId == element.id) {
                                          title = element.title.toString();
                                        }
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                            child: Text(
                                              title.tr(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: AppThemeData.regular,
                                                color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: Wrap(
                                              spacing: 6.0,
                                              runSpacing: 6.0,
                                              children: List.generate(
                                                attributes![index].attributeOptions!.length,
                                                (i) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        print("------------->" +
                                                            widget.productModel.id +
                                                            "~" +
                                                            variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString());

                                                        setState(() {
                                                          if (selectedIndexVariants.where((element) => element.contains('$index _')).isEmpty) {
                                                            selectedVariants.insert(index, attributes![index].attributeOptions![i].toString());
                                                            selectedIndexVariants.add('$index _${attributes![index].attributeOptions![i].toString()}');
                                                            selectedIndexArray.add('${index}_$i');
                                                          } else {
                                                            selectedIndexArray.remove(
                                                                '${index}_${attributes![index].attributeOptions?.indexOf(selectedIndexVariants.where((element) => element.contains('$index _')).first.replaceAll('$index _', ''))}');
                                                            selectedVariants.removeAt(index);
                                                            selectedIndexVariants.remove(selectedIndexVariants.where((element) => element.contains('$index _')).first);
                                                            selectedVariants.insert(index, attributes![index].attributeOptions![i].toString());
                                                            selectedIndexVariants.add('$index _${attributes![index].attributeOptions![i].toString()}');
                                                            selectedIndexArray.add('${index}_$i');
                                                          }
                                                        });
                                                        print('object ==> ${selectedVariants.toString()}');
                                                        print('object ==> ${selectedIndexVariants.toString()}');
                                                        print('object ==> ${selectedIndexArray.toString()}');

                                                        await cartDatabase.allCartProducts.then((value) {
                                                          final bool _productIsInList = value.any((product) =>
                                                              product.id ==
                                                              widget.productModel.id +
                                                                  "~" +
                                                                  (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                                                                      ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
                                                                      : ""));
                                                          if (_productIsInList) {
                                                            CartProduct element = value.firstWhere((product) =>
                                                                product.id ==
                                                                widget.productModel.id +
                                                                    "~" +
                                                                    (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                                                                        ? variants!
                                                                            .where((element) => element.variant_sku == selectedVariants.join('-'))
                                                                            .first
                                                                            .variant_id
                                                                            .toString()
                                                                        : ""));

                                                            setState(() {
                                                              productQnt = element.quantity;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              productQnt = 0;
                                                            });
                                                          }
                                                        });

                                                        if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                                          widget.productModel.price =
                                                              variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0';
                                                          widget.productModel.disPrice = '0';
                                                        }
                                                      },
                                                      child: _buildChip(attributes![index].attributeOptions![i].toString(), i,
                                                          selectedVariants.contains(attributes![index].attributeOptions![i].toString()) ? true : false));
                                                },
                                              ).toList(),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  Visibility(
                    visible: sectionConstantModel!.dineInActive!,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Card(
                          color: isDarkMode(context) ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        widget.productModel.calories.toString(),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text("kcal".tr(), style: const TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(widget.productModel.grams.toString(), style: const TextStyle(fontSize: 20)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text("grams".tr(), style: const TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(widget.productModel.proteins.toString(), style: const TextStyle(fontSize: 20)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text("proteins".tr(), style: const TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(widget.productModel.fats.toString(), style: const TextStyle(fontSize: 20)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text("fats".tr(), style: const TextStyle(fontSize: 16))
                                    ],
                                  )
                                ],
                              ))),
                    ),
                  ),
                  lstAddAddonsCustom.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Add Ons".tr(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.bold,
                                  fontSize: 16,
                                  color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: ShapeDecoration(
                                  color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Color(0x05000000),
                                      blurRadius: 32,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: ListView.builder(
                                      itemCount: lstAddAddonsCustom.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              Text(
                                                lstAddAddonsCustom[index].name!,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: AppThemeData.regular,
                                                  color: isDarkMode(context) ? AppThemeData.grey200 : AppThemeData.grey700,
                                                ),
                                              ),
                                              const Expanded(child: SizedBox()),
                                              Text(
                                                amountShow(amount: productCommissionPrice(lstAddAddonsCustom[index].price!)),
                                                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeData.primary300),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    lstAddAddonsCustom[index].isCheck = !lstAddAddonsCustom[index].isCheck;
                                                    if (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                                      VariantInfo? variantInfo = VariantInfo();
                                                      Map<String, String> mapData = Map();
                                                      for (var element in attributes!) {
                                                        mapData.addEntries([
                                                          MapEntry(attributesList.where((element1) => element.attributesId == element1.id).first.title.toString(),
                                                              selectedVariants[attributes!.indexOf(element)])
                                                        ]);
                                                        setState(() {});
                                                      }

                                                      variantInfo = VariantInfo(
                                                          variant_price: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ?? '0',
                                                          variant_sku: selectedVariants.join('-'),
                                                          variant_options: mapData,
                                                          variant_image: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_image ?? '',
                                                          variant_id: variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id ?? '0');

                                                      widget.productModel.variant_info = variantInfo;
                                                    }

                                                    if (lstAddAddonsCustom[index].isCheck == true) {
                                                      AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                                                          name: widget.productModel.addOnsTitle[index],
                                                          index: index,
                                                          isCheck: true,
                                                          categoryID: widget.productModel.id,
                                                          price: productCommissionPrice(lstAddAddonsCustom[index].price!));
                                                      lstTemp.add(addAddonsDemo);
                                                      saveAddOns(lstTemp);
                                                      addtocard(widget.productModel, false);
                                                    } else {
                                                      var removeIndex = -1;
                                                      for (int a = 0; a < lstTemp.length; a++) {
                                                        if (lstTemp[a].index == index && lstTemp[a].categoryID == lstAddAddonsCustom[index].categoryID) {
                                                          removeIndex = a;
                                                          break;
                                                        }
                                                      }
                                                      lstTemp.removeAt(removeIndex);
                                                      saveAddOns(lstTemp);
                                                      //widget.productModel.price = widget.productModel.disPrice==""||widget.productModel.disPrice=="0"? (widget.productModel.price) :(widget.productModel.disPrice!);
                                                      addtocard(widget.productModel, false);
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 10, right: 10),
                                                  child: Icon(
                                                    !lstAddAddonsCustom[index].isCheck ? Icons.check_box_outline_blank : Icons.check_box,
                                                    color: isDarkMode(context) ? null : Colors.grey,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                  Visibility(
                    visible: widget.productModel.specification.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: widget.productModel.specification.isNotEmpty,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Specification".tr(),
                                    style:
                                        TextStyle(fontFamily: AppThemeData.regular, fontSize: 20, color: isDarkMode(context) ? const Color(0xffffffff) : const Color(0xff000000)),
                                  ),
                                ),
                                widget.productModel.specification.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: widget.productModel.specification.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(widget.productModel.specification.keys.elementAt(index) + " : ",
                                                    style: TextStyle(color: Colors.black.withOpacity(0.60), fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: 14)),
                                                Text(widget.productModel.specification.values.elementAt(index),
                                                    style: TextStyle(color: Colors.black.withOpacity(0.90), fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: 14)),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: storeProductList.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "More From the store".tr(),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.bold,
                                        fontSize: 16,
                                        color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "See All".tr(),
                                      style: TextStyle(fontSize: 16, color: isDarkMode(context) ? const Color(0xffffffff) : AppThemeData.primary300),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.24,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: storeProductList.length > 6 ? 6 : storeProductList.length,
                                    itemBuilder: (context, index) {
                                      ProductModel productModel = storeProductList[index];
                                      String price = "0.0";
                                      String disPrice = "0.0";
                                      List<String> selectedVariants = [];
                                      List<String> selectedIndexVariants = [];
                                      List<String> selectedIndexArray = [];
                                      if (productModel.itemAttributes != null) {
                                        if (productModel.itemAttributes!.attributes!.isNotEmpty) {
                                          for (var element in productModel.itemAttributes!.attributes!) {
                                            if (element.attributeOptions!.isNotEmpty) {
                                              selectedVariants.add(productModel
                                                  .itemAttributes!.attributes![productModel.itemAttributes!.attributes!.indexOf(element)].attributeOptions![0]
                                                  .toString());
                                              selectedIndexVariants.add(
                                                  '${productModel.itemAttributes!.attributes!.indexOf(element)} _${productModel.itemAttributes!.attributes![0].attributeOptions![0].toString()}');
                                              selectedIndexArray.add('${productModel.itemAttributes!.attributes!.indexOf(element)}_0');
                                            }
                                          }
                                        }
                                        if (productModel.itemAttributes!.variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                          price = productCommissionPrice(
                                              productModel.itemAttributes!.variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ??
                                                  '0');
                                          disPrice = productCommissionPrice('0');
                                        }
                                      } else {
                                        price = productCommissionPrice(productModel.price);
                                        disPrice = productCommissionPrice(productModel.disPrice.toString());
                                      }
                                      return Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        child: GestureDetector(
                                          onTap: () async {
                                            VendorModel? vendorModel = await FireStoreUtils.getVendor(storeProductList[index].vendorID);
                                            if (vendorModel != null) {
                                              push(
                                                context,
                                                ProductDetailsScreen(
                                                  vendorModel: vendorModel,
                                                  productModel: productModel,
                                                ),
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.38,
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: Color(0x05000000),
                                                    blurRadius: 32,
                                                    offset: Offset(0, 0),
                                                    spreadRadius: 0,
                                                  )
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        child: CachedNetworkImage(
                                                      imageUrl: getImageVAlidUrl(productModel.photo),
                                                      imageBuilder: (context, imageProvider) => Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
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
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      fit: BoxFit.contain,
                                                    )),
                                                    const SizedBox(height: 8),
                                                    Text(productModel.name,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          letterSpacing: 0.5,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        )).tr(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.green,
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                    productModel.reviewsCount != 0
                                                                        ? (productModel.reviewsSum / productModel.reviewsCount).toStringAsFixed(1)
                                                                        : 0.toString(),
                                                                    style: const TextStyle(
                                                                      letterSpacing: 0.5,
                                                                      color: Colors.white,
                                                                    )),
                                                                const SizedBox(width: 3),
                                                                const Icon(
                                                                  Icons.star,
                                                                  size: 16,
                                                                  color: Colors.white,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        disPrice == "" || disPrice == productCommissionPrice('0')
                                                            ? Text(
                                                                "${amountShow(amount: price)}",
                                                                style: TextStyle(letterSpacing: 0.5, color: AppThemeData.primary300),
                                                              )
                                                            : Column(
                                                                children: [
                                                                  Text(
                                                                    "${amountShow(amount: disPrice)}",
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14,
                                                                      color: AppThemeData.primary300,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${amountShow(amount: price)}',
                                                                    style: const TextStyle(
                                                                        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                                                  ),
                                                                ],
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ))
                          ],
                        ),
                      )),
                  Visibility(
                      visible: productList.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Related Products".tr(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.bold,
                                fontSize: 16,
                                color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.24,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: productList.length > 6 ? 6 : productList.length,
                                  itemBuilder: (context, index) {
                                    ProductModel productModel = productList[index];
                                    String price = "0.0";
                                    String disPrice = "0.0";
                                    List<String> selectedVariants = [];
                                    List<String> selectedIndexVariants = [];
                                    List<String> selectedIndexArray = [];
                                    if (productModel.itemAttributes != null) {
                                      if (productModel.itemAttributes!.attributes!.isNotEmpty) {
                                        for (var element in productModel.itemAttributes!.attributes!) {
                                          if (element.attributeOptions!.isNotEmpty) {
                                            selectedVariants.add(productModel
                                                .itemAttributes!.attributes![productModel.itemAttributes!.attributes!.indexOf(element)].attributeOptions![0]
                                                .toString());
                                            selectedIndexVariants.add(
                                                '${productModel.itemAttributes!.attributes!.indexOf(element)} _${productModel.itemAttributes!.attributes![0].attributeOptions![0].toString()}');
                                            selectedIndexArray.add('${productModel.itemAttributes!.attributes!.indexOf(element)}_0');
                                          }
                                        }
                                      }
                                      if (productModel.itemAttributes!.variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty) {
                                        price = productCommissionPrice(
                                            productModel.itemAttributes!.variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_price ??
                                                '0');
                                        disPrice = productCommissionPrice('0');
                                      }
                                    } else {
                                      price = productCommissionPrice(productModel.price);
                                      disPrice = productCommissionPrice(productModel.disPrice.toString());
                                    }
                                    return Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          VendorModel? vendorModel = await FireStoreUtils.getVendor(productModel.vendorID);
                                          if (vendorModel != null) {
                                            push(
                                              context,
                                              ProductDetailsScreen(
                                                vendorModel: vendorModel,
                                                productModel: productModel,
                                              ),
                                            );
                                          }
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.38,
                                          child: Container(
                                            decoration: ShapeDecoration(
                                              color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: Color(0x05000000),
                                                  blurRadius: 32,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: CachedNetworkImage(
                                                    imageUrl: getImageVAlidUrl(productModel.photo),
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
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )),
                                                  const SizedBox(height: 8),
                                                  Text(productModel.name,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        letterSpacing: 0.5,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      )).tr(),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                  productModel.reviewsCount != 0
                                                                      ? (productModel.reviewsSum / productModel.reviewsCount).toStringAsFixed(1)
                                                                      : 0.toString(),
                                                                  style: const TextStyle(
                                                                    letterSpacing: 0.5,
                                                                    color: Colors.white,
                                                                  )),
                                                              const SizedBox(width: 3),
                                                              const Icon(
                                                                Icons.star,
                                                                size: 16,
                                                                color: Colors.white,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      disPrice == "" || disPrice == "0" || disPrice == productCommissionPrice('0')
                                                          ? Text(
                                                              "${amountShow(amount: price)}",
                                                              style: TextStyle(letterSpacing: 0.5, color: AppThemeData.primary300),
                                                            )
                                                          : Column(
                                                              children: [
                                                                Text(
                                                                  "${amountShow(amount: disPrice)}",
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: AppThemeData.primary300,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  amountShow(amount: price),
                                                                  style: const TextStyle(
                                                                      fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                                                ),
                                                              ],
                                                            ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ))
                          ],
                        ),
                      )),
                  Visibility(
                    visible: widget.productModel.reviewAttributes!.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "By Feature".tr(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.bold,
                              fontSize: 16,
                              color: isDarkMode(context) ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          widget.productModel.reviewAttributes != null
                              ? Container(
                                  decoration: ShapeDecoration(
                                    color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x05000000),
                                        blurRadius: 32,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                      itemCount: widget.productModel.reviewAttributes!.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        ReviewAttributeModel reviewAttribute = ReviewAttributeModel();
                                        for (var element in reviewAttributeList) {
                                          if (element.id == widget.productModel.reviewAttributes!.keys.elementAt(index)) {
                                            reviewAttribute = element;
                                          }
                                        }
                                        ReviewsAttribute reviewsAttributeModel = ReviewsAttribute.fromJson(widget.productModel.reviewAttributes!.values.elementAt(index));
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                  child: Text(reviewAttribute.title.toString(),
                                                      style: TextStyle(
                                                          color: isDarkMode(context) ? Colors.white : Colors.black.withOpacity(0.60),
                                                          fontWeight: FontWeight.w500,
                                                          letterSpacing: 0.5,
                                                          fontSize: 14))),
                                              RatingBar.builder(
                                                ignoreGestures: true,
                                                initialRating: (reviewsAttributeModel.reviewsSum!.toDouble() / reviewsAttributeModel.reviewsCount!.toDouble()),
                                                minRating: 1,
                                                itemSize: 20,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemBuilder: (context, _) => Icon(
                                                  Icons.star,
                                                  color: AppThemeData.primary300,
                                                ),
                                                onRatingUpdate: (double rate) {
                                                  // ratings = rate;
                                                  // print(ratings);
                                                },
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                (reviewsAttributeModel.reviewsSum!.toDouble() / reviewsAttributeModel.reviewsCount!.toDouble()).toStringAsFixed(1),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: reviewList.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListView.builder(
                            itemCount: reviewList.length > 10 ? 10 : reviewList.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: isDarkMode(context) ? AppThemeData.grey900 : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x05000000),
                                        blurRadius: 32,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ), // Change this
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              height: 45,
                                              width: 45,
                                              imageUrl: getImageVAlidUrl(reviewList[index].profile.toString()),
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(35),
                                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) => Center(
                                                  child: CircularProgressIndicator.adaptive(
                                                valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                                              )),
                                              errorWidget: (context, url, error) => ClipRRect(
                                                  borderRadius: BorderRadius.circular(35),
                                                  child: Image.network(
                                                    placeholderImage,
                                                    fit: BoxFit.cover,
                                                  )),
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    reviewList[index].uname.toString(),
                                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, letterSpacing: 1, fontSize: 16),
                                                  ),
                                                  RatingBar.builder(
                                                    ignoreGestures: true,
                                                    initialRating: reviewList[index].rating ?? 0.0,
                                                    minRating: 1,
                                                    itemSize: 22,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemPadding: const EdgeInsets.only(top: 5.0),
                                                    itemBuilder: (context, _) => Icon(
                                                      Icons.star,
                                                      color: AppThemeData.primary300,
                                                    ),
                                                    onRatingUpdate: (double rate) {
                                                      // ratings = rate;
                                                      // print(ratings);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(orderDate(reviewList[index].createdAt),
                                                style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : const Color(0XFF555353))),
                                          ],
                                        ),
                                        // const Padding(
                                        //   padding: EdgeInsets.symmetric(vertical: 8),
                                        //   child: Divider(
                                        //     thickness: 2,
                                        //   ),
                                        // ),
                                        Text(reviewList[index].comment.toString(),
                                            style: TextStyle(color: Colors.black.withOpacity(0.70), fontWeight: FontWeight.w400, letterSpacing: 1, fontSize: 14)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        reviewList[index].photos!.isNotEmpty
                                            ? SizedBox(
                                                height: 75,
                                                child: ListView.builder(
                                                  itemCount: reviewList[index].photos!.length,
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (context, index1) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: CachedNetworkImage(
                                                        height: 65,
                                                        width: 65,
                                                        imageUrl: getImageVAlidUrl(reviewList[index].photos![index1]),
                                                        imageBuilder: (context, imageProvider) => Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                          ),
                                                        ),
                                                        placeholder: (context, url) => Center(
                                                            child: CircularProgressIndicator.adaptive(
                                                          valueColor: AlwaysStoppedAnimation(AppThemeData.primary300),
                                                        )),
                                                        errorWidget: (context, url, error) => ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Image.network(
                                                              placeholderImage,
                                                              fit: BoxFit.cover,
                                                            )),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        RoundedButtonFill(
                          title: "See All Reviews".tr(),
                          color: AppThemeData.primary300,
                          textColor: AppThemeData.grey50,
                          onPress: () async {
                            push(
                              context,
                              Review(
                                productModel: widget.productModel,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: sectionConstantModel!.serviceTypeFlag == "ecommerce-service"
          ? Container(
              color: AppThemeData.primary300,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Item Total".tr() + " " + amountShow(amount: priceTemp.toString()),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ).tr(),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (MyAppState.currentUser == null) {
                        push(context, const LoginScreen());
                      } else {
                        if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
                          pushAndRemoveUntil(
                              context,
                              EcommeceDashBoardScreen(
                                user: MyAppState.currentUser!,
                                drawerSelection: DrawerSelectionEcommarce.Cart,
                                currentWidget: const CartScreen(),
                                appBarTitle: 'Your Cart',
                              ));
                        } else {
                          pushAndRemoveUntil(
                              context,
                              ContainerScreen(
                                user: MyAppState.currentUser!,
                                drawerSelection: DrawerSelection.Cart,
                                currentWidget: const CartScreen(),
                                appBarTitle: 'Your Cart',
                              ));
                        }
                      }
                    },
                    child: Text(
                      "VIEW CART".tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ).tr(),
                  )
                ],
              ),
            )
          : isOpen
              ? Container(
                  color: AppThemeData.primary300,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Item Total".tr() + " " + amountShow(amount: priceTemp.toString()),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ).tr(),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (MyAppState.currentUser == null) {
                            push(context, const LoginScreen());
                          } else {
                            if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
                              pushAndRemoveUntil(
                                  context,
                                  EcommeceDashBoardScreen(
                                    user: MyAppState.currentUser!,
                                    drawerSelection: DrawerSelectionEcommarce.Cart,
                                    currentWidget: const CartScreen(),
                                    appBarTitle: 'Your Cart',
                                  ));
                            } else {
                              pushAndRemoveUntil(
                                  context,
                                  ContainerScreen(
                                    user: MyAppState.currentUser!,
                                    drawerSelection: DrawerSelection.Cart,
                                    currentWidget: const CartScreen(),
                                    appBarTitle: 'Your Cart',
                                  ));
                            }
                          }
                        },
                        child: Text(
                          "VIEW CART".tr(),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ).tr(),
                      )
                    ],
                  ),
                )
              : null,
    );
  }

  addtocard(ProductModel productModel, bool isIncerementQuantity) async {
    bool isAddOnApplied = false;
    double AddOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      if (addAddonsDemo.categoryID == widget.productModel.id) {
        isAddOnApplied = true;
        AddOnVal = AddOnVal + double.parse(productCommissionPrice(addAddonsDemo.price!));
      }
    }
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    print("------------>${isIncerementQuantity}");
    if (productQnt > 1) {
      var joinTitleString = "";
      String mainPrice = "";
      List<AddAddonsDemo> lstAddOns = [];
      List<String> lstAddOnsTemp = [];
      double extras_price = 0.0;

      SharedPreferences sp = await SharedPreferences.getInstance();
      String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";

      bool isAddSame = false;
      if (!isAddSame) {
        if (productModel.disPrice != null && productModel.disPrice!.isNotEmpty && double.parse(productModel.disPrice!) != 0) {
          mainPrice = productModel.disPrice!;
        } else {
          mainPrice = productModel.price;
        }
      }

      if (addOns.isNotEmpty) {
        lstAddOns = AddAddonsDemo.decode(addOns);
        for (int a = 0; a < lstAddOns.length; a++) {
          AddAddonsDemo newAddonsObject = lstAddOns[a];
          if (newAddonsObject.categoryID == widget.productModel.id) {
            if (newAddonsObject.isCheck == true) {
              lstAddOnsTemp.add(newAddonsObject.name!);
              extras_price += (double.parse(newAddonsObject.price!));
            }
          }
        }

        joinTitleString = lstAddOnsTemp.join(",");
      }

      print("------------>${productQnt}");

      final bool _productIsInList =
          cartProducts.any((product) => product.id == productModel.id + "~" + (productModel.variant_info != null ? productModel.variant_info!.variant_id.toString() : ""));
      if (_productIsInList) {
        CartProduct element =
            cartProducts.firstWhere((product) => product.id == productModel.id + "~" + (productModel.variant_info != null ? productModel.variant_info!.variant_id.toString() : ""));

        await cartDatabase.updateProduct(CartProduct(
            id: element.id,
            name: element.name,
            photo: element.photo,
            price: element.price,
            vendorID: element.vendorID,
            quantity: isIncerementQuantity ? element.quantity + 1 : element.quantity,
            category_id: element.category_id,
            extras_price: extras_price.toString(),
            extras: joinTitleString,
            discountPrice: element.discountPrice!));
      } else {
        await cartDatabase.updateProduct(CartProduct(
            id: productModel.id + "~" + (productModel.variant_info != null ? productModel.variant_info!.variant_id.toString() : ""),
            name: productModel.name,
            photo: productModel.photo,
            price: mainPrice,
            discountPrice: productModel.disPrice,
            vendorID: productModel.vendorID,
            quantity: productQnt,
            extras_price: extras_price.toString(),
            extras: joinTitleString,
            category_id: productModel.categoryID,
            variant_info: productModel.variant_info));
      }
      //  });
      setState(() {});
    } else {
      if (cartProducts.isEmpty) {
        cartDatabase.addProduct(productModel, cartDatabase, isIncerementQuantity);
      } else {
        if (cartProducts[0].vendorID == widget.vendorModel.id) {
          cartDatabase.addProduct(productModel, cartDatabase, isIncerementQuantity);
        } else {
          cartDatabase.deleteAllProducts();
          cartDatabase.addProduct(productModel, cartDatabase, isIncerementQuantity);

          if (isAddOnApplied && AddOnVal > 0) {
            priceTemp += (AddOnVal * productQnt);
          }
        }
      }
    }
    updatePrice();
  }

  removetocard(ProductModel productModel, bool isIncerementQuantity) async {
    bool isAddOnApplied = false;
    double AddOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      isAddOnApplied = true;
      AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
    }
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;

    print("---->${productQnt}");
    if (productQnt >= 1) {
      //setState(() async {

      var joinTitleString = "";
      String mainPrice = "";
      List<AddAddonsDemo> lstAddOns = [];
      List<String> lstAddOnsTemp = [];
      double extras_price = 0.0;

      SharedPreferences sp = await SharedPreferences.getInstance();
      String addOns = sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";

      bool isAddSame = false;
      if (!isAddSame) {
        if (productModel.disPrice != null && productModel.disPrice!.isNotEmpty && double.parse(productModel.disPrice!) != 0) {
          mainPrice = productModel.disPrice!;
        } else {
          mainPrice = productModel.price;
        }
      }

      if (addOns.isNotEmpty) {
        lstAddOns = AddAddonsDemo.decode(addOns);
        for (int a = 0; a < lstAddOns.length; a++) {
          AddAddonsDemo newAddonsObject = lstAddOns[a];
          if (newAddonsObject.categoryID == widget.productModel.id) {
            if (newAddonsObject.isCheck == true) {
              lstAddOnsTemp.add(newAddonsObject.name!);
              extras_price += (double.parse(newAddonsObject.price!));
            }
          }
        }

        joinTitleString = lstAddOnsTemp.join(",");
      }

      final bool _productIsInList = cartProducts.any((product) =>
          product.id ==
          productModel.id +
              "~" +
              (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                  ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
                  : ""));
      if (_productIsInList) {
        CartProduct element = cartProducts.firstWhere((product) =>
            product.id ==
            productModel.id +
                "~" +
                (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                    ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
                    : ""));
        print("------------>${element.quantity}");
        await cartDatabase.updateProduct(CartProduct(
            id: element.id,
            name: element.name,
            photo: element.photo,
            price: element.price,
            vendorID: element.vendorID,
            quantity: isIncerementQuantity ? element.quantity - 1 : element.quantity,
            category_id: element.category_id,
            extras_price: extras_price.toString(),
            extras: joinTitleString,
            discountPrice: element.discountPrice!));
      } else {
        await cartDatabase.updateProduct(CartProduct(
            id: productModel.id +
                "~" +
                (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
                    ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
                    : ""),
            name: productModel.name,
            photo: productModel.photo,
            price: mainPrice,
            discountPrice: productModel.disPrice,
            vendorID: productModel.vendorID,
            quantity: productQnt,
            extras_price: extras_price.toString(),
            extras: joinTitleString,
            category_id: productModel.categoryID,
            variant_info: productModel.variant_info));
      }
    } else {
      cartDatabase.removeProduct(productModel.id +
          "~" +
          (variants!.where((element) => element.variant_sku == selectedVariants.join('-')).isNotEmpty
              ? variants!.where((element) => element.variant_sku == selectedVariants.join('-')).first.variant_id.toString()
              : ""));
      setState(() {
        productQnt = 0;
      });
    }
    updatePrice();
  }

  void getAddOnsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = prefs.getString('musics_key') != null ? prefs.getString('musics_key')! : "";

    if (musicsString.isNotEmpty) {
      setState(() {
        lstTemp = AddAddonsDemo.decode(musicsString);
      });
    }

    if (productQnt > 0) {
      lastPrice = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0"
          ? double.parse(widget.productModel.price)
          : double.parse(widget.productModel.disPrice!) * productQnt;
    }

    if (lstTemp.isEmpty) {
      setState(() {
        if (widget.productModel.addOnsTitle.isNotEmpty) {
          for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
            AddAddonsDemo addAddonsDemo =
                AddAddonsDemo(name: widget.productModel.addOnsTitle[a], index: a, isCheck: false, categoryID: widget.productModel.id, price: widget.productModel.addOnsPrice[a]);
            lstAddAddonsCustom.add(addAddonsDemo);
            //saveAddonData(lstAddAddonsCustom);
          }
        }
      });
    } else {
      var tempArray = [];

      for (int d = 0; d < lstTemp.length; d++) {
        if (lstTemp[d].categoryID == widget.productModel.id) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(name: lstTemp[d].name, index: lstTemp[d].index, isCheck: true, categoryID: lstTemp[d].categoryID, price: lstTemp[d].price);
          tempArray.add(addAddonsDemo);
        }
      }
      for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
        var isAddonSelected = false;

        for (int temp = 0; temp < tempArray.length; temp++) {
          if (tempArray[temp].name == widget.productModel.addOnsTitle[a]) {
            isAddonSelected = true;
          }
        }
        if (isAddonSelected) {
          AddAddonsDemo addAddonsDemo =
              AddAddonsDemo(name: widget.productModel.addOnsTitle[a], index: a, isCheck: true, categoryID: widget.productModel.id, price: widget.productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        } else {
          AddAddonsDemo addAddonsDemo =
              AddAddonsDemo(name: widget.productModel.addOnsTitle[a], index: a, isCheck: false, categoryID: widget.productModel.id, price: widget.productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        }
      }
    }
    updatePrice();
  }

  void saveAddOns(List<AddAddonsDemo> lstTempDemo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = AddAddonsDemo.encode(lstTempDemo);
    await prefs.setString('musics_key', encodedData);
  }

  void clearAddOnData() {
    bool isAddOnApplied = false;
    double AddOnVal = 0;

    for (int i = 0; i < lstTemp.length; i++) {
      if (lstTemp[i].categoryID == widget.productModel.id) {
        AddAddonsDemo addAddonsDemo = lstTemp[i];
        isAddOnApplied = true;
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    if (isAddOnApplied && AddOnVal > 0 && productQnt > 0) {
      priceTemp -= (AddOnVal * productQnt);
    }
  }

  void updatePrice() {
    double AddOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      if (addAddonsDemo.categoryID == widget.productModel.id) {
        AddOnVal = AddOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    List<CartProduct> cartProducts = [];
    Future.delayed(const Duration(milliseconds: 500), () {
      cartProducts.clear();

      cartDatabase.allCartProducts.then((value) {
        priceTemp = 0;
        cartProducts.addAll(value);
        for (int i = 0; i < cartProducts.length; i++) {
          CartProduct e = cartProducts[i];
          if (e.extras_price != null && e.extras_price != "" && double.parse(e.extras_price!) != 0) {
            priceTemp += double.parse(e.extras_price!) * e.quantity;
          }
          priceTemp += double.parse(e.price) * e.quantity;
        }
        setState(() {});
      });
    });
  }

  Widget _buildChip(String label, int attributesOptionIndex, bool isSelected) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: isSelected ? AppThemeData.primary300 : Colors.white,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: const EdgeInsets.all(8.0),
    );

    // Container(
    //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xffABBCC8), width: 0.5)),
    //   child: Padding(
    //     padding: const EdgeInsets.all(2.0),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: isSelected ? AppThemeData.primary300 : Colors.white,
    //         borderRadius: BorderRadius.circular(30),
    //       ),
    //       child: Center(
    //         child: Text(
    //           label,
    //           style: TextStyle(
    //             color: isSelected ? Colors.white : Colors.black,
    //           ),
    //         ),
    //       ),
    //       // child: Chip(
    //       //   label: Text(
    //       //     label,
    //       //     style: const TextStyle(
    //       //       color: Colors.white,
    //       //     ),
    //       //   ),
    //       //   backgroundColor: colors,
    //       //   elevation: 6.0,
    //       //   shadowColor: Colors.grey[60],
    //       //   padding: const EdgeInsets.all(8.0),
    //       // ),
    //     ),
    //   ),
    // );
  }
}

class AddAddonsDemo {
  String? name;
  int? index;
  String? price;
  bool isCheck;
  String? categoryID;

  AddAddonsDemo({this.name, this.index, this.price, this.isCheck = false, this.categoryID});

  static Map<String, dynamic> toMap(AddAddonsDemo music) =>
      {'index': music.index, 'name': music.name, 'price': music.price, 'isCheck': music.isCheck, "categoryID": music.categoryID};

  factory AddAddonsDemo.fromJson(Map<String, dynamic> jsonData) {
    return AddAddonsDemo(index: jsonData['index'], name: jsonData['name'], price: jsonData['price'], isCheck: jsonData['isCheck'], categoryID: jsonData["categoryID"]);
  }

  static String encode(List<AddAddonsDemo> item) => json.encode(
        item.map<Map<String, dynamic>>((item) => AddAddonsDemo.toMap(item)).toList(),
      );

  static List<AddAddonsDemo> decode(String item) => (json.decode(item) as List<dynamic>).map<AddAddonsDemo>((item) => AddAddonsDemo.fromJson(item)).toList();

  @override
  String toString() {
    return '{name: $name, index: $index, price: $price, isCheck: $isCheck, categoryID: $categoryID}';
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'index': index, 'price': price, 'isCheck': isCheck, 'categoryID': categoryID};
  }
}

class SharedData {
  bool? isCheckedValue;
  String? categoryId;

  SharedData({this.categoryId, this.isCheckedValue});
}
