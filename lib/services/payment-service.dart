import 'dart:convert';
import 'package:chatapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lipa_na_mpesa_online/lipa_na_mpesa_online.dart';
import '../utils/keys.dart' as MpesaKeys;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  FirebaseUser _user;
  UserModel _userModel;
  Status _status = Status.Uninitialized;

  //  getter
  UserModel get userModel => _userModel;

  Status get status => _status;

  FirebaseUser get user => _user;
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret = 'sk_test_LoirMMs5pEbPgs0qeiktuO2n00LPlLIGms';
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_q9gkuKRYsXr3OUM0AEjZRafJ00wn5s2zVW",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static Future<StripeTransactionResponse> payViaExistingCard(
      {String amount, String currency, CreditCard card, String user}) async {
    try {
      
      var paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card));
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);

      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id));
      // print(card.number);
      
      if (response.status == 'succeeded') {
        await StripeService.savePayWithCard(
          paymentIntentId: response.paymentIntentId, 
          paymentMethodId: card.name,
          stripeStatus: response.status,
          cardNumber: card.number,
          user : user,
          amount: amount,
        );
        return new StripeTransactionResponse(
            message: 'Transaction successful', success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static Future<StripeTransactionResponse> payViaMpesa(
      {String amount, String currency}) async {
    try {
      getData(value) async {
        await Firestore.instance
            .collection('mpesatransactonresponses')
            .document(value['CheckoutRequestID'])
            .setData(
          {
            'MerchantRequestID': value['MerchantRequestID'],
            'CheckoutRequestID': value['CheckoutRequestID'],
            'ResponseCode': value['ResponseCode'],
            'ResponseDescription': value['ResponseDescription'],
            'CustomerMessage': value['CustomerMessage'],
          },
        );
        return new StripeTransactionResponse(
            message: 'Transaction Success: ' + await value['CustomerMessage'],
            success: true);
      }

      var customerMessage = await MpesaService.lipanampesa(
        MpesaKeys.lipa_na_mpesa_passkey,
        MpesaKeys.business_short_code,
        MpesaKeys.consumer_key,
        MpesaKeys.consumer_secret,
        MpesaKeys.phone_number,
        MpesaKeys.transactiontype,
        MpesaKeys.amount,
        MpesaKeys.callbackURL,
        MpesaKeys.accountref,
        MpesaKeys.transactionDesc,
      ).then(
        (value) => {getData(value), value['CustomerMessage']},
      );
      print(customerMessage.toList().sublist(1).toString());
      return new StripeTransactionResponse(
          message: customerMessage.toList().sublist(1).toString(),
          success: true);
    } catch (e) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${e.toString()}', success: false);
    }
  }

 static Future<StripeTransactionResponse> savePayWithCard({String paymentIntentId,
      String paymentMethodId, String stripeStatus, String user, String amount, String cardNumber}) async {
    await Firestore.instance
        .collection('stripepaymentresponses')
        .document(paymentIntentId)
        .setData(
      {
        'paymentIntentId': paymentIntentId,
        'paymentMethodId': paymentMethodId,
        'ResponseCode': stripeStatus,
        'user': user,
        'amount': amount,
        'cardNumber' : cardNumber,
      },
      
    );
    return new StripeTransactionResponse(
            message: 'Transaction Saved Successfully', success: true);
  }

 static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency, String user}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
          // print(paymentMethod.card.number);
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
          
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        
        await StripeService.savePayWithCard(
          paymentIntentId: response.paymentIntentId, 
          paymentMethodId: paymentMethod.billingDetails.name,
          stripeStatus: response.status,
          user : user,
          amount: amount,
          cardNumber: paymentMethod.card.number,
        );
        return new StripeTransactionResponse(
            message: 'Transaction successful', success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(StripeService.paymentApiUrl,
          body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }
}
