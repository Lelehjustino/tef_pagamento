import 'dart:async';

import 'package:pagamento/tef/models/tef_modalidade.dart';
import 'package:pagamento/tef/models/tef_result.dart';
import 'package:pagamento/tef/models/tef_status.dart';
import 'package:pagamento/tef/tef_gateway.dart';

class MockTefGateway implements TefGateway {
  final StreamController<TefStatus> _statusController = StreamController<TefStatus>.broadcast();

  TefStatus _status = TefStatus.iniciando;

  Timer? _timer;

  TefResult? _resultado;

  bool _cancelando = false;

  @override
  TefStatus get status => _status;

  @override
  Stream<TefStatus> get statusStream => _statusController.stream;

  void _setStatus(TefStatus status) {
    _status = status;

    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  Future<TefResult> vender({
    required double valor,
    required TefModalidade modalidade,
  }) {
    if (_status == TefStatus.aguardandoCartao ||
        _status == TefStatus.cartaoDetectado ||
        _status == TefStatus.solicitandoSenha ||
        _status == TefStatus.processando) {
      return Future.error(
        TefResult(
          status: TefStatus.erro,
          mensagem: 'Já existe uma transação em andamento.',
        ),
      );
    }

    _cancelando = false;
    _resultado = null;

    final completer = Completer<TefResult>();

    _executarVenda(
      valor: valor,
      modalidade: modalidade,
      completer: completer,
    );

    return completer.future;
  }

  Future<void> _executarVenda({
    required double valor,
    required TefModalidade modalidade,
    required Completer<TefResult> completer,
  }) async {
    try {
      _setStatus(TefStatus.iniciando);

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (_cancelando) {
        _finalizarCancelamento(completer);
        return;
      }

      _setStatus(TefStatus.aguardandoCartao);

      await Future.delayed(
        const Duration(seconds: 3),
      );

      if (_cancelando) {
        _finalizarCancelamento(completer);
        return;
      }

      _setStatus(TefStatus.cartaoDetectado);

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (_cancelando) {
        _finalizarCancelamento(completer);
        return;
      }

      _setStatus(TefStatus.solicitandoSenha);

      await Future.delayed(
        const Duration(seconds: 4),
      );

      if (_cancelando) {
        _finalizarCancelamento(completer);
        return;
      }

      _setStatus(TefStatus.processando);

      await Future.delayed(
        const Duration(seconds: 3),
      );

      if (_cancelando) {
        _finalizarCancelamento(completer);
        return;
      }

      _setStatus(TefStatus.aprovado);

      _resultado = TefResult(
        status: TefStatus.aprovado,
        nsu: '123456',
        codigoAutorizacao: '789012',
        bandeira: modalidade == TefModalidade.debito
            ? 'VISA DÉBITO'
            : 'VISA CRÉDITO',
        comprovanteCliente: '''
COMPROVANTE CLIENTE

PAGAMENTO TEF
VALOR: R\$ ${valor.toStringAsFixed(2)}

BANDEIRA: VISA
NSU: 123456
AUTORIZAÇÃO: 789012

PAGAMENTO APROVADO
''',
        comprovanteEstabelecimento: '''
COMPROVANTE ESTABELECIMENTO

PAGAMENTO TEF
VALOR: R\$ ${valor.toStringAsFixed(2)}

BANDEIRA: VISA
NSU: 123456
AUTORIZAÇÃO: 789012

PAGAMENTO APROVADO
''',
        mensagem: 'Pagamento aprovado',
      );

      if (!completer.isCompleted) {
        completer.complete(_resultado);
      }
    } catch (e) {
      _setStatus(TefStatus.erro);

      if (!completer.isCompleted) {
        completer.complete(
          TefResult(
            status: TefStatus.erro,
            mensagem: e.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<void> cancelar() async {
    if (_status == TefStatus.aprovado ||
        _status == TefStatus.negado ||
        _status == TefStatus.cancelado ||
        _status == TefStatus.erro) {
      return;
    }

    _cancelando = true;

    _timer?.cancel();
  }

  void _finalizarCancelamento(
    Completer<TefResult> completer,
  ) {
    _setStatus(TefStatus.cancelado);
    
    final resultado = TefResult(
      status: TefStatus.cancelado,
      mensagem: 'Pagamento cancelado.',
    );

    _resultado = resultado;

    if (!completer.isCompleted) {
      completer.complete(resultado);
    }
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();

    await _statusController.close();
  }
}