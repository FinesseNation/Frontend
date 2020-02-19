import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/widgets/buildFinesseCard.dart';
import 'package:http/http.dart' as http;

class buildFinesseList extends StatelessWidget{
  Future<List<Finesse>> fetchFinesse() async{
    final response = await http.get('http://finesse-nation.herokuapp.com/api/food/getEvents');
    var responseJson;

    if(response.statusCode == 200){
      var data = json.decode(response.body);
      var responseJson = data.map<Finesse>((json) => Finesse.fromJson(json)).toList();
      return responseJson;
    }else{
      throw Exception('Failed to load finesses');
    }
  }

  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: fetchFinesse(),
        builder: (context, snapshot){
          return snapshot.data != null ?
              listViewWidget(snapshot.data)
              :Center(child: CircularProgressIndicator());
        },
      )
    );
  }

  Widget listViewWidget(List<Finesse> _finesses) {
    return new Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.lightBlue, Colors.pink],
            )
        ),
        child: new Center(
            child:
            ListView.builder(
                itemCount: _finesses.length*2,
                itemBuilder: (context, i) {
                  _finesses =_finesses.reversed.toList();
                  if (i.isOdd) return Divider();
                  final index = i ~/ 2;
                  return buildFinesseCard(_finesses[index]);
                })
        )
    );
  }
}