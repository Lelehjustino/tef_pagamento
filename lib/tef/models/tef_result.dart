import 'tef_status.dart';

class TefResult {
  final TefStatus status;

  /// NSU (Número Sequencial Único) da transação.
  final String? nsu;

  /// Código de autorização retornado pela transação.
  final String? codigoAutorizacao;

  /// Bandeira utilizada no pagamento.
  final String? bandeira;

  /// Comprovante destinado ao cliente.
  final String? comprovanteCliente;

  /// Comprovante destinado ao estabelecimento.
  final String? comprovanteEstabelecimento;

  /// Mensagem retornada durante ou após a transação.
  final String? mensagem;

  const TefResult({
    required this.status,
    this.nsu,
    this.codigoAutorizacao,
    this.bandeira,
    this.comprovanteCliente,
    this.comprovanteEstabelecimento,
    this.mensagem,
  });

  /// Indica se o pagamento foi aprovado.
  bool get aprovado => status == TefStatus.aprovado;

  /// Indica se o pagamento foi negado.
  bool get negado => status == TefStatus.negado;

  /// Indica se o pagamento foi cancelado.
  bool get cancelado => status == TefStatus.cancelado;

  /// Indica se ocorreu algum erro.
  bool get erro => status == TefStatus.erro;
}