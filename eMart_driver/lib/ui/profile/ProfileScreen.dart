import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/show_toast_dialog.dart';
import 'package:emartdriver/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/contactUs/ContactUsScreen.dart';
import 'package:emartdriver/ui/reauthScreen/reauth_user_screen.dart';
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

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 32, right: 32),
            child: SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Center(child: displayCircleImage(user.profilePictureURL, 130, false)),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        start: 80,
                        end: 0,
                        child: FloatingActionButton(
                            heroTag: 'userImage',
                            backgroundColor: Color(COLOR_ACCENT),
                            child: Icon(
                              Icons.camera_alt,
                              color: isDarkMode(context) ? Colors.black : Colors.white,
                            ),
                            mini: true,
                            onPressed: () => _onCameraClick(true)),
                      )
                    ],
                  ),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Center(child: displayCarImage(user.carPictureURL, 130, false)),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        start: 80,
                        end: 0,
                        child: FloatingActionButton(
                            heroTag: 'carImage',
                            backgroundColor: Color(COLOR_ACCENT),
                            child: Icon(
                              Icons.camera_alt,
                              color: isDarkMode(context) ? Colors.black : Colors.white,
                            ),
                            mini: true,
                            onPressed: () => _onCameraClick(false)),
                      )
                    ],
                  ),
                ],
              ),
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
                  onTap: () {
                    push(context, AccountDetailsScreen(user: user));
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
                // ListTile(
                //   onTap: () {
                //     push(context, SettingsScreen(user: user));
                //   },
                //   title: Text(
                //     'Settings',
                //     style: TextStyle(fontSize: 16),
                //   ).tr(),
                //   leading: Icon(
                //     CupertinoIcons.settings,
                //     color: Colors.grey,
                //   ),
                // ),

                ListTile(
                  onTap: () {
                    push(context, ContactUsScreen());
                  },
                  title: Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 16),
                  ).tr(),
                  leading: Hero(
                    tag: 'contactUs',
                    child: Icon(
                      CupertinoIcons.phone_solid,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    showDeleteAccountAlertDialog(context);
                  },
                  title: Text(
                    'Delete Account'.tr(),
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
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                ),
                child: Text(
                  'Logout'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode(context) ? Colors.white : Colors.black),
                ).tr(),
                onPressed: () async {
                  user.isActive = false;
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
        ShowToastDialog.showToast("Account delete"..tr());
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


  _onCameraClick(bool isUserImage) {
    final action = CupertinoActionSheet(
      message: Text(
        isUserImage ? 'Add Profile Picture'.tr() : 'Add Car Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            showProgress(context, 'Removing Picture...'.tr(), false);
            isUserImage ? user.profilePictureURL = '' : user.carPictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            hideProgress();
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path), isUserImage);
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
              await _imagePicked(File(image.path), isUserImage);
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

  Future<void> _imagePicked(File image, bool isUserImage) async {
    showProgress(context, isUserImage ? 'Uploading image...'.tr() : 'Uploading car image...'.tr(), false);
    if (isUserImage)
      user.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(image, user.userID);
    else
      user.carPictureURL = await FireStoreUtils.uploadCarImageToFireStorage(image, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    setState(() {});
    hideProgress();
  }
}
