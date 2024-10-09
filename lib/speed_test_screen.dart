import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  double _progressValue = 0.0;
  double _downloadRate = 0.0;
  double _uploadRate = 0.0;
  final Color _textColor = Colors.white;
  double _displayRate = 0.0;
  final internetSpeedTest = FlutterInternetSpeedTest()..enableLog();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 35, 73),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 35, 73),
        title: Text(
          'Speed Test',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 18,
            center: Text(
              '${_progressValue.toStringAsFixed(1)} %',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            percent: _progressValue / 100.0,
            barRadius: Radius.circular(10),
            linearGradient: LinearGradient(
              colors: [Color(0xff72c6ef), Color(0xff004e8f)],
              stops: [0, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Download Rate',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: _textColor,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      _downloadRate.toStringAsFixed(1),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: _textColor),
                    ),
                  ],
                ),
                SizedBox(
                  width: 15,
                ),
                VerticalDivider(
                  width: 1,
                  indent: 5,
                  endIndent: 5,
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  children: [
                    Text(
                      'Upload Rate',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: _textColor),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      _uploadRate.toStringAsFixed(1),
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SfRadialGauge(
            axes: [
              RadialAxis(
                radiusFactor: 0.85,
                minorTicksPerInterval: 1,
                tickOffset: 3,
                useRangeColorForAxis: true,
                interval: 10,
                maximum: 120,
                minimum: 0,
                axisLabelStyle: GaugeTextStyle(color: _textColor),
                ranges: [
                  GaugeRange(
                    startValue: 0,
                    endValue: 120,
                    gradient: SweepGradient(
                      colors: [Color(0xff72c6ef), Color(0xff004e8f)],
                      stops: [0, 1],
                      center: Alignment.topLeft,
                    ),
                    color: Color(0xff72c6ef),
                    startWidth: 5,
                    endWidth: 15,
                  ),
                ],
                pointers: [
                  NeedlePointer(
                    value: _displayRate,
                    enableAnimation: true,
                    needleColor: Colors.orangeAccent,
                    tailStyle: TailStyle(
                      color: Colors.white,
                      width: 0.1,
                      borderColor: Color(0xff72c6ef),
                    ),
                    knobStyle: KnobStyle(
                      color: Colors.white,
                      borderColor: Colors.orangeAccent,
                      borderWidth: 0.01,
                    ),
                  ),
                ],
                annotations: [
                  GaugeAnnotation(
                    widget: Container(
                      child: Text(
                        '${_displayRate.toStringAsFixed(2)} $_unitText',
                        style: TextStyle(
                          fontSize: 21,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.6,
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _isServerSelectionInProgress
                  ? 'Selecting Server...'
                  : 'IP: ${_ip ?? '--'} | ASP: ${_asn ?? '--'} | ISP: ${_isp ?? '--'}',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          if (!_testInProgress) ...[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)))),
                onPressed: () async {
                  await startTesting();
                },
                child: const Text(
                  'Start Test',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ))
          ] else ...[
            const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            )),
          ]
        ],
      ),
    );
  }

  bool _testInProgress = false;
  bool _isServerSelectionInProgress = false;
  String? _ip;
  String? _asn;
  String? _isp;
  String _unitText = 'Mbps';

  Future<void> startTesting() async {
    reset();
    await internetSpeedTest.startTesting(
        uploadTestServer: 'https://speed.measurementlab.net/',
        downloadTestServer: 'https://speed.measurementlab.net/',
        useFastApi: true,
        onStarted: () {
          setState(() => _testInProgress = true);
        },
        onCompleted: (TestResult download, TestResult upload) {
          if (kDebugMode) {
            print(
                'the transfer rate ${download.transferRate}, ${upload.transferRate}');
          }
          setState(() {
            _unitText = download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
            _downloadRate = download.transferRate;
            _progressValue = 100.0;
            _displayRate = _downloadRate;
          });
          setState(() {
            _unitText = upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
            _uploadRate = upload.transferRate;
            _progressValue = 100.0;
            _displayRate = _uploadRate;
            _testInProgress = false;
          });
        },
        onProgress: (double percent, TestResult data) {
          if (kDebugMode) {
            print(
                'the transfer rate ${data.transferRate}, the percent $percent');
          }
          _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
          if (data.type == TestType.download) {
            setState(() {
              _downloadRate = data.transferRate;
              _displayRate = _downloadRate;
              _progressValue = percent;
            });
          } else {
            setState(() {
              _uploadRate = data.transferRate;
              _displayRate = _uploadRate;
              _progressValue = percent;
            });
          }
        },
        onError: (String errorMessage, String speedTestError) {
          if (kDebugMode) {
            print(
                'the errorMessage $errorMessage, the speedTestError $speedTestError');
          }
          reset();
        },
        onDefaultServerSelectionInProgress: () {
          setState(() {
            _isServerSelectionInProgress = true;
          });
        },
        onDefaultServerSelectionDone: (Client? client) {
          setState(() {
            _isServerSelectionInProgress = false;
            _ip = client?.ip;
            _asn = client?.asn;
            _isp = client?.isp;
          });
        },
        onDownloadComplete: (TestResult data) {
          setState(() {
            _downloadRate = data.transferRate;
            _displayRate = _downloadRate;
            _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
            _downloadCompletionTime = data.durationInMillis;
          });
        },
        onUploadComplete: (TestResult data) {
          setState(() {
            _uploadRate = data.transferRate;
            _displayRate = _uploadRate;
            _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
            _uploadCompletionTime = data.durationInMillis;
          });
        },
        onCancel: () {
          reset();
        });
  }

  int _uploadCompletionTime = 0;
  int _downloadCompletionTime = 0;

  void reset() {
    setState(() {
      {
        _testInProgress = false;
        _downloadRate = 0;
        _uploadRate = 0;
        _progressValue = 0.0;
        _displayRate = 0.0;
        _unitText = 'Mbps';
        _downloadCompletionTime = 0;
        _uploadCompletionTime = 0;

        _ip = null;
        _asn = null;
        _isp = null;
      }
    });
  }
}
