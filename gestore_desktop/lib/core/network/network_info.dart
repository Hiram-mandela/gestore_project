import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface pour vérifier l'état de la connexion réseau
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implémentation de NetworkInfo utilisant connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return _isConnectedResult(result);
    });
  }

  /// Vérifier si le résultat de connectivité indique une connexion
  bool _isConnectedResult(List<ConnectivityResult> results) {
    // Si la liste contient au moins une connexion active (WiFi, mobile, ethernet)
    return results.any((result) =>
    result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }
}