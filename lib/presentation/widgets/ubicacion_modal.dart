import 'package:flutter/material.dart';
import '../../../core/services/ubicacion_service.dart';
import '../../../data/models/barrio_model.dart';
import '../../../data/models/canton_model.dart';
import '../../../data/models/parroquia_model.dart';
import '../../../data/models/provincia_model.dart';

enum NivelUbicacion { provincia, canton, parroquia, barrio }

class UbicacionModal extends StatefulWidget {
  final String token;
  final int? id_seleccionado; // Puede ser ID de parroquia o barrio
  final NivelUbicacion nivel;

  const UbicacionModal({
    Key? key,
    required this.token,
    this.id_seleccionado,
    required this.nivel,
  }) : super(key: key);

  @override
  State<UbicacionModal> createState() => _UbicacionModalState();
}

class _UbicacionModalState extends State<UbicacionModal> {
  final _ubicacionService = UbicacionService();

  List<ProvinciaModel> provincias = [];
  List<CantonModel> cantones = [];
  List<ParroquiaModel> parroquias = [];
  List<BarrioModel> barrios = [];

  ProvinciaModel? provinciaSel;
  CantonModel? cantonSel;
  ParroquiaModel? parroquiaSel;
  BarrioModel? barrioSel;

  @override
  void initState() {
    super.initState();
    cargarUbicacionesIniciales();
  }

  Future<void> cargarUbicacionesIniciales() async {
    provincias = await _ubicacionService.getProvincias(token: widget.token);
    setState(() {});

    if (widget.id_seleccionado != null) {
      if (widget.nivel == NivelUbicacion.barrio) {
        barrioSel = await _ubicacionService.getBarrioPorId(
          widget.id_seleccionado!,
          token: widget.token,
        );
        if (barrioSel != null) {
          parroquiaSel = await _ubicacionService.getParroquiaPorId(
            barrioSel!.parroquiaId,
            token: widget.token,
          );
        }
      } else {
        parroquiaSel = await _ubicacionService.getParroquiaPorId(
          widget.id_seleccionado!,
          token: widget.token,
        );
      }

      if (parroquiaSel != null) {
        cantonSel = await _ubicacionService.getCantonPorId(
          parroquiaSel!.cantonId,
          token: widget.token,
        );

        if (cantonSel != null) {
          provinciaSel = await _ubicacionService.getProvinciaPorId(
            cantonSel!.provinciaId,
            token: widget.token,
          );

          await cargarCantones();
          await cargarParroquias();

          if (widget.nivel == NivelUbicacion.barrio) {
            await cargarBarrios();
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> cargarCantones() async {
    if (provinciaSel != null) {
      cantones = await _ubicacionService.getCantones(
        provinciaSel!.id,
        token: widget.token,
      );
    }
  }

  Future<void> cargarParroquias() async {
    if (cantonSel != null) {
      parroquias = await _ubicacionService.getParroquias(
        cantonSel!.id,
        token: widget.token,
      );
    }
  }

  Future<void> cargarBarrios() async {
    if (parroquiaSel != null) {
      barrios = await _ubicacionService.getBarrios(
        parroquiaSel!.id,
        token: widget.token,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubicación'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.nivel.index >= NivelUbicacion.provincia.index)
              DropdownButtonFormField<ProvinciaModel>(
                value: provinciaSel,
                items: provincias
                    .map(
                      (prov) => DropdownMenuItem(
                        value: prov,
                        child: Text(prov.nombre),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Provincia'),
                onChanged: (val) async {
                  provinciaSel = val;
                  cantonSel = null;
                  parroquiaSel = null;
                  barrioSel = null;
                  await cargarCantones();
                  setState(() {});
                },
              ),
            if (widget.nivel.index >= NivelUbicacion.canton.index)
              DropdownButtonFormField<CantonModel>(
                isExpanded: true,
                value: cantonSel,
                items: cantones
                    .map(
                      (can) =>
                          DropdownMenuItem(value: can, child: Text(can.nombre)),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Cantón'),
                onChanged: (val) async {
                  cantonSel = val;
                  parroquiaSel = null;
                  barrioSel = null;
                  await cargarParroquias();
                  setState(() {});
                },
              ),
            if (widget.nivel.index >= NivelUbicacion.parroquia.index)
              DropdownButtonFormField<ParroquiaModel>(
                value: parroquiaSel,
                items: parroquias
                    .map(
                      (par) =>
                          DropdownMenuItem(value: par, child: Text(par.nombre)),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Parroquia'),
                onChanged: (val) async {
                  parroquiaSel = val;
                  barrioSel = null;
                  if (widget.nivel == NivelUbicacion.barrio) {
                    await cargarBarrios();
                  }
                  setState(() {});
                },
              ),
            if (widget.nivel == NivelUbicacion.barrio)
              DropdownButtonFormField<BarrioModel>(
                value: barrioSel,
                items: barrios
                    .map(
                      (bar) =>
                          DropdownMenuItem(value: bar, child: Text(bar.nombre)),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Barrio'),
                onChanged: (val) => setState(() => barrioSel = val),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.nivel == NivelUbicacion.barrio && barrioSel != null) {
              Navigator.of(context).pop(barrioSel);
            } else if (widget.nivel == NivelUbicacion.parroquia &&
                parroquiaSel != null) {
              Navigator.of(context).pop(parroquiaSel);
            } else if (widget.nivel == NivelUbicacion.canton &&
                cantonSel != null) {
              Navigator.of(context).pop(cantonSel);
            } else if (widget.nivel == NivelUbicacion.provincia &&
                provinciaSel != null) {
              Navigator.of(context).pop(provinciaSel);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seleccione una opción válida.')),
              );
            }
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
