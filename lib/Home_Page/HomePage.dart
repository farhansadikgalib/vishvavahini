import 'dart:io';
import 'package:back_pressed/back_pressed.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vishvavahini/Check_Connection/No%20Internet.dart';

class HomePage extends StatefulWidget {
  final String url;

  HomePage({Key? key, required this.url}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int checkInt = 0;
  late ConnectivityResult previous;


  @override
  void initState() {
    super.initState();


    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );


    Connectivity().onConnectivityChanged.listen((ConnectivityResult connresult){
      if(connresult == ConnectivityResult.none){
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => No_Internet_Connection()), (route) => false );
      }else if(previous == ConnectivityResult.none){
        // internet conn
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => No_Internet_Connection()), (route) => false );
      }

      previous = connresult;
    });




  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Exit MemoPie',style: TextStyle(fontFamily: "Poppins"),),
        content: new Text('Are you sure wanted to exit this?',),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
              style: TextStyle(color: Colors.green,fontFamily: "Poppins"),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text(
              'Yes',
              style: TextStyle(color: Colors.red,fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    )) ??
        false;
  }

  InAppWebViewController? _webViewController;
  String url = '';

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        useOnDownloadStart: true,
      ),
      android: AndroidInAppWebViewOptions(
        initialScale: 100,
        useShouldInterceptRequest: true,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  final urlController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(10, 39, 255,1)
    ));
    return OnBackPressed(
      perform: (){
        _webViewController!.goBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(widget.url),
                      headers: {},
                    ),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

