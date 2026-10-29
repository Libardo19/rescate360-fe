import 'package:flutter/material.dart';
import 'landing_footer.dart';

class LandingScaffold extends StatelessWidget {
  final String rutaActual;
  final VoidCallback? onFunciones;
  final List<Widget> secciones;

  const LandingScaffold({
    super.key,
    required this.rutaActual,
    required this.secciones,
    this.onFunciones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rutaActual),
        actions: onFunciones != null
            ? [
                IconButton(
                  icon: const Icon(Icons.functions),
                  onPressed: onFunciones,
                ),
              ]
            : null,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(rutaActual),
            ),
            if (onFunciones != null)
              ListTile(
                leading: const Icon(Icons.functions),
                title: const Text('Funciones'),
                onTap: () {
                  Navigator.of(context).pop();
                  onFunciones!.call();
                },
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [...secciones, const LandingFooter()]),
      ),
    );
  }
}
