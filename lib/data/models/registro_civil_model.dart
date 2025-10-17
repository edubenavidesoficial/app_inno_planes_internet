class RegistroCivilResponse {
  final int? idTaxDni;
  final String? idTaxTipIdeFk;
  final String? identificacion;
  final String? ruc;
  final String? nombre;
  final int? idCiuParroquiaFk;
  final String? direccion;
  final String? email;
  final String? movil;
  final String? telefono;
  final String? observacion;
  final int? usu;
  final String? fecha;
  final bool? eliminado;
  final double? deuda;
  final double? credito;
  final String? fecNacimiento;
  final String? carnetConadis;
  final String? personaContacto;
  final String? replegal;
  final String? representante;
  final String? cargo;
  final String? idTaxIdeFk;
  final int? edadCliente;

  RegistroCivilResponse({
    this.idTaxDni,
    this.idTaxTipIdeFk,
    this.identificacion,
    this.ruc,
    this.nombre,
    this.idCiuParroquiaFk,
    this.direccion,
    this.email,
    this.movil,
    this.telefono,
    this.observacion,
    this.usu,
    this.fecha,
    this.eliminado,
    this.deuda,
    this.credito,
    this.fecNacimiento,
    this.carnetConadis,
    this.personaContacto,
    this.replegal,
    this.representante,
    this.cargo,
    this.idTaxIdeFk,
    this.edadCliente,
  });

  factory RegistroCivilResponse.fromJson(Map<String, dynamic> json) {
    return RegistroCivilResponse(
      idTaxDni: json["idTaxDni"],
      idTaxTipIdeFk: json["idTaxTipIdeFk"],
      identificacion: json["identificacion"],
      ruc: json["ruc"],
      nombre: json["nombre"],
      idCiuParroquiaFk: json["idCiuParroquiaFk"],
      direccion: json["direccion"],
      email: json["email"],
      movil: json["movil"],
      telefono: json["telefono"],
      observacion: json["observacion"],
      usu: json["usu"],
      fecha: json["fecha"],
      eliminado: json["eliminado"],
      deuda: json["deuda"]?.toDouble(),
      credito: json["credito"]?.toDouble(),
      fecNacimiento: json["fecNacimiento"],
      carnetConadis: json["carnetConadis"],
      personaContacto: json["personaContacto"],
      replegal: json["replegal"],
      representante: json["representante"],
      cargo: json["cargo"],
      idTaxIdeFk: json["idTaxIdeFk"],
      edadCliente: json["edadCliente"],
    );
  }
}
