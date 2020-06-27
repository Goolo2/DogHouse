import 'package:flutter/material.dart';
import 'package:doghouse/home_page.dart';
import 'package:doghouse/store/dogmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class StorePage extends StatefulWidget {
  static String tag = 'Store-page';

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {

  void confirmPurchaseDialog(product) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('提示'),
            //可滑动
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('确认要解锁本汪吗？'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确认'),
                onPressed: () {
                  addProduct(product);
                  //Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void insufficientCoinsAlertDialog(int money) {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('提示'),
            //可滑动
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text("当前金币数量仅 $money, 不够哦！\n快去多多饲养吧"),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),

            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("Home"),
        actions: <Widget>[
          // IconButton(
          //   icon: Image.asset('images/coin.png'),
          //   iconSize: 20,
          //   tooltip: "yes",
          //   onPressed: () {}
          // ),
          FlatButton(
            child: 
              Row(
                children: <Widget>[
                  Container(
                    height:30,
                    width:30,
                    decoration: new BoxDecoration(
                      image:new DecorationImage(
                        image: AssetImage('images/coin.png'),
                        ),
                    ),
                  ),
                  Text("${Property.coins}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),),
                ],
              ),
              
            onPressed: (){},
          ),
        ],
      ),
      body:
      GridView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: HomePage.products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.8),
        itemBuilder: (context, index){
          // return ScopedModelDescendant<CartModel>(
              // builder: (context, child, model) {
            return Card(
              child: 
              Column( 
                children: <Widget>[
                    new Image.asset(HomePage.products[index].imgUrl, height: 120, width: 120,),
                   Text(HomePage.products[index].title, style: TextStyle(fontWeight: FontWeight.bold),),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/coin.png",
                          width: 15,
                          height: 15,
                        ),
                        Text(HomePage.products[index].price.toString()),
                      ],
                    ),
                  // ),
              OutlineButton(
                    child: Text(Property.dogsIdSet.contains(HomePage.products[index].id)?"已解锁":"Add"),
                    onPressed: () {
                      if (Property.dogsIdSet.contains(HomePage.products[index].id)) {
                      } else {
                        confirmPurchaseDialog(HomePage.products[index]);
                      }})
            ])); 
          // }
        // );
        },
      ),
    );
  }

  void addProduct(product) {
    print(product.title);
    if (Property.dogsIdSet.contains(product.id)){
    } else {
      if (Property.coins < product.price){
        insufficientCoinsAlertDialog(Property.coins);
      } else {
        Property.coins = Property.coins - product.price;
        Property.dogsIdSet.add(product.id);
        Property.dogsIdSet.toSet().toList();
        print(Property.dogsIdSet);
        FirebaseAuth.instance.currentUser()
            .then((currentUser) =>
            Firestore.instance.collection("users")
                .document(currentUser.email).updateData(
                {"coins": Property.coins, "dogsIdSet": Property.dogsIdSet}));
        Navigator.of(context).pop();
        setState(() {});
      }
    }
  }

}


