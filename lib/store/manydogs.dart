import 'package:flutter/material.dart';
import 'package:doghouse/home_page.dart';
import 'package:doghouse/store/dogmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorePage extends StatefulWidget {
  static String tag = 'Store-page';
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Product> _products = [
    Product(
        id: 1,
        title: "dog1",
        price: 0,
        imgUrl: "https://img.icons8.com/clouds/100/000000/dog.png",
        qty: 1),
    Product(
        id: 2,
        title: "dog2",
        price: 1000,
        imgUrl: "https://img.icons8.com/doodle/48/000000/dog.png",
        qty: 1),
    Product(
        id: 3,
        title: "dog3",
        price: 1200,
        imgUrl: "https://img.icons8.com/clouds/100/000000/dog.png",
        qty: 1),
    Product(
        id: 4,
        title: "dog4",
        price: 1500,
        imgUrl: "https://img.icons8.com/cute-clipart/64/000000/dog.png",
        qty: 1),
    Product(
        id: 5,
        title: "dog5",
        price: 1800,
        imgUrl: "https://img.icons8.com/emoji/48/000000/dog-emoji.png",
        qty: 1),
    Product(
        id: 6,
        title: "dog6",
        price: 2000,
        imgUrl: "https://img.icons8.com/cotton/64/000000/dog-sit--v1.png",
        qty: 1),
  ];

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
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.shopping_cart),
        //     onPressed: () => Navigator.pushNamed(context, '/cart'),
        //   )
        // ],
      ),
      body:
      GridView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.8),
        itemBuilder: (context, index){
          // return ScopedModelDescendant<CartModel>(
              // builder: (context, child, model) {
            return Card( 
              child: 
              Column( 
                children: <Widget>[
                  // Column(
                    Image.network(_products[index].imgUrl, height: 120, width: 120,),
                    Text(_products[index].title, style: TextStyle(fontWeight: FontWeight.bold),),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/coin.png",
                          width: 15,
                          height: 15,
                        ),
                        Text(_products[index].price.toString()),
                      ],
                    ),
                  // ),
              OutlineButton(
                    child: Text(Property.dogsIdSet.contains(_products[index].id)?"已解锁":"Add"),
                    onPressed: () {
                      if (Property.dogsIdSet.contains(_products[index].id)) {
                      } else {
                        confirmPurchaseDialog(_products[index]);
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
                .document(currentUser.uid).updateData(
                {"coins": Property.coins, "dogsIdSet": Property.dogsIdSet}));
        Navigator.of(context).pop();
        setState(() {});
      }
    }
  }

}


