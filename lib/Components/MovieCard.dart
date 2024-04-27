


import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_watchserver_ui/Model/MovieModel.dart';

class MovieCard extends StatelessWidget


{

  MovieModel model= MovieModel("", "");

  MovieCard(this.model);
  @override
  Widget build(BuildContext context) {
 
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.amber,borderRadius: BorderRadius.all(Radius.circular(5))),
      height: 70,
      child: Row(children: [
        Image.network(model.poster,),
        SizedBox(width: 10,),
        Text(model.title,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),)
      ],),
    );
  }
  
}