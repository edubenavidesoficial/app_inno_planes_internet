import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/menu_service.dart';
import '../../../data/models/menu_item_model.dart';

class SidebarWidget extends StatefulWidget {
  final String token;
  final String userName;
  final int usuGen;

  const SidebarWidget({
    Key? key,
    required this.token,
    required this.userName,
    required this.usuGen,
  }) : super(key: key);

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget>
    with SingleTickerProviderStateMixin {
  late Future<List<MenuItemModel>> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = MenuService().fetchMenu(widget.token);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// Convierte la función del API en ruta válida
  String _convertirFuncionEnRuta(String funcion) {
    if (funcion.isEmpty || funcion == "#") return "/";
    final clean = funcion
        .replaceAll("();", "")
        .replaceAll("(", "")
        .replaceAll(")", "")
        .trim();
    return "/${clean.toLowerCase()}";
  }

  void _navigateTo(String funcion) {
    final route = _convertirFuncionEnRuta(funcion);
    debugPrint("🔹 Navegando a ruta: $route");

    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'token': widget.token,
        'userName': widget.userName,
        'usuGen': widget.usuGen,
      },
    );
  }

  Widget _buildMenuItem(MenuItemModel item) {
    Icon leadingIcon = const Icon(Icons.chevron_right, color: Colors.white);

    if (item.subModulos != null && item.subModulos!.isNotEmpty) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: leadingIcon,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          title: Text(
            item.menu,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          children: item.subModulos!.map((subItem) {
            return ListTile(
              leading: const Icon(Icons.circle, size: 8, color: Colors.white70),
              title: Text(
                subItem.menu,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              onTap: () => _navigateTo(subItem.funcion ?? ""),
              hoverColor: Colors.white12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return ListTile(
        leading: leadingIcon,
        title: Text(
          item.menu,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onTap: () => _navigateTo(item.funcion ?? ""),
        hoverColor: Colors.white12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF199ED6),
              Color(0xFFB1B1D7),
              Color(0xFF199ED6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // CABECERA
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                title: Text(
                  'Hola, ${widget.userName.isNotEmpty ? widget.userName : 'Usuario'}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Bienvenido',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const Divider(color: Colors.white54, thickness: 0.5),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.white),
                title: const Text(
                  'INICIO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/dashboard',
                  arguments: {
                    'token': widget.token,
                    'userName': widget.userName,
                    'usuGen': widget.usuGen,
                  },
                ),
                hoverColor: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<MenuItemModel>>(
                  future: _menuFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay módulos disponibles',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final menuItems = snapshot.data!;
                    return ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) =>
                          _buildMenuItem(menuItems[index]),
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white54, thickness: 0.5),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text(
                  'Salir',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onTap: _logout,
                hoverColor: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
