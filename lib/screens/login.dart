import '../helpers/style.dart';
import '../provider/user.dart';
import '../screens/signup.dart';
import '../utils/Buttons.dart';
import '../utils/utility.dart';
import '../widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool _rememberMe = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool userHasTouchId = false;
  FlutterSecureStorage storage = FlutterSecureStorage();
  void _decrypt() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    //read from the secure storage
    final isUsingBio = await storage.read(key: 'useBioMet');
    setState(() {
      userHasTouchId = isUsingBio == 'true';
    });
  }

  @override
  void initState() {
    super.initState();
    storage = FlutterSecureStorage();
    // storage.deleteAll();
    _decrypt();
  }

  @override
  void dispose() {
    super.dispose();
    storage = null;
  }

  Widget _buildRememberMeCheckbox() {
    final user = Provider.of<UserProvider>(context);
    return Container(
      height: userHasTouchId ? 35 : 20.0,
      child: userHasTouchId
          ? RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 5.0,
              color: Colors.white,
              onPressed: () => user.loginWithFingerPrint(),
              child: Icon(
                Icons.fingerprint,
                color: Colors.blueAccent,
              ),
            )
          : Row(
              children: <Widget>[
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white),
                  child: Checkbox(
                    value: _rememberMe,
                    checkColor: Colors.green,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                  ),
                ),
                Text(
                  'Sign me with finger print on next login',
                  style: kLabelStyle,
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      key: _key,
      body: user.status == Status.Authenticating
          ? Loading()
          : Stack(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.green,
                          ],
                        ),
                        color: white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[350],
                            blurRadius:
                                20.0, // has the effect of softening the shadow
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  'images/logo.png',
                                  width: 260.0,
                                ),
                              ),
                            ),
                            Center(
                              child: Text("Maber Shopping App"),
                            ),
                            Center(
                              child: Text(
                                user.userdoesnotexist,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  14.0, 8.0, 14.0, 8.0),
                              child: userHasTouchId
                                  ? Text('')
                                  : Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.grey.withOpacity(0.3),
                                      elevation: 0.0,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: TextFormField(
                                          controller: email,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Email",
                                            icon: Icon(Icons.alternate_email),
                                          ),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              Pattern pattern =
                                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                              RegExp regex =
                                                  new RegExp(pattern);
                                              if (!regex.hasMatch(value))
                                                return 'Please make sure your email address is valid';
                                              else
                                                return null;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  14.0, 8.0, 14.0, 8.0),
                              child: userHasTouchId
                                  ? Text('')
                                  : Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.grey.withOpacity(0.3),
                                      elevation: 0.0,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: TextFormField(
                                          controller: password,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Password",
                                            icon: Icon(Icons.lock_outline),
                                          ),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "The password field cannot be empty";
                                            } else if (value.length < 6) {
                                              return "the password has to be at least 6 characters long";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildRememberMeCheckbox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14.0,
                                8.0,
                                14.0,
                                8.0,
                              ),
                              child: userHasTouchId
                                  ? Center(
                                      child: Text(
                                      'Press The Finger Print Button',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ))
                                  : SimpleRoundIconButton(
                                      backgroundColor: Colors.white60,
                                      iconColor: Colors.green,
                                      buttonText: Text('Login'),
                                      icon: Icon(Icons.verified_user),
                                      onPressed: () async {
                                        var bioMetCheck = _rememberMe;
                                        if (_formKey.currentState.validate()) {
                                          await user.attemptLogIn(email.text,
                                              password.text, bioMetCheck);
                                        }
                                        // _key.currentState.showSnackBar(SnackBar(content: Text("Sign in failed")));
                                      },
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Forgot password",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: userHasTouchId
                                      ? RaisedButton(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          color: Colors.red,
                                          onPressed: () => user.deleteBiomet(),
                                          child: Text(
                                              'Delete Biometric Authentication'),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SignUp(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Create an account",
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
