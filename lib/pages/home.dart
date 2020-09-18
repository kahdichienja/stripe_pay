import 'package:chatapp/config/colors.dart';
import 'package:chatapp/provider/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment-service.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'existing-cards.dart';

class HomePagePayment extends StatefulWidget {
  HomePagePayment({Key key}) : super(key: key);

  @override
  HomePagePaymentState createState() => HomePagePaymentState();
}

class HomePagePaymentState extends State<HomePagePayment> {
  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        payViaNewCard(context);
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExistingCardsPage(),
          ),
        );
        break;
      case 2:
        payViaNativePay(context);
        break;
    }
  }

  payViaNativePay(BuildContext context) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response = await StripeService.payViaMpesa(
      amount: '100',
      currency: 'KES',
    );
    await dialog.hide();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));
  }

  payViaNewCard(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ProgressDialog dialog = new ProgressDialog(context);
    // var stripeService = StripeService();
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response =
        await StripeService.payWithNewCard(amount: '15000', currency: 'USD', user: userProvider.userModel?.id);
    await dialog.hide();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        title: Text('Choose Payment Mode'),
      ),
      body: Container(
        color: AppColors.primaryWhite,
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              Icon icon;
              Text text;

              switch (index) {
                case 0:
                  icon = Icon(Icons.add_circle, color: Colors.green);
                  text = Text('Pay via new card');
                  break;
                case 1:
                  icon = Icon(Icons.credit_card, color: Colors.green);
                  text = Text('Pay via existing card');
                  break;
                case 2:
                  icon =
                      Icon(Icons.account_balance_wallet, color: Colors.green);
                  text = Text('Pay via Mpesa');
                break;
              }

              return InkWell(
                onTap: () {
                  onItemPress(context, index);
                },
                child: ListTile(
                  title: text,
                  leading: icon,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
                  color: Colors.green,
                ),
            itemCount: 3),
      ),
    );
  }
}
