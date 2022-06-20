CREATE TABLE d_evento ( --SELECT DE EVENTOS
  idEvento SERIAL PRIMARY KEY,
  numtelefone INT NOT NULL,
	instantechamada TIMESTAMP NOT NULL
);


CREATE TABLE d_meio ( --3 SELECTS
-- PARA APOIO,COMBATE,SOCORRO + 1 SELECT PARA MEIOS COM AQUELES QUE ESTAO EM MEIOS MAS NAO ESTAO
  idMeio SERIAL PRIMARY KEY,  --EM APOIO,COMBATE,SOCORRO
	nummeio SERIAL NOT NULL,
	nomemeio VARCHAR(255) NOT NULL,
	nomeentidade VARCHAR(255) NOT NULL,
	tipo VARCHAR(255)
);


CREATE TABLE d_tempo ( -- FUNÇAO PARA FAZER LOOP COM TODAS AS DATAS DESTE ANO MAIS ANTIGO ATE ANO ACTUAL.
  idData SERIAL PRIMARY KEY,
  dia INTEGER,
  mes INTEGER,
  ano INTEGER
);


CREATE TABLE d_facts ( --SELECT DE ACCIONA
  idFact SERIAL PRIMARY KEY,
  idEvento SERIAL REFERENCES d_evento(idEvento),
  idMeio SERIAL REFERENCES d_meio(idMeio),
  idData SERIAL REFERENCES d_tempo(idData)
);