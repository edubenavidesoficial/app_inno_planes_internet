class MenuItemModel {
  final int idSegMenu;
  final String menu;
  final String tipo;
  final int padre;
  final String? funcion;
  final String? icono;
  final double indice;
  final String? privilegio;
  final String? formato;
  final String? privilegioMultiple;
  final List<MenuItemModel>? subModulos;
  final int? totalMenu;

  MenuItemModel({
    required this.idSegMenu,
    required this.menu,
    required this.tipo,
    required this.padre,
    this.funcion,
    this.icono,
    required this.indice,
    this.privilegio,
    this.formato,
    this.privilegioMultiple,
    this.subModulos,
    this.totalMenu,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      idSegMenu: json['idSegMenu'],
      menu: json['menu'],
      tipo: json['tipo'],
      padre: json['padre'],
      funcion: json['funcion'],
      icono: json['icono'],
      indice: (json['indice'] as num).toDouble(),
      privilegio: json['privilegio'],
      formato: json['formato'],
      privilegioMultiple: json['privilegioMultiple'],
      subModulos: json['subModulos'] != null
          ? (json['subModulos'] as List)
          .map((e) => MenuItemModel.fromJson(e))
          .toList()
          : null,
      totalMenu: json['totalMenu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSegMenu': idSegMenu,
      'menu': menu,
      'tipo': tipo,
      'padre': padre,
      'funcion': funcion,
      'icono': icono,
      'indice': indice,
      'privilegio': privilegio,
      'formato': formato,
      'privilegioMultiple': privilegioMultiple,
      'subModulos': subModulos?.map((e) => e.toJson()).toList(),
      'totalMenu': totalMenu,
    };
  }
}
