import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

const token =
    '006f019af8754e24596bc2ec4dccde67ae8IABsNBNwONkXyF6iMrkX2oMrkSfHeacjzvclef1WBm/sagy4I8cAAAAAEADsDXZglO9oYgEAAQCT72hi';
const appId = '0edccd6596ca4266845954f9d0edf6a0';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Video Call'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _remoteUid;
  RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.create(appId);
    await _engine!.enableVideo();

    _engine!.setEventHandler(
      RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {},
          userJoined: (int uid, int elapsed) {
            setState(() {
              _remoteUid = uid;
            });
          },
          userOffline: (int uid, UserOfflineReason reason) {
            setState(() {
              _remoteUid = null;
            });
          }),
    );

    await _engine?.joinChannel(token, 'demo_video_call', null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: _localVideo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid ?? 0,
        channelId: 'demo_video_call',
      );
    } else {
      return const Text(
        'Plz wait',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _localVideo() {
    return Container(
      height: 100,
      width: 100,
      color: Colors.black,
      child: const RtcLocalView.SurfaceView(),
    );
  }
}
