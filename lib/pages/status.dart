import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_band_names/services/socket.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketServices = Provider.of<SocketService>(context);
    final status = socketServices.serverStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Server Status',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Icon(
            Icons.circle,
            color: (status == ServerStatus.Connecting)
                ? Colors.yellow
                : (status == ServerStatus.Online)
                    ? Colors.green
                    : Colors.red,
          ),
          SizedBox(width: 5)
        ],
      ),
      body: Center(
        child: Text('Server Status: ${socketServices.serverStatus}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.message,
        ),
        onPressed: () {
          final mensaje = {'nombre': 'Irvin', 'mensaje': 'Desde Flutter'};

          socketServices.socket.emit('emitir-mensaje', mensaje);
        },
      ),
    );
  }
}
