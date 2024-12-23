import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/show_toast_dialog.dart';
import 'package:emartconsumer/theme/app_them_data.dart';
import 'package:emartconsumer/ui/auth_screen/login_screen.dart';

import 'package:emartconsumer/ui/container/ContainerScreen.dart';
import 'package:emartconsumer/ui/vendorProductsScreen/NewVendorProductsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key, required this.presectionList}) : super(key: key);
  final List<SectionModel> presectionList;

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {

  @override
  void initState() {
    super.initState();}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? AppThemeData.surfaceDark : AppThemeData.surface,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "QR Code Scanner".tr(),
            style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.normal, color: isDarkMode(context) ? Colors.white : Colors.black),
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
        body: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: MobileScanner(
                // fit: BoxFit.contain,
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {

                    if (allstoreList.isNotEmpty) {
                      if (allstoreList.where((element) => element.id == barcodes.first.rawValue).isNotEmpty) {
                        VendorModel vendorModel = allstoreList.firstWhere((element) => element.id == barcodes.first.rawValue);
                        Navigator.pop(context);
                        push(context, NewVendorProductsScreen(vendorModel: vendorModel));
                      }else{
                        ShowToastDialog.showToast("Store is not available");
                      }
                    } else {
                      ShowToastDialog.showToast("Store is not available");
                    }
                  }
                },
              ),
            )));
  }


  Future<void> callMainScreen(SectionModel sectionModel, String codeVal) async {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);

      if (user != null && user.role == USER_ROLE_CUSTOMER) {
        user.active = true;
        user.role = USER_ROLE_CUSTOMER;
        sectionConstantModel = sectionModel;
        AppThemeData.primary300 = Color(int.parse(sectionModel.color!.replaceFirst("#", "0xff")));
        user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
        await FireStoreUtils.updateCurrentUser(user);
        Navigator.of(context).pop();
        pushReplacement(
            context,
            ContainerScreen(
              user: user,
              vendorId: codeVal,
            ));
      } else {
        pushReplacement(context, const LoginScreen());
      }
    } else {
      sectionConstantModel = sectionModel;
      //SELECTED_CATEGORY = sectionModel.id.toString();
      // SELECTED_SECTION_NAME = sectionModel.name.toString();
      // isDineEnable = sectionModel.dineInActive!;
      AppThemeData.primary300 = Color(int.parse(sectionModel.color!.replaceFirst("#", "0xff")));
      push(context, ContainerScreen(user: null));
    }
  }
}
