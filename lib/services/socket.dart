import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  //List<Band> _bands = [];

  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  //List<Band> get bands => this._bands;
  IO.Socket get socket => this._socket;

  SocketService() {
    this.initConfig();
  }

  void initConfig() {
    this._socket = IO.io('http://192.168.0.147:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    this._socket.on('nuevo-mensaje', (payload) {
      print('nuevo mensaje : $payload');
    });

    /*  this._socket.on('active-bands', (bands) {
      this._bands = bandToList(bands);
      notifyListeners();
    }); */
  }
}
