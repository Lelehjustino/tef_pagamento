import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pagamento/tef/mock/cli_si_tef_gateway.dart';
import 'package:pagamento/tef/models/tef_modalidade.dart';
import 'package:pagamento/tef/models/tef_status.dart';

class TesteTefController extends GetxController {
  final CliSiTefGateway tef = CliSiTefGateway();

  final RxString mensagemStatus = ''.obs;

  final Rx<TefStatus> status = TefStatus.ocioso.obs;

  @override
  void onInit() {
    super.onInit();

    tef.statusStream.listen((novoStatus) {
      atualizarStatusTef(novoStatus);
    });
  }

  Future<String> pagar() async {
    await tef.vender(
      valor: 50.00,
      modalidade: TefModalidade.debito,
    );

    return 'Pagamento realizado com sucesso!';
  }

  void atualizarStatusTef(TefStatus novoStatus) {
    status.value = novoStatus;

    switch (novoStatus) {
      case TefStatus.ocioso:
        mensagemStatus.value = 'Iniciando pagamento...';

      case TefStatus.aguardandoCartao:
        mensagemStatus.value = 'Aguardando cartão...';

      case TefStatus.cartaoDetectado:
        mensagemStatus.value = 'Cartão detectado.';

      case TefStatus.solicitandoSenha:
        mensagemStatus.value = 'Digite a senha no PinPad.';

      case TefStatus.processando:
        mensagemStatus.value = 'Processando pagamento...';

      case TefStatus.aprovado:
        mensagemStatus.value = 'Pagamento aprovado!';

      case TefStatus.negado:
        mensagemStatus.value = 'Pagamento negado.';

      case TefStatus.cancelado:
        mensagemStatus.value = 'Pagamento cancelado.';

      case TefStatus.erro:
        mensagemStatus.value = 'Erro no pagamento.';
    }
  }
}