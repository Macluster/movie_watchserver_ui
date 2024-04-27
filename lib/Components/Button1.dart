import 'package:flutter/material.dart';

class Button1 extends StatelessWidget {
  Color color;
  String imagepath;
  String text;
  Function onclick;
  Button1({required this.color,required this.imagepath, required this.text, required this.onclick});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onclick();
      },
      child: Container(
        height: 100,
        width: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
            ),
            SizedBox(
              width: 10,
            ),
            Image.asset(
              imagepath,
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
