import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:emartdriver/constants.dart';
import 'package:emartdriver/main.dart';
import 'package:emartdriver/model/ChatVideoContainer.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/model/conversation_model.dart';
import 'package:emartdriver/model/inbox_model.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/helper.dart';
import 'package:emartdriver/services/send_notification.dart';
import 'package:emartdriver/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:emartdriver/ui/fullScreenVideoViewer/FullScreenVideoViewer.dart';
import 'package:emartdriver/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:emartdriver/widget/firebase_pagination/src/models/view_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatScreens extends StatefulWidget {
  final String? orderId;
  final String? customerId;
  final String? customerName;
  final String? customerProfileImage;
  final String? restaurantId;
  final String? restaurantName;
  final String? restaurantProfileImage;
  final String? token;
  final String? chatType;
  final String? type;

  ChatScreens(
      {Key? key,
      this.orderId,
      this.customerId,
      this.customerName,
      this.restaurantName,
      this.restaurantId,
      this.customerProfileImage,
      this.restaurantProfileImage,
      this.token,
      this.chatType,
      this.type})
      : super(key: key);

  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  TextEditingController _messageController = TextEditingController();

  final ScrollController _controller = ScrollController();
  String? token;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    if (_controller.hasClients) {
      Timer(const Duration(milliseconds: 500), () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actionsIconTheme: IconThemeData(color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white),
        iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white),
        backgroundColor: Color(COLOR_PRIMARY),
        title: Text(
          widget.customerName.toString(),
          style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    // currentRecordingState = RecordingState.HIDDEN;
                  });
                },
                child: FirestorePagination(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, documentSnapshots, index) {
                    ConversationModel inboxModel = ConversationModel.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);
                    print(index);
                    print(MyAppState.currentUser!.userID);
                    print(inboxModel.senderId == MyAppState.currentUser!.userID);
                    return chatItemView(inboxModel.senderId == MyAppState.currentUser!.userID, inboxModel);
                  },
                  onEmpty: Center(child: Text("No Conversion found")),
                  // orderBy is compulsory to enable pagination
                  query: FirebaseFirestore.instance.collection('chat_driver').doc(widget.orderId).collection("thread").orderBy('createdAt', descending: false),
                  //Change types customerId
                  viewType: ViewType.list,
                  // to fetch real-time data
                  isLive: true,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            _onCameraClick();
                          },
                          icon: const Icon(Icons.camera_alt),
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _messageController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.05),
                            contentPadding: const EdgeInsets.only(top: 3, left: 10),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.0),
                              borderRadius: const BorderRadius.all(Radius.circular(30)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.0),
                              borderRadius: const BorderRadius.all(Radius.circular(30)),
                            ),
                            hintText: 'Start typing ...'.tr(),
                          ),
                          onSubmitted: (value) async {
                            if (_messageController.text.isNotEmpty) {
                              _sendMessage(_messageController.text, null, '', 'text');
                              Timer(const Duration(milliseconds: 500), () => _controller.jumpTo(_controller.position.maxScrollExtent));
                              _messageController.clear();
                              setState(() {});
                            }
                          },
                        ),
                      )),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (_messageController.text.isNotEmpty) {
                              _sendMessage(_messageController.text, null, '', 'text');
                              _messageController.clear();
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.send_rounded),
                          color: Color(COLOR_PRIMARY),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatItemView(bool isMe, ConversationModel data) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: isMe
          ? Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  data.messageType == "text"
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            color: Color(COLOR_PRIMARY),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            data.message.toString(),
                            style: TextStyle(color: data.senderId == MyAppState.currentUser!.userID ? Colors.white : Colors.black),
                          ),
                        )
                      : data.messageType == "image"
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 50,
                                maxWidth: 200,
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                child: Stack(alignment: Alignment.center, children: [
                                  GestureDetector(
                                    onTap: () {
                                      push(
                                          context,
                                          FullScreenImageViewer(
                                            imageUrl: data.url!.url,
                                          ));
                                    },
                                    child: Hero(
                                      tag: data.url!.url,
                                      child: CachedNetworkImage(
                                        imageUrl: data.url!.url,
                                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ]),
                              ))
                          : FloatingActionButton(
                              mini: true,
                              heroTag: data.id,
                              backgroundColor: Color(COLOR_PRIMARY),
                              onPressed: () {
                                push(
                                    context,
                                    FullScreenVideoViewer(
                                      heroTag: data.id.toString(),
                                      videoUrl: data.url!.url,
                                    ));
                              },
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                  SizedBox(height: 5),
                  Text(DateFormat('MMM d, yyyy hh:mm aa').format(DateTime.fromMillisecondsSinceEpoch(data.createdAt!.millisecondsSinceEpoch)),
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    data.messageType == "text"
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                              color: Colors.grey.shade300,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              data.message.toString(),
                              style: TextStyle(color: data.senderId == MyAppState.currentUser!.userID ? Colors.white : Colors.black),
                            ),
                          )
                        : data.messageType == "image"
                            ? ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 50,
                                  maxWidth: 200,
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  child: Stack(alignment: Alignment.center, children: [
                                    GestureDetector(
                                      onTap: () {
                                        push(
                                            context,
                                            FullScreenImageViewer(
                                              imageUrl: data.url!.url,
                                            ));
                                      },
                                      child: Hero(
                                        tag: data.url!.url,
                                        child: CachedNetworkImage(
                                          imageUrl: data.url!.url,
                                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ))
                            : FloatingActionButton(
                                mini: true,
                                heroTag: data.id,
                                backgroundColor: Color(COLOR_PRIMARY),
                                onPressed: () {
                                  push(
                                      context,
                                      FullScreenVideoViewer(
                                        heroTag: data.id.toString(),
                                        videoUrl: data.url!.url,
                                      ));
                                },
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                  ],
                ),
                SizedBox(height: 5),
                Text(DateFormat('MMM d, yyyy hh:mm aa').format(DateTime.fromMillisecondsSinceEpoch(data.createdAt!.millisecondsSinceEpoch)),
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
    );
  }

  _sendMessage(String message, Url? url, String videoThumbnail, String messageType) async {
    InboxModel inboxModel = InboxModel(
        lastSenderId: widget.customerId,
        customerId: widget.customerId,
        customerName: widget.customerName,
        restaurantId: widget.restaurantId,
        restaurantName: widget.restaurantName,
        createdAt: Timestamp.now(),
        orderId: widget.orderId,
        customerProfileImage: widget.customerProfileImage,
        restaurantProfileImage: widget.restaurantProfileImage,
        lastMessage: _messageController.text,
        chatType: widget.chatType);

    if (widget.chatType == "Driver") {
      await FireStoreUtils.addDriverInbox(inboxModel);
    }

    ConversationModel conversationModel = ConversationModel(
        id: Uuid().v4(),
        message: message,
        senderId: widget.restaurantId,
        receiverId: widget.customerId,
        createdAt: Timestamp.now(),
        url: url,
        orderId: widget.orderId,
        messageType: messageType,
        videoThumbnail: videoThumbnail);

    if (url != null && url.mime.toString().isNotEmpty) {
      if (url.mime.contains('image')) {
        conversationModel.message = "sent An Image".tr(args: ['${MyAppState.currentUser!.firstName} ${MyAppState.currentUser!.lastName}']);
      } else if (url.mime.contains('video')) {
        conversationModel.message = "sent A Video".tr(args: ['${MyAppState.currentUser!.firstName} ${MyAppState.currentUser!.lastName}']);
      } else if (url.mime.contains('audio')) {
        conversationModel.message = "sent A VoiceMessage".tr(args: ['${MyAppState.currentUser!.firstName} ${MyAppState.currentUser!.lastName}']);
      }
    } else if (messageType.toString() != "text") {
      conversationModel.message = messageType == "image"
          ? "sent An Image"
          : messageType == "video"
              ? "sent A Video"
              : "sent A VoiceMessage";
    }

    if (widget.chatType == "Driver") {
      await FireStoreUtils.addDriverChat(conversationModel);
    }
    Map<String, dynamic> payLoad = {};
    if (widget.type == "cab_parcel_chat") {
      User? customer = await FireStoreUtils.getCurrentUser(widget.customerId.toString());
      token = customer!.fcmToken;
      payLoad = {
        "type": "cab_parcel_chat",
        "customerName": widget.customerName.toString(),
        "restaurantName": widget.restaurantName.toString(),
        "orderId": widget.orderId,
        "restaurantId": widget.restaurantId,
        "customerId": widget.customerId,
        "customerProfileImage": widget.customerProfileImage,
        "restaurantProfileImage": widget.restaurantProfileImage,
        "token": token,
        "chatType": widget.chatType,
      };
    } else if (widget.type == "vendor_chat") {
      User? customer = await FireStoreUtils.getCurrentUser(widget.customerId.toString());
      token = customer!.fcmToken;
      payLoad = {
        "type": "vendor_chat",
        "customerName": widget.customerName.toString(),
        "restaurantName": widget.restaurantName.toString(),
        "orderId": widget.orderId,
        "restaurantId": widget.restaurantId,
        "customerId": widget.customerId,
        "customerProfileImage": widget.customerProfileImage,
        "restaurantProfileImage": widget.restaurantProfileImage,
        "token": token,
        "chatType": widget.chatType,
      };
    } else {
      ///Inbox
      User? customer = await FireStoreUtils.getCurrentUser(widget.customerId.toString());
      token = customer!.fcmToken;
      payLoad = {
        "customerName": widget.customerName.toString(),
        "restaurantName": widget.restaurantName.toString(),
        "orderId": widget.orderId,
        "restaurantId": widget.restaurantId,
        "customerId": widget.customerId,
        "customerProfileImage": widget.customerProfileImage,
        "restaurantProfileImage": widget.restaurantProfileImage,
        "token": token,
        "chatType": widget.chatType,
      };
    }
    SendNotification.sendChatFcmMessage(
        "${MyAppState.currentUser!.fullName()} ${messageType == "image" ? "sent image to you" : messageType == "video" ? "sent video to you" : "sent message to you"}",
        conversationModel.message.toString(),
        token.toString(),
        payLoad);

    // FireStoreUtils.sendChatFcmMessage(widget.customerName.toString(), conversationModel.message.toString(), widget.token.toString(),payLoad);
  }

  final ImagePicker _imagePicker = ImagePicker();

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'sendMedia',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("chooseImageFromGallery").tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Url url = await FireStoreUtils().uploadChatImageToFireStorage(File(image.path), context);
              _sendMessage('', url, '', 'image');
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text("chooseVideoFromGallery").tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              ChatVideoContainer videoContainer = await FireStoreUtils().uploadChatVideoToFireStorage(File(galleryVideo.path), context);
              _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text("takeAPicture").tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              Url url = await FireStoreUtils().uploadChatImageToFireStorage(File(image.path), context);
              _sendMessage('', url, '', 'image');
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text("recordVideo").tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? recordedVideo = await _imagePicker.pickVideo(source: ImageSource.camera);
            if (recordedVideo != null) {
              ChatVideoContainer videoContainer = await FireStoreUtils().uploadChatVideoToFireStorage(File(recordedVideo.path), context);
              _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
            }
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel',
        ).tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
