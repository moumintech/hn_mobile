import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/rendez_vous.dart';
import '../models/rappel_medicament.dart';
import '../models/prescription.dart';

/// Service de base de données SQLite local — Singleton
class DatabaseService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;

  Database? _db;

  // ─── Initialisation ───────────────────────────────────────────────────────
  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'healthnorth.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table rendez_vous
    await db.execute('''
      CREATE TABLE rendez_vous (
        id_rdv          INTEGER PRIMARY KEY,
        date_rdv        TEXT,
        heure_rdv       TEXT,
        statut          TEXT,
        specialiste_nom TEXT,
        specialiste_prenom TEXT,
        specialite      TEXT,
        etablissement_nom TEXT,
        adresse         TEXT,
        rappel_actif    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Table rappels_medicaments
    await db.execute('''
      CREATE TABLE rappels_medicaments (
        id_rappel  INTEGER PRIMARY KEY,
        heure      TEXT,
        actif      INTEGER NOT NULL DEFAULT 1,
        id_ligne   INTEGER,
        medicament TEXT,
        dosage     TEXT,
        frequence  TEXT,
        duree      TEXT
      )
    ''');

    // Table prescriptions
    await db.execute('''
      CREATE TABLE prescriptions (
        id_ordonnance          INTEGER PRIMARY KEY,
        date_prescription      TEXT,
        instructions_generales TEXT,
        est_valide             INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Table lignes_medicaments (liée aux prescriptions)
    await db.execute('''
      CREATE TABLE lignes_medicaments (
        id_ligne      INTEGER PRIMARY KEY AUTOINCREMENT,
        id_ordonnance INTEGER NOT NULL,
        medicament    TEXT,
        dosage        TEXT,
        frequence     TEXT,
        duree         TEXT,
        FOREIGN KEY (id_ordonnance) REFERENCES prescriptions(id_ordonnance)
          ON DELETE CASCADE
      )
    ''');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RENDEZ-VOUS
  // ══════════════════════════════════════════════════════════════════════════

  /// Insère ou remplace un rendez-vous.
  Future<void> insertRendezVous(RendezVous rdv) async {
    final db = await database;
    await db.insert(
      'rendez_vous',
      rdv.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère tous les rendez-vous.
  Future<List<RendezVous>> getAllRendezVous() async {
    final db = await database;
    final rows = await db.query('rendez_vous');
    return rows.map(RendezVous.fromMap).toList();
  }

  /// Met à jour un rendez-vous par son ID.
  Future<void> updateRendezVous(RendezVous rdv) async {
    final db = await database;
    await db.update(
      'rendez_vous',
      rdv.toMap(),
      where: 'id_rdv = ?',
      whereArgs: [rdv.idRdv],
    );
  }

  /// Supprime un rendez-vous par son ID.
  Future<void> deleteRendezVous(int idRdv) async {
    final db = await database;
    await db.delete('rendez_vous', where: 'id_rdv = ?', whereArgs: [idRdv]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RAPPELS MÉDICAMENTS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> insertRappel(RappelMedicament rappel) async {
    final db = await database;
    await db.insert(
      'rappels_medicaments',
      rappel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RappelMedicament>> getAllRappels() async {
    final db = await database;
    final rows = await db.query('rappels_medicaments');
    return rows.map(RappelMedicament.fromMap).toList();
  }

  Future<void> updateRappel(RappelMedicament rappel) async {
    final db = await database;
    await db.update(
      'rappels_medicaments',
      rappel.toMap(),
      where: 'id_rappel = ?',
      whereArgs: [rappel.idRappel],
    );
  }

  Future<void> deleteRappel(int idRappel) async {
    final db = await database;
    await db.delete(
      'rappels_medicaments',
      where: 'id_rappel = ?',
      whereArgs: [idRappel],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRESCRIPTIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Insère une prescription et toutes ses lignes médicaments.
  Future<void> insertPrescription(Prescription prescription) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'prescriptions',
        prescription.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Supprimer les anciennes lignes avant réinsertion
      await txn.delete(
        'lignes_medicaments',
        where: 'id_ordonnance = ?',
        whereArgs: [prescription.idOrdonnance],
      );
      for (final ligne in prescription.medicaments) {
        await txn.insert(
          'lignes_medicaments',
          ligne.toMap(prescription.idOrdonnance),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Récupère toutes les prescriptions avec leurs lignes.
  Future<List<Prescription>> getAllPrescriptions() async {
    final db = await database;
    final prescRows = await db.query('prescriptions');
    final List<Prescription> result = [];

    for (final row in prescRows) {
      final idOrd = row['id_ordonnance'] as int;
      final ligneRows = await db.query(
        'lignes_medicaments',
        where: 'id_ordonnance = ?',
        whereArgs: [idOrd],
      );
      final lignes = ligneRows.map(LigneMedicament.fromMap).toList();
      result.add(Prescription.fromMap(row, lignes));
    }
    return result;
  }

  Future<void> updatePrescription(Prescription prescription) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'prescriptions',
        prescription.toMap(),
        where: 'id_ordonnance = ?',
        whereArgs: [prescription.idOrdonnance],
      );
      await txn.delete(
        'lignes_medicaments',
        where: 'id_ordonnance = ?',
        whereArgs: [prescription.idOrdonnance],
      );
      for (final ligne in prescription.medicaments) {
        await txn.insert(
          'lignes_medicaments',
          ligne.toMap(prescription.idOrdonnance),
        );
      }
    });
  }

  Future<void> deletePrescription(int idOrdonnance) async {
    final db = await database;
    await db.delete(
      'prescriptions',
      where: 'id_ordonnance = ?',
      whereArgs: [idOrdonnance],
    );
  }

  // ─── Utilitaire ───────────────────────────────────────────────────────────

  /// Ferme la connexion (utile en tests).
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
