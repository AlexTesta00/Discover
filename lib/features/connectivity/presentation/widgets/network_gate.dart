import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkGate extends StatefulWidget {
  final Widget child;
  const NetworkGate({super.key, required this.child});

  @override
  State<NetworkGate> createState() => _NetworkGateState();
}

class _NetworkGateState extends State<NetworkGate> {
  late final StreamSubscription _connSub;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();

    _connSub = Connectivity()
        .onConnectivityChanged
        .asyncMap((_) => InternetConnectionChecker.instance.hasConnection)
        .listen((has) {
      if (!mounted) return;
      setState(() => _hasInternet = has);
    });

    // Verifica iniziale.
    _initialCheck();
  }

  Future<void> _initialCheck() async {
    final has = await InternetConnectionChecker.instance.hasConnection;
    if (!mounted) return;
    setState(() => _hasInternet = has);
  }

  @override
  void dispose() {
    _connSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet) ...[
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Connessione assente',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sembra che tu non sia connesso a Internet.\n'
                        'Controlla la connessione per continuare a usare l’app.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () async {
                          final has =
                              await InternetConnectionChecker.instance.hasConnection;
                          if (!mounted) return;
                          setState(() => _hasInternet = has);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}