import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluwe/fluwe.dart';

class AllRoutePage extends StatefulWidget {
  @override
  _AllRoutePageState createState() => _AllRoutePageState();
}

enum AllRouteType { title, page, function }

class _AllRoutePageState extends State<AllRoutePage> {
  List allPages = [
    {'title': '弹出', 'type': AllRouteType.title},
    {'title': '司机即时弹出框', 'type': AllRouteType.function},
    {}
  ];

  // Widget headerTitle() {
  //   return
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    allPages = [
      {'title': '弹出', 'type': AllRouteType.title},
      {'title': '司机即时弹出框', 'type': AllRouteType.function},
      {}
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffaaaaaa),
      appBar: AppBar(
        title: Text('测试所有页面'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(allPages.length, (index) {
            switch (allPages[index]['type']) {
              case AllRouteType.title:
                return Container(
                  height: px(100),
                  alignment: Alignment.center,
                  color: Colors.black12,
                  child: Text(allPages[index]['title']),
                );
                break;
              case AllRouteType.page:
                return RaisedButton(
                  child: Text(allPages[index]['title']),
                  onPressed: () {
                    FluweRouter.navigateTo(page: allPages[index]['title']);
                  },
                );
                break;
              case AllRouteType.function:
                return RaisedButton(
                  child: Text(allPages[index]['title']),
                  onPressed: () {
                    allPages[index]['function']();
                  },
                );
                break;
              default:
                print(123);
                return Column(
                  children: [
                    dialogBody(),
                    SizedBox(),
                    IconButton(
                      icon: Icon(Icons.close),
                      iconSize: px(70),
                      onPressed: () {
                        print(123);
                      },
                    ),
                  ],
                );
            }
          }).toList(),
        ),
      ),
    );
  }

  Widget dialogBody() {
    return Container(
      width: px(650),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(px(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   height: px(100),
          // ),
          pathItem(
            '勒流勒流中学勒流勒流中学',
            color: Colors.green,
            footer: Container(
              padding: EdgeInsets.only(right: px(20)),
              child: Text(
                '14:00 上车',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: px(26),
                ),
              ),
            ),
          ),
          pathItem('大良桂畔路', color: Colors.blue, pre: '经'),
          pathItem('大良欢乐海岸', color: Colors.blue, pre: '经'),
          pathItem(
            '大良清晖园',
            color: Colors.orange,
            pre: '到',
            footer: Container(
              padding: EdgeInsets.only(right: px(20)),
              child: Text(
                '15:00 到达',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: px(26),
                ),
              ),
            ),
          ),

          // Container(
          //   height: px(8),
          //   width: px(600),
          //   color: Colors.blue,
          // )
          Container(
            color: Colors.black,
            height: px(8),
            child: AnimateProcessWidget(
              color: Colors.blue,
              duration: Duration(seconds: 30),
              height: px(8),
              width: px(600),
              onProcess: (process) {
                print(process);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget pathItem(String address,
      {Color color = Colors.blue, String pre = '从', Widget footer}) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: px(35),
        height: 1.1,
        color: Color(0xff333333),
      ),
      child: Container(
        height: px(100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: px(60),
                  child: Text(
                    pre,
                    style: TextStyle(
                      fontSize: px(27),
                      color: Colors.black38,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: px(20),
                  height: px(20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(px(10)),
                  ),
                ),
                SizedBox(
                  width: px(20),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: px(400)),
                  child: Text(address),
                )
              ],
            ),
            footer ?? Container()
          ],
        ),
      ),
    );
  }
}

class AnimateProcessWidget extends StatefulWidget {
  final Duration duration;
  final Function onFinish;
  final double height;
  final Color color;
  final double width;
  final Function(double process) onProcess;
  const AnimateProcessWidget({
    this.duration = const Duration(seconds: 1),
    this.onFinish,
    this.height = 3,
    this.color,
    this.onProcess,
    this.width,
  });
  @override
  _AnimateProcessWidgetState createState() => _AnimateProcessWidgetState();
}

class _AnimateProcessWidgetState extends State<AnimateProcessWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  @override
  void initState() {
    // AnimationController继承于Animation，可以调用addListener
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          widget.onProcess != null
              ? widget.onProcess(_animation?.value)
              : (() {})();
        }
        if (status == AnimationStatus.completed) {
          widget.onFinish != null ? widget.onFinish() : (() {})();
        }
      });
    // Interval : begin 参数 代表 延迟多长时间开始 动画  end 参数 代表 超过多少 直接就是 100% 即直接到动画终点
    _animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.linear)));
    // _animation有不同的构建方式
    // _animation = Tween(begin: 1.0,end: 0.2).chain(CurveTween(curve: Curves.easeIn)).animate(_controller);
    //  _animation = _controller.drive(Tween(begin: 1.0,end: 0.1)).drive(CurveTween(curve: Curves.linearToEaseOut));
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width != null
          ? widget.width * _animation.value
          : MediaQuery.of(context).size.width * _animation.value,
      height: widget.height,
      color: widget.color,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
