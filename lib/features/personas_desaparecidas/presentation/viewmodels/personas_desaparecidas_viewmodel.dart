import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_desaparecida.dart';

/// Lista de personas desaparecidas. Por ahora vive en memoria: los reportes
/// nuevos se mantienen mientras la app esté abierta.
/// TODO: reemplazar por llamadas a la API de rescate360-be.
class PersonasViewModel extends Notifier<List<PersonaDesaparecida>> {
  @override
  List<PersonaDesaparecida> build() => _ejemplo();

  void agregar(PersonaDesaparecida persona) {
    state = [persona, ...state];
  }
}

final personasViewModelProvider =
    NotifierProvider<PersonasViewModel, List<PersonaDesaparecida>>(
  PersonasViewModel.new,
);

// Datos de ejemplo (ficticios) hasta conectar la API.
List<PersonaDesaparecida> _ejemplo() {
  final ahora = DateTime.now();
  return [
    PersonaDesaparecida(
      id: 'p1',
      nombre: 'María Fernanda López',
      edad: 15,
      sexo: 'Mujer',
      estatura: '1.60 m',
      fechaVista: ahora.subtract(const Duration(days: 2)),
      lugar: 'Barrio El Prado',
      descripcion:
          'Cabello largo y castaño, contextura delgada, tez trigueña. '
          'Salió del colegio y no llegó a casa.',
      senasParticulares: 'Lunar pequeño en la mejilla izquierda y aretes '
          'plateados.',
      vestimenta: 'Uniforme escolar azul y morral negro.',
      contactoNombre: 'Sandra López (madre)',
      contactoTelefono: '+57 300 123 4567',
      estado: EstadoPersona.urgente,
    ),
    PersonaDesaparecida(
      id: 'p2',
      nombre: 'Carlos Andrés Rojas',
      edad: 32,
      sexo: 'Hombre',
      estatura: '1.75 m',
      fechaVista: ahora.subtract(const Duration(days: 4)),
      lugar: 'Vereda La Esperanza',
      descripcion:
          'Contextura media, cabello corto negro y barba. Salió a trabajar '
          'en el campo y no regresó.',
      senasParticulares: 'Tatuaje de una brújula en el antebrazo derecho.',
      vestimenta: 'Camisa a cuadros, jean y botas de caucho.',
      contactoNombre: 'Julián Rojas (hermano)',
      contactoTelefono: '+57 301 987 6543',
      estado: EstadoPersona.enInvestigacion,
    ),
    PersonaDesaparecida(
      id: 'p3',
      nombre: 'Lucía Herrera',
      edad: 8,
      sexo: 'Mujer',
      estatura: '1.30 m',
      fechaVista: ahora.subtract(const Duration(days: 6)),
      lugar: 'Centro',
      descripcion: 'Cabello rizado y oscuro. Se separó de su familia en el '
          'mercado. Ya fue encontrada y está con ellos.',
      contactoNombre: 'Marta Herrera (abuela)',
      contactoTelefono: '+57 302 555 0198',
      estado: EstadoPersona.encontrada,
    ),
  ];
}
