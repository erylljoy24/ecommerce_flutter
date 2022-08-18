import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:magri/models/id_type.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/partials/appbar.dart';

class TakePhoto extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  bool isLoading = false;
  bool _hasImage = false;
  String? _imagePath;

  double progress = 0.2;

  CameraDescription? _cameraDescription;

  bool _isCamera = true;

  // Add two variables to the state class to store the CameraController and
  // the Future.
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  List<IdType> _idTypes = [];

  @override
  void initState() {
    super.initState();

    currentFile('take_photo.dart');

    getCamera();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void getCamera() async {
    // Obtain a list of the available cameras on the device.
    // final cameras = await availableCameras(); // This get the list

    // Get only front camera
    final firstCamera = (await availableCameras()).firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    // if (cameras.length > 0) {
    // Get a specific camera from the list of available cameras.
    // final firstCamera = cameras.first;

    setState(() {
      _cameraDescription = firstCamera;
    });

    print(firstCamera.toString());

    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      firstCamera,
      // Define the resolution to use.
      // ResolutionPreset.high,
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  Widget guidelines() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      width: double.infinity,
      height: 470,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: new Icon(Icons.close),
                  radius: 12,
                ),
                onTap: () {
                  // Show camera
                  setState(() {
                    _isCamera = true;
                  });
                },
              )
            ],
          ),
          Center(
              child: Text(
            'Guidelines in taking your ID Photo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          Text(
              '\u2022 Make sure that the information in your ID is same with information you entered.'),
          Text(
              '\u2022 Please ensure that your ID is up to date and not expired.'),
          Text(
              '\u2022 Make sure you are in a well-lit room and place the ID on a plain dark surface.'),
          Text(
              '\u2022 Double check if the photos of your ID are clear and the details are readable before submission.'),
          Text('\u2022'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Need Image'),
              Text('Need Image'),
              Text('Need Image'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                child: new Icon(Icons.close, size: 18),
                radius: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'Take a selfie'),
      backgroundColor: Colors.grey,
      body: _hasImage
          ? Image.file(File(_imagePath!))
          : _isCamera
              ? FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return CameraPreview(_controller);
                    } else {
                      // Otherwise, display a loading indicator.
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                )
              : guidelines(),
      floatingActionButton: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: _hasImage
              ? SizedBox(
                  height: 120.0,
                  width: double.infinity,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                            width: 140.0,
                            height: 40.0,
                            child: new ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                //elevation: 5.0,
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.green)),
                                primary: Colors.green[700],
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Use Image',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white))
                                  ]),
                              onPressed: () {
                                // Use image and return
                                Navigator.pop(context, {
                                  "result": "success",
                                  "imagePath": _imagePath
                                });
                              },
                            )),
                        SizedBox(
                          width: 140.0,
                          height: 40.0,
                          child: new ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              //elevation: 5.0,
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0),
                                  side: BorderSide(color: Colors.green)),
                              primary: Colors.white,
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Retake',
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.black))
                                ]),
                            onPressed: () {
                              setState(() {
                                _hasImage = false;
                                _imagePath = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 210.0,
                  width: double.infinity,
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              // width: 200,
                              child: Text(
                            'Take a selfie',
                            style: TextStyle(color: Colors.white),
                          )),
                          GestureDetector(
                              onTap: () async {
                                if (_isCamera) {
                                  print('tap shot');
                                  await _initializeControllerFuture;

                                  // Attempt to take a picture and get the file `image`
                                  // where it was saved.
                                  final image = await _controller.takePicture();

                                  setState(() {
                                    _hasImage = true;
                                    _imagePath = image.path;
                                  });

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => DisplayPictureScreen(
                                  //       // Pass the automatically generated path to
                                  //       // the DisplayPictureScreen widget.
                                  //       imagePath: image?.path,
                                  //     ),
                                  //   ),
                                  // );
                                } else {
                                  print('tap shot not enable');
                                }
                              },
                              child:

                                  //  SizedBox(
                                  //   width: 70,
                                  //   height: 70,
                                  //   child: CustomPaint(
                                  //     painter: CirclePainter(),
                                  //   ),
                                  // )

                                  // Container(
                                  //   width: 70,
                                  //   height: 70,
                                  //   child: CustomPaint(
                                  //     painter: MakeCircle(
                                  //         strokeWidth: 2, strokeCap: StrokeCap.round),
                                  //   ),
                                  // ),

                                  Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CustomPaint(
                                      painter: CirclePainter(),
                                    ),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String? imagePath;

  const DisplayPictureScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: body_color,
        title: Text(
          'Photo',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        leading: popArrow(context),
        bottomOpacity: 0.0,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath!)),
    );
  }
}

/// Draws a circle if placed into a square widget.
class CirclePainter extends CustomPainter {
  final _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4
    // Use [PaintingStyle.fill] if you want the circle to be filled.
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
