import 'package:emartconsumer/userPrefrence.dart';

class Preferences {
  static const languageCodeKey = "languageCodeKey";
  static const isFinishOnBoardingKey = "isFinishOnBoardingKey";
  static const foodDeliveryType = "foodDeliveryType";

  static const themKey = "themKey";


  static const payFastSettings = "payFastSettings";
  static const mercadoPago = "MercadoPago";
  static const paypalSettings = "paypalSettings";
  static const stripeSettings = "stripeSettings";
  static const flutterWave = "flutterWave";
  static const payStack = "payStack";
  static const paytmSettings = "PaytmSettings";
  static const walletSettings = "walletSettings";
  static const razorpaySettings = "razorpaySettings";
  static const codSettings = "CODSettings";
  static const midTransSettings = "midTransSettings";
  static const orangeMoneySettings = "orangeMoneySettings";
  static const xenditSettings = "xenditSettings";


  static bool getBoolean(String key) {
    return UserPreference.preferences.getBool(key) ?? false;
  }

  static Future<void> setBoolean(String key, bool value) async {
    await UserPreference.preferences.setBool(key, value);
  }

  static String getString(String key, {String? defaultValue}) {
    return UserPreference.preferences.getString(key) ?? defaultValue ?? "";
  }

  static Future<void> setString(String key, String value) async {
    await UserPreference.preferences.setString(key, value);
  }

  static int getInt(String key) {
    return UserPreference.preferences.getInt(key) ?? 0;
  }

  static Future<void> setInt(String key, int value) async {
    await UserPreference.preferences.setInt(key, value);
  }

  static Future<void> clearSharPreference() async {
    await UserPreference.preferences.clear();
  }

  static Future<void> clearKeyData(String key) async {
    await UserPreference.preferences.remove(key);
  }
}
