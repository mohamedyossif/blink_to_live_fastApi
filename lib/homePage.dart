import 'package:blink_to_live_test/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart'as io;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking=false;
  String result='';
  CameraController ? cameraController;
  CameraImage ? cameraImage;
  io.Socket ?socket;
  final channel = IOWebSocketChannel.connect('ws://localhost:8000/blink-to-live',);
  @override
  void initState() {
    super.initState();
  //  connect();
  }
  void connect()
  {
    socket=io.io("http://127.0.0.1:8000",<String,dynamic>{
      "transport":["websocket"],
      "autoConnect":false,
    });
    socket!.connect();
  }
  initCamera()
  {
    cameraController=CameraController(cameras![1],ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
          if(!mounted){
            return ;
          }
          setState(() {
            cameraController!.startImageStream((img) {
              var x= img.planes.map((plane) {
                return plane.bytes;
              }).toList();
              print("dfdfdfdffddf");
              print(x);
            });
          });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Center(
              child: TextButton(
                child:Container(
                  height: 270,
                  width: 360,
                  margin:const EdgeInsets.only(top: 15),
                  child: cameraImage == null?const SizedBox(
                    height: 270,
                    width: 360,
                    child: Icon(Icons.photo_camera_front,color: Colors.blue,),
                  ):AspectRatio(aspectRatio: cameraController!.value.aspectRatio,
                  child:  CameraPreview(cameraController!),
                  ),
                ) ,
                onPressed:(){
                  initCamera();
                } ,),
            ),
            // StreamBuilder(
            //   stream: channel.stream,
            //   builder: (context, snapshot) {
            //     return Text(snapshot.hasData ? '${snapshot.data}' : '');
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
