import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/internal_config.dart';
import 'package:flutter_application_1/model/response/trip_get_res.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/trips.dart';
import 'package:http/http.dart' as http;

class Showtrippage extends StatefulWidget {
  int cid = 0;
  Showtrippage({super.key, required this.cid});

  @override
  State<Showtrippage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Showtrippage> {
  List<TripGetRespose> tripGetResponses = [];
  late Future<void> loadData;
  @override
  void initState() {
    super.initState();
    // getTrips();
    loadData = getTrips();
  }

  // onlu one Ececution
  // Cannot run asyn function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('รายการทริป'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              log(value);
              if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(cid: widget.cid),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text('ข้อมูลส่วนตัว')),
              PopupMenuItem(value: 'logout', child: Text('ออกจากระบบ')),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          return SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('ปลายทาง'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: getTrips,
                          child: Text('ทั้งหมด'),
                        ),
                        FilledButton(
                          onPressed: getTripsAsia,
                          child: Text('เอเชีย'),
                        ),
                        FilledButton(
                          onPressed: () {
                            getTripsEURO();
                          },
                          child: Text('ยุโรป'),
                        ),
                        FilledButton(
                          onPressed: () {
                            getTripsASEAN();
                          },
                          child: Text('อาเชียน'),
                        ),
                        FilledButton(
                          onPressed: () {
                            getTripsNorthAmerica();
                          },
                          child: Text('อเมริกาเหนือ'),
                        ),
                        FilledButton(
                          onPressed: () {
                            getTripsSouthAmerica();
                          },
                          child: Text('อเมริกาใต้'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tripGetResponses.length,
                    itemBuilder: (context, index) {
                      final trip = tripGetResponses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // รูปภาพ
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  trip.coverimage ?? '',
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                                ),
                              ),

                              // เนื้อหาทัวร์
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip.name ?? 'ไม่ระบุชื่อ',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      trip.country ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      trip.detail.length > 100
                                          ? '${trip.detail.substring(0, 100)}...'
                                          : (trip.detail ?? ''),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${trip.duration} วัน',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '฿${trip.price}',
                                          style: const TextStyle(
                                            color: Colors.deepOrange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () => gotoTrip(trip.idx),
                                          child: Text('รายละเอียดเพิม่เติม'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Add the Expanded widget here inside the Column
              ],
            ),
          );
        },
      ),
    );
  }

  void gotoTrip(int idx) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripPage(idx: idx)),
    );
  }

  Future<void> getTrips() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    tripGetResponses = tripGetResposeFromJson(res.body);
    setState(() {
      tripGetResponses = tripGetResposeFromJson(res.body);
    });
    log(tripGetResponses.length.toString());
  }

  Future<void> getTripsEURO() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));

    // แปลงข้อมูลจาก JSON ทั้งหมด
    var allTrips = tripGetResposeFromJson(res.body);

    // กรองเฉพาะทริปโซน EURO
    var euroTrips = allTrips
        .where((trip) => trip.destinationZone.toUpperCase() == "ยุโรป")
        .toList();

    setState(() {
      tripGetResponses = euroTrips;
    });

    log("EURO trips: ${tripGetResponses.length}");
  }

  Future<void> getTripsAsia() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    // แปลงข้อมูลจาก JSON ทั้งหมด
    var allTrips = tripGetResposeFromJson(res.body);
    // กรองเฉพาะทริปโซน EURO
    var euroTrips = allTrips
        .where((trip) => trip.destinationZone.toUpperCase() == "เอเชีย")
        .toList();

    setState(() {
      tripGetResponses = euroTrips;
    });

    log("ASIA  trips: ${tripGetResponses.length}");
  }

  Future<void> getTripsASEAN() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    // แปลงข้อมูลจาก JSON ทั้งหมด
    var allTrips = tripGetResposeFromJson(res.body);
    // กรองเฉพาะทริปโซน "เอเชียตะวันออกเฉียงใต้"
    var aseanTrips = allTrips
        .where((trip) => trip.destinationZone == "เอเชียตะวันออกเฉียงใต้")
        .toList();

    setState(() {
      tripGetResponses = aseanTrips;
    });

    log("ASEAN trips: ${tripGetResponses.length}");
  }

  Future<void> getTripsNorthAmerica() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    // แปลงข้อมูลจาก JSON ทั้งหมด
    var allTrips = tripGetResposeFromJson(res.body);
    // กรองเฉพาะโซน "อเมริกาเหนือ"
    var naTrips = allTrips
        .where((trip) => trip.destinationZone == "อเมริกาเหนือ")
        .toList();

    setState(() {
      tripGetResponses = naTrips;
    });

    log("North America trips: ${tripGetResponses.length}");
  }

  Future<void> getTripsSouthAmerica() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    // แปลงข้อมูลจาก JSON
    var allTrips = tripGetResposeFromJson(res.body);
    // กรองเฉพาะโซน "อเมริกาใต้"
    var saTrips = allTrips
        .where((trip) => trip.destinationZone == "อเมริกาใต้")
        .toList();

    setState(() {
      tripGetResponses = saTrips;
    });

    log("South America trips: ${tripGetResponses.length}");
  }
}
