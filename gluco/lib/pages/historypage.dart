// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/mainbottomappbar.dart';
import 'package:gluco/styles/defaultappbar.dart';
import 'package:gluco/views/historyvo.dart';
import 'package:gluco/app_icons.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage();

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Map<String, Map<String, List<MeasurementVO>>> _monthsMap =
      HistoryVO.measurementsVOMap;

  @override
  Widget build(BuildContext context) {
    bool _isSameYear = _monthsMap.keys
            .map((monthYear) {
              return monthYear.substring(monthYear.indexOf(RegExp(r'[0-9]')));
            })
            .toSet()
            .length ==
        1;
    return Scaffold(
      appBar: defaultAppBar(title: 'Histórico de Medições'),
      bottomNavigationBar: mainBottomAppBar(context, MainBottomAppBar.history),
      body: Container(
        padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          color: CustomColors.scaffWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: _monthsMap.isEmpty
            ? Center(
                child: Text(
                  'Não há medições recentes',
                  style: Theme.of(context).textTheme.headline6,
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(4),
                itemCount: _monthsMap.length,
                itemBuilder: (c, indexMonth) {
                  // as chaves são ordenadas do mais velho pro mais novo,
                  // para fazer o display das medicoes mais novas primeiro
                  // é necessário inverte-las
                  String monthKey =
                      _monthsMap.keys.toList().reversed.elementAt(indexMonth);
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
                              _isSameYear
                                  ? monthKey.substring(0, monthKey.indexOf(','))
                                  : monthKey,
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
                        // mesma questão dos meses, a lista de chaves de dias
                        // precisa ser invertida para mostrar primeiro as
                        // medições mais recentes
                        children: _monthsMap[monthKey]!
                            .keys
                            .toList()
                            .reversed
                            .fold([], (total, dayKey) {
                          total.add(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0, left: 8.0, bottom: 8.0),
                                  child: Text(
                                    dayKey,
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
                                      _monthsMap[monthKey]![dayKey]
                                          ?.elementAt(panelIndex)
                                          .isExpanded = !isExpanded;
                                    });
                                  }),
                                  children: _monthsMap[monthKey]![dayKey]!
                                      .map<ExpansionPanel>(
                                          (MeasurementVO measurementVO) {
                                    return ExpansionPanel(
                                      backgroundColor: CustomColors.histWhite,
                                      isExpanded: measurementVO.isExpanded,
                                      canTapOnHeader: true,
                                      headerBuilder: ((context, isExpanded) {
                                        return ListTile(
                                          title: Text(
                                            'Glicose',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                          subtitle: Text(
                                              '${measurementVO.glucose} mg/dL'),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                CustomColors.lightBlue,
                                            child: Icon(AppIcons.molecula,
                                                color: Colors.white, size: 32),
                                          ),
                                        );
                                      }),
                                      body: Column(
                                        children: [
                                          ListTile(
                                            title: Text(
                                              'Saturação de oxigênio',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            subtitle:
                                                Text('${measurementVO.spo2}%'),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  CustomColors.lightGreen,
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
                                                '${measurementVO.pr_rpm} bpm'),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  CustomColors.greenBlue,
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
                          return total;
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
