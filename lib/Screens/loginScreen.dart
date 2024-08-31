import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/Loading.dart';
import 'package:senseriduvarkagidi/Screens/newAccount.dart';
import 'package:senseriduvarkagidi/Screens/utils/animations.dart';
import 'package:senseriduvarkagidi/Screens/utils/text_utils.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedIndex=0;
  bool _rememberMe = false;
  bool showOption=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin:const  EdgeInsets.symmetric(vertical: 10),
        height: 49,
        width: double.infinity,

        child: Row(
          children: [
            Expanded(
                child:showOption? ShowUpAnimation(
                  delay: 100,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: Genel.bgList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context,index){
                        return   GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedIndex=index;
                            });
                          },
                          child: CircleAvatar(
                            radius: 30,

                            backgroundColor:selectedIndex==index? Colors.white:Colors.transparent,
                            child: Padding(
                              padding:const  EdgeInsets.all(1),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(Genel.bgList[index],),
                              ),
                            ),
                          ),
                        );

                      }),
                ):const SizedBox()),
            const  SizedBox(width: 20,),
            showOption? GestureDetector(
                onTap: (){
                  setState(() {
                    showOption=false;
                  });
                },
                child:const  Icon(Icons.close,color: Colors.white,size: 30,)) :
            GestureDetector(
              onTap: (){
                setState(() {
                  showOption=true;
                });
              },
              child: CircleAvatar(

                backgroundColor: Colors.white,
                child: Padding(
                  padding:const  EdgeInsets.all(1),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(Genel.bgList[selectedIndex],),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration:  BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Genel.bgList[selectedIndex]),fit: BoxFit.fill
          ),

        ),
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),


          ),
          child: ClipRRect(

            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(filter:ImageFilter.blur(sigmaY: 5,sigmaX: 5),
                child:Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const   Spacer(),
                      Center(child: TextUtil(text: "Giriş",weight: true,size: 30,) ),
                      const   Spacer(),
                      TextUtil(text: "Email",),
                      Container(
                        height: 35,
                        decoration:const  BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white))
                        ),
                        child:TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration:const  InputDecoration(
                            suffixIcon: Icon(Icons.mail,color: Colors.white,),
                            fillColor: Colors.white,
                            border: InputBorder.none,),
                        ),
                      ),
                      const   Spacer(),
                      TextUtil(text: "Şifre",),
                      Container(
                        height: 35,
                        decoration:const  BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white))
                        ),
                        child:TextFormField(
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration:const  InputDecoration(
                            suffixIcon: Icon(Icons.lock,color: Colors.white,),
                            fillColor: Colors.white,
                            border: InputBorder.none,),
                        ),
                      ),
                      const   Spacer(),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text('Beni Hatırla', style: TextStyle(color: Colors.white)),
                      ],
                    ), const   Spacer(),
                      GestureDetector(
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration:  BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          alignment: Alignment.center,
                          child: TextUtil(text: "Giriş",color: Colors.black,),
                        ),onTap: () {
                        Yardimci.Sayfa_Gecisi(context, Loading());
                        },
                      ),
                      const   Spacer(),
                      Center(child: GestureDetector(
                        child: TextUtil(text: "Hesabınız yok mu kayıt olun",size: 12,weight: true,),
                        onTap: () {
                          Yardimci.Sayfa_Gecisi(context, newAccount());
                        },
                      )),
                      const   Spacer(),


                    ],
                  ),
                ) ),
          ),
        ),


      ),



    );
  }
}
