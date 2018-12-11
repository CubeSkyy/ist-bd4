CREATE TABLE Camara (
	numcamara SERIAL PRIMARY KEY
);

CREATE TABLE Video(
	datahorainicio TIMESTAMP NOT NULL,
	datahorafim TIMESTAMP NOT NULL,
	numcamara INTEGER NOT NULL REFERENCES Camara(numcamara),
	PRIMARY KEY (datahorainicio, numcamara)
);

CREATE TABLE SegmentoVideo(
	numsegmento SERIAL NOT NULL,
	duracao INTERVAL NOT NULL,
	datahorainicio TIMESTAMP NOT NULL,
	numCamara INTEGER NOT NULL,
	PRIMARY KEY (numsegmento, datahorainicio, numcamara),
	FOREIGN KEY (datahorainicio, numcamara) REFERENCES Video(datahorainicio, numcamara) ON DELETE CASCADE
);

CREATE TABLE Local(
	moradalocal VARCHAR(355) PRIMARY KEY
);

CREATE TABLE Vigia (
	moradalocal VARCHAR(355) NOT NULL REFERENCES Local(moradalocal),
	numcamara INTEGER NOT NULL,
	PRIMARY KEY (moradalocal, numcamara)
);

CREATE TABLE ProcessoSocorro (
	numprocessosocorro SERIAL PRIMARY KEY
);

CREATE TABLE EventoEmergencia (
	numtelefone INT NOT NULL,
	instantechamada TIMESTAMP NOT NULL,
	nomepessoa VARCHAR(255) NOT NULL,
	moradalocal VARCHAR(255) NOT NULL REFERENCES Local (moradalocal),
	numprocessosocorro INTEGER REFERENCES ProcessoSocorro (numprocessosocorro) ON DELETE SET NULL,
	UNIQUE (numtelefone, nomepessoa),
	PRIMARY KEY (numtelefone, instantechamada)
);

CREATE TABLE EntidadeMeio (
	nomeentidade VARCHAR(255) PRIMARY KEY
);

CREATE TABLE Meio (
	nummeio SERIAL NOT NULL,
	nomemeio VARCHAR(255) NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL REFERENCES EntidadeMeio(nomeentidade),
	PRIMARY KEY (nummeio, nomeentidade)
);

CREATE TABLE MeioCombate(
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	PRIMARY KEY (nummeio, nomeentidade),
	FOREIGN KEY (nummeio, nomeentidade) REFERENCES Meio(nummeio, nomeentidade)
);

CREATE TABLE MeioApoio(
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	PRIMARY KEY (nummeio, nomeentidade),
	FOREIGN KEY (nummeio, nomeentidade) REFERENCES Meio(nummeio, nomeentidade)
);

CREATE TABLE MeioSocorro(
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	PRIMARY KEY (nummeio, nomeentidade),
	FOREIGN KEY (nummeio, nomeentidade) REFERENCES Meio(nummeio, nomeentidade)
);

CREATE TABLE Transporta (
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	numvitimas INTEGER NOT NULL DEFAULT 0,
	numprocessosocorro INTEGER NOT NULL REFERENCES ProcessoSocorro(numprocessosocorro),
	PRIMARY KEY (nummeio, nomeentidade, numprocessosocorro),
	FOREIGN KEY (nummeio, nomeentidade) REFERENCES MeioSocorro(nummeio, nomeentidade)
);

CREATE TABLE Alocado (
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	numHoras INTEGER NOT NULL DEFAULT 0,
	numprocessosocorro INTEGER NOT NULL REFERENCES ProcessoSocorro(numprocessosocorro),
	PRIMARY KEY (nummeio, nomeentidade, numprocessosocorro),
	FOREIGN KEY (nummeio, nomeentidade) REFERENCES MeioApoio(nummeio, nomeentidade)
);

CREATE TABLE Acciona(
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	numprocessosocorro INTEGER NOT NULL REFERENCES ProcessoSocorro(numprocessosocorro) ON DELETE CASCADE,
	PRIMARY KEY (nummeio, nomeentidade, numprocessosocorro),
	FOREIGN KEY (nummeio, nomeentidade) REFERENCES Meio(nummeio, nomeentidade)
);

CREATE TABLE Coordenador (
	idcoordenador SERIAL PRIMARY KEY 
);

CREATE TABLE Audita (
	datahorainicio TIME NOT NULL,
	datahorafim TIME NOT NULL,
	dataautoria DATE NOT NULL,
	texto TEXT NOT NULL,
	nummeio SERIAL NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	numprocessosocorro INTEGER NOT NULL,
	idcoordenador SERIAL REFERENCES Coordenador(idcoordenador),
	PRIMARY KEY (nummeio, nomeentidade, numprocessosocorro, idcoordenador),
	FOREIGN KEY (nummeio, nomeentidade, numprocessosocorro) REFERENCES Acciona(nummeio, nomeentidade,numprocessosocorro)
);


CREATE TABLE Solicita (
    datahorainicio TIMESTAMP NOT NULL,
	datahorafim TIMESTAMP NOT NULL,
	numCamara INTEGER NOT NULL,
	datahorainicioVideo TIMESTAMP NOT NULL,
	idcoordenador SERIAL REFERENCES Coordenador(idcoordenador),
	PRIMARY KEY (idcoordenador, datahorainicioVideo, numCamara),
	FOREIGN KEY (datahorainicioVideo, numCamara) REFERENCES Video(datahorainicio, numCamara) ON DELETE CASCADE
);

