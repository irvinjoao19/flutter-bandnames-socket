import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:app_band_names/models/band.dart';
import 'package:app_band_names/services/socket.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    /*  Band(id: '1', name: 'METALICA', votes: 5),
    Band(id: '2', name: 'AC/DC', votes: 5),
    Band(id: '3', name: 'GUNS N\' ROSES', votes: 5),
    Band(id: '4', name: 'PANDA', votes: 5) */
  ];

  @override
  void initState() {
    final socketServices = Provider.of<SocketService>(context, listen: false);
    socketServices.socket.on('active-bands', (payload) {
      this.bands = bandToList(payload);
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    final socketServices = Provider.of<SocketService>(context, listen: false);
    socketServices.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketServices = Provider.of<SocketService>(context);
    final status = socketServices.serverStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: (status == ServerStatus.Connecting)
                  ? Icon(Icons.circle, color: Colors.yellow[900])
                  : (status == ServerStatus.Online)
                      ? Icon(Icons.check_circle, color: Colors.blue[300])
                      : Icon(Icons.offline_bolt, color: Colors.red))
        ],
      ),
      body: bands.isNotEmpty
          ? Column(
              children: [
                _showGraph(),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bands.length,
                    itemBuilder: (context, index) => _bandTile(bands[index]),
                  ),
                ),
              ],
            )
          : _progress(),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketServices = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white)),
        ),
      ),
      onDismissed: (_) => socketServices.socket.emit('delete-band', band.id),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketServices.socket.emit('update-band', band.id),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('New Band Name'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text))
          ],
        ),
      );
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('New Band Name'),
        content: CupertinoTextField(controller: textController),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: addBandToList(textController.text)),
          CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  addBandToList(String name) {
    if (name.length > 1) {
      final socketServices = Provider.of<SocketService>(context, listen: false);
      socketServices.socket.emit('add-band', name);
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = Map();

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      ),
    );
  }

  Widget _progress() {
    return Center(child: CircularProgressIndicator());
  }
}
