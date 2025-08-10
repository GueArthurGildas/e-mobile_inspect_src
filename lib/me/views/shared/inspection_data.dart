class InspectionDatac {
  final List<dynamic> pays;
  final List<dynamic> ports;
  final List<dynamic> pavillons;
  final List<dynamic> typesNavire;

  InspectionDatac({
    required this.pays,
    required this.ports,
    required this.pavillons,
    required this.typesNavire,
  });

  dynamic toObj() {
    return {
      'pays': pays,
      'ports': ports,
      'pavillons': pavillons,
      'typesNavire': typesNavire,
    };
  }
}
