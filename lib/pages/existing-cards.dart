import 'package:chatapp/components/appbar.dart';
// import 'package:chatapp/components/card.dart';
import 'package:chatapp/config/colors.dart';
import 'package:chatapp/config/size.dart';
import 'package:chatapp/provider/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_credit_card/credit_card_widget.dart';
import '../expenseswidget.dart';
import '../services/payment-service.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ExistingCardsPage extends StatefulWidget {
  ExistingCardsPage({Key key}) : super(key: key);

  @override
  ExistingCardsPageState createState() => ExistingCardsPageState();
}

class ExistingCardsPageState extends State<ExistingCardsPage> {
  List cards = [
    {
      'cardNumber': '4242424242424242',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '4000056655665556',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '5555555555554444',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '2223003122003222',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '5200828282828210',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '5105105105105100',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '378282246310005',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '371449635398431',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '6011111111111117',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '6011000990139424',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '3056930009020004',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '36227206271667',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '3566002020360505',
      'expiryDate': '04/23',
      'cardHolderName': 'Tracer',
      'cvvCode': '123',
      'showBackView': false,
    },
    {
      'cardNumber': '6200000000000005',
      'expiryDate': '04/23',
      'cardHolderName': 'Tracer',
      'cvvCode': '123',
      'showBackView': false,
    },
    {
      'cardNumber': '6200000000000233',
      'expiryDate': '04/23',
      'cardHolderName': 'FakeCard ForTest',
      'cvvCode': '123',
      'showBackView': false,
    },
  ];

  payViaExistingCard(BuildContext context, card) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var expiryArr = card['expiryDate'].split('/');
    CreditCard stripeCard = CreditCard(
      number: card['cardNumber'],
      expMonth: int.parse(expiryArr[0]),
      expYear: int.parse(expiryArr[1]),
    );
    var response = await StripeService.payViaExistingCard(
      amount: '2500',
      currency: 'USD',
      card: stripeCard,
      user: userProvider.userModel?.id
    );
    await dialog.hide();
    Scaffold.of(context)
        .showSnackBar(SnackBar(
          content: Text(response.message),
          duration: new Duration(milliseconds: 1200),
        ))
        .closed
        .then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = SizeConfig.getHeight(context);
    var width = SizeConfig.getWidth(context);
    double fontSize(double size) {
      return size * width / 414;
    }

    return Scaffold(
      body: Container(
        color: AppColors.primaryWhite,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: height / 8,
                child: CustomAppBar(),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width / 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tap a Card To Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: cards.length,
                          itemBuilder: (BuildContext context, int index) {
                            var card = cards[index];
                            return InkWell(
                              onTap: () {
                                payViaExistingCard(context, card);
                              },
                              child: Container(
                                width: width,
                                decoration: BoxDecoration(
                                  boxShadow: AppColors.neumorpShadow,
                                  color: AppColors.primaryWhite,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: EdgeInsets.symmetric(
                                    horizontal: width / 25,
                                    vertical: height / 30),
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      top: 150,
                                      bottom: -200,
                                      left: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.blue[900]
                                                      .withOpacity(0.2),
                                                  blurRadius: 50,
                                                  spreadRadius: 2,
                                                  offset: Offset(20, 0)),
                                              BoxShadow(
                                                  color: Colors.white12,
                                                  blurRadius: 0,
                                                  spreadRadius: -2,
                                                  offset: Offset(0, 0)),
                                            ],
                                            shape: BoxShape.circle,
                                            color: Colors.white30),
                                      ),
                                    ),
                                    Positioned.fill(
                                      top: -100,
                                      bottom: -100,
                                      left: -300,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.blue[900]
                                                      .withOpacity(0.2),
                                                  blurRadius: 50,
                                                  spreadRadius: 2,
                                                  offset: Offset(20, 0)),
                                              BoxShadow(
                                                  color: Colors.white12,
                                                  blurRadius: 0,
                                                  spreadRadius: -2,
                                                  offset: Offset(0, 0)),
                                            ],
                                            shape: BoxShape.circle,
                                            color: Colors.white30),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width / 20,
                                          vertical: height / 20),
                                      child: Stack(
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                width: width / 2.0,
                                                child: Image.asset(
                                                  "assets/mastercardlogo.png",
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Container(
                                                height: height / 9,
                                                width: width / 1.5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "**** **** **** ",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  fontSize(20),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(
                                                          card['cardNumber'].substring(
                                                              card['cardNumber']
                                                                      .length -
                                                                  4),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  fontSize(30),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      card['cardHolderName']
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              fontSize(15),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue),
                                                    )
                                                  ],
                                                ),
                                              )),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              alignment: Alignment.topRight,
                                              width: width / 6,
                                              height: height / 16,
                                              child: Column(
                                                children: <Widget>[
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Text(
                                                        'Expire \n' +
                                                            card['expiryDate'],
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  color: AppColors.primaryWhite,
                                                  boxShadow:
                                                      AppColors.neumorpShadow,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              alignment: Alignment.bottomRight,
                                              width: width / 6,
                                              height: height / 16,
                                              child: Column(
                                                children: <Widget>[
                                                  Center(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      "CVC:\n.." +
                                                          card['cvvCode'].substring(
                                                              card['cvvCode']
                                                                      .length -
                                                                  1),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ))
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  color: AppColors.primaryWhite,
                                                  boxShadow:
                                                      AppColors.neumorpShadow,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // CreditCardWidget(
                              //   cardNumber: card['cardNumber'],
                              //   expiryDate: card['expiryDate'],
                              //   cardHolderName: card['cardHolderName'],
                              //   cvvCode: card['cvvCode'],
                              //   showBackView: false,
                              // ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: ExpensesWidget())
            ],
          ),
        ),
      ),
    );
  }
}
