import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:questions_answers_by_camera/main.dart';

class Scan extends StatefulWidget {

	@override
	_Scan createState() => _Scan();
}

class _Scan extends State<Scan> with WidgetsBindingObserver {
	CameraController? controller;
	bool _isCameraInitialized = false;
	void onNewCameraSelected(CameraDescription cameraDescription) async {
		final previousCameraController = controller;
		final CameraController cameraController = CameraController(cameraDescription, ResolutionPreset.high, imageFormatGroup: ImageFormatGroup.jpeg);
		await previousCameraController?.dispose();
		if (mounted) {
			setState(() {
				controller = cameraController;
			});
		}

		cameraController.addListener(() {
			if (mounted) setState(() {});
		});

		try {
			await cameraController.initialize();
		} on CameraException catch(e) {
			print('Error initializeing camera: $e');
		}

		if (mounted) {
			setState(() {
				_isCameraInitialized = controller!.value.isInitialized;
			});
		}
	}

	@override
	void initState() {
		if (cameras.length == 0) {
			print('No camera detected.');
			return;
		}
		onNewCameraSelected(cameras[0]);
		super.initState();
	}

	@override
	void dispose() {
		controller?.dispose();
		super.dispose();
	}

	@override
	void didChangeAppLifecycleState(AppLifecycleState state) {
		final CameraController? cameraController = controller;
		if (cameraController == null || !cameraController.value.isInitialized) return;

		if (state == AppLifecycleState.inactive) {
			cameraController.dispose();
		} else if (state == AppLifecycleState.resumed) {
			onNewCameraSelected(cameras[0]);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: _isCameraInitialized
				? AspectRatio(aspectRatio: 1 / controller!.value.aspectRatio, child: controller!.buildPreview(),)
				: Container()
		);
	}
}
