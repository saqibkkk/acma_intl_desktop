import 'package:flutter/material.dart';
import '../Controllers/updateController.dart';
import '../utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AutoUpdater updater = AutoUpdater();
  final utils = Utils();
  bool updateAvailable = false;
  String latestVersion = "";
  double progress = 0.0;
  String status = "Checking for updates...";
  bool isDownloading = false;
  bool internetAvailable = true;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_animationController);

    _checkInternetAndUpdate();
  }

  Future<void> _checkInternetAndUpdate() async {
    internetAvailable = await Utils.isInternetAvailable();
    if (!internetAvailable) {
      setState(() {
        status = "No Internet Connection";
      });
      return;
    }
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    try {
      final latest = await updater.getLatestRelease();
      if (latest != null && updater.isNewerVersion(latest["version"]!)) {
        setState(() {
          updateAvailable = true;
          latestVersion = latest["version"]!;
          status = "New version available: $latestVersion";
        });
      } else {
        setState(() {
          status = "You are on the latest version.";
        });
        await Future.delayed(const Duration(seconds: 1));
        _goToHome();
      }
    } catch (e) {
      setState(() {
        status = "Error fetching update: $e";
        internetAvailable = false;
      });
    }
  }

  Future<void> _startUpdate() async {
    internetAvailable = await Utils.isInternetAvailable();
    if (!internetAvailable) {
      setState(() {
        status = "No Internet Connection";
      });
      return;
    }

    setState(() {
      isDownloading = true;
      progress = 0.0;
      status = "Downloading update...";
    });

    try {
      final latest = await updater.getLatestRelease();
      if (latest == null) throw Exception("Failed to get update info.");

      final filePath = await updater.downloadUpdate(latest["url"]!, (prog) {
        _animation = Tween<double>(begin: _animation.value, end: prog).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut));
        _animationController.forward(from: 0);
        setState(() {
          progress = prog;
          status = "Downloading... ${(prog * 100).toStringAsFixed(0)}%";
        });
      });

      if (filePath != null) {
        setState(() {
          progress = 1.0;
          status = "Update downloaded successfully:\n$filePath";
          isDownloading = false;
          updateAvailable = false; // remove button
        });
      } else {
        throw Exception("Download failed.");
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
        isDownloading = false;
      });
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.white, Colors.blue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/acmaLogo.png',
                width: 500,
                height: 500,
              ),
              const SizedBox(height: 20),
              if (isDownloading)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: _animation.value,
                                strokeWidth: 8,
                                color: Colors.red,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                            Text(
                              "${(_animation.value * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(status, textAlign: TextAlign.center),
                      ],
                    );
                  },
                )
              else if (updateAvailable)
                utils.customElevatedFunctionButton(
                  onPressed: _startUpdate,
                  btnName: status.contains("No Internet")
                      ? "No Internet Connection"
                      : "Download Update",
                  bgColor: Colors.blueGrey,
                  fgColor: Colors.white,
                )
              else
                Column(
                  children: [
                    // const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
