import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Teléfono con las 4 pestañas de la app (datos de ejemplo, no vienen de la API).
class PhoneMockup extends StatefulWidget {
  final double ancho;
  final bool inclinado;
  const PhoneMockup({super.key, this.ancho = 300, this.inclinado = false});

  @override
  State<PhoneMockup> createState() => _PhoneMockupState();
}

class _PhoneMockupState extends State<PhoneMockup> {
  static const _pestanas = <(IconData, String)>[
    (Icons.home_outlined, 'Inicio'),
    (Icons.map_outlined, 'Mapa'),
    (Icons.description_outlined, 'Reportes'),
    (Icons.more_horiz, 'Más'),
  ];
  static const _accesos = <(IconData, String)>[
    (Icons.map_outlined, 'Mapa de emergencia'),
    (Icons.sos, 'Solicitar ayuda'),
    (Icons.report_outlined, 'Reportar incidente'),
    (Icons.notifications_none, 'Alertas'),
    (Icons.local_hospital_outlined, 'Centros de ayuda'),
    (Icons.cloud_off_outlined, 'Modo sin conexión'),
  ];
  static const _filtros = <(String, String)>[
    ('todos', 'Todos'),
    ('z', 'Zonas peligrosas'),
    ('c', 'Centros'),
  ];
  // (x, y, tipo) en coordenadas Alignment (-1..1)
  static const _pines = <(double, double, String)>[
    (-0.56, -0.40, 'z'),
    (0.20, 0.10, 'z'),
    (0.50, -0.60, 'c'),
    (-0.30, 0.40, 'c'),
    (0.00, -0.50, 'z'),
    (0.70, 0.36, 'c'),
  ];

  int _tab = 0;
  String _filtro = 'todos';
  bool _sobre = false;

  @override
  Widget build(BuildContext context) {
    final inclinar = widget.inclinado && !_sobre;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: inclinar ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, t, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0008 * t)
          ..rotateY(-0.21 * t)
          ..rotateX(0.05 * t)
          ..rotateZ(0.09 * t),
        child: child,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _sobre = true),
        onExit: (_) => setState(() => _sobre = false),
        child: _telefono(),
      ),
    );
  }

  Widget _telefono() {
    return Container(
      width: widget.ancho,
      height: widget.ancho * 2.05,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(38),
        border: Border.all(color: const Color(0xFF05080F), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: switch (_tab) {
                  0 => _inicio(),
                  1 => _mapa(),
                  2 => _reportes(),
                  _ => _mas(),
                },
              ),
            ),
          ),
          _barra(),
        ],
      ),
    );
  }

  // ---------- Pestañas ----------
  Widget _inicio() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo('Hola, Oscar'),
          _sub('Estamos aquí para ayudarte.'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [for (final a in _accesos) _Acceso(a.$1, a.$2)],
          ),
          const SizedBox(height: 14),
          const Text('Alertas recientes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const _Fila(Icons.warning_amber_rounded, AppColors.danger,
              'Riesgo de deslizamiento', 'Hace 12 min · Zona Norte'),
          const _Fila(Icons.add_circle_outline, AppColors.info,
              'Centro de ayuda disponible', 'Refugio Central · Abierto 24/7'),
        ],
      );

  Widget _mapa() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo('Mapa de emergencia'),
          _sub('Filtra lo que quieres ver.'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in _filtros)
                _Chip(f.$2, _filtro == f.$1,
                    () => setState(() => _filtro = f.$1)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF121A2B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                    child: CustomPaint(painter: _CuadriculaPainter())),
                for (final p in _pines)
                  Align(
                    alignment: Alignment(p.$1, p.$2),
                    child: AnimatedOpacity(
                      opacity:
                          (_filtro == 'todos' || _filtro == p.$3) ? 1 : 0.08,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.location_on,
                          size: 26,
                          color:
                              p.$3 == 'z' ? AppColors.danger : AppColors.info),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refugio Central',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text('Abierto 24/7 · 1,2 km · ubicación aproximada',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      );

  Widget _reportes() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo('Mis reportes'),
          _sub('Sigue el estado de cada uno.'),
          const SizedBox(height: 12),
          const _Fila(Icons.check_circle_outline, AppColors.success,
              'Árbol caído en vía', 'Verificado · hace 2 h'),
          const _Fila(Icons.hourglass_top, AppColors.warning,
              'Inundación en barrio', 'En revisión · prioridad sugerida: alta'),
          const _Fila(Icons.schedule, AppColors.textSecondary,
              'Falla de alumbrado', 'En cola, se enviará al tener señal'),
        ],
      );

  Widget _mas() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo('Más'),
          _sub('Tu cuenta y ajustes.'),
          const SizedBox(height: 12),
          for (final t in const [
            'Mi perfil',
            'Contactos de emergencia',
            'Configuración',
            'Ayuda',
            'Privacidad de datos',
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(children: [
                Expanded(child: Text(t, style: const TextStyle(fontSize: 12))),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textSecondary),
              ]),
            ),
          const SizedBox(height: 4),
          const Text(
              'No sustituye a los organismos oficiales. Riesgo vital: 123.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );

  // ---------- Barra inferior ----------
  Widget _barra() => Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _pestanas.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: _tab == i,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _tab = i),
                    child: SizedBox(
                      height: 52,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_pestanas[i].$1,
                              size: 21,
                              color: _tab == i
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          Text(_pestanas[i].$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _tab == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _tab == i
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _titulo(String t) => Text(t,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  Widget _sub(String t) => Text(t,
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary));
}

class _Acceso extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Acceso(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icono, size: 20, color: AppColors.primary),
          Text(texto,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;
  const _Fila(this.icono, this.color, this.titulo, this.detalle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icono, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 12)),
                Text(detalle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;
  const _Chip(this.texto, this.activo, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: activo,
      child: Material(
        color: activo ? AppColors.primary : AppColors.surfaceElevated,
        shape: StadiumBorder(
          side: BorderSide(
              color: activo ? AppColors.primary : AppColors.surfaceBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(texto,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: activo ? Colors.white : AppColors.textSecondary,
                )),
          ),
        ),
      ),
    );
  }
}

class _CuadriculaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.surfaceBorder
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
