import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';
import 'dart:io';

import 'package:cleanmate_customer_app/data/Order.dart' as _order;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/style/theme.dart' as Theme;

class CreateOrder extends StatefulWidget {
  String OrderNo;
  CreateOrder({
    Key key,
    @required this.OrderNo,
  }) : super(key: key);
  @override
  _CreateOrderState createState() => new _CreateOrderState(this.OrderNo);
}
class _CreateOrderState extends State<CreateOrder> {
  String OrderNo;
  _CreateOrderState(this.OrderNo);

  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = Colors.black;
  Color cl_text_pro_en = HexColor("#989fa7");
  Color cl_cart = HexColor("#18b4ed");
  Color cl_bar = HexColor("#18b4ed");
  Color cl_line_ver = HexColor("#677787");

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();

  GlobalKey _globalKey = new GlobalKey();
  bool inside = false;
  Uint8List imageInMemory;

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
//      String bs64 = base64Encode(pngBytes);
//      print(pngBytes);
//      print(bs64);
      print('png done');
      setState(() {
        imageInMemory = pngBytes;
        inside = false;
      });
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }
  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      final channel = const MethodChannel('channel:me.alfian.share/share');
      channel.invokeMethod('shareFile', 'image.png');

    } catch(e) {
      print(e.toString());
    }
  }


  @override
  void initState() {
    //_capturePng();
    for(int i=0;i<proName.length;i++){
      totalAmount+=proPrice[i]*proCount[i];
      totalCount+=proCount[i];
    }
    print('order no : '+widget.OrderNo);
    super.initState();
  }

  Widget _buildTitle() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0,bottom: 12.0),
      //padding: const EdgeInsets.all(3.0),
      child: Center(
        child: Text('ใบรับฝากผ้า',style: TextStyle(color: cl_text_pro_th,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins')
        ),
      ),
    );
  }
  Widget _buildLine(width){
    return Container(
      color: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      width: width,
      height: 1.0,
    );
  }
  Widget _buildDetail(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        inside ? CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange))
            :
        imageInMemory != null
            ? Container(
            child: Image.memory(imageInMemory),
            margin: EdgeInsets.all(10))
            : Container(),
      ],
    );
  }
  Widget _buildContent() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        children: <Widget>[
          //_contentWidget(),
          _buildLogo(),
          _buildTitle(),
          //_contentWidget(),
          _buildHead(),
          _buildDetail(),
        ],
      ),
    );
  }
  Widget _buildLogo(){
    return Padding(
      padding: EdgeInsets.only(top: 25.0,left: 32.0,right: 32.0),
      child: new Image(

          fit: BoxFit.cover,
          image: new AssetImage('assets/images/logo_smart.png')),
    );
  }
  String getOrderNo='';
  String getBranchName='';
  String getBranchCode='';
  String getPhoneBranch='';
  String getOrderDate='';
  String getAppointDate='';
  String getCustomerName='';
  String getPhoneCust='';
  String getCounts='';
  String getAmount='';
  void _getOrder(){
    fetchOrder(OrderNo).then((order){
      getOrderNo=order[0].OrderNo.toString();
      getBranchName=order[0].BranchNameTH.toString();
      getBranchCode=order[0].BranchCode.toString();
      getPhoneBranch=order[0].PhoneBranch.toString();
      getOrderDate=order[0].OrderDate.toString();
      getAppointDate=order[0].AppointmentDate.toString();
      getCustomerName=order[0].CustomerName.toString();
      getPhoneCust=order[0].PhoneCustomer.toString();
      getCounts=order[0].Count.toString();
      getAmount=order[0].Amount.toString();
    });
  }
  Widget _buildHead() {
    var size = MediaQuery
        .of(context)
        .size;
    double itemWidthLine = (size.width*90)/100;
    final formatter = new NumberFormat("#,###.#");
    return FutureBuilder<List<_order.Order>>(
      future: fetchOrder(OrderNo),
      builder: (context, snapshot) {
        List<_order.Order> order=snapshot.data;
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData
            ? Column(
          children: <Widget>[
            _buildLine(itemWidthLine),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('เลขที่ออเดอร์ :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].OrderNo.toString(),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('สาขา :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].BranchNameTH + ' (' + order[0].BranchCode + ')',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('โทร :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].PhoneBranch.length==10?
                    order[0].PhoneBranch.substring(0,3)+'-'+order[0].PhoneBranch.substring(3,order[0].PhoneBranch.length):
                    order[0].PhoneBranch.substring(0,2)+'-'+order[0].PhoneBranch.substring(2,order[0].PhoneBranch.length),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            _buildLine(itemWidthLine),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('วันที่ทำรายการ :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].OrderDate,
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('วันที่นัดรับผ้า :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].AppointmentDate,
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('ชื่อลูกค้า :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].CustomerName,
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('เบอร์โทรศัพท์มือถือ :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(order[0].PhoneCustomer.substring(0,3)+'-'+order[0].PhoneCustomer.substring(3,order[0].PhoneCustomer.length),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            _buildLine(itemWidthLine),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0,top: 8.0),
                  child: Container(
                    child: Text('รวมจำนวน (ชิ้น) :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0,top: 8.0),
                  child: Container(
                    child: Text(order[0].Count.toString(),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('ราคารวม :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text('฿'+formatter.format(int.parse(order[0].Amount.toString().substring(0,order[0].Amount.toString().indexOf('.')))),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            _buildLine(itemWidthLine),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('ส่วนลดโปรโมชั่น :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text('฿0.00',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('ส่วนลด Voucher :',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text('฿0.00',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('ส่วนลดสมาชิก : ',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text('฿0.00',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text('ราคารวมสุทธิ : ',
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text('฿'+formatter.format(int.parse(order[0].Amount.toString().substring(0,order[0].Amount.toString().indexOf('.')))),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            ),
            /*Container(
              width: 150.0,
              padding: const EdgeInsets.only(bottom: 8.0,top: 16.0),
              child: Container(
                height: 45.0,
                child: RaisedButton(
                  color: Colors.cyan,
                  onPressed: () {
                    _capturePng();
                  },
                  child: Center(
                    child: Text(
                      'เสร็จสิ้น',
                      style: new TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
            ),*/
          ],)
            : InkWell(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("ERROR OCCURRED, Tap to retry !"),
            ),
            onTap: () => setState(() {}))
            : CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange));
      },
    );

    /*return Column(
      children: <Widget>[
        _buildLine(itemWidthLine),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('เลขที่ออเดอร์ :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getOrderNo,
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('สาขา :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getBranchName+' ('+getBranchCode+')',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('โทร :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getPhoneBranch,
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        _buildLine(itemWidthLine),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('วันที่ทำรายการ :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getOrderDate,
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('วันที่นัดรับผ้า :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getAppointDate,
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('ชื่อลูกค้า :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getCustomerName,
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('เบอร์โทรศัพท์มือถือ :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text(getPhoneCust,
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        _buildLine(itemWidthLine),
        _buildListProduct(),
        _buildLine(itemWidthLine),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('ส่วนลดโปรโทชั่น :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text('฿0',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('ส่วนลด Voucher :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text('฿0',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('ส่วนลดสมาชิก : ',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text('฿0',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('ราคารวมสุทธิ : ',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text('฿'+totalAmount.toString(),
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Container(
          width: 150.0,
          padding: const EdgeInsets.only(bottom: 8.0,top: 16.0),
          child: Container(
            height: 45.0,
            child: RaisedButton(
              color: Colors.cyan,
              onPressed: () {
                _capturePng();
              },
              child: Center(
                child: Text(
                  'เสร็จสิ้น',
                  style: new TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );*/
  }
  List<String> proName=['กางเกงยีนส์','เสื้อเชิ๊ต','เสื้อสตรี','กางเกง'];
  List<int> proPrice=[70,60,40,90];
  List<int> proCount=[1,3,2,4];
  int totalAmount=0,totalCount=0;


  Widget _buildListProduct(){
    return Column(
      children: <Widget>[
        /*Center(
          child: Text('ซักน้ำ',
              style: TextStyle(color: cl_text_pro_th,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins')
          ),
        ),
        ListView.builder(
          itemCount: proName.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            final int total=proPrice[index]*proCount[index];
            totalAmount+=total;
            totalCount+=proCount[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Container(
                    child: Text(proName[index],
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text(proCount[index].toString(),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: Container(
                    child: Text('฿'+proPrice[index].toString(),
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')
                    ),
                  ),
                ),
              ],
            );
          },
        ),*/
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0,top: 8.0),
              child: Container(
                child: Text('รวมจำนวน :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0,top: 8.0),
              child: Container(
                child: Text(totalCount.toString(),
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Container(
                child: Text('ราคารวม :',
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 22.0),
              child: Container(
                child: Text('฿'+totalAmount.toString(),
                    style: TextStyle(color: cl_text_pro_th,
                        fontSize: 16.0,
                        fontFamily: 'Poppins')
                ),
              ),
            ),
          ],
        ),
        //_contentWidget(),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: RepaintBoundary(
              key: _globalKey,
              child: WillPopScope(
                onWillPop: () {
                  print('back');
                },
                child: Scaffold(
                  body: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
                      BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          //color: Colors.black12.withOpacity(0.5),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _buildContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child:  Container(
              margin: EdgeInsets.only(top: 0.0,bottom: 4.0),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.Colors.loginGradientStart,
                    offset: Offset(1.0, 6.0),
                    blurRadius: 20.0,
                  ),
                  BoxShadow(
                    color: Theme.Colors.loginGradientEnd,
                    offset: Offset(1.0, 6.0),
                    blurRadius: 20.0,
                  ),
                ],
                gradient: new LinearGradient(
                    colors: [
                      /*Theme.Colors.loginGradientEnd,
                    Theme.Colors.loginGradientStart*/
                      Color(0xFF2CB044),
                      Color(0xFF2CB044)
                    ],
                    begin: const FractionalOffset(0.2, 0.2),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Theme.Colors.loginGradientEnd,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      "เสร็จสิ้น",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onPressed: () {
                    _haveFinish();
                  }
              ), /*Container(
              width: 150.0,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                height: 45.0,
                child: RaisedButton(
                  color: Colors.cyan,
                  onPressed: () {
                    //_capturePng();
                    _haveFinish();
                  },
                  child: Center(
                    child: Text(
                      'เสร็จสิ้น',
                      style: new TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),*/
            ),
          ),
        ],
      ),
    );
  }
  void _haveFinish() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove("productID");
      prefs.remove("productCount");
      prefs.remove("productServiceType");
      prefs.remove("count");
      prefs.remove("total");
      prefs.remove("DateAppoint");
      prefs.remove('SpecialDetail');
    });
    Navigator.of(context).pushNamedAndRemoveUntil('/HomeScreen', (Route<dynamic> route) => false);
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }
  //fetch branch
  Future<List<_order.Order>> fetchOrder(orderNo) async {
    try {
      final paramDic = {
        "OrderNo": orderNo,
      };
      http.Response response =
      await http.post(Server().IPAddress + '/data/get/Order.php',body: paramDic);
      //print(response.statusCode.toString());
      if (response.statusCode == 200) {
        print(response.body.toString());
        List responseJson = json.decode(response.body);
        return responseJson.map((m) => new _order.Order.fromJson(m)).toList();
      } else {
        print('Something went wrong. \nResponse Code : ${response.statusCode}');
      }
    } catch (exception) {
      print(exception.toString());
    }
  }
}