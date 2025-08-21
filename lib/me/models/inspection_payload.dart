import 'dart:io';

import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_4/engins_listview.dart';
import 'package:test_app_divkit/me/views/shared/file_manager.dart';

class InBoardObserver {
  bool present;
  String? nom;
  String? prenom;
  String? societe;
  String? numeroPasseport;
  String? dateExpirationPasseport;

  InBoardObserver({
    this.present = false,
    this.nom,
    this.prenom,
    this.societe,
    this.numeroPasseport,
    this.dateExpirationPasseport,
  });

  factory InBoardObserver.fromMap(Map<String, dynamic> map) {
    return InBoardObserver(
      present: map['present'] ?? false,
      nom: map['nom'],
      prenom: map['prenom'],
      societe: map['societe'],
      numeroPasseport: map['numeroPasseport'],
      dateExpirationPasseport: map['dateExpirationPasseport'],
    );
  }

  Map<String, dynamic> toMap() => {
    'present': present,
    'nom': nom,
    'prenom': prenom,
    'societe': societe,
    'numeroPasseport': numeroPasseport,
    'dateExpirationPasseport': dateExpirationPasseport,
  };

  Map<String, dynamic> toJson() => toMap();
}

class Motif {
  List<dynamic> objet;
  String? observation;

  Motif({this.observation, required this.objet});

  factory Motif.fromMap(Map<String, dynamic> map) => Motif(
    objet: map['objet'] is List ? map['objet'] : [map['objet']],
    observation: map['observation'],
  );

  Map<String, dynamic> toMap() => {'objet': objet, 'observation': observation};

  Map<String, dynamic> toJson() => toMap();
}

class CapitaineNavire {
  String? nom;
  String? passeport;
  dynamic nationalite;
  String? dateExpirationPasseport;

  CapitaineNavire({
    this.nom,
    this.passeport,
    this.nationalite,
    this.dateExpirationPasseport,
  });

  factory CapitaineNavire.fromMap(Map<String, dynamic> map) => CapitaineNavire(
    nom: map['nom'] ?? map['nomCapitaine'],
    passeport: map['passeport'] ?? map['passeportCapitaine'],
    nationalite: map['nationalite'] ?? map['nationaliteCapitaine'],
    dateExpirationPasseport:
        map['dateExpirationPasseport'] ??
        map['dateExpirationPasseportCapitaine'],
  );

  Map<String, dynamic> toMap() => {
    'nom': nom,
    'passeport': passeport,
    'nationalite': nationalite,
    'dateExpirationPasseport': dateExpirationPasseport,
  };

  Map<String, dynamic> toJson() => toMap();
}

class ProprietaireNavire {
  String? nomProprietaire;
  dynamic nationalite;

  ProprietaireNavire({this.nomProprietaire, this.nationalite});

  factory ProprietaireNavire.fromMap(Map<String, dynamic> map) =>
      ProprietaireNavire(
        nomProprietaire: map['nom'] ?? map['nomProprietaire'],
        nationalite: map['nationalite'] ?? map['nationaliteProprietaire'],
      );

  Map<String, dynamic> toMap() => {
    'nomProprietaire': nomProprietaire,
    'nationalite': nationalite,
  };

  Map<String, dynamic> toJson() => toMap();
}

class DocumentInspection {
  dynamic file;
  dynamic typeDocument;

  DocumentInspection({required this.file, required this.typeDocument});

  factory DocumentInspection.fromMap(Map<String, dynamic> map) =>
      DocumentInspection(file: map['file'], typeDocument: map['typeDocument']);

  factory DocumentInspection.fromLocalFileItem(LocalFileItem f) =>
      DocumentInspection(file: File(f.path), typeDocument: f.type);

  Map<String, dynamic> toMap() => {'file': file, 'typeDocument': typeDocument};
}

class InstalledEngine {
  dynamic typesEngin;
  dynamic etatsEngin;
  String? observation;

  InstalledEngine({
    this.observation,
    required this.typesEngin,
    required this.etatsEngin,
  });

  factory InstalledEngine.fromMap(Map<String, dynamic> map) => InstalledEngine(
    typesEngin: map['typesEngin'],
    etatsEngin: map['etatsEngin'],
    observation: map['observation'],
  );

  factory InstalledEngine.fromEngineItem(EngineItem engine) => InstalledEngine(
    typesEngin: engine.typesEngins.id,
    etatsEngin: engine.etatsEngins.id,
    observation: engine.observation,
  );

  Map<String, dynamic> toMap() => {
    'typesEngin': typesEngin,
    'etatsEngin': etatsEngin,
    'observation': observation,
  };

  Map<String, dynamic> toJson() => toMap();
}

class OnBoardCapture {
  dynamic especes;
  dynamic zonesCapture;
  dynamic presentation;
  dynamic conservation;
  dynamic quantiteObservee;
  dynamic quantiteDeclaree;
  dynamic quantiteRetenue;

  OnBoardCapture({
    required this.especes,
    required this.conservation,
    required this.presentation,
    required this.zonesCapture,
    this.quantiteObservee,
    this.quantiteDeclaree,
    this.quantiteRetenue,
  });

  factory OnBoardCapture.fromMap(Map<String, dynamic> map) => OnBoardCapture(
    especes: map['especes']?.id,
    zonesCapture: map['zonesCapture']?.id,
    presentation: map['presentation']?.id,
    conservation: map['conservation']?.id,
    quantiteObservee: map['quantiteObservee'],
    quantiteDeclaree: map['quantiteDeclaree'],
    quantiteRetenue: map['quantiteRetenue'],
  );

  Map<String, dynamic> toMap() => {
    'especes': especes,
    'zonesCapture': zonesCapture,
    'presentation': presentation,
    'conservation': conservation,
    'quantiteObservee': quantiteObservee,
    'quantiteDeclaree': quantiteDeclaree,
    'quantiteRetenue': quantiteRetenue,
  };

  Map<String, dynamic> toJson() => toMap();
}

class InspectionPayload {
  dynamic id;
  String? createdAt;
  String? updatedAt;
  String? dateArriveeEffective;
  String? dateDebutInspection;
  dynamic portInspection;
  dynamic pavillonNavire;
  dynamic typeNavire;
  dynamic paysEscale;
  String? maillage;
  String? dimensionsCales;
  String? marquageNavire;
  String? baliseVMS;
  String? portEscale;
  String? dateEscaleNavire;
  bool demandePrealablePort;
  InBoardObserver? observateurEmbarque;
  Motif? motifEntreePort;
  dynamic societeConsignataire;
  dynamic agentShipping;
  CapitaineNavire? capitaine;
  ProprietaireNavire? proprietaireNavire;
  List<DocumentInspection> documents;
  List<InstalledEngine> enginsInstalles;
  List<OnBoardCapture> capturesDebarquees;
  List<OnBoardCapture> capturesABord;
  List<OnBoardCapture> capturesInterdites;
  bool infractionObservee;
  String? detailInfractions;
  String? referenceInstrumentsJuridiques;
  String? commentairesCapitaine;
  String? mesuresPrises;
  String? journaux_bord;
  String? observations_supplementaires_1;
  String? doc_captures;
  String? observations_supplementaires_2;
  String? info_commerciale;
  String? observations_supplementaires_3;
  bool? engins_examine_psma;
  String? remarques_supplementaires;

  InspectionPayload({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.dateArriveeEffective,
    this.dateDebutInspection,
    this.portInspection,
    this.pavillonNavire,
    this.typeNavire,
    this.paysEscale,
    this.maillage,
    this.dimensionsCales,
    this.marquageNavire,
    this.baliseVMS,
    this.portEscale,
    this.dateEscaleNavire,
    this.demandePrealablePort = false,
    this.observateurEmbarque,
    this.motifEntreePort,
    this.societeConsignataire,
    this.agentShipping,
    this.capitaine,
    this.proprietaireNavire,
    this.documents = const [],
    this.enginsInstalles = const [],
    this.capturesDebarquees = const [],
    this.capturesABord = const [],
    this.capturesInterdites = const [],
    this.infractionObservee = false,
    this.detailInfractions,
    this.referenceInstrumentsJuridiques,
    this.commentairesCapitaine,
    this.doc_captures,
    this.engins_examine_psma,
    this.info_commerciale,
    this.journaux_bord,
    this.mesuresPrises,
    this.observations_supplementaires_1,
    this.observations_supplementaires_2,
    this.observations_supplementaires_3,
    this.remarques_supplementaires,
  });

  factory InspectionPayload.fromMap(Map<String, dynamic> map) {
    List<DocumentInspection> documents = (map['documents'] == null)
        ? []
        : (map['documents'] as List<dynamic>).map((d) {
            if (d is LocalFileItem) {
              return DocumentInspection.fromLocalFileItem(d);
            } else {
              return DocumentInspection.fromMap(d);
            }
          }).toList();
    List<InstalledEngine> enginsInstalles = (map['enginsInstalles'] == null)
        ? []
        : (map['enginsInstalles'] as List<dynamic>).map((e) {
            if (e is EngineItem) {
              return InstalledEngine.fromEngineItem(e);
            } else {
              return InstalledEngine.fromMap(e);
            }
          }).toList();

    return InspectionPayload(
      id: map['id'],
      createdAt: (map['createdAt'] is DateTime)
          ? map['createdAt'].toString()
          : map['createdAt'],
      updatedAt: (map['updatedAt'] is DateTime)
          ? map['updatedAt'].toString()
          : map['updatedAt'],
      dateArriveeEffective: (map['dateArriveeEffective'] is DateTime)
          ? map['dateArriveeEffective'].toString()
          : map['dateArriveeEffective'],
      dateDebutInspection: (map['dateDebutInspection'] is DateTime)
          ? map['dateDebutInspection'].toString()
          : map['dateDebutInspection'],
      portInspection: map['portInspection'],
      pavillonNavire: map['pavillonNavire'],
      typeNavire: map['typeNavire'],
      paysEscale: map['paysEscale'],
      maillage: map['maillage'],
      dimensionsCales: map['dimensionsCales'],
      marquageNavire: map['marquageNavire'],
      baliseVMS: map['baliseVMS'],
      portEscale: map['portEscale'],
      dateEscaleNavire: (map['dateEscaleNavire'] is DateTime)
          ? map['dateEscaleNavire'].toString()
          : map['dateEscaleNavire'],
      demandePrealablePort: map['demandePrealablePort'] ?? false,
      observateurEmbarque: InBoardObserver.fromMap(map['observateurEmbarque']),
      motifEntreePort: Motif.fromMap(map),
      societeConsignataire: map['societeConsignataire'],
      agentShipping: map['agentShipping'],
      capitaine: CapitaineNavire.fromMap(map),
      proprietaireNavire: ProprietaireNavire.fromMap(map),
      documents: documents,
      enginsInstalles: enginsInstalles,
      capturesDebarquees: (map['capturesDebarquees'] == null)
          ? []
          : (map['capturesDebarquees'] as List<dynamic>)
                .map((c) => OnBoardCapture.fromMap(c))
                .toList(),
      capturesABord: (map['capturesABord'] == null)
          ? []
          : (map['capturesABord'] as List<dynamic>)
                .map((c) => OnBoardCapture.fromMap(c))
                .toList(),
      capturesInterdites: (map['capturesInterdites'] == null)
          ? []
          : (map['capturesInterdites'] as List<dynamic>)
                .map((c) => OnBoardCapture.fromMap(c))
                .toList(),
      infractionObservee: map['infractionObservee'],
      detailInfractions: map['detailInfractions'],
      referenceInstrumentsJuridiques: map['referenceInstrumentsJuridiques'],
      commentairesCapitaine: map['commentairesCapitaine'],
      mesuresPrises: map['mesuresPrises'],
      journaux_bord: map['journaux_bord'],
      observations_supplementaires_1: map['observations_supplementaires_1'],
      doc_captures: map['doc_captures'],
      observations_supplementaires_2: map['observations_supplementaires_2'],
      info_commerciale: map['info_commerciale'],
      observations_supplementaires_3: map['observations_supplementaires_3'],
      engins_examine_psma: map['engins_examine_psma'],
      remarques_supplementaires: map['remarques_supplementaires'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'dateArriveeEffective': dateArriveeEffective,
    'dateDebutInspection': dateDebutInspection,
    'portInspection': portInspection,
    'pavillonNavire': pavillonNavire,
    'typeNavire': typeNavire,
    'paysEscale': paysEscale,
    'maillage': maillage,
    'dimensionsCales': dimensionsCales,
    'marquageNavire': marquageNavire,
    'baliseVMS': baliseVMS,
    'portEscale': portEscale,
    'dateEscaleNavire': dateEscaleNavire,
    'demandePrealablePort': demandePrealablePort,
    'observateurEmbarque': observateurEmbarque,
    'motifEntreePort': motifEntreePort,
    'societeConsignataire': societeConsignataire,
    'agentShipping': agentShipping,
    'capitaine': capitaine,
    'proprietaireNavire': proprietaireNavire,
    'documents': documents,
    'enginsInstalles': enginsInstalles,
    'capturesDebarquees': capturesDebarquees,
    'capturesABord': capturesABord,
    'capturesInterdites': capturesInterdites,
    'infractionObservee': infractionObservee,
    'detailInfractions': detailInfractions,
    'referenceInstrumentsJuridiques': referenceInstrumentsJuridiques,
    'commentairesCapitaine': commentairesCapitaine,
    'mesuresPrises': mesuresPrises,
    'journaux_bord': journaux_bord,
    'observations_supplementaires_1': observations_supplementaires_1,
    'doc_captures': doc_captures,
    'observations_supplementaires_2': observations_supplementaires_2,
    'info_commerciale': info_commerciale,
    'observations_supplementaires_3': observations_supplementaires_3,
    'engins_examine_psma': engins_examine_psma,
    'remarques_supplementaires': remarques_supplementaires,
  };

  Map<String, dynamic> toJson() => {...toMap(), 'documents': null};

  List<DocumentInspection> get getDocuments => documents;
}
