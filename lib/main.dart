import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_watchserver_ui/Backend/Backend.dart';
import 'package:movie_watchserver_ui/Components/Button1.dart';
import 'package:movie_watchserver_ui/Components/MovieCard.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool serverStatus = false;
  int pid = 0;
  var movieList = [];
  var currentDirectory = "Add Current Directory";
  var serverIp = "Add IP";
  var iptextController = TextEditingController();

  var clients = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitalData();
  }

  @override
  void dispose() {
    // Save data here before the widget is removed
    super.dispose();
    stopServer();
  }

  getInitalData() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/Config.txt';
    final file = File(filePath);
    var strarry = ["directory-temp", "IP-192.168.1.40"];
    if (file.existsSync()) {
      String contents = await file.readAsString();
      currentDirectory = contents.split(",")[0].split("-")[1];
      serverIp = contents.split(",")[1].split("-")[1];
      iptextController.text = serverIp;
      setState(() {});
    }
  }

  void startNodeServer() async {
    try {
      await Process.start('node', ['./lib/Backend/app.js'])
          .then((Process process) async {
        //   print('Node.js server started.');
        serverStatus = true;

        setState(() {
          pid = process.pid;
        });

        process.stdout.transform(utf8.decoder).listen((data) {
          print(data);
          if (data.contains("Connectedclients:")) {
            clients = data.split(":")[1];
          }
          setState(() {
            
          });
        });

        process.stderr.transform(utf8.decoder).listen((data) {
          print('Error: $data');
        });
        const snackBar = SnackBar(
          content: Text('Server Started'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } catch (e) {
      print('Error starting Node.js server: $e');
    }
  }

  void stopServer() {
    Process.killPid(pid);
    setState(() {
      serverStatus = false;
    });
    const snackBar = SnackBar(
      content: Text('Server Stoped'),
      duration: Duration(seconds: 3), // Adjust the duration as needed
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void changeIp() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/Config.txt';
    final file = File(filePath);
    var strarry = ["directory-temp", "IP-192.168.1.40"];
    if (file.existsSync()) {
      String contents = await file.readAsString();
      strarry = contents.split(",");
    }

    var output = strarry[0] +
        "," +
        strarry[1].split("-")[0] +
        "-" +
        iptextController.text;

    await file.writeAsString(output);
    const snackBar = SnackBar(
      content: Text('IP Address Changed'),
      duration: Duration(seconds: 3), // Adjust the duration as needed
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void getDirectory() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/Config.txt';
    final file = File(filePath);
    var strarry = ["directory-temp", "IP-192.168.1.40"];
    if (file.existsSync()) {
      String contents = await file.readAsString();
      strarry = contents.split(",");
    }

    // Read file asynchronously

    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      currentDirectory = result;
      setState(() {});
    } else {
      // User canceled the picker
    }

    var output = strarry[0].split("-")[0] +
        "-" +
        currentDirectory.replaceAll('\\', "/") +
        "," +
        strarry[1];

    // Write to file
    await file.writeAsString(output);
    const snackBar = SnackBar(
      content: Text('Directory Changed'),
      duration: Duration(seconds: 3), // Adjust the duration as needed
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Movie Watch Server",
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                serverStatus == false
                    ? Button1(
                        color: Colors.amber,
                        imagepath: "assets/Images/start.png",
                        text: "Start Server",
                        onclick: () {
                          startNodeServer();
                        })
                    : Button1(
                        color: Colors.red,
                        imagepath: "assets/Images/stop.png",
                        text: "Stop Server",
                        onclick: () {
                          stopServer();
                        }),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Movies Available",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          
                          TextButton(
                              onPressed: () async {
                                movieList = await Backend().getMovies();
                                setState(() {});
                              },
                              child: Text("Fetch Movies"))
                        ],
                      ),
                      SizedBox(height: 20,),
                      Container(
                        height: 100,
                        width: 600,
                        child: ListView.builder(
                            itemCount: movieList.length,
                            itemBuilder: (context, index) {
                              return MovieCard(movieList[index]);
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  height: 300,
                  width: 1,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                          "Connected Devices",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                    SizedBox(height: 20,),

                    clients!=""?
                    Container(

                      padding: EdgeInsets.all(10),
                      height: 70,
                      width: 400,
                      decoration: BoxDecoration(  color: Colors.amber,borderRadius: BorderRadius.all(Radius.circular(5))),
                    
                      alignment: Alignment.center,
                      child: Container(
                     
                        child: Row(
                        
                          crossAxisAlignment: CrossAxisAlignment.center,
                       
                                             
                          children: [
                            Icon(Icons.person,color: Colors.white,size: 30,),
                            SizedBox(width: 10,),
                           
                            Baseline(baseline: 30.0,baselineType: TextBaseline.alphabetic,child: Text(clients,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500)) ,)
                          ],
                        ),
                      ),
                    ):Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text("No device Connected",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w400),),
                    ),

                    SizedBox(height: 20,),
                   const Text(
                          "Server Configs",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Text(
                            "Current Directory : ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(currentDirectory, style: TextStyle(fontSize: 17)),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                getDirectory();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: Text("Change"),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Text(
                            "Server IP: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Container(
                              width: 100,
                              child: TextField(
                                controller: iptextController,
                                decoration:
                                    InputDecoration(border: InputBorder.none),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                changeIp();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: Text("Change"),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ))
                        ],
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
