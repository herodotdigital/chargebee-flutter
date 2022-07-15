import 'dart:developer';
import 'dart:io';
import 'package:chargebee_flutter/src/constants.dart';
import 'package:chargebee_flutter/src/utils/cb_exception.dart';
import 'package:chargebee_flutter/src/utils/product.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Chargebee {
  static const platform = MethodChannel(Constants.methodChannelName);

/* Configure the app details with chargebee system */
  static Future<void> configure(String site, String publishableApiKey,
      [String? sdkKey = "", packageName = ""]) async {
    try {
      if (Platform.isIOS) {
        final args = {
          Constants.siteName: site,
          Constants.apiKey: publishableApiKey,
          Constants.sdkKey: sdkKey
        };

        await platform.invokeMethod(Constants.mAuthentication, args);
      } else {
        final args = {
          Constants.siteName: site,
          Constants.apiKey: publishableApiKey,
          Constants.sdkKey: sdkKey,
          Constants.packageName: packageName
        };
        await platform.invokeMethod(Constants.mAuthentication, args);
      }
    } on CBException catch (e) {
      log('CBException : ${e.message}');
    }
  }

  /* Get the product/sku details from Play console/ App Store */
  static Future<List<Product>> retrieveProducts(
      List<String> listOfGPlayProductIDs) async {
    List<Object?> result = [];
    List<Product> products = [];
    try {
      result = await platform.invokeMethod(Constants.mGetProducts,
          {Constants.productIDs: listOfGPlayProductIDs});
      if (result.isNotEmpty) {
        for (var i = 0; i < result.length; i++) {
          var obj = result[i].toString();
          Product product = Product.fromJson(jsonDecode(obj));
          products.add(product);
        }
      }
    } on CBException catch (e) {
      log('CBException : ${e.message}');
    }
    return products;
  }

  /* Buy the product with/without customer Id */
  static Future<PurchaseResult> purchaseProduct(Product product,
      [String? customerId]) async {
    String purchaseResult = await platform.invokeMethod(
        Constants.mPurchaseProduct,
        {Constants.product: product.id, Constants.customerId: customerId});
    if (purchaseResult.isNotEmpty) {
      return PurchaseResult.fromJson(jsonDecode(purchaseResult.toString()));
    } else {
      return PurchaseResult("", purchaseResult);
    }
  }

  /* Get the subscription details from chargebee system */
  static Future<List<Subscripton?>> retrieveSubscriptions(
      Map<String, String> queryParams) async {
    List<Subscripton> subscriptions = [];

    if (Platform.isIOS) {
      try {
        String result = await platform.invokeMethod(
            Constants.mSubscriptionMethod, queryParams);
        log('result : $result');
        List<dynamic> jsonData = jsonDecode(result.toString());
        for (var value in jsonData) {
          var wrapper = SubscriptonList.fromJson(value);
          subscriptions.add(wrapper.subscripton!);
        }
        print(subscriptions.first.subscriptionId);
        print(subscriptions.first.status);
        return subscriptions;
      } on CBException catch (e) {
        log('CBException : ${e.message}');
      }
    } else {
      // try {
      //   result = await platform.invokeMethod(
      //       Constants.mSubscriptionMethod, {Constants.customerId: queryParams});
      //   log('result : $result');
      //   //   return result;
      // } on CBException catch (e) {
      //   log('CBException : ${e.message}');
      // }
    }
    return subscriptions;
    // return result;
  }
}
