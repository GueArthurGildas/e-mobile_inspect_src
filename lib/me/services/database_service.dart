import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum DBTables {
  activites_navires,
  agent_shipings,
  consignations,
  types_documents,
  users,
  zones_capture,
  presentation_produit,
  pays,
  types_engins,
  etats_engins,
  especes,
  conservations
}

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'inspection.db');

    // À activer temporairement si tu veux forcer la recréation
    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // free space - for storage optimisation
        await db.execute('VACUUM;');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS pays (
            id INTEGER PRIMARY KEY,
            code TEXT NOT NULL,
            libelle TEXT NOT NULL,
            deleted_at TEXT,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS activites_navires (
            id INTEGER PRIMARY KEY,
            libelle TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS agent_shipings (
            id INTEGER PRIMARY KEY,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            contact TEXT NOT NULL,
            photo TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS consignations (
            id INTEGER PRIMARY KEY,
            nom_societe TEXT NOT NULL,
            contact TEXT NOT NULL,
            situation_geo TEXT NOT NULL,
            persone_contact TEXT,
            email_contact TEXT,
            tel_contact TEXT,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS types_documents (
            id INTEGER PRIMARY KEY,
            libelle TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        // await db.execute('''
        //   CREATE TABLE IF NOT EXISTS users (
        //     id INTEGER PRIMARY KEY,
        //     name TEXT NOT NULL,
        //     prenom TEXT,
        //     email TEXT NOT NULL,
        //     telephone TEXT,
        //     email_verified_at TEXT,
        //     password TEXT NOT NULL,
        //     typeutilisateur_id INTEGER,
        //     remember_token TEXT,
        //     deleted_at TEXT,
        //     created_at TEXT,
        //     updated_at TEXT,
        //     statut_user_id INTEGER,
        //     pays_id INTEGER
        //   );
        // ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            json_role TEXT,
            field_json_inspect_done TEXT,
            field_json_inspect_pending TEXT,
            sync INTEGER DEFAULT 0
            
        );
        ''');





        await db.execute('''
          CREATE TABLE IF NOT EXISTS zones_capture (
            id INTEGER PRIMARY KEY,
            code TEXT NOT NULL,
            libelle TEXT NOT NULL,
            deleted_at TEXT,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS presentation_produit (
            id INTEGER PRIMARY KEY,
            libelle TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS pavillons (
        id INTEGER PRIMARY KEY,
        libelle TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS typenavires (
        id INTEGER PRIMARY KEY,
        libelle TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS ports (
        id INTEGER PRIMARY KEY,
        libelle TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );
        ''');

        await db.execute('''
         CREATE TABLE IF NOT EXISTS types_engins (
        id INTEGER PRIMARY KEY,
        code TEXT NOT NULL,
        label_english_name TEXT NOT NULL,
        french_name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );

        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS etats_engins (
        id INTEGER PRIMARY KEY,
        libelle TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );
        ''');

        await db.execute('''
         CREATE TABLE IF NOT EXISTS especes (
        id INTEGER PRIMARY KEY,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );
        ''');

        await db.execute('''
         CREATE TABLE IF NOT EXISTS conservations (
        id INTEGER PRIMARY KEY,
        libelle TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
    );
        ''');



        await db.execute('''
  CREATE TABLE IF NOT EXISTS inspections (
    id INTEGER PRIMARY KEY,
    created_at TEXT,
    updated_at TEXT,
    date_escale_navire TEXT,
    date_depart_navire TEXT,
    date_arrive_navire TEXT,
    date_fin_inspection TEXT,
    date_deb_inspection TEXT,
    date_prevue_arriv_navi TEXT,
    date_prevue_inspect TEXT,
    titre_inspect TEXT,
    consigne_inspect TEXT,
    navire_id INTEGER,
    captaine_id INTEGER,
    statut_inspection_id INTEGER,
    agent_shiping_id INTEGER,
    infraction_id INTEGER,
    user_id INTEGER,
    observateur_embarque_id INTEGER,
    position_navires_id INTEGER,
    port_inspection_id INTEGER,
    pays_escale_id INTEGER,
    port_escale_id INTEGER,
    type_navire_id INTEGER,
    type_pavillon_id INTEGER,
    pavillon_navire_id INTEGER,
    dpeps_id INTEGER,
    dpep_status_id INTEGER,
    consignations_id INTEGER,
    proprietaires_id INTEGER,
    captaines_id INTEGER,
    controle_engins_navire_id INTEGER,
    resultat_inspection_id INTEGER,
    pavillon_navire_fao TEXT,
    ircs_fao TEXT,
    non_navire_fao TEXT,
    imo_num_fao TEXT,
    external_id_fao TEXT,
    navire_nonexistant_id INTEGER,
    ports_last_escale TEXT,
    activit_port_obs TEXT,
    observa_embarq_status TEXT,
    respect_mesure_id INTEGER,
    navire_fao_id INTEGER,
    sync INTEGER DEFAULT 0,
    payload_json TEXT,
    json_field TEXT NOT NULL DEFAULT '{}',
    navire TEXT NOT NULL DEFAULT '{}',
    navire_json TEXT NOT NULL DEFAULT '{}'
  );
''');



      },
    );
  }
}

// await db.execute('''CREATE TABLE IF NOT EXISTS activite_navires ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS activite_navire_inspections ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, activite_navire_id INTEGER NOT NULL, inspection_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS agent_shipings ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, nom TEXT NOT NULL, prenom TEXT NOT NULL, contact TEXT NOT NULL, photo TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS autorisation_peche_engins ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, autorisation_peche_id INTEGER NOT NULL, engin_id INTEGER NOT NULL, sequence INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS autorisation_peche_epecepoisssons ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, autorisation_peche_id INTEGER NOT NULL, especepoisson_id INTEGER NOT NULL, sequence INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS autorisation_peche_zones ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, autorisation_peche_id INTEGER NOT NULL, zone_id INTEGER NOT NULL, sequence INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS autorisation_transbordements ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, demande_id INTEGER NOT NULL, identifiant TEXT NOT NULL, delivrerpar TEXT NOT NULL, debut TEXT NOT NULL, fin TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS autorissation_peches ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, demande_id INTEGER NOT NULL, indentificateur TEXT NOT NULL, delivrerpar TEXT NOT NULL, dateemission TEXT NOT NULL, dateexpiration TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS captures ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, demande_id INTEGER NOT NULL, especepoissons_id INTEGER NOT NULL, zonecapture_id INTEGER NOT NULL, produit_id INTEGER DEFAULT NULL, qteabort INTEGER NOT NULL DEFAULT '0', qteadebarquee INTEGER NOT NULL DEFAULT '0', PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS comment_docs ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, commentaire TEXT NOT NULL, doc_espace_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS condition_poissons ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS consignations ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, nom_societe TEXT NOT NULL, contact TEXT NOT NULL, situation_geo TEXT NOT NULL, persone_contact TEXT DEFAULT NULL, email_contact TEXT DEFAULT NULL, tel_contact TEXT DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS controle_engins_navire ( id INTEGER NOT NULL , maillage_mm REAL DEFAULT NULL , dimension_cales TEXT DEFAULT NULL , details_dimension_cales TEXT , engins_interdits TEXT DEFAULT NULL , details_engins_interdits TEXT , marquage_conforme TEXT DEFAULT NULL , details_marquage TEXT , vms TEXT DEFAULT NULL , details_vms TEXT , created_at TEXT NULL DEFAULT CURRENT_TIMESTAMP , updated_at TEXT NULL DEFAULT CURRENT_TIMESTAMP , PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS demandes ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, reference TEXT NOT NULL, datedemande TEXT NOT NULL, statutdemandes_id INTEGER DEFAULT NULL, naviresnonexistants_id INTEGER DEFAULT NULL, portescalenvisage_id INTEGER DEFAULT NULL, portdernierescale_id INTEGER DEFAULT NULL, datedernierescale date DEFAULT NULL, datearriveeestimee date NOT NULL, heurearriveeestimee INTEGER DEFAULT NULL, minutearriveeestimee INTEGER DEFAULT NULL, mofif_rejet TEXT DEFAULT NULL, datedevalidation TEXT DEFAULT NULL, type_refus_id INTEGER DEFAULT NULL, supervisor_id INTEGER DEFAULT NULL, datedevalidationsupervisor TEXT DEFAULT NULL, navire_uvi TEXT DEFAULT NULL, nom_navire TEXT DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS demande_motifentrees ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, demande_id INTEGER NOT NULL, motifentrees_id INTEGER NOT NULL, autre TEXT DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS detailtransbordements_especes ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, detailtransbordement_id INTEGER NOT NULL, especepoisson_id INTEGER NOT NULL, produit_id INTEGER NOT NULL, quantite REAL NOT NULL DEFAULT '0.00', PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS detailtransbordements_zones ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, detailtransbordement_id INTEGER NOT NULL, zonecapture_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS detail_transbordements ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, etatnaviredonneur_id INTEGER NOT NULL, nomnaviredonneur TEXT DEFAULT NULL, numeroidentificationnumerodonneur TEXT DEFAULT NULL, datetranssbordement TEXT DEFAULT NULL, demande_id INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS documents ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, path TEXT DEFAULT NULL, navire_id INTEGER DEFAULT NULL, type_document_id INTEGER NOT NULL, inspection_id INTEGER DEFAULT NULL, date_delivre date DEFAULT NULL, date_expiration date DEFAULT NULL, delive_par TEXT DEFAULT NULL, identifiant_doc TEXT DEFAULT NULL, type_doc_uploade INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS doc_espaces ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, path TEXT NOT NULL, titre TEXT NOT NULL, description TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS dpeps ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, ref_search TEXT DEFAULT NULL, path_dpep TEXT DEFAULT NULL, navire_id INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS dpep_status ( id INTEGER NOT NULL , libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS engins ( id INTEGER NOT NULL , code TEXT NOT NULL, libelle TEXT NOT NULL, isscfg TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS engin_installs ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, etat_engin TEXT DEFAULT NULL, observation TEXT path_img_engin TEXT DEFAULT NULL, type_engin_install_id INTEGER NOT NULL, inspection_id INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS errorlogs ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, module TEXT NOT NULL, methode TEXT NOT NULL, message TEXT NOT NULL, state tinyINTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS escale_navire ( id INTEGER NOT NULL , date date NOT NULL, ports_id INTEGER NOT NULL, pays_id INTEGER NOT NULL, PRIMARY, UNIQUE, UNIQUE );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS especes ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, nom_francais TEXT NOT NULL, nom_connu TEXT NOT NULL, nom_scientif TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS espece_poissons ( id INTEGER NOT NULL , code TEXT NOT NULL, name TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS espece_uses ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT DEFAULT NULL, qte_declaree INTEGER DEFAULT NULL, qte_debarquee INTEGER DEFAULT NULL, type_espece_use_id INTEGER DEFAULT NULL, espece_id INTEGER DEFAULT NULL , inspection_id INTEGER NOT NULL, qte_reste_a_bord INTEGER DEFAULT NULL, qte_trouvee INTEGER DEFAULT NULL, photo TEXT DEFAULT NULL, partie TEXT DEFAULT NULL, observation TEXT DEFAULT NULL, espece_poissons_id INTEGER NOT NULL, condition_poissons_id INTEGER NOT NULL, presentation_produit_id INTEGER NOT NULL, PRIMARY,condition_poissons_id,presentation_produit_id) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS espece_zone ( id INTEGER NOT NULL , espece_uses_id INTEGER NOT NULL, zone_id INTEGER NOT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS etat_conditions ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, qte TEXT NOT NULL, espece_id INTEGER NOT NULL, transbordement_id INTEGER NOT NULL, condition_poisson_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS failed_jobs ( id INTEGER NOT NULL , uuid TEXT NOT NULL, connection TEXT NOT NULL, queue TEXT NOT NULL, payload TEXT NOT NULL, exception TEXT NOT NULL, failed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY, UNIQUE );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS feature ( id INTEGER NOT NULL , libelle TEXT DEFAULT NULL, libelle_en TEXT DEFAULT NULL, module_id INTEGER NOT NULL, menu_url TEXT DEFAULT NULL, icone TEXT DEFAULT NULL, ordre INTEGER DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS fichiers ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, nom TEXT DEFAULT NULL, source TEXT DEFAULT NULL, type_fichier_id INTEGER DEFAULT NULL, demande_id INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS infractions ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, code_infraction TEXT NOT NULL, description TEXT NOT NULL, risque TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS inspections ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, date_escale_navire date DEFAULT NULL, date_depart_navire date DEFAULT NULL, date_arrive_navire date DEFAULT NULL, date_fin_inspection date DEFAULT NULL, date_deb_inspection date DEFAULT NULL, date_prevue_arriv_navi date DEFAULT NULL, date_prevue_inspect date DEFAULT NULL, titre_inspect TEXT DEFAULT NULL, consigne_inspect TEXT DEFAULT NULL, navire_id INTEGER DEFAULT NULL, captaine_id INTEGER DEFAULT NULL, statut_inspection_id INTEGER DEFAULT NULL, agent_shiping_id INTEGER DEFAULT NULL, infraction_id INTEGER DEFAULT NULL, observateur_embarque_id INTEGER DEFAULT NULL, position_navires_id INTEGER DEFAULT NULL, port_inspection_id INTEGER DEFAULT NULL , pays_escale_id INTEGER DEFAULT NULL , port_escale_id INTEGER DEFAULT NULL , type_navire_id INTEGER DEFAULT NULL, type_pavillon_id INTEGER DEFAULT NULL, pavillon_navire_id INTEGER DEFAULT NULL, dpeps_id INTEGER DEFAULT NULL, dpep_status_id INTEGER DEFAULT NULL, consignations_id INTEGER DEFAULT NULL, agent_shipings_id INTEGER DEFAULT NULL, proprietaires_id INTEGER DEFAULT NULL, captaines_id INTEGER DEFAULT NULL, controle_engins_navire_id INTEGER DEFAULT NULL, resultat_inspection_id INTEGER DEFAULT NULL, pavillon_navire_fao TEXT DEFAULT NULL, ircs_fao TEXT DEFAULT NULL, non_navire_fao TEXT DEFAULT NULL, imo_num_fao TEXT DEFAULT NULL, external_id_fao TEXT DEFAULT NULL, navire_nonexistant_id INTEGER DEFAULT NULL, ports_last_escale TEXT DEFAULT NULL, activit_port_obs TEXT DEFAULT NULL, observa_embarq_status TEXT DEFAULT NULL, respect_mesure_id INTEGER DEFAULT NULL, PRIMARY,type_pavillon_id,pavillon_navire_id),dpep_status_id),agent_shipings_id,proprietaires_id,captaines_id),pays_escale_id) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS inspection_users ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, date TEXT DEFAULT NULL, inspection_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS licences ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, date_delivre TEXT NOT NULL, date_expire TEXT NOT NULL, path TEXT NOT NULL, navire_id INTEGER NOT NULL, type_de_licence_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS model_has_permissions ( permission_id INTEGER NOT NULL, model_type TEXT NOT NULL, model_id INTEGER NOT NULL, PRIMARY,model_id,model_type),model_type) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS model_has_roles ( role_id INTEGER NOT NULL, model_type TEXT NOT NULL, model_id INTEGER NOT NULL, PRIMARY,model_id,model_type),model_type) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS module ( id INTEGER NOT NULL , libelle TEXT DEFAULT NULL, libelle_en TEXT DEFAULT NULL, menu_url TEXT DEFAULT NULL, icone TEXT DEFAULT NULL, ordre INTEGER DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS motif_entrees ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS navires ( id INTEGER NOT NULL , nom_navire TEXT NOT NULL, etatpavillon_id INTEGER DEFAULT NULL, omi TEXT NOT NULL, typenavire_id INTEGER DEFAULT NULL, ircs TEXT NOT NULL, certificat_imatriculation TEXT NOT NULL, identifiant_externe TEXT NOT NULL, mmssi TEXT NOT NULL, portattache_id INTEGER DEFAULT NULL, capitaine_id INTEGER DEFAULT NULL, proprietaire_id INTEGER DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, engin_id INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS navires_nonexistants ( id INTEGER NOT NULL , nom TEXT NOT NULL, etatpavillon_id INTEGER DEFAULT NULL, omi TEXT NOT NULL, typenavire_id INTEGER DEFAULT NULL, ircs TEXT NOT NULL, certificat_imatriculation TEXT DEFAULT NULL, identifiant_externe TEXT NOT NULL, mmsi TEXT NOT NULL, capitaine TEXT DEFAULT NULL, proprietaire TEXT DEFAULT NULL, portattache_id INTEGER DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, engin_id INTEGER DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS notifications ( id char(36) NOT NULL, type TEXT NOT NULL, notifiable_type TEXT NOT NULL, notifiable_id INTEGER NOT NULL, data TEXT NOT NULL, read_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY,notifiable_id) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS observateur_embarques ( id INTEGER NOT NULL , created_at TEXT NOT NULL, updated_at TEXT NOT NULL, nom TEXT NOT NULL, prenom TEXT NOT NULL, societe TEXT NOT NULL, photo TEXT DEFAULT NULL, passport TEXT NOT NULL, document TEXT DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS observations ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, titre TEXT DEFAULT NULL, detail TEXT DEFAULT NULL, type_observation_id INTEGER NOT NULL, inspection_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS observation_transbords ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, titre TEXT NOT NULL, detail TEXT NOT NULL, transbordement_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS orgp ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS password_resets ( email TEXT NOT NULL, token TEXT NOT NULL, created_at TEXT NULL DEFAULT NULL );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS pavillons ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, nom TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS pays ( id INTEGER NOT NULL , code TEXT NOT NULL, libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS periodes ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS permissions ( id INTEGER NOT NULL , name TEXT NOT NULL, guard_name TEXT NOT NULL, libelle TEXT NOT NULL, feature_id INTEGER NOT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, PRIMARY,guard_name) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS personal_access_tokens ( id INTEGER NOT NULL , tokenable_type TEXT NOT NULL, tokenable_id INTEGER NOT NULL, name TEXT NOT NULL, token TEXT NOT NULL, abilities TEXT last_used_at TEXT NULL DEFAULT NULL, expires_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY, UNIQUE,tokenable_id) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS ports ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, pays_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS position_navires ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS presentation_produit ( id INTEGER NOT NULL , libelle TEXT NOT NULL, created_at TEXT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NULL , PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS produits ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS proprietaires ( id INTEGER NOT NULL , nom TEXT NOT NULL, pays_id INTEGER DEFAULT NULL, observation TEXT DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, email TEXT DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS respect_mesure ( id INTEGER NOT NULL , journaux_bord TEXT DEFAULT NULL, observations_supplementaires_1 TEXT, doc_captures TEXT DEFAULT NULL, observations_supplementaires_2 TEXT, info_commerciale TEXT DEFAULT NULL, observations_supplementaires_3 TEXT, engins_examine_psma TEXT DEFAULT NULL, remarques_supplementaires TEXT, created_at TEXT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NULL , PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS resultat_inspection ( id INTEGER NOT NULL , constatations_inspecteur TEXT, infraction_constatee TEXT DEFAULT NULL, reference_juridiques TEXT, commentaires_capitaine TEXT, mesures_prises TEXT, rapport_capitaine TEXT DEFAULT NULL, nom_inspecteur TEXT DEFAULT NULL, signature_inspecteur TEXT DEFAULT NULL, exam_books TEXT DEFAULT NULL, exam_obs TEXT doc_compliance TEXT DEFAULT NULL, doc_obs TEXT info_system TEXT DEFAULT NULL, info_obs TEXT fishing_gear TEXT DEFAULT NULL, equipment_check TEXT DEFAULT NULL, equip_obs TEXT inspector_conclusions TEXT infractions TEXT captain_observations TEXT actions_taken TEXT updated_at TEXT DEFAULT NULL, created_at TEXT DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS roles ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, name TEXT NOT NULL, guard_name TEXT NOT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, description TEXT PRIMARY, UNIQUE,guard_name) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS role_has_permissions ( permission_id INTEGER NOT NULL, role_id INTEGER NOT NULL, PRIMARY,role_id) );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS role_navires ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, transbordement_id INTEGER NOT NULL, navire_id INTEGER NOT NULL, type_role_navire_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS ssn ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, demande_id INTEGER NOT NULL, orgp_id INTEGER NOT NULL, typessn_id INTEGER NOT NULL, etat_id INTEGER NOT NULL, systemecommunications_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS statut_demandes ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS statut_etat_pavillons ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS statut_inspections ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, statut TEXT NOT NULL, code_statut TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS statut_orgp ( id INTEGER NOT NULL , deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, demande_id INTEGER NOT NULL, orgp_id INTEGER NOT NULL, statutetatpavillon_id INTEGER NOT NULL, numeroorgpnavire TEXT NOT NULL, surlistenavireautorise INTEGER NOT NULL DEFAULT '0', surlistenavireindrn INTEGER NOT NULL DEFAULT '0', PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS statut_transbordements ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, statut TEXT NOT NULL, code_statut TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS statut_users ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS systeme_communications ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS transbordements ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, date TEXT NOT NULL, date_debut_transb TEXT NOT NULL, date_fin_transb TEXT NOT NULL, position TEXT NOT NULL, statut_transbordement_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS transbordement_users ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, date TEXT NOT NULL, transbordement_id INTEGER NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS typeutilisateur ( id INTEGER NOT NULL , libelle TEXT NOT NULL, code TEXT DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_de_licences ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, description TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_documents ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_doc_uploade ( id INTEGER NOT NULL , libelle TEXT NOT NULL, created_at TEXT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NULL , PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_engin_installs ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, code TEXT NOT NULL, label_english_name TEXT NOT NULL, french_name TEXT NOT NULL, iss_cfg TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_espece_uses ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_fichiers ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_navires ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_observations ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, description TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_pavillons ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, description TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_refus ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_role_navires ( id INTEGER NOT NULL , created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, libelle TEXT NOT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS type_ssn ( id INTEGER NOT NULL , libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS users ( id INTEGER NOT NULL , name TEXT NOT NULL, prenom TEXT DEFAULT NULL, email TEXT NOT NULL, telephone TEXT DEFAULT NULL, email_verified_at TEXT NULL DEFAULT NULL, password TEXT NOT NULL, typeutilisateur_id INTEGER DEFAULT NULL, remember_token TEXT DEFAULT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, statut_user_id INTEGER DEFAULT NULL, pays_id INTEGER DEFAULT NULL, PRIMARY, UNIQUE );''');
// await db.execute('''CREATE TABLE IF NOT EXISTS zones ( id INTEGER NOT NULL , code TEXT NOT NULL, libelle TEXT NOT NULL, deleted_at TEXT NULL DEFAULT NULL, created_at TEXT NULL DEFAULT NULL, updated_at TEXT NULL DEFAULT NULL, PRIMARY );''');
//
