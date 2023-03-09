
-- Creazione Database 

CREATE DATABASE f1_epicode;

-- Utilizzo Database

USE f1_epicode;

-- Creazione Tabella Circuito

CREATE TABLE circuito(
  id INT PRIMARY KEY,
  nome VARCHAR(50) UNIQUE NOT NULL,
  nazione VARCHAR(50) NOT NULL
)engine=innodb;

-- Creazione Tabella Pilota

CREATE TABLE pilota(
  numero INT PRIMARY KEY,
  full_name VARCHAR(50) UNIQUE NOT NULL,
  nazione VARCHAR(50) NOT NULL,
  data_nascita DATE NOT NULL
)engine=innodb;

-- Creazione Tabella Team

CREATE TABLE teams( 
  nome VARCHAR(50) PRIMARY KEY NOT NULL,
  nazione VARCHAR(50) NOT NULL,
  fondazione YEAR NOT NULL
)engine=innodb;

-- Creazione Tabella Contratto

CREATE TABLE contratto(
  id INT PRIMARY KEY AUTO_INCREMENT,
  numero_pilota INT NOT NULL,
  nome_team VARCHAR(50) NOT NULL,
  compenso_annuale FLOAT NOT NULL,
  durata INT NOT NULL,
  anno_ingaggio YEAR NOT NULL,
  FOREIGN KEY (numero_pilota) REFERENCES pilota(numero),
  FOREIGN KEY (nome_team) REFERENCES teams(nome) 
)engine=innodb;

-- Creazione Tabella Gara

CREATE TABLE gara(
  id_circuito INT NOT NULL,
  posizione_finale INT,
  numero_pilota INT NOT NULL,
  posizione_partenza INT NOT NULL,
  PRIMARY KEY (id_circuito, numero_pilota),
  FOREIGN KEY (id_circuito) REFERENCES circuito(id),
  FOREIGN KEY (numero_pilota) REFERENCES pilota(numero),
)engine=innodb;

-- Creazione Tabella Classifica Piloti

CREATE TABLE classifica_piloti (
    posizione INT UNIQUE NOT NULL,
    numero_pilota INT NOT NULL,
    punti INT NOT NULL,
    PRIMARY KEY (posizione),
    FOREIGN KEY (numero_pilota) REFERENCES pilota(numero)
)engine=innodb;




