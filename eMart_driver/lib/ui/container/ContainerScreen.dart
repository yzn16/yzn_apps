import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/CurrencyModel.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/Language/language_choose_screen.dart';
import 'package:emartdriver/ui/auth/AuthScreen.dart';
import 'package:emartdriver/ui/bank_details/bank_details_Screen.dart';
import 'package:emartdriver/ui/chat_screen/inbox_screen.dart';
import 'package:emartdriver/ui/home/HomeScreen.dart';
import 'package:emartdriver/ui/ordersScreen/OrdersScreen.dart';
import 'package:emartdriver/ui/privacy_policy/privacy_policy.dart';
import 'package:emartdriver/ui/profile/ProfileScreen.dart';
import 'package:emartdriver/ui/termsAndCondition/terms_and_codition.dart';
import 'package:emartdriver/ui/wallet/walletScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

enum DrawerSelection {
  Home,
  Cuisines,
  Search,
  Cart,
  Drivers,
  rideSetting,
  Profile,
  Orders,
  Logout,
  Wallet,
  BankInfo,
  termsCondition,
  privacyPolicy,
  inbox,
  chooseLanguage,
}

class ContainerScreen extends StatefulWidget {
  final User user;

  ContainerScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _ContainerScreen createState() {
    return _ContainerScreen();
  }
}

class _ContainerScreen extends State<ContainerScreen> {
  String _appBarTitle = 'Home'.tr();
  final fireStoreUtils = FireStoreUtils();
  late Widget _currentWidget;
  DrawerSelection _drawerSelection = DrawerSelection.Home;

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _currentWidget = HomeScreen();
    setCurrency();
    updateCurrentLocation();
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  setCurrency() async {
    /*FireStoreUtils().getCurrency().then((value) => value.forEach((element) {
          if (element.isactive = true) {
            currencyData = element;
          }
        }));*/
    await FireStoreUtils().getRazorPayDemo();
    await FireStoreUtils.getPaypalSettingData();
    await FireStoreUtils.getStripeSettingData();
    await FireStoreUtils.getPayStackSettingData();
    await FireStoreUtils.getFlutterWaveSettingData();
    await FireStoreUtils.getPaytmSettingData();
    await FireStoreUtils.getWalletSettingData();
    await FireStoreUtils.getPayFastSettingData();
    await FireStoreUtils.getMercadoPagoSettingData();
    await FireStoreUtils.getDriverOrderSetting();
    await FireStoreUtils.getOrangeMoneySettingData();
    await FireStoreUtils.getXenditSettingData();
    await FireStoreUtils.getMidTransSettingData();


    setState(() {
      isLoading = false;
    });
  }

  Location location = Location();

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.granted) {
      print("---->");
      location.enableBackgroundMode(enable: true);
      location.changeSettings(accuracy: LocationAccuracy.navigation, distanceFilter: 50);
      location.onLocationChanged.listen((locationData) async {
        locationDataFinal = locationData;

        await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
          if (value != null) {
            User driverUserModel = value;
            if (driverUserModel.isActive == true) {
              driverUserModel.location = UserLocation(latitude: locationData.latitude ?? 0.0, longitude: locationData.longitude ?? 0.0);
              driverUserModel.rotation = locationData.heading;
              FireStoreUtils.updateCurrentUser(driverUserModel);
            }
          }
        });
      });
    } else {
      await openBackgroundLocationDialog();
      await location.requestPermission().then((permissionStatus) {
        if (permissionStatus == PermissionStatus.granted) {
          location.enableBackgroundMode(enable: true);
          location.changeSettings(accuracy: LocationAccuracy.navigation, distanceFilter: 50);
          location.onLocationChanged.listen((locationData) async {
            locationDataFinal = locationData;
            await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
              if (value != null) {
                User driverUserModel = value;
                if (driverUserModel.isActive == true) {
                  driverUserModel.location = UserLocation(latitude: locationData.latitude ?? 0.0, longitude: locationData.longitude ?? 0.0);
                  driverUserModel.rotation = locationData.heading;
                  FireStoreUtils.updateCurrentUser(driverUserModel);
                }
              }
            });
          });
        }
      });
    }
  }

  openBackgroundLocationDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              //width: 300.0,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                      "Background Location permission".tr(),
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: Text("This app collects location data to enable location fetching at the time of you are on the way to deliver order or even when the app is in background.".tr()),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0)),
                      ),
                      child: Text(
                        "Okay".tr(),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  DateTime pre_backpress = DateTime.now();

  final audioPlayer = AudioPlayer(playerId: "playerId");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
        pre_backpress = DateTime.now();
        if (cantExit) {
          //show snackbar
          final snack = SnackBar(
            content: Text(
              'Press Back button again to Exit'.tr(),
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false; // false will do nothing when back press
        } else {
          return true; // true will exit the app
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          displayCircleImage(MyAppState.currentUser!.profilePictureURL, 60, false),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              MyAppState.currentUser!.fullName(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            MyAppState.currentUser!.email,
                            style: TextStyle(color: Colors.white),
                          ),
                          SwitchListTile(
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Online".tr(),
                              style: TextStyle(color: Colors.white),
                            ),
                            value: MyAppState.currentUser!.isActive,
                            onChanged: (value) {
                              setState(() {
                                MyAppState.currentUser!.isActive = value;
                              });
                              if (MyAppState.currentUser!.isActive == true) {
                                updateCurrentLocation();
                              }
                              FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
                            },
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Home,
                        title: Text('Home').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Home;
                            _appBarTitle = 'Home'.tr();
                            _currentWidget = HomeScreen();
                          });
                        },
                        leading: Icon(CupertinoIcons.home),
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Orders,
                        leading: Image.asset(
                          'assets/images/truck.png',
                          color: _drawerSelection == DrawerSelection.Orders
                              ? Color(COLOR_PRIMARY)
                              : isDarkMode(context)
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade600,
                          width: 24,
                          height: 24,
                        ),
                        title: Text('Orders').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Orders;
                            _appBarTitle = 'Orders'.tr();
                            _currentWidget = OrdersScreen();
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Wallet,
                        leading: Icon(Icons.account_balance_wallet_sharp),
                        title: Text('Wallet').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Wallet;
                            _appBarTitle = 'Earnings'.tr();
                            _currentWidget = WalletScreen();
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.BankInfo,
                        leading: Icon(Icons.account_balance),
                        title: Text('Withdraw method').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.BankInfo;
                            _appBarTitle = 'Withdraw method'.tr();
                            _currentWidget = BankDetailsScreen();
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Profile,
                        leading: Icon(CupertinoIcons.person),
                        title: Text('Profile').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.Profile;
                            _appBarTitle = 'My Profile'.tr();
                            _currentWidget = ProfileScreen(
                              user: MyAppState.currentUser!,
                            );
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.chooseLanguage,
                        leading: Icon(
                          Icons.language,
                          color: _drawerSelection == DrawerSelection.chooseLanguage
                              ? Color(COLOR_PRIMARY)
                              : isDarkMode(context)
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade600,
                        ),
                        title: const Text('Language').tr(),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _drawerSelection = DrawerSelection.chooseLanguage;
                            _appBarTitle = 'Language'.tr();
                            _currentWidget = LanguageChooseScreen(
                              isContainer: true,
                            );
                          });
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.termsCondition,
                        leading: const Icon(Icons.policy),
                        title: const Text('Terms and Condition').tr(),
                        onTap: () async {
                          push(context, const TermsAndCondition());
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.privacyPolicy,
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('Privacy policy').tr(),
                        onTap: () async {
                          push(context, const PrivacyPolicyScreen());
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.inbox,
                        leading: Icon(CupertinoIcons.chat_bubble_2_fill),
                        title: Text('Inbox').tr(),
                        onTap: () {
                          if (MyAppState.currentUser == null) {
                            Navigator.pop(context);
                            push(context, AuthScreen());
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              _drawerSelection = DrawerSelection.inbox;
                              _appBarTitle = 'My Inbox'.tr();
                              _currentWidget = InboxScreen();
                            });
                          }
                        },
                      ),
                    ),
                    ListTileTheme(
                      style: ListTileStyle.drawer,
                      selectedColor: Color(COLOR_PRIMARY),
                      child: ListTile(
                        selected: _drawerSelection == DrawerSelection.Logout,
                        leading: Icon(Icons.logout),
                        title: Text('Log out').tr(),
                        onTap: () async {
                          audioPlayer.stop();
                          Navigator.pop(context);
                          await FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
                            MyAppState.currentUser = value;
                          });
                          MyAppState.currentUser!.isActive = false;
                          MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
                          await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
                          await auth.FirebaseAuth.instance.signOut();
                          MyAppState.currentUser = null;
                          location.enableBackgroundMode(enable: false);
                          pushAndRemoveUntil(context, AuthScreen(), false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("V : $appVersion"),
              )
            ],
          ),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: isDarkMode(context) ? Colors.white : Color(DARK_COLOR),
          ),
          centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
          backgroundColor: isDarkMode(context) ? Color(DARK_COLOR) : Colors.white,
          title: Text(
            _appBarTitle,
            style: TextStyle(
              color: isDarkMode(context) ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: isLoading ?Center(child: CircularProgressIndicator(),):_currentWidget,
      ),
    );
  }

}
