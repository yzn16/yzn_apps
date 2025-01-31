import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartstore/main.dart';
import 'package:emartstore/model/VendorModel.dart';
import 'package:emartstore/services/FirebaseHelper.dart';
import 'package:emartstore/services/helper.dart';
import 'package:emartstore/services/show_toast_dailog.dart';
import 'package:emartstore/ui/offer/offer_model/offer_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../constants.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({Key? key, required this.offerModel}) : super(key: key);
  final OfferModel? offerModel;

  @override
  _AddOfferScreenState createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  var _result = "Fix Price".tr();
  final format = DateFormat("yyyy-MM-dd");
  TextEditingController txtCouponCode = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController txtAddPrice = TextEditingController();
  TextEditingController txtExpieryDate = TextEditingController();
  List<dynamic> _mediaFiles = [];
  bool isOfferEnable = false;
  bool isPublic = false;
  var downloadUrl = "";

  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  FireStoreUtils fireStoreUtils = FireStoreUtils();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVendor();
    if (widget.offerModel != null) {
      txtCouponCode.text = widget.offerModel!.code!;
      description.text = widget.offerModel!.description!;
      txtAddPrice.text = widget.offerModel!.discount!;
      txtExpieryDate.text = getDate(widget.offerModel!.expiresAt!.toDate().toString())!;
      _result = widget.offerModel!.discountType!;
      downloadUrl = widget.offerModel!.image!;
      isOfferEnable = widget.offerModel!.isEnabled!;
      isPublic = widget.offerModel!.isPublic!;
    }
  }

  VendorModel? vendorModel;
  getVendor() async {
    await FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID.toString())!.then(
      (value) {
        setState(() {
          vendorModel = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Create Offer".tr(),
            style: TextStyle(fontFamily: "Poppins", letterSpacing: 0.5, fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: isDarkMode(context) ? Colors.white : Colors.black,
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ), //isDarkMode(context) ? Color(COLOR_DARK) : null,
        body: Builder(builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.black12,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Coupon Code".tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: txtCouponCode,
                            validator: validateEmptyField,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                hintText: "Add coupon code".tr(),
                                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                hintStyle:
                                    TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                                )),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Title".tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: description,
                            validator: validateEmptyField,
                            maxLength: 30,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                hintText: "Enter Title".tr(),
                                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                hintStyle:
                                    TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                                )),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Select Coupon Type".tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.grey, disabledColor: Colors.grey),
                            child: RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Fix Price'.tr(),
                                  style: TextStyle(color: Colors.grey, fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                ),
                                value: "Fix Price".tr(),
                                groupValue: _result,
                                activeColor: Color(COLOR_PRIMARY),
                                onChanged: (value) {
                                  setState(() {
                                    _result = value!.toString();
                                    print(_result.toString());
                                  });
                                }),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.grey,
                              disabledColor: Colors.grey,
                            ),
                            child: RadioListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Percentage'.tr(),
                                  style: TextStyle(color: Colors.grey, fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                ),
                                value: "Percentage".tr(),
                                activeColor: Color(COLOR_PRIMARY),
                                groupValue: _result,
                                onChanged: (value) {
                                  setState(() {
                                    _result = value!.toString();
                                  });
                                }),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: txtAddPrice,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            decoration: InputDecoration(
                                hintText: _result == "Percentage".tr() ? "Add percentage".tr() : "Add price".tr(),
                                suffixIcon: Container(
                                  margin: EdgeInsets.only(top: 11, right: 0),
                                  child: Text(
                                    _result == "Percentage".tr() ? "%" : currencyData!.symbol,
                                    style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 22, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                hintStyle:
                                    TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                                )),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Expires at".tr(),
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DateTimeField(
                            format: format,
                            controller: txtExpieryDate,
                            validator: (date) => (txtExpieryDate.text == '') ? "This field can't be empty.".tr() : null,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                hintText: "Select date".tr(),
                                hintStyle:
                                    TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode(context) ? Colors.white : Colors.black38, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.0),
                                )),
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: widget.offerModel == null ? DateTime.now() : widget.offerModel!.expiresAt!.toDate(),
                                  lastDate: DateTime(2100));
                            },
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          _mediaFiles.isEmpty == true
                              ? InkWell(
                                  onTap: () {
                                    _pickImage();
                                  },
                                  child: widget.offerModel == null
                                      ? Image(
                                          image: AssetImage("assets/images/add_offer_img.png"),
                                          width: MediaQuery.of(context).size.width * 1,
                                          height: MediaQuery.of(context).size.height * 0.12,
                                        )
                                      : widget.offerModel!.image == ""
                                          ? Image(
                                              image: AssetImage("assets/images/add_offer_img.png"),
                                              width: MediaQuery.of(context).size.width * 1,
                                              height: MediaQuery.of(context).size.height * 0.12,
                                            )
                                          : ClipRRect(
                                              borderRadius: new BorderRadius.circular(15.0),
                                              child: CachedNetworkImage(
                                                imageUrl: downloadUrl,
                                                height: 135,
                                                width: 135,
                                              )))
                              : _imageBuilder(_mediaFiles.first),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10), color: Colors.white, border: Border.all(color: isDarkMode(context) ? Colors.white : Colors.black38)),
                            padding: EdgeInsets.zero,
                            child: SwitchListTile.adaptive(
                                activeColor: Color(COLOR_ACCENT),
                                title: Text('Activate'.tr(), style: TextStyle(fontSize: 15, color: Color(0Xff696A75), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                                value: isOfferEnable,
                                onChanged: (bool newValue) async {
                                  setState(() {
                                    isOfferEnable = newValue;
                                  });
                                }),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10),
                                color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                                border: Border.all(color: isDarkMode(context) ? Colors.black87 : Colors.black38)),
                            padding: EdgeInsets.zero,
                            child: SwitchListTile.adaptive(
                                activeColor: Color(COLOR_ACCENT),
                                title: Text('Public'.tr(),
                                    style:
                                        TextStyle(fontSize: 15, color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                                value: isPublic,
                                onChanged: (bool newValue) async {
                                  setState(() {
                                    isPublic = newValue;
                                  });
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState?.validate() == false) {
                  } else {
                    await ShowToastDialog.showLoader(widget.offerModel == null ? 'Adding Offer...'.tr() : "Editing Offer...".tr());
                    if (_mediaFiles.length > 0) {
                      var uniqueID = Uuid().v4();
                      Reference upload = FirebaseStorage.instance.ref().child(STORAGE_ROOT +
                          'store/offerImages/$uniqueID'
                              '.png');

                      UploadTask uploadTask = upload.putFile(_mediaFiles.first);
                      uploadTask.whenComplete(() {}).catchError((onError) {
                        print((onError as PlatformException).message);
                      });
                      var storageRef = (await uploadTask.whenComplete(() {})).ref;
                      downloadUrl = await storageRef.getDownloadURL();
                      downloadUrl.toString();
                    }

                    Timestamp myTimeStamp = Timestamp.fromDate(DateTime.parse(txtExpieryDate.text.toString().trim()).toUtc());

                    OfferModel mOfferModel = widget.offerModel ?? OfferModel();
                    mOfferModel.code = txtCouponCode.text.toString().trim();
                    mOfferModel.description = description.text;
                    mOfferModel.discount = txtAddPrice.text.toString().trim();
                    mOfferModel.discountType = _result;
                    mOfferModel.image = downloadUrl;
                    mOfferModel.expiresAt = myTimeStamp;
                    mOfferModel.isEnabled = isOfferEnable;
                    mOfferModel.isPublic = isPublic;
                    mOfferModel.vendorID = MyAppState.currentUser!.vendorID;
                    mOfferModel.section_id = vendorModel!.section_id;

                    /*  mOfferModel.code = txtCouponCode.text.toString().trim();
                    mOfferModel.description = "";
                    mOfferModel.discount = txtAddPrice.text.toString().trim();
                    mOfferModel.discountType = _result;
                    mOfferModel.image = downloadUrl;
                    mOfferModel.expiresAt = myTimeStamp;
                    mOfferModel.isEnabled = isOfferEnable;
                    mOfferModel.vendorID = MyAppState.currentUser!.vendorID;
                    mOfferModel.section_id = MyAppState.currentUser!.section_id;*/

                    widget.offerModel == null ? fireStoreUtils.addOffer(mOfferModel, context) : fireStoreUtils.updateOffer(mOfferModel, context);
                    await ShowToastDialog.closeLoader();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(25, 0, 25, 20),
                  padding: EdgeInsets.fromLTRB(15, 12, 15, 12),
                  decoration: new BoxDecoration(
                    color: Color(COLOR_PRIMARY),
                    borderRadius: new BorderRadius.circular(7),
                  ),
                  child: Text(
                    widget.offerModel == null ? "Create Coupon".tr() : "Edit Coupon".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          );
        }));
  }

  @override
  void dispose() {
    txtExpieryDate.dispose();
    txtAddPrice.dispose();
    txtCouponCode.dispose();
    super.dispose();
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _imageBuilder(dynamic image) {
    // bool isLastItem = image == null;
    return GestureDetector(
      onTap: () {
        // _viewOrDeleteImage(image);
      },
      child: Container(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                  )
                : displayImage(image),
          ),
        ),
      ),
    );
  }

  String? getDate(String date) {
    final format = DateFormat("yyyy-MM-dd");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }
}
