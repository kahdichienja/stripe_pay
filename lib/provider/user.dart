import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/order.dart';
import '../services/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider with ChangeNotifier {
  FirebaseAuth _auth;
  final db = Firestore.instance;
  FlutterSecureStorage storage;
  FirebaseUser _user;
  Status _status = Status.Uninitialized;
  UserServices _userServices = UserServices();
  OrderServices _orderServices = OrderServices();
  bool userHasTouchId = false;
  String userdoesnotexist = '';

  final LocalAuthentication auth = LocalAuthentication();

  UserModel _userModel;

//  getter
  UserModel get userModel => _userModel;

  Status get status => _status;

  FirebaseUser get user => _user;

  // public variables
  List<OrderModel> orders = [];

  UserProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onStateChanged);
  }

  deleteBiomet() async {
    storage = FlutterSecureStorage();
    storage.deleteAll();
    notifyListeners();
  }

  encrypt(String email, String password) async {
    //write to the secure storage
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'password', value: password);
    await storage.write(key: 'useBioMet', value: 'true');

    print('Encrypting and saving $email');
    print('Encrypting and saving $password');

    notifyListeners();
  }

  Future<String> attemptLogIn(
      String email, String password, bool bioMetCheck) async {
    final LocalAuthentication _localAuthentication = LocalAuthentication();

    Future<bool> _isBiometricAvailable() async {
      bool isAvailable = false;
      try {
        isAvailable = await _localAuthentication.canCheckBiometrics;
      } on PlatformException catch (e) {
        print(e);
      }

      // if (!mounted) return isAvailable;

      isAvailable
          ? print('Biometric Auth is available!')
          : print('Biometric is unavailable.');

      return isAvailable;
      // ...
    }

    // To retrieve the list of biometric types
    // (if available).
    Future<void> _getListOfBiometricTypes() async {
      List<BiometricType> listOfBiometrics;
      try {
        listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
      } on PlatformException catch (e) {
        print(e);
      }

      // if (!mounted) return;

      print(listOfBiometrics);
      // ...
    }

    // Process of authentication user using
    // biometrics.
    Future<void> _authenticateUser() async {
      bool isAuthenticated = false;
      try {
        isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
          localizedReason: "Do You Want To Use Biometric For Next Login.",
          useErrorDialogs: true,
          stickyAuth: true,
        );
      } on PlatformException catch (e) {
        print(e);
      }

      // if (!mounted) return;

      isAuthenticated
          ? print('User is authenticated!')
          : print('User is not authenticated.');

      if (isAuthenticated) {
        FlutterSecureStorage storage = FlutterSecureStorage();
        storage.deleteAll();
        signIn(email, password);
        await storage.write(key: "email", value: email);
        await storage.write(key: "password", value: password);
        await storage.write(key: "useBioMet", value: "true");

        print('Encrypting and saving $email');
        print('Encrypting and saving $password');
      }
      // ...
    }

    bioMetCheck == true ? await _authenticateUser() : signIn(email, password);
    notifyListeners();
    return email;
  }

  loginWithFingerPrint() async {
    final LocalAuthentication _localAuthentication = LocalAuthentication();
    FlutterSecureStorage storage = FlutterSecureStorage();
    // reading data from secure storage.
    final email = await storage.read(key: 'email');
    final pwd = await storage.read(key: 'password');

    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    // if (!mounted) return isAvailable;

    isAvailable
        ? print('Biometric Auth is available!')
        : print('Biometric is unavailable.');

    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    // if (!mounted) return;

    print(listOfBiometrics);

    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Do You Want To Use Biometric For Login.",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    // if (!mounted) return;

    isAuthenticated
        ? print('User is authenticated!')
        : print('User is not authenticated.');

    if (isAuthenticated) {
      // Here you can pass email and pwd to login Function to Auth With Server and obtain token.
      print('$email');
      print('$pwd');
      signIn(email, pwd);
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => DashboardPage(),
      //   ),
      // );
    }
    notifyListeners();
  }

  // loginWithBioMet() async {
  //   final email = await storage.read(key: 'email');
  //   final password = await storage.read(key: 'password');
  //   final canCheck = await auth.canCheckBiometrics;
  //   if (canCheck) {
  //     List<BiometricType> availableBiomentrics =
  //         await auth.getAvailableBiometrics();
  //     if (Platform.isIOS) {
  //       if (availableBiomentrics.contains(BiometricType.face)) {
  //         // use face id
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Face ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           encrypt(email, password);
  //         }
  //       } else if (availableBiomentrics.contains(BiometricType.fingerprint)) {
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Finger Print ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           encrypt(email, password);
  //         }
  //       }
  //     } else if (Platform.isAndroid) {
  //       if (availableBiomentrics.contains(BiometricType.face)) {
  //         // use face id
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Face ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           encrypt(email, password);
  //         }
  //       } else if (availableBiomentrics.contains(BiometricType.fingerprint)) {
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Finger Print ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           encrypt(email, password);
  //         }
  //       }
  //     }
  //   } else {
  //     print('Cant Check');
  //   }
  // }

  // authenticateWithBioMet(String email, String password) async {
  //   print('pwd =================================================' + password);
  //   final canCheck = await auth.canCheckBiometrics;
  //   if (canCheck) {
  //     List<BiometricType> availableBiomentrics =
  //         await auth.getAvailableBiometrics();
  //     if (Platform.isIOS) {
  //       if (availableBiomentrics.contains(BiometricType.face)) {
  //         // use face id
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Face ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           signIn(email, password);
  //           await storage.write(key: 'email', value: email);
  //           await storage.write(key: 'password', value: password);
  //           await storage.write(key: 'useBioMet', value: 'true');
  //         }
  //       } else if (availableBiomentrics.contains(BiometricType.fingerprint)) {
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Finger Print ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           signIn(email, password);
  //           await storage.write(key: 'email', value: email);
  //           await storage.write(key: 'password', value: password);
  //           await storage.write(key: 'useBioMet', value: 'true');
  //         }
  //       }
  //     } else if (Platform.isAndroid) {
  //       if (availableBiomentrics.contains(BiometricType.face)) {
  //         // use face id
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Face ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           signIn(email, password);
  //           await storage.write(key: 'email', value: email);
  //           await storage.write(key: 'password', value: password);
  //           await storage.write(key: 'useBioMet', value: 'true');
  //         }
  //       } else if (availableBiomentrics.contains(BiometricType.fingerprint)) {
  //         final authenticated = await auth.authenticateWithBiometrics(
  //           localizedReason: 'Enable Finger Print ID to sign in Quickly',
  //           stickyAuth: true,
  //           useErrorDialogs: true,
  //         );
  //         if (authenticated) {
  //           signIn(email, password);
  //           await storage.write(key: 'email', value: email);
  //           await storage.write(key: 'password', value: password);
  //           await storage.write(key: 'useBioMet', value: 'true');
  //         }
  //       }
  //     }
  //   } else {
  //     // if no biomet just sign in.
  //     signIn(email, password);
  //     print('Cant Check');
  //   }
  // }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print(user.email);
      print(user.uid);

      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      if (e.code == 'ERROR_USER_NOT_FOUND') {
        userdoesnotexist =
            "User Not Found with the provided Credintials; Please Try Again";
      }
      if (e.code == 'ERROR_WRONG_PASSWORD') {
        userdoesnotexist = "Invalid Credintials Please Try Again";
      }
      print(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      _status = Status.Authenticating;

      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      print(user.uid);
      // _userServices.createUser({'name': name, 'email': email, 'uid': user.uid, 'stripeId': ''});
      if (user.uid == null) {
        print(user);
        return false;
      }
        await db.collection('users').document(user.uid).setData(
            {'name': name, 'email': email, 'uid': user.uid, 'stripeId': ''});

        signIn(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        userdoesnotexist = "User Already exists, Please Try Again With Another Account";
        _status = Status.Unauthenticated;
      }
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onStateChanged(FirebaseUser user) async {
    if (user == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = user;
      _userModel = await _userServices.getUserById(user.uid);
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<bool> addToCart(
      {ProductModel product, String size, String color}) async {
    try {
      var uuid = Uuid();
      String cartItemId = uuid.v4();
      List<CartItemModel> cart = _userModel.cart;

      Map cartItem = {
        "id": cartItemId,
        "name": product.name,
        "image": product.picture,
        "productId": product.id,
        "price": product.price,
        "size": size,
        "color": color
      };

      CartItemModel item = CartItemModel.fromMap(cartItem);
//      if(!itemExists){
      print("CART ITEMS ARE: ${cart.toString()}");
      _userServices.addToCart(userId: _user.uid, cartItem: item);
//      }

      return true;
    } catch (e) {
      print("THE ERROR ${e.toString()}");
      return false;
    }
  }

  Future<bool> removeFromCart({CartItemModel cartItem}) async {
    print("THE PRODUC IS: ${cartItem.toString()}");

    try {
      _userServices.removeFromCart(userId: _user.uid, cartItem: cartItem);
      return true;
    } catch (e) {
      print("THE ERROR ${e.toString()}");
      return false;
    }
  }

  getOrders() async {
    orders = await _orderServices.getUserOrders(userId: _user.uid);
    notifyListeners();
  }

  Future<void> reloadUserModel() async {
    _userModel = await _userServices.getUserById(user.uid);
    notifyListeners();
  }
}
