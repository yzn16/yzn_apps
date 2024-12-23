import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartstore/constants.dart';
import 'package:emartstore/main.dart';
import 'package:emartstore/model/User.dart';
import 'package:emartstore/model/VendorModel.dart';
import 'package:emartstore/services/FirebaseHelper.dart';
import 'package:emartstore/services/helper.dart';
import 'package:emartstore/services/show_toast_dailog.dart';
import 'package:emartstore/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:emartstore/ui/auth/AuthScreen.dart';
import 'package:emartstore/ui/settings/SettingsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late User user;
  late VendorModel vendor;
  bool? isLoader = false;
  Stream? userStream;
  @override
  void initState() {
    //user = widget.user;
    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        MyAppState.currentUser = value;
        isLoader = true;
      });
    });
    userStream = FireStoreUtils.getCurrentUserStream(MyAppState.currentUser!.userID);

    userStream!.listen((event) {
      setState(() {
        user = event;
        MyAppState.currentUser = event;
        print("===123+");
        print(user.firstName);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isLoader!
          ? Center(
              child: CircularProgressIndicator(color: Color(COLOR_PRIMARY)),
            )
          : SingleChildScrollView(
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, left: 32, right: 32),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Center(child: displayCircleImage(user.profilePictureURL, 130, false)),
                      Positioned(
                        right: 120,
                        child: ClipOval(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: FloatingActionButton(
                                backgroundColor: Color(COLOR_ACCENT),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: isDarkMode(context) ? Colors.black : Colors.white,
                                ),
                                mini: true,
                                onPressed: _onCameraClick),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
                  child: Text(
                    user.fullName(),
                    style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () async {
                          vendor = (await FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID))!;
                          //push(context, new AccountDetailsScreen(/*user: user,*/ vendor:vendor));
                          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => AccountDetailsScreen(/*user: user,*/ vendor: vendor))).then((value) {
                            if (value != null) {
                              setState(() {
                                FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
                                  setState(() {
                                    user = value!;
                                    MyAppState.currentUser = value;
                                  });
                                });
                              });
                            }
                          });
                          print(vendor);
                        },
                        title: Text(
                          'Account Details',
                          style: TextStyle(fontSize: 16),
                        ).tr(),
                        leading: Icon(
                          CupertinoIcons.person_alt,
                          color: Colors.blue,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          push(context, new SettingsScreen(/*user: user*/));
                        },
                        title: Text(
                          'Settings',
                          style: TextStyle(fontSize: 16),
                        ).tr(),
                        leading: Icon(
                          CupertinoIcons.settings,
                          color: Colors.grey,
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          showDeleteAccountAlertDialog(context);
                          // AuthProviders? authProvider;
                          // List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
                          // await Future.forEach(userInfoList, (auth.UserInfo info) {
                          //   switch (info.providerId) {
                          //     case 'password':
                          //       authProvider = AuthProviders.PASSWORD;
                          //       break;
                          //     case 'phone':
                          //       authProvider = AuthProviders.PHONE;
                          //       break;
                          //     case 'facebook.com':
                          //       authProvider = AuthProviders.FACEBOOK;
                          //       break;
                          //     case 'apple.com':
                          //       authProvider = AuthProviders.APPLE;
                          //       break;
                          //   }
                          // });
                          // bool? result = await showDialog(
                          //   context: context,
                          //   builder: (context) => ReAuthUserScreen(
                          //     provider: authProvider!,
                          //     email: auth.FirebaseAuth.instance.currentUser!.email,
                          //     phoneNumber: auth.FirebaseAuth.instance.currentUser!.phoneNumber,
                          //     deleteUser: true,
                          //   ),
                          // );
                          // if (result != null && result) {
                          //   ShowToastDialog.showLoader( "DeletingAccount".tr());
                          //   await FireStoreUtils.deleteUser();
                          //   await auth.FirebaseAuth.instance.signOut();
                          //   ShowToastDialog.closeLoader();
                          //   MyAppState.currentUser = null;
                          //   pushAndRemoveUntil(context, AuthScreen(), false);
                          // }
                        },
                        title: Text(
                          'Delete Account',
                          style: TextStyle(fontSize: 16),
                        ).tr(),
                        leading: Icon(
                          CupertinoIcons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200)),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode(context) ? Colors.white : Colors.black),
                      ).tr(),
                      onPressed: () async {
                        user.fcmToken = "";
                        user.lastOnlineTimestamp = Timestamp.now();
                        await FireStoreUtils.updateCurrentUser(user);
                        await auth.FirebaseAuth.instance.signOut();
                        MyAppState.currentUser = null;
                        pushAndRemoveUntil(context, AuthScreen(), false);
                      },
                    ),
                  ),
                ),
              ]),
            ),
    );
  }


  showDeleteAccountAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Ok".tr()),
      onPressed: () async {
        ShowToastDialog.showLoader("Please wait"..tr());
        await FireStoreUtils.deleteUser();

        MyAppState.currentUser = null;
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Account delete successfully"..tr());
        pushAndRemoveUntil(context,  AuthScreen(), false);
      },
    );
    Widget cancel = TextButton(
      child: Text("Cancel".tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Account delete".tr()),
      content: Text("Are you sure want to delete Account.".tr()),
      actions: [
        okButton,
        cancel,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Profile Picture',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            ShowToastDialog.showLoader('Removing Picture...'.tr());
            user.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            ShowToastDialog.closeLoader();
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Future<void> _imagePicked(File image) async {
    ShowToastDialog.showLoader('Uploading image...'.tr());
    user.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(image, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    ShowToastDialog.closeLoader();
  }
}
