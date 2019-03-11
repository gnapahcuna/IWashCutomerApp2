import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:flutter/material.dart';
class ChangeLanguage extends StatefulWidget {
  String Language;
  ChangeLanguage({
    Key key,
    @required this.Language,
  }) : super(key: key);
  @override
  _ChangeLanguageState createState() => new _ChangeLanguageState();
}
class _ChangeLanguageState extends State<ChangeLanguage> {
  final List<String> languagesList = ["ภาษาไทย", "English"];
  final List<String> images = ["assets/images/lang_thai.png","assets/images/lang_eng.png"];
  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: cl_text_pro_th),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: new Text(
          'เปลี่ยนภาษา', style: new TextStyle(color: cl_text_pro_th),),
      ),
      body: _buildLanguagesList(),
    );
  }

  _buildLanguagesList() {
    return ListView.builder(
      itemCount: languagesList.length,
      itemBuilder: (context, index){
        return _buildLanguageItem(languagesList[index],images[index]);
      },
    );
  }

  @override
  void initState() {
  }

  _buildLanguageItem(String language,String image){
    var size = MediaQuery
        .of(context)
        .size;
    return InkWell(
      onTap: () {
        print(language);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.only(left: size.width/4.5,right: size.width/4.5),
        width: size.width/2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Container(
              padding: EdgeInsets.only(right: 26.0),
              child: new SizedBox(
                height: 42.0,
                width: 42.0,
                child: Image(
                    fit: BoxFit.contain,
                    image: new AssetImage(
                        image)),
              )
            ),
            new Container(
              padding: EdgeInsets.only(right: 26.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  language,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: cl_text_pro_th
                  ),
                ),
              ),
            ),
            widget.Language==language?Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Icon(Icons.check,color: Colors.deepOrange,)
            ):Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0)),

          ],
        ),
      )
    );
  }
}