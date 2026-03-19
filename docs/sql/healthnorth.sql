-- phpMyAdmin SQL

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";



--
-- Base de données : `healthnorth`
--

-- --------------------------------------------------------

--
-- Structure de la table `api_token`
--

DROP TABLE IF EXISTS `api_token`;
CREATE TABLE IF NOT EXISTS `api_token` (
  `id_token` int NOT NULL AUTO_INCREMENT,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_creation` datetime DEFAULT CURRENT_TIMESTAMP,
  `id_patient` int NOT NULL,
  `role` enum('patient','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'patient',
  PRIMARY KEY (`id_token`),
  KEY `fk_token_patient` (`id_patient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dossier_patient`
--

DROP TABLE IF EXISTS `dossier_patient`;
CREATE TABLE IF NOT EXISTS `dossier_patient` (
  `id_dossier` int NOT NULL AUTO_INCREMENT,
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `personne_a_contacter` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medecin_traitant` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_patient` int NOT NULL,
  PRIMARY KEY (`id_dossier`),
  UNIQUE KEY `id_patient` (`id_patient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `etablissement`
--

DROP TABLE IF EXISTS `etablissement`;
CREATE TABLE IF NOT EXISTS `etablissement` (
  `id_etablissement` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adresse` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_etablissement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ligne_ordonnance`
--

DROP TABLE IF EXISTS `ligne_ordonnance`;
CREATE TABLE IF NOT EXISTS `ligne_ordonnance` (
  `id_ligne` int NOT NULL AUTO_INCREMENT,
  `medicament` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `frequence` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duree` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_ordonnance` int NOT NULL,
  PRIMARY KEY (`id_ligne`),
  KEY `fk_ligne_ord` (`id_ordonnance`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `option_patient`
--

DROP TABLE IF EXISTS `option_patient`;
CREATE TABLE IF NOT EXISTS `option_patient` (
  `id_option` int NOT NULL AUTO_INCREMENT,
  `libelle` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `valeur` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `id_patient` int NOT NULL,
  PRIMARY KEY (`id_option`),
  KEY `fk_option_patient` (`id_patient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ordonnance`
--

DROP TABLE IF EXISTS `ordonnance`;
CREATE TABLE IF NOT EXISTS `ordonnance` (
  `id_ordonnance` int NOT NULL AUTO_INCREMENT,
  `date_ordonnance` date NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `id_patient` int NOT NULL,
  PRIMARY KEY (`id_ordonnance`),
  KEY `fk_ord_patient` (`id_patient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `patient`
--

DROP TABLE IF EXISTS `patient`;
CREATE TABLE IF NOT EXISTS `patient` (
  `id_patient` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `num_secu` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telephone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `personne_a_contacter` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medecin_traitant` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mot_de_passe` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_patient`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `num_secu` (`num_secu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `rappel_medicament`
--

DROP TABLE IF EXISTS `rappel_medicament`;
CREATE TABLE IF NOT EXISTS `rappel_medicament` (
  `id_rappel` int NOT NULL AUTO_INCREMENT,
  `heure` time NOT NULL,
  `actif` tinyint(1) DEFAULT '1',
  `id_patient` int NOT NULL,
  `id_ligne` int DEFAULT NULL,
  PRIMARY KEY (`id_rappel`),
  KEY `fk_rappel_patient` (`id_patient`),
  KEY `fk_rappel_ligne` (`id_ligne`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `rendez_vous`
--

DROP TABLE IF EXISTS `rendez_vous`;
CREATE TABLE IF NOT EXISTS `rendez_vous` (
  `id_rdv` int NOT NULL AUTO_INCREMENT,
  `date_rdv` date NOT NULL,
  `heure_rdv` time NOT NULL,
  `statut` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_patient` int NOT NULL,
  `id_specialiste` int NOT NULL,
  `id_etablissement` int NOT NULL,
  `id_type` int DEFAULT NULL,
  PRIMARY KEY (`id_rdv`),
  KEY `fk_rdv_patient` (`id_patient`),
  KEY `fk_rdv_specialiste` (`id_specialiste`),
  KEY `fk_rdv_etablissement` (`id_etablissement`),
  KEY `fk_rdv_type` (`id_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `specialiste`
--

DROP TABLE IF EXISTS `specialiste`;
CREATE TABLE IF NOT EXISTS `specialiste` (
  `id_specialiste` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `specialite` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_specialiste`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `type_intervention`
--

DROP TABLE IF EXISTS `type_intervention`;
CREATE TABLE IF NOT EXISTS `type_intervention` (
  `id_type` int NOT NULL AUTO_INCREMENT,
  `libelle` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_type`),
  UNIQUE KEY `libelle` (`libelle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `api_token`
--
ALTER TABLE `api_token`
  ADD CONSTRAINT `fk_token_patient` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id_patient`) ON DELETE CASCADE;

--
-- Contraintes pour la table `dossier_patient`
--
ALTER TABLE `dossier_patient`
  ADD CONSTRAINT `fk_dossier_patient` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id_patient`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ligne_ordonnance`
--
ALTER TABLE `ligne_ordonnance`
  ADD CONSTRAINT `fk_ligne_ord` FOREIGN KEY (`id_ordonnance`) REFERENCES `ordonnance` (`id_ordonnance`) ON DELETE CASCADE;

--
-- Contraintes pour la table `option_patient`
--
ALTER TABLE `option_patient`
  ADD CONSTRAINT `fk_option_patient` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id_patient`) ON DELETE CASCADE;

--
-- Contraintes pour la table `ordonnance`
--
ALTER TABLE `ordonnance`
  ADD CONSTRAINT `fk_ord_patient` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id_patient`) ON DELETE CASCADE;

--
-- Contraintes pour la table `rappel_medicament`
--
ALTER TABLE `rappel_medicament`
  ADD CONSTRAINT `fk_rappel_ligne` FOREIGN KEY (`id_ligne`) REFERENCES `ligne_ordonnance` (`id_ligne`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_rappel_patient` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id_patient`) ON DELETE CASCADE;

--
-- Contraintes pour la table `rendez_vous`
--
ALTER TABLE `rendez_vous`
  ADD CONSTRAINT `fk_rdv_etablissement` FOREIGN KEY (`id_etablissement`) REFERENCES `etablissement` (`id_etablissement`),
  ADD CONSTRAINT `fk_rdv_patient` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id_patient`),
  ADD CONSTRAINT `fk_rdv_specialiste` FOREIGN KEY (`id_specialiste`) REFERENCES `specialiste` (`id_specialiste`),
  ADD CONSTRAINT `fk_rdv_type` FOREIGN KEY (`id_type`) REFERENCES `type_intervention` (`id_type`);
COMMIT;

