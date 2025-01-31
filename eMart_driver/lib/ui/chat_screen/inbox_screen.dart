import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartdriver/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:emartdriver/widget/firebase_pagination/src/models/view_type.dart';
import 'package:flutter/material.dart';
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/model/inbox_model.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/ui/chat_screen/chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirestorePagination(
        //item builder type is compulsory.
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>?;
          InboxModel inboxModel = InboxModel.fromJson(data!);
          return InkWell(
            onTap: () async {
              await showProgress(context, "Please wait".tr(), false);

              User? customer = await FireStoreUtils.getCurrentUser(inboxModel.customerId.toString());
              User? driver = await FireStoreUtils.getCurrentUser(inboxModel.restaurantId.toString());
              await hideProgress();

              push(
                  context,
                  ChatScreens(
                    customerName: '${customer!.firstName + " " + customer.lastName}',
                    restaurantName: '${driver!.firstName + " " + driver.lastName}',
                    orderId: inboxModel.orderId,
                    restaurantId: driver.userID,
                    customerId: customer.userID,
                    customerProfileImage: customer.profilePictureURL,
                    restaurantProfileImage: driver.profilePictureURL,
                    token: customer.fcmToken,
                    chatType: inboxModel.chatType,
                  ));
            },
            child: ListTile(
              leading: ClipOval(
                child: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    imageUrl: inboxModel.customerProfileImage.toString(),
                    imageBuilder: (context, imageProvider) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                        ),
                    errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          placeholderImage,
                          fit: BoxFit.cover,
                        ))),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(inboxModel.customerName.toString())),
                  Text(DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(inboxModel.createdAt!.millisecondsSinceEpoch)), style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              subtitle: Text("Order Id : #" + inboxModel.orderId.toString()),
            ),
          );
        },
        shrinkWrap: true,
        onEmpty: Center(child: Text("No Conversion found")),
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance.collection('chat_driver').where("restaurantId", isEqualTo: MyAppState.currentUser!.userID).orderBy('createdAt', descending: true),
        //Change types customerId
        viewType: ViewType.list,
        initialLoader: CircularProgressIndicator(),
        // to fetch real-time data
        isLive: true,
      ),
    );
  }
}
