import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pagamento/controllers/teste_tef_controller.dart';
import 'package:pagamento/tef/mock/mock_tef_gateway.dart';
import 'package:pagamento/tef/models/tef_modalidade.dart';
import 'package:pagamento/tef/models/tef_status.dart';

class TesteTefPage extends StatefulWidget {
  const TesteTefPage({super.key});

  @override
  State<TesteTefPage> createState() => _TesteTefPageState();
}

class _TesteTefPageState extends State<TesteTefPage> {
  final TesteTefController controller = Get.find<TesteTefController>();
  final MockTefGateway tef = MockTefGateway();

  StreamSubscription<TefStatus>? _subscription;

  bool cliqueiPagar = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste TEF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Obx(() => Text(
              controller.mensagemStatus.value == '' ? 'Aguardando pagamento...' : controller.mensagemStatus.value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )),

            SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (cliqueiPagar) return;
                  cliqueiPagar = true;
                  try {
                    await controller.pagar();
                  } catch (e) {
                    debugPrint(e.toString());
                  } finally {
                    cliqueiPagar = false;
                  }
                },
                child: Text('PAGAR R\$ 50,00'),
              ),
            ),

            Obx(() {
              final status = controller.status.value;

              final podeCancelar =
                  status == TefStatus.iniciando ||
                  status == TefStatus.aguardandoCartao ||
                  status == TefStatus.cartaoDetectado ||
                  status == TefStatus.solicitandoSenha ||
                  status == TefStatus.processando;

              if (!podeCancelar) {
                return SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      controller.status.value = TefStatus.cancelado;
                    });
                    await controller.tef.cancelar();
                    await Future.delayed(
                      const Duration(seconds: 3),
                    );
                    controller.status.value = TefStatus.iniciando;
                    controller.mensagemStatus.value = '';
                  },
                  child: Text('CANCELAR'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}