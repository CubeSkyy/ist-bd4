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

INSERT INTO d_facts(idData, idMeio, idEvento)
  SELECT idData, idMeio, idEvento 
  FROM d_evento, d_meio, d_evento;


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