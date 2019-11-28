import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=chave";

void main() async{
  

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor:  Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
      )
    ),
  ));
}

Future<Map> getData() async{
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Center msgTexto(String texto){
  return Center(
                child: Text(texto,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 25.0),
                  textAlign: TextAlign.center,
                )
              );
}

TextField getTextField(String label, String prefix, 
        TextEditingController editControler, Function f){
  return TextField(
    controller: editControler,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix
    ),
    style: TextStyle(
      color: Colors.amber, fontSize: 25.0,
    ),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController realController = TextEditingController();
  TextEditingController dolarController = TextEditingController();
  TextEditingController euroController = TextEditingController();

  double dolar;
  double euro;

  bool _clearCampos(String texto){
    if(texto.isEmpty){
      realController.text="";
      dolarController.text="";
      euroController.text="";
      return true;
    }
    return false;
  }

  void _realChanged(String text){
    if(!_clearCampos(text)){
      double real = double.parse(text);
      dolarController.text = (real/this.dolar).toStringAsPrecision(2);
      euroController.text = (real/this.euro).toStringAsPrecision(2);
    }
  }

  void _dolarChanged(String text){
    if(!_clearCampos(text)){
      double dolar = double.parse(text);
      realController.text = (dolar*this.dolar).toStringAsPrecision(2);
      euroController.text = ((dolar*this.dolar)/euro).toStringAsPrecision(2);
    }
  }

  void _euroChanged(String text){
    if(!_clearCampos(text)){
      double euro = double.parse(text);
      realController.text = (euro/this.euro).toStringAsPrecision(2);
      dolarController.text = (euro*this.euro/this.dolar).toStringAsPrecision(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return  msgTexto("Carregando os dados!");
              default:
              if(snapshot.hasError){
                return msgTexto("Erro ao carregar dados!");
              }else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,size:120.0, color: Colors.amber),
                      getTextField("Reais", "R\$", realController,  _realChanged),
                      Divider(),
                      getTextField("Dolar", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      getTextField("Euro", "\€",euroController, _euroChanged),
                    ],
                  )
                  );
              }
        }
        },
        )
    );
  }
}