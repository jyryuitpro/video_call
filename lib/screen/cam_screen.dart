import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_call/const/agora.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({Key? key}) : super(key: key);

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine;
  int? uid;
  int? otherUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE'),
      ),
      body: FutureBuilder(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          // 처음 실행하는 경우
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: Text('권한이 있습니다.'),
          );
        },
      ),
    );
  }

  Future<bool> init() async {
    final resp = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = resp[Permission.camera];
    final micPermission = resp[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted ||
        micPermission != PermissionStatus.granted) {
      throw '카메라 또는 마이크 권한이 없습니다.';
    }

    if (engine == null) {
      RtcEngineContext context = RtcEngineContext(APP_ID);

      engine = await RtcEngine.createWithContext(context);

      engine!.setEventHandler(
        RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {
            print('채널에 입장했습니다. uid : $uid');
            setState(() {
              this.uid = uid;
            });
          },
          leaveChannel: (state) {
            print('채널 퇴장');
            setState(() {
              uid = null;
            });
          },
          userJoined: (int uid, int elapsed) {
            print('상대가 채널에 입장했습니다. uid : $uid');
            setState(() {
              otherUid = uid;
            });
          },
          userOffline: (int uid, UserOfflineReason reason) {
            print('상대가 채널에서 나갔습니다. uid : $uid');
            setState(() {
              otherUid = null;
            });
          },
        ),
      );

      // 비디오 활성화
      await engine!.enableVideo();
      // 채널에 들어가기
      // await engine!.joinChannel(
      //   TEMP_TOKEN,
      //   CHANNEL_NAME,
      //   null,
      //   0,
      // );
    }

    return true;
  }
}
