import 'dart:async';
import 'dart:convert';

import 'package:blink_to_live_test/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class HomePage extends StatefulWidget {
  WebSocketChannel channel = IOWebSocketChannel.connect(
    "ws://localhost:8000/blink-to-live",
  );
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? cameraImage;
  var ourImageArray;
  var parsedJson;
  var bytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  initCamera() {
    cameraController = CameraController(cameras![1], ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController!.startImageStream((img) {
          cameraImage = img;
          ourImageArray = cameraImage!.planes[0].bytes;
          // print(cameraImage);
          // print("#################################3camera is working");
        });
      });
    });
  }

  sendDataToServer() {
    Timer myTimer = Timer.periodic(const Duration(microseconds: 200), (timer) {
      setState(() {
        try {
          widget.channel.sink.add(ourImageArray);
          print(
              "^^^^^^^^^^^^^^^^^^^data sent to server^^^^^^^^^^^^^^^^^^^^^^^^^^");

          print(
              "&&&&&&&&&&&&&&&&&&&&& this is camera imG ${ourImageArray} &&&&&&&&&&");
        } catch (e) {
          print(
              "*************************************Error from server ${e.toString()}****************************");
        }
      });
    });
  }

  void sendData() {
    if (_controller.text.isNotEmpty) {
      widget.channel.sink.add(_controller.text);
    }
  }

  String getFaceMove(AsyncSnapshot<dynamic> snapshot) {
    return snapshot.hasData ? '${jsonDecode(snapshot.data)["faces"]}' : '';
  }

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              cameraImage == null
                  ? const SizedBox(
                      height: 270,
                      width: 360,
                      child: Icon(
                        Icons.photo_camera_front,
                        color: Colors.blue,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    ),
              TextButton(
                child: const Text('start camera'),
                onPressed: () {
                  initCamera();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                child: const Text('send data to socket  camera'),
                onPressed: () {
                  sendDataToServer();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: "Send message to the server"),
                controller: _controller,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                child: const Text('send string to socket  camera'),
                onPressed: () {
                  sendData();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: widget.channel.stream,
                builder: (context, snapshot) {
                  print(
                      "##############################${snapshot.data.toString()}############################");
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      getFaceMove(snapshot),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
