import 'dart:async';
import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/config/internal_config.dart'; // ใช้สำรองถ้าโหลด config ไม่ทัน
import 'package:flutter_application_1/model/request/customer_login_post_req.dart';
import 'package:flutter_application_1/model/response/customer_login_post_res.dart';
import 'package:flutter_application_1/pages/register_page.dart';
import 'package:flutter_application_1/pages/show_trip_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ---------------- UI/STATE ----------------
  final _formKey = GlobalKey<FormState>();
  final _phoneCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  // ---------------- CONFIG ----------------
  String _endpointFromConfig = ''; // โหลดจาก Configuration.getConfig()

  @override
  void initState() {
    super.initState();
    // โหลด config (ไม่บล็อก UI)
    Configuration.getConfig().then((config) {
      setState(() {
        _endpointFromConfig = (config['apiEndpoint'] ?? '').toString();
      });
    }).catchError((e) {
      log('Load config error: $e');
    });
  }

  @override
  void dispose() {
    _phoneCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  // ---------------- HELPERS ----------------
  String get _baseEndpoint {
    // ถ้าโหลด config ทันใช้ค่านั้นก่อน ไม่งั้น fallback เป็น API_ENDPOINT จาก internal_config.dart
    final raw = _endpointFromConfig.isNotEmpty ? _endpointFromConfig : API_ENDPOINT;
    // กันท้าย/หัวให้ไม่มีซ้ำ //
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  Uri _loginUri() => Uri.parse('$_baseEndpoint/customers/login');

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final req = CustomerLoginPostRequest(
      phone: _phoneCtl.text.trim(),
      password: _passCtl.text,
    );

    try {
      final res = await http
          .post(
            _loginUri(),
            headers: const {"Content-Type": "application/json; charset=utf-8"},
            body: customerLoginPostRequestToJson(req),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = customerLoginPostResponseFromJson(res.body);
        log('fullname: ${data.customer.fullname}');
        log('email: ${data.customer.email}');
        log('idx: ${data.customer.idx}');

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Showtrippage(cid: data.customer.idx),
          ),
        );
      } else {
        // แสดง error จาก server ถ้ามี
        String message = 'เข้าสู่ระบบไม่สำเร็จ (${res.statusCode})';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['message'] is String) {
            message = body['message'];
          }
        } catch (_) {}
        _showSnack(message);
      }
    } on TimeoutException {
      _showSnack('เซิร์ฟเวอร์ตอบช้า ลองใหม่อีกครั้ง');
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topImage =
        "https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?q=80&w=2070&auto=format&fit=crop"; // เสือเดิมก็ได้ เปลี่ยนลิงก์ให้คมขึ้น

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('เข้าสู่ระบบ'),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ----- HERO IMAGE + GRADIENT -----
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(topImage, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.45),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline,
                              color: Colors.white.withOpacity(0.95)),
                          const SizedBox(width: 8),
                          Text(
                            'ยินดีต้อนรับกลับมา',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ----- CARD -----
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // PHONE
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('หมายเลขโทรศัพท์',
                                style: theme.textTheme.titleMedium),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneCtl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.phone_outlined),
                              hintText: 'เช่น 0812345678',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'กรอกเบอร์โทรศัพท์';
                              if (value.length < 8) {
                                return 'เบอร์สั้นเกินไป';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('รหัสผ่าน',
                                style: theme.textTheme.titleMedium),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.key_outlined),
                              hintText: 'กรอกรหัสผ่าน',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                tooltip:
                                    _obscure ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').isEmpty) return 'กรอกรหัสผ่าน';
                              if ((v ?? '').length < 4) {
                                return 'รหัสผ่านอย่างน้อย 4 ตัวอักษร';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 12),

                          // REMEMBER / REGISTER
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed:
                                    _loading ? null : () => _goRegister(),
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text('ลงทะเบียนใหม่'),
                              ),
                              const Spacer(),
                              if (_endpointFromConfig.isEmpty)
                                Tooltip(
                                  message:
                                      'กำลังใช้ค่า API สำรอง: $API_ENDPOINT',
                                  child: const Icon(Icons.info_outline,
                                      size: 18),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // SUBMIT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(_loading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ'),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ลิงก์ช่วยเหลือเบาๆ
              TextButton(
                onPressed: _loading
                    ? null
                    : () => _showSnack('ติดต่อผู้ดูแลระบบเพื่อขอความช่วยเหลือ'),
                child: const Text('ลืมรหัสผ่าน / พบปัญหา?'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _goRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Registerpage()),
    );
  }
}
