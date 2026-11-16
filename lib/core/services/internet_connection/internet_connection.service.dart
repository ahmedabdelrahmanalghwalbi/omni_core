part of '../../../omni_core.dart';

class InternetConnectionService {
  final InternetConnection _connection = InternetConnection();

  Stream<InternetStatus> get onStatusChange => _connection.onStatusChange;

  Future<bool> get hasConnection async => _connection.hasInternetAccess;
}
