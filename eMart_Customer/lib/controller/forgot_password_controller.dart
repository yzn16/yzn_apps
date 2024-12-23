import 'package:emartconsumer/services/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;

  forgotPassword() async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailEditingController.value.text,
      );
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Reset Password link sent your ${emailEditingController.value.text} email');
      Get.back();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ShowToastDialog.showToast('No user found for that email.');
      }
    }
  }
}
