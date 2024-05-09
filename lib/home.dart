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
  List<dynamic> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  /* Fetch Data */
  Future fetchData()async{
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(apiFunction, receivePort.sendPort);

    receivePort.listen((message) {
      setState(() {
        data = message;
        print('Result $data');
      });
    });
  }

  /* Hit Api */
  static void apiFunction(SendPort sendPort)async{
    final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
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
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index){
          return ListTile(
            leading: Text(data[index]['userId'].toString()),
            title: Text(data[index]['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        },

      ),
    );
  }
}
