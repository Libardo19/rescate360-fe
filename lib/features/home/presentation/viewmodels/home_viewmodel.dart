import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/resumen_inicio_model.dart';

/// Estado de la pantalla Home.
/// TODO(backend): [accesosRapidos] es fijo (son botones de navegación),
/// pero [alertaActiva] y [alertasRecientes] deben venir de
/// home_repository.dart -> home_remote_datasource.dart cuando exista la API.
class HomeState {
  final AlertaActiva? alertaActiva;
  final List<AlertaReciente> alertasRecientes;

  const HomeState({this.alertaActiva, this.alertasRecientes = const []});
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState()) {
    _cargarResumen();
  }

  static const accesosRapidos = [
    AccesoRapido(label: 'Mapa de emergencia', icon: Icons.map_rounded, ruta: '/mapa'),
    AccesoRapido(label: 'Solicitar ayuda', icon: Icons.campaign_rounded, ruta: '/solicitudes'),
    AccesoRapido(label: 'Reportar incidente', icon: Icons.report_rounded, ruta: '/reportes'),
    AccesoRapido(label: 'Personas desaparecidas', icon: Icons.person_search_rounded, ruta: '/personas'),
    AccesoRapido(label: 'Centros de ayuda', icon: Icons.apartment_rounded, ruta: '/centros'),
    AccesoRapido(label: 'Donaciones y necesidades', icon: Icons.favorite_rounded, ruta: '/donaciones'),
  ];

  void _cargarResumen() {
    // Mock: no hay alerta sísmica activa en este momento, por lo que la
    // tarjeta destacada del Home no debe mostrarse (ver home_screen.dart).
    state = const HomeState(
      alertaActiva: null,
      alertasRecientes: [
        AlertaReciente(
          titulo: 'Zona de alto riesgo',
          descripcion: 'Mantente alejado de la zona costera.',
          tipo: TipoAlerta.riesgo,
        ),
        AlertaReciente(
          titulo: 'Centro de ayuda disponible',
          descripcion: 'Refugio Central - Abierto 24/7',
          tipo: TipoAlerta.informativa,
        ),
      ],
    );
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});
