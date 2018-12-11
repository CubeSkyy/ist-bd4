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
  idTempo SERIAL PRIMARY KEY,
  dia INTEGER,
  mes INTEGER,
  ano INTEGER
);


CREATE TABLE facts ( --SELECT DE ACCIONA
  idFact SERIAL PRIMARY KEY,
  idEvento INTEGER REFERENCES d_evento(idEvento),
  idMeio INTEGER REFERENCES d_meio(idMeio),
  idTempo INTEGER REFERENCES d_tempo(idTempo)
);

INSERT INTO d_evento(numtelefone, instantechamada)
  SELECT numtelefone, instantechamada
  FROM eventoemergencia;

INSERT INTO d_meio(nummeio, nomemeio, nomeentidade, tipo)
  SELECT nummeio, nomemeio, nomeentidade, 'Apoio'
  FROM meioapoio NATURAL JOIN meio;

INSERT INTO d_meio(nummeio, nomemeio, nomeentidade, tipo)
  SELECT nummeio, nomemeio, nomeentidade, 'Combate'
  FROM meiocombate NATURAL JOIN meio;

INSERT INTO d_meio(nummeio, nomemeio, nomeentidade, tipo)
  SELECT nummeio, nomemeio, nomeentidade, 'Socorro'
  FROM meiosocorro NATURAL JOIN meio;

INSERT INTO d_meio(nummeio, nomemeio, nomeentidade, tipo)
  SELECT nummeio, nomemeio, nomeentidade, NULL
  FROM meio
  WHERE (nummeio, nomeentidade) NOT IN (
  SELECT * FROM meioapoio
  UNION
  SELECT * FROM meiosocorro
  UNION
  SELECT * FROM meiocombate
  );


CREATE OR REPLACE FUNCTION populateTempo()
  RETURNS VOID AS
  $$
  DECLARE
    date DATE;
    duration INTERVAL;
    test varchar(255);
  BEGIN
    duration := '24 HOURS';
    SELECT EXTRACT( year from min(instantechamada)) INTO test FROM eventoemergencia;
    date := test || '-01-01';

     LOOP
     exit when date = '2019-01-01';
     INSERT INTO d_tempo(dia,mes,ano)
     VALUES (EXTRACT(day from date),EXTRACT(month from date),EXTRACT(year from date));
     date:= date + duration;
     end loop;

  END
  $$ LANGUAGE plpgsql;