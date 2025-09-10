import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/model/response/customer_idx_get_res.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  int cid = 0;
  ProfilePage({super.key, required this.cid});

  @override
  State<ProfilePage> createState() => _PorfilePageState();
}

class _PorfilePageState extends State<ProfilePage> {
  String url = '';
  late CustomerIdxGetResponse customerLoginPostResponse;
  late Future<void> loadData;

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'ยืนยันการยกเลิกสมาชิก?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ปิด'),
                        ),
                        FilledButton(
                          onPressed: delete,
                          child: const Text('ยืนยัน'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('ยกเลิกสมาชิก'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    customerLoginPostResponse.image,
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 16),
                Text("ชื่อ-นามสกุล", style: TextStyle(fontSize: 20)),
                TextFormField(
                  initialValue: customerLoginPostResponse.fullname,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) {
                    customerLoginPostResponse.fullname = value;
                  },
                ),
                const SizedBox(height: 16),
                Text("หมายเลขโทรศัพท์", style: TextStyle(fontSize: 20)),
                TextFormField(
                  initialValue: customerLoginPostResponse.phone,
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) {
                    customerLoginPostResponse.phone = value;
                  },
                ),
                const SizedBox(height: 16),
                Text("อีเมล", style: TextStyle(fontSize: 20)),
                TextFormField(
                  initialValue: customerLoginPostResponse.email,
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) {
                    customerLoginPostResponse.email = value;
                  },
                ),
                Text("image", style: TextStyle(fontSize: 20)),
                TextFormField(
                  initialValue: customerLoginPostResponse.image,
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) {
                    customerLoginPostResponse.image = value;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: update, child: Text("แก้ไขข้อมูล")),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> update() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];

    var json = {
      "fullname": customerLoginPostResponse.fullname,
      "phone": customerLoginPostResponse.phone,
      "email": customerLoginPostResponse.email,
      "image": customerLoginPostResponse.image,
    };

    var res = await http.put(
      Uri.parse('$url/customers/${widget.cid}'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode(json),
    );
    log(res.body);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สำเร็จ'),
        content: const Text('บันทึกข้อมูลเรียบร้อย'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/customers/${widget.cid}'));
    log(res.body);
    customerLoginPostResponse = customerIdxGetResponseFromJson(res.body);
  }

  void delete() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];

    var res = await http.delete(Uri.parse('$url/customers/${widget.cid}'));
    log(res.statusCode.toString());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
