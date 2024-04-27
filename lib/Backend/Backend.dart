
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movie_watchserver_ui/Model/MovieModel.dart';



class Backend
{


  Future<List<MovieModel>> getMovies()async
  {
    var response= await   http.get(Uri.parse("http://192.168.1.40:3000/movies?type=movie&genre="));


    var  list=  jsonDecode(response.body)as List;  
    List<MovieModel> modelList=[];

    list.forEach((element) {
      modelList.add(MovieModel(element['Title'], element['Poster']));

     });

    return modelList;
  }

 Future<String> getClientNames()async
  {
    var response= await   http.get(Uri.parse("http://192.168.1.40:3000/clients"));


  print("clients"+response.body);

    return response.body;
  }




}


