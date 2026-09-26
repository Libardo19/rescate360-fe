/// Validaciones básicas de formularios (registro / login).
/// Sin dependencias externas: solo RegExp y validaciones de texto.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

  static final RegExp _phoneRegex = RegExp(r'^[0-9]{7,15}$');

  static String? requerido(String? value, {String campo = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$campo es obligatorio';
    }
    return null;
  }

  static String? nombre(String? value) {
    final req = requerido(value, campo: 'El nombre');
    if (req != null) return req;
    if (value!.trim().length < 3) return 'El nombre es demasiado corto';
    return null;
  }

  static String? correo(String? value) {
    final req = requerido(value, campo: 'El correo');
    if (req != null) return req;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? telefono(String? value) {
    // Campo opcional: solo se valida si el usuario escribió algo.
    if (value == null || value.trim().isEmpty) return null;
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un teléfono válido';
    }
    return null;
  }

  static String? password(String? value) {
    final req = requerido(value, campo: 'La contraseña');
    if (req != null) return req;
    if (value!.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  static String? confirmarPassword(String? value, String original) {
    final req = requerido(value, campo: 'La confirmación');
    if (req != null) return req;
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }
}
