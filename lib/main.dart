import 'dart:io';

import 'package:baidu_speech/util.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '百度语音合成'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.path}) : super(key: key);

  final String title;
  final String path;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<FileSystemEntity> fileList = [];

  void _speakAudio() {
    SpeechSynthesizer.saveAudio('测试').then((value) {
      refreshFileList();
    });
    // setState(() {
    //   _counter++;
    // });
  }

  @override
  void initState() {
    if (widget.path == null) {
      SpeechSynthesizer.init(
          appKey: '9NHeHhUQSgm64Y6zGXBrNbjX',
          appSecret: 'BsK30ixaj2oevyqrkCosE64XEtFFlV1m');
    }

    if (mounted) {
      refreshFileList();
    }
    super.initState();
  }

  Future refreshFileList() async {
    Directory dir;
    if (widget.path != null) {
      dir = Directory(widget.path);
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    fileList = dir.listSync();
    print(fileList);
    // for (var f in fileList) {
    //   print(f.path);
    //   var isFile = FileSystemEntity.isFileSync(f.path);
    //   if (!isFile) {
    //     print(f.path);
    //   } else {}
    // }
    setState(() {});
  }

  Widget dirItem(index, {Function onLongPress}) {
    bool isFile = FileSystemEntity.isFileSync(fileList[index].path);
    return Builder(
      builder: (ctx) => InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: !isFile ? Colors.yellowAccent : Colors.transparent,
              border: Border(
                  bottom: BorderSide(
                color: Colors.black26,
              ))),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fileList[index].path.split('/').last),
                    fileList[index].path.endsWith('mp3')
                        ? Container(
                            padding: EdgeInsets.all(5),
                            color: Colors.green,
                            child: Text(
                              '可播放',
                              style:
                                  TextStyle(color: Colors.white, height: 1.1),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Text(
                  fileList[index].statSync().size.toString() + '节字',
                  style: TextStyle(
                    color: Color(0xffaaaaaa),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          if (!isFile) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) {
                  return MyHomePage(
                    path: fileList[index].path,
                  );
                },
              ),
            );
          } else {
            // SpeechSynthesizer.audioPlayer.playBytes(Uint8List);
            if (fileList[index].path.endsWith('mp3')) {
              print('播放');
              print(File(fileList[index].path).readAsBytesSync());
              SpeechSynthesizer.audioPlayer.playBytes(
                  File(fileList[index].path).readAsBytesSync(),
                  volume: 1);
            }
          }
        },
        onLongPress: () {
          // print(context);
          showBottomSheet(
              context: ctx,
              builder: (ctx) => Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black12)],
                      color: Colors.white,
                    ),
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          child:
                              Text('删除' + fileList[index].path.split('/').last),
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: InkWell(
                              child: Container(
                                height: 30,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Text('取消'),
                              ),
                              onTap: () => Navigator.of(context).pop(),
                            )),
                            Expanded(
                                child: GestureDetector(
                              child: Container(
                                height: 30,
                                color: Colors.red,
                                alignment: Alignment.center,
                                child: Text(
                                  '删除',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              onTap: () {
                                isFile
                                    ? File(fileList[index].path).deleteSync()
                                    : Directory(fileList[index].path)
                                        .deleteSync();
                                Navigator.of(context).pop();
                                refreshFileList();
                              },
                            )),
                          ],
                        )
                      ],
                    ),
                  ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path ?? widget.title ?? ''),
      ),
      body: Builder(
        builder: (ctx) => RefreshIndicator(
          onRefresh: () async {
            refreshFileList();
          },
          child: ListView(
            children: List.generate(fileList.length, (index) => dirItem(index))
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speakAudio,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
