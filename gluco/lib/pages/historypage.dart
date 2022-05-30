// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/styles/colors.dart';
import '../styles/defaultappbar.dart';

import '../view/historicoteste.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage();

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AppBar appBar = defaultAppBar(title: "Histórico de Medições");

  // Somente para popular a página de histórico (poderia ser substituida por um get do bd)
  final _medidasTeste = HistoricoTeste.getCollectedAsMap();

  @override
  Widget build(BuildContext context) {
    bool _mesmoAno = _medidasTeste.keys
            .map((mesano) {
              return mesano.substring(mesano.indexOf(RegExp(r'[0-9]')));
            })
            .toSet()
            .length ==
        1;
    return Scaffold(
      appBar: appBar,
      body: Container(
        padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          color: fundoScaf2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: _medidasTeste.isEmpty
            ? Center(
                child: Text(
                  'Não há medições recentes',
                  style: Theme.of(context).textTheme.headline6,
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(4),
                itemCount: _medidasTeste.length,
                itemBuilder: (c, indexMonth) {
                  String mes = _medidasTeste.keys.elementAt(indexMonth);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              // se houverem medidas de anos diferentes, o mês mostra o ano também,
                              // caso contrário só o nome do mês
                              _mesmoAno
                                  ? mes.substring(0, mes.indexOf(','))
                                  : mes,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: MediaQuery.of(context).size.width * 0.15,
                            colors: const [Colors.grey, Colors.transparent],
                          ),
                        ),
                      ),
                      Column(
                        children: _medidasTeste[mes]!.keys.fold([], (t, dia) {
                          t.add(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0, left: 8.0, bottom: 8.0),
                                  child: Text(
                                    dia,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Precisa corrigir a borda arredondada do ExpansionPanelList
                                // e o padding entre os ExpansionPanel quando fechados
                                ExpansionPanelList(
                                  expandedHeaderPadding: EdgeInsets.all(0),
                                  elevation: 4,
                                  expansionCallback: ((panelIndex, isExpanded) {
                                    setState(() {
                                      _medidasTeste[mes]![dia]
                                          ?.elementAt(panelIndex)
                                          .isExpanded = !isExpanded;
                                    });
                                  }),
                                  children: _medidasTeste[mes]![dia]!
                                      .map<ExpansionPanel>(
                                          (CollectedVO collected) {
                                    return ExpansionPanel(
                                      backgroundColor: fundoHist,
                                      isExpanded: collected.isExpanded,
                                      headerBuilder: ((context, isExpanded) {
                                        return ListTile(
                                          title: Text(
                                            'Glicose',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                          subtitle: Text(
                                              '${collected.dados.glicose} mg/dL'),
                                          leading: CircleAvatar(
                                            backgroundColor: azulClaro,
                                            child: Icon(
                                              Icons.hub_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }),
                                      body: Column(
                                        children: [
                                          ListTile(
                                            title: Text(
                                              'Temperatura',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            subtitle: Text(
                                                '${collected.dados.temperatura}°C'),
                                            leading: CircleAvatar(
                                              backgroundColor: azulEsverdeado,
                                              child: Icon(
                                                Icons.thermostat_sharp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            title: Text(
                                              'Saturação de oxigênio',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            subtitle: Text(
                                                '${collected.dados.saturacao}%'),
                                            leading: CircleAvatar(
                                              backgroundColor: verdeClaro,
                                              child: Icon(
                                                Icons.air,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            title: Text(
                                              'Frequência cardíaca',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            subtitle: Text(
                                                '${collected.dados.batimento} bpm'),
                                            leading: CircleAvatar(
                                              backgroundColor: verdeAzulado,
                                              child: Icon(
                                                Icons.favorite,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                          return t;
                        }),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 15)),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
