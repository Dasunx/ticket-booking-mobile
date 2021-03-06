import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ticket_booking_client/class/DarkThemeProvider.dart';
import 'package:ticket_booking_client/class/Payment.dart';
import 'package:ticket_booking_client/class/User.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_booking_client/screens/payment/make_payment.dart';

class PaymentHistory extends StatefulWidget {
  static const String id = "payment_history";
  final User user;

  const PaymentHistory({Key key, this.user}) : super(key: key);

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  List<Payment> phItems = new List<Payment>();
  String url = 'https://urbanticket.herokuapp.com/api/payment/by-user-id/';
  bool isLoaded = false;

  loadPayment() async {
    try {
      final http.Response response =
          await http.get(url + widget.user.userId, headers: <String, String>{
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 201) {
        //phItems = paymentListFromJson(jsonDecode(response.body)['payment']);
        //print(jsonDecode(response.body)['payments']);
        jsonDecode(response.body)['payments'].forEach((d) {
          setState(() {
            phItems.add(Payment.fromJson(d));
          });
        });
      }
    } catch (error) {
      print(error);
    }
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    loadPayment();
    //phItems.add(
    //new Payment(1000, DateTime.parse('2020-10-11 20:47:27.908'), "card"));
    //phItems.add(new Payment(2400, DateTime.now(), "CDM"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment history"),
      ),
      body: Container(
        child: isLoaded
            ? phItems.length > 0
                ? ListView.builder(
                    itemCount: phItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 6, top: 10, left: 6),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      phItems[index].type == "Fine"
                                          ? '- LKR ${phItems[index].payAmount.toString()}'
                                          : 'LKR ${phItems[index].payAmount.toString()}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: phItems[index].type == "Fine"
                                            ? Colors.red
                                            : themeChange.darkTheme
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    Spacer(),
                                    Chip(
                                      backgroundColor:
                                          phItems[index].type == "Fine"
                                              ? Colors.red
                                              : Colors.blue,
                                      label: Text(
                                        '${phItems[index].type.toString()}',
                                      ),
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        child: Icon(
                                          Icons.done,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${DateFormat.yMMMd().add_jm().format(phItems[index].date.toLocal()).toString()}',
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : Container(
                    child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage('images/no-data.png'),
                          )),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "No Payments",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.popAndPushNamed(context, MakePayment.id,
                                arguments: widget.user);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Top Up ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
