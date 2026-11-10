/// Roles del backend (`rol` en UsuarioOut).
enum Rol {
  ciudadano('ciudadano', 'Ciudadano'),
  voluntario('voluntario', 'Voluntario'),
  administrador('administrador', 'Administrador'),
  superAdmin('super_admin', 'Super admin');

  const Rol(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static Rol desde(String valor) =>
      Rol.values.firstWhere((r) => r.valor == valor, orElse: () => Rol.ciudadano);

  /// Administradores y super admin trabajan en el panel web, no en la app.
  bool get usaPanelWeb => this == Rol.administrador || this == Rol.superAdmin;
}
