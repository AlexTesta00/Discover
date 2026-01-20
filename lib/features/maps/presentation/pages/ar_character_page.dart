import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:discover/features/character/domain/entities/character.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ARCharacterPage extends StatefulWidget {
  const ARCharacterPage({super.key, required this.character});

  final Character character;

  @override
  State<ARCharacterPage> createState() => _ARCharacterPageState();
}

class _ARCharacterPageState extends State<ARCharacterPage> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _isTakingPhoto = false;

  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Errore inizializzazione camera: $e');
      rethrow;
    }
  }

  /// Controlla / richiede permesso per poter salvare nelle foto
  Future<bool> _ensureSavePermission() async {
    var status = await Permission.photos.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.photos.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showPermissionDialog();
      return false;
    }

    return false;
  }

  Future<void> _showPermissionDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Permesso necessario'),
          content: const Text(
            'Per salvare le foto nella galleria devi abilitare il permesso dalle impostazioni dell\'app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: const Text('Apri impostazioni'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Cattura lo screenshot di camera + sticker (senza i pulsanti)
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isTakingPhoto) return;

    setState(() => _isTakingPhoto = true);

    try {
      final ok = await _ensureSavePermission();
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permesso per salvare le foto negato')),
        );
        return;
      }

      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Boundary nullo, impossibile catturare l’immagine');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile catturare la scena')),
        );
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        name: 'discover_${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint('Risultato salvataggio immagine: $result');

      if (!mounted) return;

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto salvata nella galleria!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile salvare la foto')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError ||
              _controller == null ||
              !_controller!.value.isInitialized) {
            return const Center(
              child: Text(
                'Impossibile avviare la fotocamera',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 🔁 SOLO questa parte viene catturata nello screenshot
              RepaintBoundary(
                key: _previewKey,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fotocamera
                    CameraPreview(_controller!),

                    // Leggera ombra per far risaltare lo sticker
                    Container(color: Colors.black.withValues(alpha: 0.08)),

                    // Personaggio ridimensionabile e trascinabile
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: false,
                        child: InteractiveViewer(
                          panEnabled: true,
                          scaleEnabled: true,
                          minScale: 0.3,
                          maxScale: 3.0,
                          boundaryMargin: const EdgeInsets.all(500),
                          child: Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              widget.character.imageAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Questi elementi NON sono dentro il RepaintBoundary -> non finiscono in foto

              // Pulsante indietro (floating in alto a sinistra)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FloatingActionButton.small(
                      heroTag: 'back_ar',
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Pulsante scatto foto (in basso al centro)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: FloatingActionButton(
                      heroTag: 'capture_ar',
                      backgroundColor: Colors.white,
                      onPressed: _isTakingPhoto ? null : _takePicture,
                      child: _isTakingPhoto
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_alt,
                              color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
