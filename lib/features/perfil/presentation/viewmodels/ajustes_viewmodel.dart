import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ModoTema { claro, oscuro, sistema }

/// Claves de las preferencias de notificaciones.
const List<String> clavesNotificaciones = [
  'comunidad',
  'reportes',
  'solicitudes',
  'importantes',
];

const String _kTema = 'ajustes_tema';
const String _kIdioma = 'ajustes_idioma';
const String _kNotif = 'ajustes_notif_';
const String _kNombre = 'perfil_nombre';
const String _kCorreo = 'perfil_correo';
const String _kTelefono = 'perfil_telefono';

/// Preferencias de la app y datos básicos del perfil, guardados en el celular.
class Ajustes {
  final ModoTema modoTema;
  final String idioma;
  final Map<String, bool> notificaciones;
  final String nombre;
  final String correo;
  final String telefono;

  const Ajustes({
    required this.modoTema,
    required this.idioma,
    required this.notificaciones,
    required this.nombre,
    required this.correo,
    required this.telefono,
  });

  static const Ajustes inicial = Ajustes(
    modoTema: ModoTema.claro,
    idioma: 'es',
    notificaciones: {
      'comunidad': true,
      'reportes': true,
      'solicitudes': true,
      'importantes': true,
    },
    nombre: '',
    correo: '',
    telefono: '',
  );

  Ajustes copyWith({
    ModoTema? modoTema,
    String? idioma,
    Map<String, bool>? notificaciones,
    String? nombre,
    String? correo,
    String? telefono,
  }) {
    return Ajustes(
      modoTema: modoTema ?? this.modoTema,
      idioma: idioma ?? this.idioma,
      notificaciones: notificaciones ?? this.notificaciones,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
    );
  }
}

class AjustesViewModel extends Notifier<Ajustes> {
  @override
  Ajustes build() {
    _cargar();
    return Ajustes.inicial;
  }

  Future<void> _cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final temaGuardado = prefs.getString(_kTema);
      final notificaciones = <String, bool>{
        for (final clave in clavesNotificaciones)
          clave: prefs.getBool('$_kNotif$clave') ?? true,
      };

      state = Ajustes(
        modoTema: ModoTema.values.firstWhere(
          (m) => m.name == temaGuardado,
          orElse: () => ModoTema.claro,
        ),
        idioma: prefs.getString(_kIdioma) ?? 'es',
        notificaciones: notificaciones,
        nombre: prefs.getString(_kNombre) ?? '',
        correo: prefs.getString(_kCorreo) ?? '',
        telefono: prefs.getString(_kTelefono) ?? '',
      );
    } catch (_) {
      // Si no se pueden leer las preferencias, se queda con los valores
      // por defecto.
    }
  }

  Future<void> _guardarTexto(String clave, String valor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(clave, valor);
    } catch (_) {}
  }

  Future<void> _guardarBool(String clave, bool valor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(clave, valor);
    } catch (_) {}
  }

  Future<void> cambiarTema(ModoTema modo) async {
    state = state.copyWith(modoTema: modo);
    await _guardarTexto(_kTema, modo.name);
  }

  Future<void> cambiarIdioma(String idioma) async {
    state = state.copyWith(idioma: idioma);
    await _guardarTexto(_kIdioma, idioma);
  }

  Future<void> cambiarNotificacion(String clave, bool valor) async {
    state = state.copyWith(
      notificaciones: {...state.notificaciones, clave: valor},
    );
    await _guardarBool('$_kNotif$clave', valor);
  }

  Future<void> guardarPerfil({
    required String nombre,
    required String correo,
    required String telefono,
  }) async {
    state = state.copyWith(
      nombre: nombre,
      correo: correo,
      telefono: telefono,
    );
    await _guardarTexto(_kNombre, nombre);
    await _guardarTexto(_kCorreo, correo);
    await _guardarTexto(_kTelefono, telefono);
  }
}

final ajustesProvider = NotifierProvider<AjustesViewModel, Ajustes>(
  AjustesViewModel.new,
);
