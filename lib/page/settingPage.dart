import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';

class Setting extends StatefulWidget {
  Setting({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late BluetoothCharacteristic targetChar;
  late StreamSubscription<List<int>> streamSubscription;
  List<DropdownMenuItem<String>>? dropDownMenuItems;
  TextEditingController valueController = TextEditingController();
  final ssidController = TextEditingController();
  final passController = TextEditingController();
  final linkController = TextEditingController();
  double counter = 0;
  String text = '';
  String receive = '';
  String value = '';
  String jsonString = '';
  String ssid = '';
  String pass = '';
  String link = '';
  String? selectedValue;
  List<String> options = [];
  bool play = false;
  bool power = false;
  bool lamp = false;
  bool noise = false;
  bool music = false;
  bool retry = false;
  Timer? timer;
  bool stopTimer = false;

  @override
  void initState() {
    discoverTes();
    super.initState();
  }

  discoverTes() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == service.uuid.toString()) {
        service.characteristics.forEach((char) async {
          if (char.uuid.toString() == char.uuid.toString()) {
            targetChar = char;
            setState(() {});
            char.value.listen((value) {
              setState(() {
                dropDownMenuItems = value
                    .map((value) => DropdownMenuItem(
                          value: value.toString(),
                          child: Text(value.toString()),
                        ))
                    .toList();
                String drop = utf8.decode(value).trim();
                options.add(drop.trim());
              });
              // receiveData();
              setState(() {});
            });
            setState(() {});
          }
        });
      }
    });
  }

  Future<void> reading() async {
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      receiveData();
      if (stopTimer) {
      timer.cancel();
    }
    });
    await Future.delayed(Duration(seconds: 3));
  }

  void sendJsonToEsp() {
    value = valueController.text;
    convertInputToJson();
    Navigator.pop(context);
    sendJsonString(jsonString);
    valueController.clear();
  }

  void sendWifi() {
    ssid = ssidController.text;
    pass = passController.text;
    link = linkController.text;
    convertWifi();
    Navigator.pop(context);
    sendJsonString(jsonString);
    ssidController.clear();
    passController.clear();
    linkController.clear();
    setState(() {});
  }

  sendJsonString(String jsonString) async {
    Uint8List json = utf8.encode(jsonString) as Uint8List;
    targetChar.write(json);
  }

  void addCounter(String pluses) {
    if (counter + 0.1 <= 1.0) {
      setState(() {
        counter += 0.1;
      });
    }
    Uint8List plus = utf8.encode(pluses) as Uint8List;
    targetChar.write(plus, withoutResponse: true);
  }

  void subtractCounter(String mineses) {
    if (counter - 0.1 >= 0.0) {
      setState(() {
        counter -= 0.1;
      });
    }
    Uint8List mines = utf8.encode(mineses) as Uint8List;
    targetChar.write(mines, withoutResponse: true);
  }

  writeData(String data) {
    try {
      List<int> bytes = utf8.encode(data);
      targetChar.write(bytes, withoutResponse: true);
      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> sendOnMessageToBluetooth(String message) async {
    writeData('8');
    await Future.delayed(Duration(seconds: 3));
    List<int> data = utf8.encode(message);
    targetChar.write(data);
  }

  Future<void> receiveData() async {
    try {
      List<int> value = await targetChar.read();
      receive = utf8.decode(value).trim();
      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  void convertInputToJson() {
    value = value.replaceAll(new RegExp(r'\s'), "");
    jsonString = '{"DLT":"$value"}';
  }

  void convertWifi() {
    ssid = ssid.replaceAll(new RegExp(r'\s'), "");
    pass = pass.replaceAll(new RegExp(r'\s'), "");
    link = link.replaceAll(new RegExp(r'\s'), "");
    jsonString = '{"S":"$ssid"},{"PW":"$pass"},{"f":"$link"}';
  }

  sendConvert() {
    List<int> json = utf8.encode('/${selectedValue?.trim()}');
    targetChar.write(json, withoutResponse: true);
  }

  Future<void> displayInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Write title'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  value = jsonString.trim();
                });
              },
              controller: valueController,
              decoration: InputDecoration(hintText: "title"),
            ),
            actions: <Widget>[
              ElevatedButton(child: Text('OK'), onPressed: sendJsonToEsp),
            ],
          );
        });
  }

  void openLoading(BuildContext context, [bool mounted = true]) async {
    if (noise || music) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              // The background color
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // The loading indicator
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 15,
                    ),
                    // Some text
                    Text('Loading...')
                  ],
                ),
              ),
            );
          });
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> displayInstall(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Download'),
            content: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      value = jsonString.trim();
                    });
                  },
                  controller: ssidController,
                  decoration: InputDecoration(hintText: "ssid"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      value = jsonString.trim();
                    });
                  },
                  controller: passController,
                  decoration: InputDecoration(hintText: "pass"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      value = jsonString.trim();
                    });
                  },
                  controller: linkController,
                  decoration: InputDecoration(hintText: "link"),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(child: Text('OK'), onPressed: sendWifi),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final Color _baseColor = Color.fromRGBO(42, 50, 75, 1);
    final Color baseColor12 = Color.fromRGBO(42, 50, 75, 0.1);
    final Color textColor = Color.fromRGBO(42, 50, 75, 0.8);
    final Color bgColor = Color.fromRGBO(252, 252, 252, 1);
    final Color subText = Color.fromRGBO(0, 0, 0, 0.56);
    final Color disableBaseColor = Color.fromRGBO(216, 226, 220, 1);
    final Color disableBaseColor12 = Color.fromRGBO(0, 0, 0, 0.56);
    final Color fieldBgColor = Color.fromRGBO(221, 225, 234, 1);
    final Color lampOn = Color.fromRGBO(249, 203, 64, 1);
    final Color powerOn = Color.fromRGBO(36, 169, 108, 1);
    final Color redColor = Color.fromRGBO(214, 71, 51, 1);

    void playPaused() {
      if (play == true) {
        writeData('3\n');
      } else {
        writeData('4\n');
      }
      setState(() {
        play = !play;
      });
      debugPrint('$play');
    }

    void lampStats() {
      if (lamp == true) {
        writeData('lagu.mp3\n');
      } else {
        writeData('0\n');
      }
      setState(() {
        lamp = !lamp;
      });
      debugPrint('$lamp');
    }

    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          toolbarHeight: (constraints.maxHeight * 0.1),
          backgroundColor: _baseColor,
          title: Text(widget.device.name),
          actions: <Widget>[
            IconButton(
              color: power ? powerOn : disableBaseColor,
              icon: Icon(Icons.power_settings_new),
              iconSize: (width * 0.1),
              tooltip: "On/Off",
              onPressed: () {
                setState(() {
                  power = !power;
                });
              },
            ),
            IconButton(
                icon: Icon(Icons.lightbulb),
                color: lamp ? lampOn : fieldBgColor,
                iconSize: (width * 0.1),
                tooltip: "Save Todo and Retrun to List",
                onPressed: lampStats),
          ],
        ),
        body: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: width * 0.11,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: _baseColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              await widget.device.disconnect();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.bluetooth_disabled,
                            ),
                          ),
                        ),
                        Badge(
                          animationType: BadgeAnimationType.fade,
                          padding: const EdgeInsets.all(10.0),
                          badgeContent:
                              Text('1', style: TextStyle(color: Colors.white)),
                          badgeColor: redColor,
                          toAnimate: true,
                          child: Container(
                            height: (height * 0.060),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _baseColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                receiveData();
                              },
                              child: Icon(
                                Icons.mail_rounded,
                                color: bgColor,
                                size: (width * 0.08),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: (constraints.maxWidth * 0.03)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: baseColor12,
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: (constraints.maxWidth * 0.04)),
                                  color: _baseColor,
                                  height: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal:
                                            (constraints.maxWidth * 0.05),
                                      ),
                                      child: Text(
                                        "Settings",
                                        style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                                color: textColor,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: (constraints.maxWidth * 0.01)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('noise'),
                                                  Switch(
                                                      value: noise,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          noise = value;
                                                        });
                                                        openLoading(context);
                                                        if (noise == true) {
                                                          sendOnMessageToBluetooth(
                                                              '5\n');
                                                        } else if (noise ==
                                                            false) {
                                                          writeData('3\n');
                                                        }
                                                      }),
                                                ],
                                              ),
                                              Container(
                                                height: 20,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon((Icons
                                                        .noise_aware_sharp)),
                                                    IconButton(
                                                      onPressed: () {
                                                        addCounter(counter
                                                            .toStringAsFixed(
                                                                1));
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        subtractCounter(counter
                                                            .toStringAsFixed(
                                                                1));
                                                      },
                                                      icon: const Icon(
                                                        Icons.minimize_rounded,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text('play music'),
                                                  Switch(
                                                      value: music,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          music = value;
                                                        });
                                                        openLoading(context);
                                                        if (music == true) {
                                                          sendOnMessageToBluetooth(
                                                              'l\n');
                                                          receiveData();
                                                        } else if (music ==
                                                            false) {
                                                          writeData('9\n');
                                                          receiveData();
                                                        }
                                                      })
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.developer_board,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      addCounter(counter
                                                          .toStringAsFixed(1));
                                                    },
                                                    icon: const Icon(
                                                      Icons.add,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      subtractCounter(counter
                                                          .toStringAsFixed(1));
                                                    },
                                                    icon: const Icon(
                                                      Icons.minimize,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                Expanded(
                    flex: 8,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Play Music",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                    color: _baseColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            child: Container(
                              padding: EdgeInsets.all((width * 0.04)),
                              height: width / 2.5,
                              width: width / 1.19,
                              color: baseColor12,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: (0.05)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: _baseColor,
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: DropdownButton(
                                      underline: Container(
                                        height: 0,
                                      ),
                                      hint: Text(
                                        "Select Music",
                                        style: TextStyle(color: bgColor),
                                      ),
                                      isExpanded: true,
                                      style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                              color: bgColor, fontSize: 16)),
                                      items: options
                                          .where(
                                              (value) => value.contains('.mp3'))
                                          .map((value) {
                                        return DropdownMenuItem(
                                            value: value.trim(),
                                            child: Text(value.trim()));
                                      }).toList(),
                                      onChanged: (value) => setState(() {
                                        selectedValue = value;
                                      }),
                                      icon: Icon(Icons.arrow_drop_down_rounded),
                                      iconEnabledColor: bgColor,
                                      iconSize: 42,
                                      dropdownColor: _baseColor,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: (height * 0.06),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _baseColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                          onPressed: () {
                                            writeData('R\n');
                                            setState(() {
                                              retry = !retry;
                                            });
                                          },
                                          child: Icon(
                                            Icons.repeat_one_rounded,
                                            color: retry ? powerOn : bgColor,
                                            size: (width * 0.08),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                              color: _baseColor,
                                              iconSize: width * 0.1,
                                              onPressed: () {
                                                writeData('P\n');
                                              },
                                              icon: Icon(
                                                  Icons.skip_previous_rounded)),
                                          IconButton(
                                            color: _baseColor,
                                            iconSize: width * 0.1,
                                            icon: play
                                                ? Icon(Icons.stop)
                                                : Icon(Icons.play_arrow),
                                            onPressed: playPaused,
                                          ),
                                          IconButton(
                                              color: _baseColor,
                                              iconSize: width * 0.1,
                                              onPressed: () {
                                                writeData('N\n');
                                              },
                                              icon:
                                                  Icon(Icons.skip_next_rounded))
                                        ],
                                      ),
                                      Container(
                                        height: (height * 0.06),
                                        width: (height * 0.07),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _baseColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                          onPressed: sendConvert,
                                          child: Icon(
                                            Icons.send_rounded,
                                            color: bgColor,
                                            size: (width * 0.06),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ])),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: (height * 0.065),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _baseColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              displayInput(context);
                            },
                            child: Icon(
                              Icons.delete,
                              color: redColor,
                              size: (width * 0.08),
                            ),
                          ),
                        ),
                        Container(
                          height: (height * 0.065),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _baseColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              displayInstall(context);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload, color: bgColor),
                                Text(
                                  "Upload New Song",
                                  style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                          color: bgColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      );
    });
  }
}