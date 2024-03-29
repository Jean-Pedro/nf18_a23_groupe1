DROP TABLE IF EXISTS Users CASCADE;
CREATE TABLE Users
(
    idUser INTEGER PRIMARY KEY,
    login VARCHAR(6) NOT NULL UNIQUE,
    motDePasse VARCHAR(30) NOT NULL,
    type VARCHAR(15),
    CHECK (type IN ('veterinaire', 'assistant', 'client'))
);

DROP TABLE IF EXISTS Admin CASCADE;
CREATE TABLE Admin
(
    idAdmin INTEGER PRIMARY KEY,
    login CHAR(6) NOT NULL,
    motDePasse VARCHAR(30) NOT NULL
);

DROP TABLE IF EXISTS Medicament CASCADE;
CREATE TABLE Medicament (
    nomMol VARCHAR(100) PRIMARY KEY,
    description TEXT NOT NULL,
    quantiteMedicamentJour INTEGER NOT NULL
);

DROP TABLE IF EXISTS Client CASCADE;
CREATE TABLE Client (
    idClient INTEGER PRIMARY KEY REFERENCES Users(idUser),
    infos JSON NOT NULL
);

DROP TABLE IF EXISTS Espece CASCADE;
CREATE TABLE Espece(
    idEspece INTEGER PRIMARY KEY,
    typeEspece VARCHAR(30),
    intitulePrecis VARCHAR(30),
    CHECK (typeEspece IN ('félin', 'canidé','reptile', 'rongeur', 'oiseau', 'autre')),
    CHECK ( NOT (intitulePrecis IS NULL AND typeEspece='autre'))
);

DROP TABLE IF EXISTS Assistant CASCADE;
CREATE TABLE Assistant (
    idAssist INTEGER PRIMARY KEY REFERENCES Users(idUser),
    infos JSON,
    specialite INTEGER REFERENCES Espece(idEspece)
);

DROP TABLE IF EXISTS Animal CASCADE;
CREATE TABLE Animal (
    idAnimal INTEGER PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    numPuceId INTEGER,
    numPasseport INTEGER,
    taille VARCHAR(7) NOT NULL,
    espece INTEGER REFERENCES Espece NOT NULL,
    CHECK (taille in ('petite', 'moyenne', 'autre'))
);

DROP TABLE IF EXISTS Veterinaire CASCADE;
CREATE TABLE Veterinaire (
    idVet INTEGER PRIMARY KEY REFERENCES Users(idUser),
    infos JSON,
    specialite INTEGER REFERENCES Espece(idEspece)
);

DROP TABLE IF EXISTS DossierMedical CASCADE;
CREATE TABLE DossierMedical (
    idDossier INTEGER PRIMARY KEY,
    mesureTaille INTEGER,
    mesurePoids INTEGER,
    debutTraitement DATE NOT NULL,
    dureeTraitement INTEGER NOT NULL,
    ObservationGenerale TEXT NOT NULL,
    descriptionProcedure TEXT NOT NULL,
    saisie DATE NOT NULL,
    animal INTEGER REFERENCES Animal(idAnimal) NOT NULL,
    veterinairePrescripteur INTEGER REFERENCES Veterinaire(idVet) NOT NULL,
    resultatAnalyse JSON,
    CHECK (mesureTaille IS NOT NULL OR mesurePoids IS NOT NULL)
);


DROP TABLE IF EXISTS AFaitVet CASCADE;
CREATE TABLE AFaitVet(
	veterinaire INTEGER REFERENCES Veterinaire(idVet),
	dossier INTEGER REFERENCES DossierMedical(idDossier),
	PRIMARY KEY (veterinaire, dossier)
);

DROP TABLE IF EXISTS AFaitAssist CASCADE;
CREATE TABLE AFaitAssist(
	assistant INTEGER REFERENCES Assistant(idAssist),
	dossier INTEGER REFERENCES DossierMedical(idDossier),
	PRIMARY KEY (assistant, dossier)
);

DROP TABLE IF EXISTS ContientMedicDoss CASCADE;
CREATE TABLE ContientMedicDoss(
	medicament VARCHAR(100) REFERENCES Medicament(nomMol),
	dossier INTEGER REFERENCES DossierMedical(idDossier),
	PRIMARY KEY (medicament, dossier)
);


DROP TABLE IF EXISTS autorisePour CASCADE;
CREATE TABLE autorisePour (
    medicament VARCHAR(11) REFERENCES Medicament(nomMol),
    espece INTEGER REFERENCES Espece(idEspece),
    PRIMARY KEY (medicament, espece)
);

DROP TABLE IF EXISTS EstSuiviPar CASCADE;
CREATE TABLE EstSuiviPar (
    animal INTEGER REFERENCES Animal(idAnimal),
    veterinaire INTEGER REFERENCES Veterinaire(idVet),
    debut DATE NOT NULL,
    fin DATE,
    PRIMARY KEY (animal, veterinaire)
);
-- On pensera à vérifier la contrainte complexe de minimalité dans la couche applicative'

DROP TABLE IF EXISTS EstPossedePar CASCADE;
CREATE TABLE EstPossedePar(
    animal INTEGER REFERENCES Animal(idAnimal),
    client INTEGER REFERENCES Client(idClient),
    debut DATE NOT NULL,
    fin DATE,
    PRIMARY KEY (animal, client)
);

-- Vue pour les statistiques de consommation de médicaments
CREATE VIEW quantiteMedicamentConsommee AS
SELECT M.nomMol, sum(M.quantiteMedicamentJour*DM.dureeTraitement) AS quantiteTotaleConsommee
FROM ContientMedicDoss AS CMD
JOIN DossierMedical AS DM ON CMD.dossier = DM.idDossier
JOIN Medicament AS M ON CMD.medicament = M.nomMol
GROUP BY M.nomMol;



INSERT INTO Users (idUser, login, motDePasse, type) VALUES(1, 'user1', '123456789', 'client');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(2, 'user2', '123456789', 'client');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(3, 'user3', '123456789', 'client');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(4, 'user4', '123456789', 'client');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(5, 'user5', '123456789', 'client');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(6, 'user6', '123456789', 'client');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(7, 'user7', '123456789', 'assistant');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(8, 'user8', '123456789', 'assistant');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(9, 'user9', '123456789', 'assistant');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(10, 'user10', '123456789', 'veterinaire');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(11, 'user11', '123456789', 'veterinaire');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(12, 'user12', '123456789', 'veterinaire');
INSERT INTO Users (idUser, login, motDePasse, type) VALUES(13, 'user13', '123456789', 'veterinaire');

INSERT INTO Admin (idAdmin, login, motDePasse ) VALUES(1, 'admin', '123');

--  Medicaments

INSERT INTO Medicament (nomMol, description, quantiteMedicamentJour) VALUES ('amoxicillin', 'Antibiotique à effet général', 1);

INSERT INTO Medicament (nomMol, description, quantiteMedicamentJour) VALUES ('paracetamol', 'Antidouleur miraculeux', 2);

INSERT INTO Medicament (nomMol, description, quantiteMedicamentJour) VALUES ('GSE', 'Désinfectant, utile das le cas de grippe aviaire', 50);


-- Clients

INSERT INTO Client (idClient, infos) VALUES (1, '{"nom" : "Darmanin", "prenom" : "Gérald", "dateNaissance" : "1982-10-11", "adresse" : "Hôtel de Beauvau, Paris", "tel" : "0607080910"}');

INSERT INTO Client (idClient, infos) VALUES (2, '{"nom" : "Borne", "prenom" : "Elizabeth", "dateNaissance" : "1961-04-18", "adresse" : "Hôtel de Matignon, Paris 7ème", "tel" : "0607883911"}');

INSERT INTO Client (idClient, infos) VALUES (3, '{"nom" : "Macron", "prenom" : "Emmanuel", "dateNaissance" : "1977-12-21", "adresse" : "Palais de l Elysee, Paris 8ème", "tel" : "0907688920"}');

INSERT INTO Client (idClient, infos) VALUES (4, '{"nom" : "Béchu", "prenom" : "Christophe", "dateNaissance" : "1974-06-11", "adresse" : "Hôtel de Roquelaure, 246, boulevard Saint-Germain, Paris 7ème", "tel" : "0589748945"}');

INSERT INTO Client (idClient, infos) VALUES (5, '{"nom" : "Béchu", "prenom" : "Marie-Hortense", "dateNaissance" : "1977-08-02", "adresse" : "Hôtel de Roquelaure, 246, boulevard Saint-Germain, Paris 7ème", "tel" : "0543748288"}');

INSERT INTO Client (idClient, infos) VALUES (6, '{"nom" : "Retailleau", "prenom" : "Sylvie", "dateNaissance" : "1965-02-24", "adresse" : "Pavillon Boncourt, 21 rue Descartes, Paris 5ème", "tel" : "0523848728"}');


-- Espece

INSERT INTO Espece (idEspece, typeEspece, intitulePrecis) VALUES (1, 'canidé', 'Croisé Labrador ');

INSERT INTO Espece (idEspece, typeEspece, intitulePrecis) VALUES (2, 'autre', 'Panda');

INSERT INTO Espece (idEspece, typeEspece, intitulePrecis) VALUES (3, 'félin', 'chat');

INSERT INTO Espece (idEspece, typeEspece, intitulePrecis) VALUES (4, 'oiseau', 'Perruche');


-- Assistants

INSERT INTO Assistant (idAssist, infos, specialite) VALUES (7, '{"nom" : "Renaud", "prenom" : "Augustin", "dateNaissance" : "1965-02-24", "adresse" : "124 Rue de Paris", "tel" : "0685159675"}', 1);

INSERT INTO Assistant (idAssist, infos, specialite) VALUES (8, '{"nom" : "Eberhardt", "prenom" : "Alexandre", "dateNaissance" : "1965-02-25", "adresse" : "12 rue des fleurs", "tel" : "0684559671"}', 4);

INSERT INTO Assistant (idAssist, infos, specialite) VALUES (9, '{"nom" : "Fouinat", "prenom" : "Quentin", "dateNaissance" : "1965-02-26", "adresse" : "34 avenue du Port", "tel" : "0645627891"}', 2);

-- Animal

INSERT INTO Animal (idAnimal, nom, espece, numPuceId, numPasseport, taille) VALUES (1, 'Nemo', 1, 111111, 123456, 'petite');

INSERT INTO Animal (idAnimal, nom, espece, numPuceId, numPasseport, taille) VALUES (2, 'Dori', 2, 111111, 123456, 'moyenne');

INSERT INTO Animal (idAnimal, nom, espece, numPuceId, numPasseport, taille) VALUES (3, 'Bubu', 4, 020304, 968574, 'petite');

INSERT INTO Animal (idAnimal, nom, espece, numPuceId, numPasseport, taille) VALUES (4, 'fifi', 3, 020323, 966574, 'petite');


-- Veterinaires

INSERT INTO Veterinaire (idVet, infos, specialite) VALUES (10, '{"nom" : "Pontoire", "prenom" : "Julien", "dateNaissance" : "2003-12-01", "adresse" : "36 Rue de l''Eglise", "tel" : "0632458956"}', 1);

INSERT INTO Veterinaire (idVet, infos, specialite) VALUES (11, '{"nom" : "Biffe", "prenom" : "Simon", "dateNaissance" : "2003-12-02", "adresse" : "25 Avenue de la Gare", "tel" : "0645769512"}', 4);

INSERT INTO Veterinaire (idVet, infos, specialite) VALUES (12, '{"nom" : "Vital", "prenom" : "Simon", "dateNaissance" : "2003-12-03", "adresse" : "12 Rue de Paris", "tel" : "0745126398"}', 2);

INSERT INTO Veterinaire (idVet, infos, specialite) VALUES (13, '{"nom" : "Ragot", "prenom" : "Nils", "dateNaissance" : "2003-12-04", "adresse" : "15 rue d''Amiens", "tel" : "0745864297"}', 2);


-- DossierMédical

INSERT INTO DossierMedical (idDossier, mesureTaille, mesurePoids, debutTraitement, dureeTraitement, ObservationGenerale, descriptionProcedure, saisie, animal, veterinairePrescripteur, resultatAnalyse) VALUES (1, 10, 5, '2003-12-04', 20, 'Blessure à la patte', 'Guérir la patte', '2003-12-03', 1, 10, '["https://messuperresultats.com/z5VytYNpQJJYY6D-gUq13A"]');

INSERT INTO DossierMedical (idDossier, mesureTaille, mesurePoids, debutTraitement, dureeTraitement, ObservationGenerale, descriptionProcedure, saisie, animal, veterinairePrescripteur, resultatAnalyse) VALUES (2, 100, 50, '2004-12-04', 30, 'Blessure à la tête', 'Guérir la tête', '2004-12-03', 2, 10, '["https://messuperresultats.com/z5VytYNpQJJYY6D-gUq13A", "https://messuperresultats.com/z5VCTRYJQJJYY6D-gU236A", "https://messuperresultats.com/z5VytYNpSS682F-h5613A"]');

INSERT INTO DossierMedical (idDossier, mesureTaille, mesurePoids, debutTraitement, dureeTraitement, ObservationGenerale, descriptionProcedure, saisie, animal, veterinairePrescripteur, resultatAnalyse) VALUES (3, 100, 50, '2013-01-04', 10, 'Puce', 'Appliquer le produit anti-puce', '2013-12-03', 3, 12, '["https://messuperresultats.com/z5FT486965DERHTD6YY6D-gUq13A", "https://messuperresultats.com/DRTYFTKU849HTYF5-u8563A"]');




-- AFaitVet

INSERT INTO AFaitVet (veterinaire, dossier) VALUES (10, 1);

INSERT INTO AFaitVet (veterinaire, dossier) VALUES (11, 2);

INSERT INTO AFaitVet (veterinaire, dossier) VALUES (11, 3);

INSERT INTO AFaitVet (veterinaire, dossier) VALUES (12, 3);


-- AFaitAssist

INSERT INTO AFaitAssist (assistant, dossier) VALUES (7, 3);

INSERT INTO AFaitAssist (assistant, dossier) VALUES (8, 2);

INSERT INTO AFaitAssist (assistant, dossier) VALUES (9, 1);


-- ContientMedicDoss

INSERT INTO ContientMedicDoss (medicament, dossier) VALUES ('paracetamol', 1);

INSERT INTO ContientMedicDoss (medicament, dossier) VALUES ('paracetamol', 2);

INSERT INTO ContientMedicDoss (medicament, dossier) VALUES ('amoxicillin', 2);

INSERT INTO ContientMedicDoss (medicament, dossier) VALUES ('paracetamol', 3);


-- autorisePour

INSERT INTO AutorisePour (medicament, espece) VALUES ('amoxicillin', 3);

INSERT INTO AutorisePour (medicament, espece) VALUES ('paracetamol', 1);

INSERT INTO AutorisePour (medicament, espece) VALUES ('paracetamol', 2);

INSERT INTO AutorisePour (medicament, espece) VALUES ('paracetamol', 4);

INSERT INTO AutorisePour (medicament, espece) VALUES ('paracetamol', 3);

INSERT INTO AutorisePour (medicament, espece) VALUES ('GSE', 4);


-- EstSuiviPar

INSERT INTO EstSuiviPar (animal, veterinaire, debut, fin) VALUES (1, 10, '2023-11-10', '2023-11-13');

INSERT INTO EstSuiviPar (animal, veterinaire, debut, fin) VALUES (2, 12, '2022-10-11', '2023-11-13');

INSERT INTO EstSuiviPar (animal, veterinaire, debut, fin) VALUES (3, 11, '2012-12-13', '2020-01-20');

INSERT INTO EstSuiviPar (animal, veterinaire, debut, fin) VALUES (3, 13, '2020-01-21', '2023-11-13');

INSERT INTO EstSuiviPar (animal, veterinaire, debut, fin) VALUES (4, 13, '2016-06-30', '2020-10-10');


-- EstPossedePar

INSERT INTO EstPossedePar (animal, client, debut, fin) VALUES (1, 3, '2017-08-27', '2023-11-13');

INSERT INTO EstPossedePar (animal, client, debut, fin) VALUES (2, 1, '2017-08-27', '2023-11-13');

INSERT INTO EstPossedePar (animal, client, debut, fin) VALUES (3, 3, '2014-09-24', '2022-10-08');

INSERT INTO EstPossedePar (animal, client, debut, fin) VALUES (4, 1, '2013-02-24', '2017-11-18');
