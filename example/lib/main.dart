import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

void main() {
  runApp(MyApp());
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'pos':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(type: deviceType));
    case 'cds':
      return MaterialPageRoute(
          builder: (_) => DevicesListScreen(type: deviceType));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          ));
  }
}

String deviceType;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'pos');
                deviceType = "pos";
              },
              child: Container(
                color: Colors.red,
                child: Center(
                    child: Text(
                      'POS',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'cds');
                deviceType = "cds";
              },
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                      'CDS',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({this.type});

  final String type;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  List<Device> devices = [];
  final nearbyService = NearbyService(serviceType: 'mp-connection');

  @override
  void initState() {
    super.initState();

    nearbyService.stateChangedSubject((device) => {
      devices.add(device)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_input_antenna),
            onPressed: () {
              if (deviceType == 'pos') {
                _showPOSMenuDialog();
              } else {
                _showCDSMenuDialog();
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              title: Text(device.displayName),
              subtitle: Text('State: $device.state'),

            );
          }),
    );
  }

  Widget _item(Device device) {
    return Container(
      color: Colors.grey,
    );
  }

  _showPOSMenuDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Connection menu"),
            actions: [
              FlatButton(
                child: Text("Search CDS"),
                onPressed: () {
                  nearbyService.startBrowsingForPeers();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _showCDSMenuDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Connection menu"),
            actions: [
              FlatButton(
                child: Text("Turn on connection mode"),
                onPressed: () {
                  nearbyService.startAdvertisingPeer();
                  nearbyService.startBrowsingForPeers();
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Turn off connection mode"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}