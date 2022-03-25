import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _scanBarcode = 'Unknown';

  final List<String> fish_tanks = [
    'FT1',
    'FT2',
    'FT3',
    'FT4',
    'FT5',
    'FT6',
    'FT7',
    'FT8',
    'FT9',
    'FT10'
  ];

  final List<String> fish_feed = ['0.8', '1.2', '2.5', '3', '4'];

  List<String> primary_feed = [];
  List<String> secondary_feed = [];
  List<int> primary_feed_grams = [];
  List<int> secondary_feed_grams = [];
  List<bool> previous_feed_left_over = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fish_tanks.forEach((element) {
      primary_feed.add('0.8');
      secondary_feed.add('1.2');
      primary_feed_grams.add(0);
      secondary_feed_grams.add(0);
      previous_feed_left_over.add(false);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      // print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  _tile(int index) {
    return Column(children: [
      Text(fish_tanks[index]),
      SizedBox(height: 10.0),
      Row(
        children: [
          Text("Primary Feed"),
          SizedBox(width: 30.0),
          DropdownButton<String>(
            value: primary_feed[index],
            items: fish_feed.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                primary_feed[index] = newValue ?? primary_feed[index];
              });
            },
          ),
          SizedBox(width: 30.0),
          Flexible(
              child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Primary Feed (grams)',
              hintText: '0',
            ),
            onChanged: (String? newValue) {
              setState(() {
                primary_feed_grams[index] = int.parse(newValue ?? '0');
              });
            },
          )),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Barcode scan')),
            body: Builder(builder: (BuildContext context) {
              return ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Fish Feed Log',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 20.0),
                        Flex(
                          direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                                onPressed: () => scanBarcodeNormal(),
                                child: Text('Start barcode scan')),
                            Text('Scan result : $_scanBarcode\n',
                                style: TextStyle(fontSize: 20))
                          ],
                        ),
                        SizedBox(height: 20.0),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: fish_tanks.length,
                          itemBuilder: (context, index) {
                            return _tile(index);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              );
            })));
  }
}
