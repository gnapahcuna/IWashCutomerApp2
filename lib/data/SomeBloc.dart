import "dart:async";

class SomeBloc {

  final _data = StreamController<List<String>>();
  Stream<List<String>> get data => _data.stream;

  final _url = StreamController<List<String>>();
  Sink<List<String>> get urlIn => _url.sink;
  Stream<List<String>> get urlOut => _url.stream;


  SomeBloc() {
    urlOut.listen(_handleData);
  }

  void _handleData(List<String> urlList) {
    _data.add(urlList);
  }

}