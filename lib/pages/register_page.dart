import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/internal_config.dart';
import 'package:flutter_application_1/model/register/customer_register_port_req.dart';
import 'package:flutter_application_1/model/response/customer_login_post_res.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:http/http.dart' as http;

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Registerpage> {
  TextEditingController fullname = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  // TextEditingController image = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController comfirempassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ลงทะเบียนสมาชิกใหม่')),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text('ชื่อ-นามสกุล'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: fullname,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 25),
                child: Text('หมายเลขโทรศัพท์'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 25),
                child: Text('อีเมล์'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 25),
                child: Text('รหัสผ่าน'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 25),
                child: Text('ยืนยันรหัสผ่าน'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: comfirempassword,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FilledButton(
                      onPressed: () => register(),
                      child: const Text('สมัคสมาชิก'),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: login,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: const Text('หากยังมีบัญชีอยู่แล้ว?'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('เข้าสู่ระบบ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  register() {
    // Implement registration logic here
    // You can use the text from the controllers to send to your backend
    String fullName = fullname.text;
    String phoneNumber = phone.text;
    String emailAddress = email.text;
    // String userImage = image.text;
    String userPassword = password.text;
    String confirmPassword = comfirempassword.text;

    if (userPassword == confirmPassword) {
      CustomerRegisterPostRequest customerRegisterPostRequest =
          CustomerRegisterPostRequest(
            fullname: fullName,
            phone: phoneNumber,
            email: emailAddress,
            image: '', // Assuming image is optional or handled separately
            password: userPassword,
          );

      http
          .post(
            Uri.parse("$API_ENDPOINT/customers"),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: customerRegisterPostRequestToJson(
              customerRegisterPostRequest,
            ),
          )
          .then((value) {
            CustomerLoginPostResponse customerLoginPostResponse =
                customerLoginPostResponseFromJson(value.body);
            log(customerLoginPostResponse.customer.fullname);
            log(customerLoginPostResponse.customer.email);
          });
      // Add validation and API call logic as needed
      log('Password: $userPassword');
      log('Confirm Password: $confirmPassword');
      MaterialPageRoute(builder: (context) => LoginPage());
    } else {
      log("nononononononononon");
    }
  }
}
