import 'package:pagamento/tef/models/tef_modalidade.dart';
import 'package:pagamento/tef/models/tef_result.dart';
import 'package:pagamento/tef/models/tef_status.dart';

abstract class TefGateway {
  TefStatus get status;

  Stream<TefStatus> get statusStream;

  Future<TefResult> vender({
    required double valor,
    required TefModalidade modalidade,
  });

  Future<void> cancelar();

  Future<void> dispose();
}