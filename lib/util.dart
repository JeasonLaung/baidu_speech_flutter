import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechSpeakerType {
  /// 度小宇
  final int duxiaoyu = 1;

  /// 度小美
  final int duxiaomei = 0;

  /// 度逍遥
  final int duxiaoyao = 3;

  /// 度丫丫
  final int duyaya = 4;
}

class SpeechAduioType {
  final int mp3 = 3;

  final int pcm16k = 4;

  final int pcm8k = 5;

  final int wav = 6;
}

class SpeechSynthesizerResponse {
  String accessToken;
  int expiresIn;
  String refreshToken;
  String scope;
  String sessionKey;
  String sessionSecret;

  SpeechSynthesizerResponse(
      {this.accessToken,
      this.expiresIn,
      this.refreshToken,
      this.scope,
      this.sessionKey,
      this.sessionSecret});

  SpeechSynthesizerResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    refreshToken = json['refresh_token'];
    scope = json['scope'];
    sessionKey = json['session_key'];
    sessionSecret = json['session_secret'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['refresh_token'] = this.refreshToken;
    data['scope'] = this.scope;
    data['session_key'] = this.sessionKey;
    data['session_secret'] = this.sessionSecret;
    return data;
  }
}

class SpeechSynthesizerConfig {
  String text;
  String language;
  String ctp;
  String token;
  String cuid;

  /// 选择发声种类[SpeechSpeakerType]
  int person;
  int audioType;
  // 音量 取值0-15
  int volume;
  // 语速 取值0-15
  int speed;
  // 音调 取值0-15
  int pitch;

  SpeechSynthesizerConfig({
    this.ctp = '1',
    this.cuid,
    this.language = 'zh',
    this.token,
    this.person,
    this.volume,
    this.audioType,
    this.text,
    this.speed,
    this.pitch,
  });

  /// 混入
  SpeechSynthesizerConfig mixins(SpeechSynthesizerConfig config) {
    if (config == null) {
      return this;
    }
    audioType = config.audioType ?? audioType;
    cuid = config.cuid ?? cuid;
    ctp = config.ctp ?? ctp;
    language = config.language ?? language;
    person = config.person ?? person;
    volume = config.volume ?? volume;
    audioType = config.audioType ?? audioType;
    text = config.text ?? text;
    speed = config.speed ?? speed;
    pitch = config.pitch ?? pitch;
    token = config.token ?? token;
    return this;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['aue'] = audioType;
    data['tex'] = text;
    data['cuid'] = 'MPCX_' + DateTime.now().microsecondsSinceEpoch.toString();
    data['ctp'] = ctp;
    data['tok'] = token;
    data['lan'] = language;
    data['spd'] = text;
    data['pit'] = pitch;
    data['vol'] = volume;
    data['per'] = person;
    Map<String, dynamic> _data = {};

    data.keys.toList().forEach((k) {
      if (data[k] != null && data.containsKey(k)) {
        _data[k] = data[k];
      }
    });
    return _data;
  }
}

/// 语音合成器
class SpeechSynthesizer {
  static String _token;
  static String _appKey;
  static String _appSecret;
  static SharedPreferences _cache;
  static AudioPlayer audioPlayer;

  static SpeechSynthesizerConfig _config = SpeechSynthesizerConfig(
      cuid: 'MPCX_' + DateTime.now().millisecondsSinceEpoch.toString());
  static final String cacheName = 'CACHE_BAIDU_TOKEN';
  static final String url = "https://openapi.baidu.com/oauth/2.0/token";

  static Future init({
    String appKey,
    String appSecret,
    String token,
  }) async {
    _appSecret = appSecret;
    _appKey = appKey;
    _token = token;
    audioPlayer =
        AudioPlayer(playerId: DateTime.now().microsecondsSinceEpoch.toString());
    await getToken();
    print(_token);
  }

  static Future<SharedPreferences> getCache() async {
    if (_cache != null) {
      return _cache;
    } else {
      _cache = await SharedPreferences.getInstance();
      return _cache;
    }
  }

  static setConfig() {}

  static Future getToken() async {
    if (_token != null) {
      return _token;
    } else {
      var cache = await getCache();
      var tempCache = cache.get(cacheName);
      if (tempCache != null) {
        Map tempJson = json.decode(tempCache);
        if (tempJson['expires'] >
            DateTime.now().millisecondsSinceEpoch ~/ 1000) {
          _token = tempJson['token'];
          return _token;
        }
      }

      if (_appSecret != null && _appKey != null) {
        var res = await Dio().get(url, queryParameters: {
          "grant_type": "client_credentials",
          "client_id": _appKey,
          "client_secret": _appSecret,
        });
        if (res.statusCode == 200 && res.data['access_token'] != null) {
          int expiresTime =
              20 * 24 * 60 * 60 + DateTime.now().millisecondsSinceEpoch ~/ 1000;
          await cache.setString(
            cacheName,
            json.encode(
              {'expires': expiresTime, 'token': res.data['access_token']},
            ),
          );
          _token = res.data['access_token'];
          return _token;
        }
      } else {
        throw "参数key与secert或token均不存在";
      }
    }
  }

  static speakAudio(String text, {SpeechSynthesizerConfig config}) async {
    var __config = _config;
    __config.text = text;
    __config.token = config?.token ?? _token;
    Map json1 = _config.mixins(config).toJson();

    Directory dir = await getApplicationDocumentsDirectory();
    String savePath = dir.path +
        '/' +
        DateTime.now().microsecondsSinceEpoch.toString() +
        '.mp3';
    String downPath = toUrl(json1);
    // 播放
    audioPlayer.play(downPath);
  }

  static Future saveAudio(String text, {SpeechSynthesizerConfig config}) async {
    var __config = _config;
    __config.text = text;
    __config.token = config?.token ?? _token;
    // return print(__config.toJson());
    Map json1 = __config.mixins(config).toJson();

    Directory dir = await getApplicationDocumentsDirectory();
    String savePath = dir.path +
        '/' +
        DateTime.now().microsecondsSinceEpoch.toString() +
        '.mp3';
    String downPath = toUrl(json1);
    // return print(downPath);
    // 播放
    await Dio().download(downPath, savePath).then((value) async {
      print((value.data as ResponseBody).stream);
      print('保存成功$savePath');
      showToast('保存成功$savePath');
    });
    // await Dio().get(downPath).then((value) async {
    //   print(value.data);
    //   showToast('保存成功$downPath');
    // });
  }

  static String toUrl(Map params) {
    var url = 'https://tsn.baidu.com/text2audio?';
    var paramString = params.keys.toList().map((key) {
      return key.toString() + '=' + params[key].toString();
    }).join('&');
    return url + paramString;
  }
}
