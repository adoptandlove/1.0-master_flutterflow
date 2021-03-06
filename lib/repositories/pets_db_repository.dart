import 'dart:convert';

import 'package:adoptandlove/pets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:streamqflite/streamqflite.dart';

class PetsDBRepository {
  static StreamDatabase _db;

  static final PetsDBRepository _instance = new PetsDBRepository.internal();

  factory PetsDBRepository() => _instance;

  static const _tableShelters = "Shelters";
  static const _columnShelterId = "shelter_id";
  static const _columnShelterName = "shelter_name";
  static const _columnShelterEmail = "shelter_email";
  static const _columnShelterPhone = "shelter_phone";

  static const _tablePets = "Pets";
  static const _columnPetId = "pet_id";
  static const _columnPetShelterId = "pet_shelter_id";
  static const _columnPetAvailable = "pet_available";
  static const _columnPetType = "pet_type";
  static const _columnPetProfilePhoto = "pet_profile_photo";
  static const _columnPetName = "pet_name";
  static const _columnPetShortDescription = "pet_short_description";
  static const _columnPetDescription = "pet_description";
  static const _columnPetPhotosJson = "pet_photos_json";

  static const _tablePetChoices = "PetChoices";
  static const _columnPetChoicesId = "pet_choice_id";
  static const _columnPetChoicesPetId = "pet_choice_pet_id";
  static const _columnPetChoicesChoice = "pet_choice_choice";
  static const _columnPetChoicesCreatedAt = "pet_choice_created_at";

  static const _indexPetChoicesPetId = "index_PetChoices_pet_id";
  static const _indexPetChoicesChoice = "index_PetChoices_choice";

  static const _petDecisionNumDislike = 1;
  static const _petDecisionNumLike = 2;
  static const _petDecisionNumGetPet = 3;

  PetsDBRepository.internal();

  Future initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'getpet-pets.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _db = StreamDatabase(db);
  }

  Future _onCreate(Database db, int newVersion) async {
    await db.execute("""
CREATE TABLE IF NOT EXISTS `$_tableShelters` (
  `$_columnShelterId` INTEGER NOT NULL, 
  `$_columnShelterName` TEXT NOT NULL, 
  `$_columnShelterEmail` TEXT NOT NULL, 
  `$_columnShelterPhone` TEXT NOT NULL, 
  PRIMARY KEY(`$_columnShelterId`)
);
""");

    await db.execute("""
CREATE TABLE IF NOT EXISTS `$_tablePets` (
  `$_columnPetId` INTEGER NOT NULL,
  `$_columnPetShelterId` INTEGER NOT NULL,
  `$_columnPetName` TEXT NOT NULL,
  `$_columnPetAvailable` INTEGER NOT NULL,
  `$_columnPetType` INTEGER NOT NULL,
  `$_columnPetProfilePhoto` TEXT NOT NULL,
  `$_columnPetShortDescription` TEXT NOT NULL,
  `$_columnPetDescription` TEXT NOT NULL,
  `$_columnPetPhotosJson` TEXT NOT NULL,
  PRIMARY KEY(`$_columnPetId`),
  FOREIGN KEY(`$_columnPetShelterId`) REFERENCES `$_tableShelters`(`$_columnShelterId`) ON UPDATE NO ACTION ON DELETE CASCADE
);
""");

    await db.execute("""
CREATE TABLE IF NOT EXISTS `$_tablePetChoices` (
  `$_columnPetChoicesId` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  `$_columnPetChoicesPetId` INTEGER NOT NULL,
  `$_columnPetChoicesChoice` INTEGER NOT NULL,
  `$_columnPetChoicesCreatedAt` INTEGER NOT NULL,
  FOREIGN KEY(`$_columnPetChoicesPetId`) REFERENCES `$_tablePets`(`$_columnPetId`) ON UPDATE NO ACTION ON DELETE CASCADE
);
""");

    await db.execute("""
CREATE UNIQUE INDEX `$_indexPetChoicesPetId` ON `$_tablePetChoices` (`$_columnPetChoicesPetId`);
""");

    await db.execute("""
CREATE INDEX `$_indexPetChoicesChoice` ON `$_tablePetChoices` (`$_columnPetChoicesChoice`);
      """);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion == 2) {
      await db.execute("""
      ALTER TABLE `$_tablePets` ADD COLUMN `$_columnPetType` INTEGER NOT NULL DEFAULT ${PetType.dog.dbRepresentation};
""");
    }
  }

  Map<String, dynamic> _getShelterMap(Shelter shelter, bool includePetId) {
    Map<String, dynamic> m = {
      _columnShelterName: shelter.name,
      _columnShelterEmail: shelter.email,
      _columnShelterPhone: shelter.phone,
    };

    if (includePetId) {
      m[_columnShelterId] = shelter.id;
    }

    return m;
  }

  Future insertOrUpdateShelters(List<Shelter> shelters) async {
    if (shelters.isEmpty) {
      return [];
    }

    var batch = _db.batch();

    shelters.forEach(
      (shelter) => batch.insert(
        _tableShelters,
        _getShelterMap(shelter, true),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      ),
    );

    await batch.commit(noResult: true);

    return await updateShelters(shelters);
  }

  Future updateShelters(List<Shelter> shelters) async {
    if (shelters.isEmpty) {
      return [];
    }

    var batch = _db.batch();

    shelters.forEach(
      (shelter) => batch.update(
        _tableShelters,
        _getShelterMap(shelter, false),
        where: '$_columnShelterId = ?',
        whereArgs: [shelter.id],
      ),
    );

    return await batch.commit(noResult: true);
  }

  Future removePetsWithoutChoice() async {
    return await _db.rawQuery(""" 
DELETE FROM 
  $_tablePets 
WHERE $_columnPetId IN (
  SELECT $_columnPetId
  FROM $_tablePets 
  LEFT JOIN $_tablePetChoices ON $_tablePets.$_columnPetId = $_tablePetChoices.$_columnPetChoicesPetId 
  WHERE $_tablePetChoices.$_columnPetChoicesPetId IS NULL
);
""");
  }

  Map<String, dynamic> _getPetMap(Pet pet, bool includePetId) {
    Map<String, dynamic> m = {
      _columnPetShelterId: pet.shelter.id,
      _columnPetAvailable: pet.available ? 1 : 0,
      _columnPetProfilePhoto: pet.profilePhoto,
      _columnPetName: pet.name,
      _columnPetType: pet.petType.dbRepresentation,
      _columnPetShortDescription: pet.shortDescription,
      _columnPetDescription: pet.description,
      _columnPetPhotosJson: jsonEncode(
        pet.photos.map((photo) => photo.photo).toList(),
      ),
    };

    if (includePetId) {
      m[_columnPetId] = pet.id;
    }

    return m;
  }

  Future insertPets(List<Pet> pets) async {
    if (pets.isEmpty) {
      return [];
    }

    var shelters = pets.map((p) => p.shelter).toSet().toList(growable: false);
    await this.insertOrUpdateShelters(shelters);

    var batch = _db.batch();

    pets.forEach(
      (pet) => batch.insert(
        _tablePets,
        _getPetMap(pet, true),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      ),
    );
    await batch.commit(noResult: true);
  }

  Future updatePets(List<Pet> pets) async {
    if (pets.isEmpty) {
      return [];
    }

    var shelters = pets.map((p) => p.shelter).toSet().toList(growable: false);
    await this.insertOrUpdateShelters(shelters);

    var batch = _db.batch();

    pets.forEach(
      (pet) => batch.update(
        _tablePets,
        _getPetMap(pet, false),
        where: '$_columnPetId = ?',
        whereArgs: [pet.id],
      ),
    );
    await batch.commit(noResult: true);
  }

  Future insertPetChoice(Pet pet, PetDecision decision) async {
    var decisionNumber;
    switch (decision) {
      case PetDecision.dislike:
        decisionNumber = _petDecisionNumDislike;
        break;
      case PetDecision.like:
        decisionNumber = _petDecisionNumLike;
        break;
      case PetDecision.getPet:
        decisionNumber = _petDecisionNumGetPet;
        break;
      default:
        decisionNumber = null;
    }
    if (decisionNumber != null) {
      _db.insert(
        _tablePetChoices,
        {
          _columnPetChoicesPetId: pet.id,
          _columnPetChoicesChoice: decisionNumber,
          _columnPetChoicesCreatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Shelter _mapToShelter(Map map) {
    return Shelter(
      id: map[_columnShelterId],
      name: map[_columnShelterName],
      email: map[_columnShelterEmail],
      phone: map[_columnShelterPhone],
    );
  }

  Pet _mapToPet(Map map) {
    var photos = (jsonDecode(map[_columnPetPhotosJson]) as List)
        .map((p) => p as String)
        .map<PetPhoto>((p) => PetPhoto(
              photo: p,
            ))
        .toList(growable: false);

    var decisionRaw = map[_columnPetChoicesChoice];
    PetDecision decision;
    switch (decisionRaw) {
      case _petDecisionNumLike:
        decision = PetDecision.like;
        break;
      case _petDecisionNumDislike:
        decision = PetDecision.dislike;
        break;
      case _petDecisionNumGetPet:
        decision = PetDecision.getPet;
        break;
      default:
        decision = null;
    }

    return Pet(
      id: map[_columnPetId],
      name: map[_columnPetName],
      shortDescription: map[_columnPetShortDescription],
      description: map[_columnPetDescription],
      photos: photos,
      profilePhoto: map[_columnPetProfilePhoto],
      petType: _mapDBRepresentationToPetType(map[_columnPetType]),
      shelter: _mapToShelter(map),
      decision: decision,
      available: map[_columnPetAvailable] == 1 ? true : false,
    );
  }

  static PetType _mapDBRepresentationToPetType(int r) {
    switch (r) {
      case 1:
        return PetType.dog;
      case 2:
        return PetType.cat;
      default:
        throw ArgumentError("Unable to map $r to Pet representation");
    }
  }

  List<Pet> _mapToPets(List<Map> listOfMaps) {
    return listOfMaps.map((m) => _mapToPet(m)).toList(growable: false);
  }

  Stream<List<Pet>> getPetsFavorites() {
    return _db.createRawQuery([_tablePets, _tablePetChoices], """ 
SELECT 
  $_tablePets.*,
  $_tableShelters.*,
  $_tablePetChoices.*
FROM 
  $_tablePets 
  INNER JOIN $_tableShelters ON $_tablePets.$_columnPetShelterId = $_tableShelters.$_columnShelterId 
  INNER JOIN $_tablePetChoices ON $_tablePets.$_columnPetId = $_tablePetChoices.$_columnPetChoicesPetId 
  AND $_tablePetChoices.$_columnPetChoicesChoice IN (
    $_petDecisionNumLike, $_petDecisionNumGetPet
  )
WHERE $_tablePets.$_columnPetAvailable = 1 
ORDER BY 
  $_tablePetChoices.$_columnPetChoicesCreatedAt DESC;
    """).asyncMap((query) => query()).map((rows) => _mapToPets(rows));
  }

  Future<List<int>> getFavoritePetIds() async {
    var petsMap = await _db.rawQuery(""" 
SELECT 
  $_tablePets.$_columnPetId
FROM 
  $_tablePets 
  INNER JOIN $_tablePetChoices ON $_tablePets.$_columnPetId = $_tablePetChoices.$_columnPetChoicesPetId 
  AND $_tablePetChoices.$_columnPetChoicesChoice IN (
    $_petDecisionNumLike, $_petDecisionNumGetPet
  )
    """);

    return petsMap
        .map((map) => map[_columnPetId] as int)
        .toList(growable: false);
  }

  Future<List<int>> getDislikedPetIds() async {
    var petsMap = await _db.rawQuery(""" 
SELECT 
  $_tablePets.$_columnPetId
FROM 
  $_tablePets 
  INNER JOIN $_tablePetChoices ON $_tablePets.$_columnPetId = $_tablePetChoices.$_columnPetChoicesPetId 
  AND $_tablePetChoices.$_columnPetChoicesChoice = $_petDecisionNumDislike
    """);

    return petsMap
        .map((map) => map[_columnPetId] as int)
        .toList(growable: false);
  }

  Future dispose() async {
    if (_db != null && _db.isOpen) {
      await _db.close();
      _db = null;
    }
  }
}
