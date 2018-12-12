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

INSERT INTO d_facts(idevento, idmeio, iddata)
WITH temp as (
     SELECT *, EXTRACT(day from instantechamada) as dia,  EXTRACT(month from instantechamada) as mes, EXTRACT(year from instantechamada) as ano
     FROM acciona NATURAL JOIN eventoemergencia

    )

SELECT idevento, idmeio, iddata FROM temp NATURAL  JOIN d_evento NATURAL JOIN d_meio NATURAL JOIN d_tempo;


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

SELECT populatetempo();

--ULTIMA QUERRY

SELECT tipo, ano, mes, count(idmeio)
FROM d_facts NATURAL JOIN d_evento NATURAL JOIN d_meio NATURAL JOIN d_tempo
WHERE idevento = 15
GROUP BY ROLLUP(tipo, ano, mes)
ORDER BY tipo, ano, mes;