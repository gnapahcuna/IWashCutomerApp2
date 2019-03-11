import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  OrderCard(this.productName,this.productPrice,this.productCount,this.productImage,this.productColor);
  final String productName;
  final String productPrice;
  final String productCount;
  final String productImage;
  final String productColor;

  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#18b4ed");
  Color cl_bar = HexColor("#18b4ed");
  Color cl_line_ver = HexColor("#677787");

  BoxDecoration _buildShadowAndRoundedCorners() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(4.0),
      boxShadow: <BoxShadow>[
        BoxShadow(
          spreadRadius: 2.0,
          //blurRadius: 10.0,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Image.network(
                        productImage,
                        fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductName() {
    return Padding(
      padding: const EdgeInsets.only( left: 4.0, right: 4.0),
      child: Center(
        child: Text(
          productName.length>16?productName.substring(0,16)+'..' : productName,
          style: TextStyle(color: cl_text_pro_th.withOpacity(0.85),
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins'),
        ),
      ),
    );
  }
  Widget _buildProductPrice() {
    final formatter = new NumberFormat("#,###.#");
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0,top: 2.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '฿'+formatter.format(int.parse(productPrice)),
              style: TextStyle(color: cl_text_pro_th.withOpacity(0.85),
                  fontSize: 16.0,
                  fontFamily: 'Poppins'),
            ),
            Text(
              ' x '+productCount,
              style: TextStyle(color: Colors.deepOrange,
                  fontSize: 16.0,
                  fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCoupon() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
      child: Center(
        child: Container(
          width: 100.0,
          margin: EdgeInsets.only(top: 4.0),
          padding: const EdgeInsets.only(
              top: 4.0, left: 4.0, right: 4.0, bottom: 4.0),
          decoration: BoxDecoration(
              color: Colors.white,
              //borderRadius: BorderRadius.all(8.0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular( 4.0),
                  bottomLeft: Radius.circular( 4.0),
                  bottomRight: Radius.circular(4.0)
              ),
              border: Border(
                top: BorderSide(color: Colors.red, width: 1.0),
                bottom: BorderSide(color: Colors.red, width: 1.0),
                left: BorderSide(color: Colors.red, width: 1.0),
                right: BorderSide(color: Colors.red, width: 1.0),
              )
          ),
          child: Center(
            child: Text('ใช้คูปองซักน้ำ',style: TextStyle(color: Colors.red,
                fontSize: 12.0,
                fontFamily: 'Poppins')),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    double itemHeight = size.height / 3.5;
    return Container(
      width: size.width/3,
      padding: const EdgeInsets.only(
          left: 1.0, right: 1.0, top: 8.0, bottom: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: _buildShadowAndRoundedCorners(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: (itemHeight * 50) / 100,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: _buildThumbnail(),
            ),
          ),
          _buildProductName(),
          _buildProductPrice(),
          //_buildCoupon(),
          /*Flexible(flex: 3, child: _buildThumbnail()),
          Flexible(flex: 2, child: _buildProductName()),
          Flexible(flex: 2, child: _buildProductPrice()),*/
        ],
      ),
    );
  }
}
