import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> data1 = [];
  Map<String, dynamic> data2 = {};

  static final stopwatch1 = Stopwatch();
  static final stopwatch2 = Stopwatch();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  /* Fetch Data */
  Future fetchData()async{
    ReceivePort receivePort1 = ReceivePort();
    ReceivePort receivePort2 = ReceivePort();

    
    await Future.wait([
     Isolate.spawn(apiFunction1, receivePort1.sendPort),
     Isolate.spawn(apiFunction2, receivePort2.sendPort)
    ]);

    receivePort1.listen((message) {
      setState(() {
        data1 = message;
        print('Result1 $data1');
      });
    });

    receivePort2.listen((message) {
      setState(() {
        data2 = message;
        print('Result2 $data2');
      });
    });
  }

  /* Hit Api */
  static void apiFunction1(SendPort sendPort)async{
    stopwatch1.start();
    final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    stopwatch1.stop();
    final elapsedTime = stopwatch1.elapsedMilliseconds;
    print('Time taken for Api 1: $elapsedTime ms');

    if (response.statusCode == 200){
      sendPort.send(jsonDecode(response.body));
    }

    else{
      print('Error ${response.body}');
    }

  }


  static void apiFunction2(SendPort sendPort)async{
    stopwatch2.start();
    final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts/3"));
    stopwatch2.stop();
    final elapsedTime = stopwatch2.elapsedMilliseconds;
    print('Time taken for Api 2: ${elapsedTime} ms');


    if (response.statusCode == 200){
      sendPort.send(jsonDecode(response.body));
    }

    else{
      print('Error ${response.body}');
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: data1.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : ListView.builder(
            itemCount: data1.length,
            itemBuilder: (context, index){
              return ListTile(
                leading: Text(data1[index]['id'].toString()),
                title: Text(data1[index]['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            },

          )),

          Expanded(
              flex: 1,
              child: data2.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.red))
                  : Center(
                    child: ListTile(
                      leading: Text(data2['id'].toString()),
                      title: Text(data2['body'].toString(), maxLines: 1),
                                  ),
                  )),
        ],
      ),
    );
  }
}
