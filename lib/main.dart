import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:smile_flutter/smile_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppPage(),
    );
  }
}

class AppPage extends StatelessWidget {
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await SmileFlutter.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
  }

  AlertDialog showAlert(BuildContext context, String title, String body) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        okButton,
      ],
    );
  }

  handleSelfieResult(BuildContext context, Map<dynamic, dynamic>? result) {
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];
    var title = "Selfie Capture Failed";
    var body =
        "Failed selfie capture with error ${resultCode} tag ${resultTag}";
    if (resultCode == -1) {
      title = "Selfie Capture Success";
      body =
      "Successfully captured selfie with tag ${result["SID_RESULT_TAG"]}";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return showAlert(context, title, body);
      },
    );
  }

  processResponse(BuildContext context, Map<dynamic, dynamic>? response) {
    if (response != null) {
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return showAlert(context, "Job Submission Failed",
              "Job Submission Failed for tag ${response!["result"]["ResultCode"]} with response");
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smile ID Flutter Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                  onPressed: () async {
                    var result = await SmileFlutter.captureSelfie("") ?? null;
                    handleSelfieResult(context, result);
                  },
                  child: Text("Selfie Test")),
              OutlinedButton(
                  onPressed: () async {
                    var result = await SmileFlutter.captureIDCard("") ?? null;
                    handleSelfieResult(context, result);
                  },
                  child: Text("ID Card Test")),
              OutlinedButton(
                  onPressed: () async {
                    var result =
                        await SmileFlutter.captureSelfieAndIDCard("") ?? null;
                    handleSelfieResult(context, result);
                  },
                  child: Text("Selfie and ID Card Test")),
              OutlinedButton(
                  onPressed: () async {
                    var result = await SmileFlutter.captureSelfie("") ?? null;
                    var resultCode = result!["SID_RESULT_CODE"];
                    var resultTag = result["SID_RESULT_TAG"];
                    if (resultCode == -1) {
                      var submitResult = await SmileFlutter.submitJob(
                          resultTag, 4, false, null, null, null);
                      print("Just got here");
                      print(submitResult);
                      // log(submitResult);
                      processResponse(context, submitResult);
                      return;
                    }
                    print("Should not get here");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return showAlert(context, "Selfie Capture Failed",
                            "Successfully captured selfie with tag ${result["SID_RESULT_TAG"]}");
                      },
                    );
                  },
                  child: Text("Enroll")),
              OutlinedButton(
                  onPressed: () {}, child: Text("Enroll with ID Card")),
              OutlinedButton(
                  onPressed: () {}, child: Text("Enroll with ID Number")),
              OutlinedButton(onPressed: () {}, child: Text("Authenticate")),
            ],
          ),
        ),
      ),
    );
  }
}