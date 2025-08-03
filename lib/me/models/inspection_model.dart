class Inspection {
  final int id;
  final String? createdAt;
  final String? updatedAt;
  final String? dateEscaleNavire;
  final String? dateDepartNavire;
  final String? dateArriveNavire;
  final String? dateFinInspection;
  final String? dateDebInspection;
  final String? datePrevueArrivNavi;
  final String? datePrevueInspect;
  final String? titreInspect;
  final String? consigneInspect;

  final int? navireId;
  final int? captaineId;
  final int? statutInspectionId;
  final int? agentShipingId;
  final int? infractionId;
  final int? userId;
  final int? observateurEmbarqueId;
  final int? positionNaviresId;
  final int? portInspectionId;
  final int? paysEscaleId;
  final int? portEscaleId;
  final int? typeNavireId;
  final int? typePavillonId;
  final int? pavillonNavireId;
  final int? dpepsId;
  final int? dpepStatusId;
  final int? consignationsId;
  final int? proprietairesId;
  final int? captainesId;
  final int? controleEnginsNavireId;
  final int? resultatInspectionId;
  final String? pavillonNavireFao;
  final String? ircsFao;
  final String? nonNavireFao;
  final String? imoNumFao;
  final String? externalIdFao;
  final int? navireNonexistantId;
  final String? portsLastEscale;
  final String? activitPortObs;
  final String? observaEmbarqStatus;
  final int? respectMesureId;
  final int? navireFaoId;
  final int sync;

  Inspection({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.dateEscaleNavire,
    this.dateDepartNavire,
    this.dateArriveNavire,
    this.dateFinInspection,
    this.dateDebInspection,
    this.datePrevueArrivNavi,
    this.datePrevueInspect,
    this.titreInspect,
    this.consigneInspect,
    this.navireId,
    this.captaineId,
    this.statutInspectionId,
    this.agentShipingId,
    this.infractionId,
    this.userId,
    this.observateurEmbarqueId,
    this.positionNaviresId,
    this.portInspectionId,
    this.paysEscaleId,
    this.portEscaleId,
    this.typeNavireId,
    this.typePavillonId,
    this.pavillonNavireId,
    this.dpepsId,
    this.dpepStatusId,
    this.consignationsId,
    this.proprietairesId,
    this.captainesId,
    this.controleEnginsNavireId,
    this.resultatInspectionId,
    this.pavillonNavireFao,
    this.ircsFao,
    this.nonNavireFao,
    this.imoNumFao,
    this.externalIdFao,
    this.navireNonexistantId,
    this.portsLastEscale,
    this.activitPortObs,
    this.observaEmbarqStatus,
    this.respectMesureId,
    this.navireFaoId,
    this.sync = 0,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dateEscaleNavire: json['date_escale_navire'],
      dateDepartNavire: json['date_depart_navire'],
      dateArriveNavire: json['date_arrive_navire'],
      dateFinInspection: json['date_fin_inspection'],
      dateDebInspection: json['date_deb_inspection'],
      datePrevueArrivNavi: json['date_prevue_arriv_navi'],
      datePrevueInspect: json['date_prevue_inspect'],
      titreInspect: json['titre_inspect'],
      consigneInspect: json['consigne_inspect'],
      navireId: json['navire_id'],
      captaineId: json['captaine_id'],
      statutInspectionId: json['statut_inspection_id'],
      agentShipingId: json['agent_shiping_id'],
      infractionId: json['infraction_id'],
      userId: json['user_id'],
      observateurEmbarqueId: json['observateur_embarque_id'],
      positionNaviresId: json['position_navires_id'],
      portInspectionId: json['port_inspection_id'],
      paysEscaleId: json['pays_escale_id'],
      portEscaleId: json['port_escale_id'],
      typeNavireId: json['type_navire_id'],
      typePavillonId: json['type_pavillon_id'],
      pavillonNavireId: json['pavillon_navire_id'],
      dpepsId: json['dpeps_id'],
      dpepStatusId: json['dpep_status_id'],
      consignationsId: json['consignations_id'],
      proprietairesId: json['proprietaires_id'],
      captainesId: json['captaines_id'],
      controleEnginsNavireId: json['controle_engins_navire_id'],
      resultatInspectionId: json['resultat_inspection_id'],
      pavillonNavireFao: json['pavillon_navire_fao'],
      ircsFao: json['ircs_fao'],
      nonNavireFao: json['non_navire_fao'],
      imoNumFao: json['imo_num_fao'],
      externalIdFao: json['external_id_fao'],
      navireNonexistantId: json['navire_nonexistant_id'],
      portsLastEscale: json['ports_last_escale'],
      activitPortObs: json['activit_port_obs'],
      observaEmbarqStatus: json['observa_embarq_status'],
      respectMesureId: json['respect_mesure_id'],
      navireFaoId: json['navire_fao_id'],
      sync: json['sync'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'date_escale_navire': dateEscaleNavire,
      'date_depart_navire': dateDepartNavire,
      'date_arrive_navire': dateArriveNavire,
      'date_fin_inspection': dateFinInspection,
      'date_deb_inspection': dateDebInspection,
      'date_prevue_arriv_navi': datePrevueArrivNavi,
      'date_prevue_inspect': datePrevueInspect,
      'titre_inspect': titreInspect,
      'consigne_inspect': consigneInspect,
      'navire_id': navireId,
      'captaine_id': captaineId,
      'statut_inspection_id': statutInspectionId,
      'agent_shiping_id': agentShipingId,
      'infraction_id': infractionId,
      'user_id': userId,
      'observateur_embarque_id': observateurEmbarqueId,
      'position_navires_id': positionNaviresId,
      'port_inspection_id': portInspectionId,
      'pays_escale_id': paysEscaleId,
      'port_escale_id': portEscaleId,
      'type_navire_id': typeNavireId,
      'type_pavillon_id': typePavillonId,
      'pavillon_navire_id': pavillonNavireId,
      'dpeps_id': dpepsId,
      'dpep_status_id': dpepStatusId,
      'consignations_id': consignationsId,
      'proprietaires_id': proprietairesId,
      'captaines_id': captainesId,
      'controle_engins_navire_id': controleEnginsNavireId,
      'resultat_inspection_id': resultatInspectionId,
      'pavillon_navire_fao': pavillonNavireFao,
      'ircs_fao': ircsFao,
      'non_navire_fao': nonNavireFao,
      'imo_num_fao': imoNumFao,
      'external_id_fao': externalIdFao,
      'navire_nonexistant_id': navireNonexistantId,
      'ports_last_escale': portsLastEscale,
      'activit_port_obs': activitPortObs,
      'observa_embarq_status': observaEmbarqStatus,
      'respect_mesure_id': respectMesureId,
      'navire_fao_id': navireFaoId,
      'sync': sync,
    };

  }

  /// ✅ Pour SQLite → Objet
  factory Inspection.fromMap(Map<String, dynamic> map) {
    return Inspection(
      id: map['id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      dateEscaleNavire: map['date_escale_navire'],
      dateDepartNavire: map['date_depart_navire'],
      dateArriveNavire: map['date_arrive_navire'],
      dateFinInspection: map['date_fin_inspection'],
      dateDebInspection: map['date_deb_inspection'],
      datePrevueArrivNavi: map['date_prevue_arriv_navi'],
      datePrevueInspect: map['date_prevue_inspect'],
      titreInspect: map['titre_inspect'],
      consigneInspect: map['consigne_inspect'],
      navireId: map['navire_id'],
      captaineId: map['captaine_id'],
      statutInspectionId: map['statut_inspection_id'],
      agentShipingId: map['agent_shiping_id'],
      infractionId: map['infraction_id'],
      userId: map['user_id'],
      observateurEmbarqueId: map['observateur_embarque_id'],
      positionNaviresId: map['position_navires_id'],
      portInspectionId: map['port_inspection_id'],
      paysEscaleId: map['pays_escale_id'],
      portEscaleId: map['port_escale_id'],
      typeNavireId: map['type_navire_id'],
      typePavillonId: map['type_pavillon_id'],
      pavillonNavireId: map['pavillon_navire_id'],
      dpepsId: map['dpeps_id'],
      dpepStatusId: map['dpep_status_id'],
      consignationsId: map['consignations_id'],
      proprietairesId: map['proprietaires_id'],
      captainesId: map['captaines_id'],
      controleEnginsNavireId: map['controle_engins_navire_id'],
      resultatInspectionId: map['resultat_inspection_id'],
      pavillonNavireFao: map['pavillon_navire_fao'],
      ircsFao: map['ircs_fao'],
      nonNavireFao: map['non_navire_fao'],
      imoNumFao: map['imo_num_fao'],
      externalIdFao: map['external_id_fao'],
      navireNonexistantId: map['navire_nonexistant_id'],
      portsLastEscale: map['ports_last_escale'],
      activitPortObs: map['activit_port_obs'],
      observaEmbarqStatus: map['observa_embarq_status'],
      respectMesureId: map['respect_mesure_id'],
      navireFaoId: map['navire_fao_id'],
      sync: map['sync'] ?? 0,
    );
  }

  /// ✅ Pour Objet → SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'date_escale_navire': dateEscaleNavire,
      'date_depart_navire': dateDepartNavire,
      'date_arrive_navire': dateArriveNavire,
      'date_fin_inspection': dateFinInspection,
      'date_deb_inspection': dateDebInspection,
      'date_prevue_arriv_navi': datePrevueArrivNavi,
      'date_prevue_inspect': datePrevueInspect,
      'titre_inspect': titreInspect,
      'consigne_inspect': consigneInspect,
      'navire_id': navireId,
      'captaine_id': captaineId,
      'statut_inspection_id': statutInspectionId,
      'agent_shiping_id': agentShipingId,
      'infraction_id': infractionId,
      'user_id': userId,
      'observateur_embarque_id': observateurEmbarqueId,
      'position_navires_id': positionNaviresId,
      'port_inspection_id': portInspectionId,
      'pays_escale_id': paysEscaleId,
      'port_escale_id': portEscaleId,
      'type_navire_id': typeNavireId,
      'type_pavillon_id': typePavillonId,
      'pavillon_navire_id': pavillonNavireId,
      'dpeps_id': dpepsId,
      'dpep_status_id': dpepStatusId,
      'consignations_id': consignationsId,
      'proprietaires_id': proprietairesId,
      'captaines_id': captainesId,
      'controle_engins_navire_id': controleEnginsNavireId,
      'resultat_inspection_id': resultatInspectionId,
      'pavillon_navire_fao': pavillonNavireFao,
      'ircs_fao': ircsFao,
      'non_navire_fao': nonNavireFao,
      'imo_num_fao': imoNumFao,
      'external_id_fao': externalIdFao,
      'navire_nonexistant_id': navireNonexistantId,
      'ports_last_escale': portsLastEscale,
      'activit_port_obs': activitPortObs,
      'observa_embarq_status': observaEmbarqStatus,
      'respect_mesure_id': respectMesureId,
      'navire_fao_id': navireFaoId,
      'sync': sync,
    };
  }

}
