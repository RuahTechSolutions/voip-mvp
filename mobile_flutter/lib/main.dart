import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoIP Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'VoIP Token Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.ruah.voip.test/apn');

  String _apnToken = 'Not initialized';
  String _voipToken = 'Not initialized';
  bool _isLoading = true;
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeTokens();
    _listenToCallKitEvents();
  }

  Future<void> _initializeTokens() async {
    try {
      print('Requesting APN token...');
      // Call native iOS code to get APN token
      final String apnToken = await platform.invokeMethod('getAPNToken');
      print('APN Token received: $apnToken');

      setState(() {
        _apnToken = apnToken;
      });
    } catch (e) {
      print('Error getting APN token: $e');
      setState(() {
        _apnToken = 'Error: $e';
      });
    }

    // Get VoIP token from flutter_callkit_incoming
    await _getVoIPToken();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getVoIPToken() async {
    try {
      print('Requesting VoIP token...');
      final String? voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      print('VoIP Token received: $voipToken');

      setState(() {
        _voipToken = voipToken ?? 'Token not available yet';
      });
    } catch (e) {
      print('Error getting VoIP token: $e');
      setState(() {
        _voipToken = 'Error: $e';
      });
    }
  }

  void _listenToCallKitEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;

      switch (event.event) {
        case Event.actionDidUpdateDevicePushTokenVoip:
          final token = event.body['deviceTokenVoIP'] as String?;
          if (token != null) {
            print('VoIP Token updated: $token');
            setState(() {
              _voipToken = token;
            });
          }
          break;
        case Event.actionCallIncoming:
          print('Incoming call: ${event.body}');
          setState(() {
            _notifications.add('Incoming call: ${event.body['nameCaller']}');
          });
          break;
        case Event.actionCallAccept:
          print('Call accepted: ${event.body}');
          setState(() {
            _notifications.add('Call accepted');
          });
          break;
        case Event.actionCallDecline:
          print('Call declined: ${event.body}');
          setState(() {
            _notifications.add('Call declined');
          });
          break;
        case Event.actionCallEnded:
          print('Call ended: ${event.body}');
          setState(() {
            _notifications.add('Call ended');
          });
          break;
        default:
          print('CallKit event: ${event.event}');
          break;
      }
    });
  }

  Future<void> _copyToClipboard(String text) async {
    if (text.contains('Not initialized') || text.contains('Error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot copy invalid token')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'APN Token Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Apple Push Notification Token:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _apnToken,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(_apnToken),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Token'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Send this token to your server for APN notifications',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.phone_in_talk, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'VoIP Push Token:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _voipToken,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _copyToClipboard(_voipToken),
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Token'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _getVoIPToken,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Send this token to your server for VoIP push calls',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Received Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_notifications.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No notifications received yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._notifications.map((notification) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            notification,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
      ),
    );
  }
}
