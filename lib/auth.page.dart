import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:test_stream/channellist.page.dart';
import 'package:test_stream/config.dart';
import 'package:test_stream/stream.api.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    Key key,
  }) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // FORM KEY
  final formKey = GlobalKey<FormState>();
  // CONTROLLER
  TextEditingController textInputController = TextEditingController();
  TextEditingController textNumberController = TextEditingController();
  // STATE
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange[200],
              Colors.orange[600],
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      child: Text(
                        "SkuyChat.com",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    inputFieldName(),
                    inputFieldNumber(),
                    buttonStartChat(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container inputFieldName() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 15),
      child: TextFormField(
        controller: this.textInputController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Nama lengkap wajib diisi';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Nama Lengkap",
          contentPadding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }

  Container inputFieldNumber() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        controller: this.textNumberController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Nomor handphone wajib diisi';
          }
          String validNumber = Config.validationPhoneNumber(value);
          if (validNumber.isNotEmpty) {
            return validNumber;
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Nomor handphone",
          contentPadding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }

  Container buttonStartChat(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.5),
            offset: Offset.zero,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(
            "Selanjutnya",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onPressed: () => handleStartChat(
          context: context,
        ),
      ),
    );
  }

  Future handleStartChat({
    @required BuildContext context,
  }) async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      // DATA FORM
      String fullName = this.textInputController.text;
      String phoneNumber = this.textNumberController.text;
      // SET ID FROM NUMBER PHONE
      String id = 'skuychat-' + phoneNumber;
      // CONFIGURE STREAM
      final client = Client(
        Config.apiKey,
        logLevel: Level.SEVERE,
      );
      // DEFAULT IMAGE
      String defaultImage =
          'https://i2.wp.com/www.winhelponline.com/blog/wp-content/uploads/2017/12/user.png?fit=256%2C256&quality=100&ssl=1';

      // Initialize user
      await StreamApi.initUser(
        client,
        id: id,
        imageUrl: defaultImage,
        username: fullName.toLowerCase(),
      );

      setState(() {
        isLoading = false;
      });
      // GO TO CHAT LIST
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ChannelListPage(client),
        ),
        (route) => false,
      );
    }
  }
}
