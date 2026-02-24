import 'package:flutter/material.dart';
import 'package:nethive_neo/data/mock_data.dart';

class ReporteProvider extends ChangeNotifier {
  final kpiNacional  = mockKpiNacional;
  final kpiEstatal   = mockKpiEstatal;
  final kpiMunicipal = mockKpiMunicipalTijuana;
  final alertas      = mockAlertasEstatales;

  // Tendencias (ultimos 7 dias) — datos del KPI nacional
  List<double> get tendenciaRecibidas  => kpiNacional.tendencia7Dias;
  List<double> get tendenciaResueltas  => kpiNacional.tendenciaResueltas;
  List<double> get tendenciaCriticas   => kpiNacional.tendenciaCriticas;
}
