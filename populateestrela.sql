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

SELECT populatetempo();



CREATE OR REPLACE FUNCTION public.d_meio_numprocessosocorro(
	p_nummeio integer,
	p_nomeentidade character varying,
	p_numprocessosocorro integer)
RETURNS INTEGER
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE v_idMeio INTEGER;
BEGIN
	SELECT idMeio into v_idMeio FROM d_meio dm 
		INNER JOIN alocado ao ON dm.nummeio = ao.nummeio AND dm.nomeentidade = ao.nomeentidade AND dm.tipo = 'Apoio'
	WHERE dm.nummeio = $1
	AND dm.nomeentidade = $2
	AND ao.numprocessosocorro = $3;
	IF  NOT FOUND THEN
		SELECT idMeio into v_idMeio FROM d_meio dm
			INNER JOIN transporta ta ON dm.nummeio = ta.nummeio AND dm.nomeentidade = ta.nomeentidade AND dm.tipo = 'Socorro'
		WHERE dm.nummeio = $1
			AND dm.nomeentidade = $2
			AND ta.numprocessosocorro = $3;
		IF NOT FOUND THEN
			SELECT idMeio into v_idMeio FROM d_meio dm
				INNER JOIN meiocombate mc ON dm.nummeio = mc.nummeio AND dm.nomeentidade = mc.nomeentidade AND dm.tipo = 'Combate'
			WHERE
				dm.nummeio = $1
				AND dm.nomeentidade = $2;
			IF NOT FOUND THEN
				SELECT idMeio into v_idMeio FROM d_meio dm
				INNER JOIN meio me ON dm.nummeio = me.nummeio AND dm.nomeentidade = me.nomeentidade AND dm.tipo is NULL
			WHERE
				dm.nummeio = $1
				AND dm.nomeentidade = $2;
			END IF;
		END IF;
	END IF;
	RETURN v_idMeio;
END;
$BODY$;

INSERT INTO d_facts(idevento, idmeio, iddata)
SELECT de.idevento, d_meio_numprocessosocorro(ac.nummeio,ac.nomeentidade,ac.numprocessosocorro), dt.idData
     FROM acciona ac
      NATURAL JOIN eventoemergencia ee
      NATURAL JOIN d_evento de
      INNER JOIN d_tempo dt ON 
        EXTRACT(DAY FROM ee.instantechamada) = dt.dia 
        AND EXTRACT(MONTH FROM ee.instantechamada) = dt.mes 
        AND  EXTRACT(YEAR FROM ee.instantechamada) = dt.ano 



--ULTIMA QUERRY

SELECT tipo, ano, mes, count(idmeio)
FROM d_facts 
  NATURAL JOIN d_evento 
  NATURAL JOIN d_meio 
  NATURAL JOIN d_tempo
WHERE idevento = 15
GROUP BY ROLLUP(tipo, ano, mes)
ORDER BY tipo, ano, mes;