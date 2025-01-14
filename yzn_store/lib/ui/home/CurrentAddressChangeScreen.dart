// import 'package:easy_localization/easy_localization.dart';
// import 'package:emartconsumer/constants.dart';
// import 'package:emartconsumer/main.dart';
// import 'package:emartconsumer/model/AddressModel.dart';
// import 'package:emartconsumer/model/User.dart';
// import 'package:emartconsumer/services/FirebaseHelper.dart';
// import 'package:emartconsumer/services/helper.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:place_picker/place_picker.dart';
//
// class CurrentAddressChangeScreen extends StatefulWidget {
//   static const kInitialPosition = LatLng(-33.8567844, 151.213108);
//
//   const CurrentAddressChangeScreen({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _CurrentAddressChangeScreenState createState() => _CurrentAddressChangeScreenState();
// }
//
// class _CurrentAddressChangeScreenState extends State<CurrentAddressChangeScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   // String? line1, line2, zipCode, city;
//   String? country;
//   var street = TextEditingController();
//   var street1 = TextEditingController();
//   var landmark = TextEditingController();
//   var landmark1 = TextEditingController();
//   var zipcode = TextEditingController();
//   var zipcode1 = TextEditingController();
//   var city = TextEditingController();
//   var city1 = TextEditingController();
//   var cutries = TextEditingController();
//   var cutries1 = TextEditingController();
//   var lat;
//   var long;
//
//   AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
//
//   @override
//   void dispose() {
//     street.dispose();
//     landmark.dispose();
//     city.dispose();
//     // cutries.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (MyAppState.currentUser != null) {
//       MyAppState.currentUser!.shippingAddress.country != '' ? country = MyAppState.currentUser!.shippingAddress.country : null;
//       street.text = MyAppState.currentUser!.shippingAddress.line1;
//       landmark.text = MyAppState.currentUser!.shippingAddress.line2;
//       city.text = MyAppState.currentUser!.shippingAddress.city;
//       zipcode.text = MyAppState.currentUser!.shippingAddress.postalCode;
//       cutries.text = MyAppState.currentUser!.shippingAddress.country;
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Change Address'.tr(),
//           style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
//         ).tr(),
//       ),
//       body: Container(
//           color: isDarkMode(context) ? null : const Color(0XFFF1F4F7),
//           child: Form(
//               key: _formKey,
//               autovalidateMode: _autoValidateMode,
//               child: SingleChildScrollView(
//                   child: Column(children: [
//                 const SizedBox(
//                   height: 40,
//                 ),
//                 Card(
//                   elevation: 0.5,
//                   color: isDarkMode(context) ? const Color(DARK_BG_COLOR) : const Color(0XFFFFFFFF),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   margin: const EdgeInsets.only(left: 20, right: 20),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                         child: TextFormField(
//                             // controller: street,
//                             controller: street1.text.isEmpty ? street : street1,
//                             textAlignVertical: TextAlignVertical.center,
//                             textInputAction: TextInputAction.next,
//                             validator: validateEmptyField,
//                             // onSaved: (text) => line1 = text,
//                             onSaved: (text) => street.text = text!,
//                             style: const TextStyle(fontSize: 18.0),
//                             keyboardType: TextInputType.streetAddress,
//                             cursorColor: AppThemeData.primary300,
//                             // initialValue:
//                             //     MyAppState.currentUser!.shippingAddress.line1,
//                             decoration: InputDecoration(
//                               // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                               labelText: 'Street 1'.tr(),
//                               labelStyle: const TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                               hintStyle: TextStyle(color: Colors.grey.shade400),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: AppThemeData.primary300),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).errorColor),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).errorColor),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               enabledBorder: const UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                                 // borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             )),
//                       ),
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                         child: TextFormField(
//                           // controller: _controller,
//                           controller: landmark1.text.isEmpty ? landmark : landmark1,
//                           textAlignVertical: TextAlignVertical.center,
//                           textInputAction: TextInputAction.next,
//                           validator: validateEmptyField,
//                           onSaved: (text) => landmark.text = text!,
//                           style: const TextStyle(fontSize: 18.0),
//                           keyboardType: TextInputType.streetAddress,
//                           cursorColor: AppThemeData.primary300,
//                           decoration: InputDecoration(
//                             labelText: 'Landmark'.tr(),
//                             labelStyle: const TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                             hintStyle: TextStyle(color: Colors.grey.shade400),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: AppThemeData.primary300),
//                             ),
//                             errorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).errorColor),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             focusedErrorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).errorColor),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             enabledBorder: const UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                               // borderRadius: BorderRadius.circular(8.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                         child: TextFormField(
//                           controller: zipcode1.text.isEmpty ? zipcode : zipcode1,
//                           textAlignVertical: TextAlignVertical.center,
//                           textInputAction: TextInputAction.next,
//                           validator: validateEmptyField,
//                           onSaved: (text) => zipcode.text = text!,
//                           style: const TextStyle(fontSize: 18.0),
//                           keyboardType: TextInputType.phone,
//                           cursorColor: AppThemeData.primary300,
//                           // initialValue: MyAppState
//                           //     .currentUser!.shippingAddress.postalCode,
//                           decoration: InputDecoration(
//                             // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                             labelText: 'Zip Code'.tr(),
//                             labelStyle: const TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                             hintStyle: TextStyle(color: Colors.grey.shade400),
//                             focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: AppThemeData.primary300),
//                             ),
//                             errorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).errorColor),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             focusedErrorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).errorColor),
//                               borderRadius: BorderRadius.circular(8.0),
//                             ),
//                             enabledBorder: const UnderlineInputBorder(
//                               borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                               // borderRadius: BorderRadius.circular(8.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                           padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                           child: TextFormField(
//                             controller: city1.text.isEmpty ? city : city1,
//                             textAlignVertical: TextAlignVertical.center,
//                             textInputAction: TextInputAction.next,
//                             validator: validateEmptyField,
//                             onSaved: (text) => city.text = text!,
//                             style: const TextStyle(fontSize: 18.0),
//                             keyboardType: TextInputType.streetAddress,
//                             cursorColor: AppThemeData.primary300,
//                             // initialValue:
//                             //     MyAppState.currentUser!.shippingAddress.city,
//                             decoration: InputDecoration(
//                               // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                               labelText: 'City'.tr(),
//                               labelStyle: const TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                               hintStyle: TextStyle(color: Colors.grey.shade400),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: AppThemeData.primary300),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).errorColor),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).errorColor),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               enabledBorder: const UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                                 // borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                           )),
//                       Container(
//                           padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
//                           child: TextFormField(
//                             controller: cutries1.text.isEmpty ? cutries : cutries1,
//                             textAlignVertical: TextAlignVertical.center,
//                             textInputAction: TextInputAction.next,
//                             validator: validateEmptyField,
//                             onSaved: (text) => cutries.text = text!,
//                             style: const TextStyle(fontSize: 18.0),
//                             keyboardType: TextInputType.streetAddress,
//                             cursorColor: AppThemeData.primary300,
//                             // initialValue:
//                             //     MyAppState.currentUser!.shippingAddress.city,
//                             decoration: InputDecoration(
//                               // contentPadding: EdgeInsets.symmetric(horizontal: 24),
//                               labelText: 'Country'.tr(),
//                               labelStyle: const TextStyle(color: Color(0Xff696A75), fontSize: 17),
//                               hintStyle: TextStyle(color: Colors.grey.shade400),
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: AppThemeData.primary300),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).errorColor),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               focusedErrorBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Theme.of(context).errorColor),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               enabledBorder: const UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Color(0XFFB1BCCA)),
//                                 // borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Card(
//                             child: ListTile(
//                                 leading: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     // ImageIcon(
//                                     //   AssetImage('assets/images/current_location1.png'),
//                                     //   size: 23,
//                                     //   color: AppThemeData.primary300,
//                                     // ),
//                                     Icon(
//                                       Icons.location_searching_rounded,
//                                       color: AppThemeData.primary300,
//                                     ),
//                                   ],
//                                 ),
//                                 title: Text(
//                                   "Current Location".tr(),
//                                   style: TextStyle(color: AppThemeData.primary300),
//                                 ),
//                                 subtitle: Text(
//                                   "Using GPS".tr(),
//                                   style: TextStyle(color: AppThemeData.primary300),
//                                 ),
//                                 onTap: () async {
//                                   LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker(GOOGLE_API_KEY)));
//
//                                   if (result != null) {
//                                     street1.text = result.name.toString();
//                                     landmark1.text = result.subLocalityLevel1!.name == null ? result.subLocalityLevel2!.name.toString() : result.subLocalityLevel1!.name.toString();
//                                     city1.text = result.city!.name.toString();
//                                     cutries1.text = result.country!.name.toString();
//                                     zipcode1.text = result.postalCode.toString();
//                                     lat = result.latLng!.latitude;
//                                     long = result.latLng!.longitude;
//                                   }
//                                   setState(() {});
//                                 })),
//                       ),
//                       const SizedBox(
//                         height: 40,
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox()
//               ])))),
//       bottomNavigationBar: Container(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.all(15),
//               backgroundColor: AppThemeData.primary300,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () => validateForm(),
//             child: Text(
//               'DONE'.tr(),
//               style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   validateForm() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState!.save();
//
//       {
//         if (MyAppState.currentUser != null) {
//           if (MyAppState.currentUser!.shippingAddress.location.latitude == 0 && MyAppState.currentUser!.shippingAddress.location.longitude == 0) {
//             if (lat == 0 && long == 0) {
//               showDialog(
//                   barrierDismissible: false,
//                   context: context,
//                   builder: (_) {
//                     return AlertDialog(
//                       content: Text('select-current-location'.tr()),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             hideProgress();
//                             Navigator.pop(context, true);
//                           }, // passing true
//                           child: const Text('OK').tr(),
//                         ),
//                       ],
//                     );
//                   }).then((exit) {
//                 if (exit == null) return;
//
//                 if (exit) {
//                   // user pressed Yes button
//                 } else {
//                   // user pressed No button
//                 }
//               });
//             }
//           } else {
//             if (lat == null || long == null || (lat == 0 && long == 0)) {
//               lat = MyAppState.currentUser!.shippingAddress.location.latitude;
//               long = MyAppState.currentUser!.shippingAddress.location.longitude;
//             }
//           }
//
//           showProgress(context, 'Saving Address...'.tr(), true);
//           MyAppState.currentUser!.location = UserLocation(
//             latitude: lat,
//             longitude: long,
//           );
//           AddressModel userAddress = AddressModel(
//               name: MyAppState.currentUser!.fullName(),
//               postalCode: zipcode.text,
//               line1: street.text,
//               line2: landmark.text,
//               country: cutries.text,
//               city: city.text,
//               location: MyAppState.currentUser!.location,
//               email: MyAppState.currentUser!.email);
//           MyAppState.currentUser!.shippingAddress = userAddress;
//           await FireStoreUtils.updateCurrentUserAddress(userAddress);
//           hideProgress();
//           hideProgress();
//         }
//         MyAppState.selectedPosition = Position.fromMap({'latitude': lat, 'longitude': long});
//
//         String passAddress = street.text.toString() + ", " + landmark.text.toString() + ", " + city.text.toString() + ", " + zipcode.text.toString() + ", " + cutries.text.toString();
//         Navigator.pop(context, passAddress);
//       }
//     } else {
//       setState(() {
//         _autoValidateMode = AutovalidateMode.onUserInteraction;
//       });
//     }
//   }
// }
