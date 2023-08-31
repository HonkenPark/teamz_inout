import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teamz_inout/aes_manager.dart';
import 'package:teamz_inout/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late int _status; //0:IDLE, 1:before Work, 2:now Work, 3: after work, 4: error
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _status = 0;
    super.initState();
  }

  void _login(bool init) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      return;
    }

    var userInfoObj = {'id': username, 'pw': password};
    String userInfoStr = jsonEncode(userInfoObj);
    int status =
        await ApiService.getInOutStatus(AesManager.encrypt(userInfoStr));
    if (status == 4) {
      Fluttertoast.showToast(
        msg: "에러가 발생했습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _isLoading = false;
        status = 0;
        _status = status;
      });
    } else {
      setState(() {
        _isLoading = false;
        _status = status;
      });

      if (init) {
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _status = 0;
          });
        });
      }
    }
  }

  void _requestInOut() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    var userInfoObj = {
      'id': _usernameController.text,
      'pw': _passwordController.text
    };
    String userInfoStr = jsonEncode(userInfoObj);

    bool isFinish =
        await ApiService.requestInOut(AesManager.encrypt(userInfoStr));
    if (isFinish) {
      setState(() {
        _isLoading = false;
      });
      _login(true);
    } else {
      Fluttertoast.showToast(
        msg: "에러가 발생했습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        _isLoading = false;
      });
      _login(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF41576F),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img_login_logo.png'),
                  ),
                ),
              ),
              const Spacer(),
              _status == 0
                  ? _loginPage()
                  : _status == 1
                      ? _beforeWork()
                      : _status == 2
                          ? _nowWork()
                          : _afterWork(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginPage() {
    if (_isLoading) {
      return Column(
        children: [
          const Text(
            '팀즈 서버정보 수신중입니다.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            controller: _usernameController,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              icon: Icon(Icons.account_circle),
              iconColor: Colors.white,
              labelText: '아이디를 입력하세요',
              labelStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            onSubmitted: (_) {
              _login(false);
            },
            controller: _passwordController,
            style: const TextStyle(
              color: Colors.white,
            ),
            obscureText: true,
            decoration: const InputDecoration(
              icon: Icon(Icons.lock),
              iconColor: Colors.white,
              labelText: '패스워드를 입력하세요',
              labelStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () {
              _login(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 20,
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text(
              '로그인',
              style: TextStyle(
                color: Color(0xFF41576F),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
      ],
    );
  }

  Widget _beforeWork() {
    if (_isLoading) {
      return Column(
        children: [
          const Text(
            '서버에 출근 요청 전송중입니다.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '현재 [출근전] 상태입니다.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        ElevatedButton(
          onPressed: _requestInOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 20,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text(
            '출근',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
        ),
      ],
    );
  }

  Widget _nowWork() {
    if (_isLoading) {
      return Column(
        children: [
          const Text(
            '서버에 퇴근 요청 전송중입니다.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '현재 [근무중] 상태입니다.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        ElevatedButton(
          onPressed: _requestInOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 20,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text(
            '퇴근',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
        ),
      ],
    );
  }

  Widget _afterWork() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '현재 [퇴근후] 상태입니다.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 20,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text(
            '퇴근완료',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
        ),
      ],
    );
  }
}
