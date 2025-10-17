// lib/presentation/pages/validation/validation_page.dart

import 'package:flutter/material.dart';
import '/presentation/viewmodels/validation_viewmodel.dart';
import 'package:provider/provider.dart';

class ValidationPage extends StatelessWidget {
  const ValidationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ValidationViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Validación de Identidad')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (viewModel.isLoading)
              const CircularProgressIndicator()
            else if (viewModel.isAuthenticationSuccessful)
              const Text('Autenticación exitosa. ¡Continúa con la validación!')
            else
              ElevatedButton(
                onPressed: () {
                  // Llama al viewmodel para iniciar la autenticación
                  viewModel.authenticate('usuario', 'contraseña');
                },
                child: const Text('Iniciar Autenticación'),
              ),
            // Aquí se renderizarán los widgets para cada paso (subir fotos, etc.)
          ],
        ),
      ),
    );
  }
}