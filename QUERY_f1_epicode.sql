-- Il più giovane dei Piloti, dei 5 Team più storici: 
-- [Team, Fondazione, Pilota, Data di Nascita]
-- "Team Storico, Pilota giovane"

SELECT
tb2.nome AS team, 
tb2.fondazione,
pilota.full_name AS pilota,
pilota.data_nascita
FROM pilota
INNER JOIN
  (
  SELECT 
  tb1.nome, 
  tb1.fondazione,
  contratto.numero_pilota
  FROM contratto
  INNER JOIN 
    (
    SELECT 
    nome,
    fondazione
    FROM
    teams
    ORDER BY fondazione ASC
    LIMIT 5  
    ) AS tb1
  ON tb1.nome = contratto.nome_team
  ) AS tb2
ON tb2.numero_pilota = pilota.numero
ORDER BY data_nascita DESC
LIMIT 1;




-- Il più anziano dei Piloti, dei 5 Team più giovani: 
-- [Team, Fondazione, Pilota, Data di Nascita]
-- "Team giovane, Guida esperta"

SELECT
tb2.nome AS team, 
tb2.fondazione,
pilota.full_name AS pilota,
pilota.data_nascita
FROM pilota
INNER JOIN
  (
  SELECT 
  tb1.nome, 
  tb1.fondazione,
  contratto.numero_pilota
  FROM contratto
  INNER JOIN 
    (
    SELECT 
    nome,
    fondazione
    FROM
    teams
    ORDER BY fondazione DESC
    LIMIT 5  
    ) AS tb1
  ON tb1.nome = contratto.nome_team
  ) AS tb2
ON tb2.numero_pilota = pilota.numero
ORDER BY data_nascita ASC
LIMIT 1;


-- Il Circuito dove si è posizionato meglio, il Pilota arrivato ultimo in classifica:
-- [Nazione, Circuito, Pilota, Posizione nella Gara] 
-- "Il meglio dell'Ultimo"

SELECT
tb2.nazione,
tb2.circuito,
tb2.pilota,
tb2.posizione_finale AS best_piazzamento_gara,
posizione AS pos_classifica_finale
FROM classifica_piloti
INNER JOIN
  (SELECT 
  tb1.nazione,
  tb1.numero_pilota,
  circuito,
  full_name AS pilota,
  posizione_finale
  FROM pilota
  INNER JOIN 
    (
    SELECT 
    nazione, 
    nome AS circuito, 
    posizione_finale,
    gara.numero_pilota  
    FROM circuito
    INNER JOIN gara
    ON circuito.id = gara.id_circuito
    WHERE numero_pilota = 
      (SELECT numero_pilota
      FROM classifica_piloti
      ORDER BY posizione DESC
      LIMIT 1)
    ORDER BY posizione_finale ASC
    LIMIT 1
    ) AS tb1
  ON tb1.numero_pilota = pilota.numero) AS tb2
ON tb2.numero_pilota = classifica_piloti.numero_pilota;



-- Il pilota più anziano che guadagna di più: 
-- [Nome, Compenso, Eta]
-- Sono intesi più anziani, i piloti di età maggiore alla media di età del gruppo.
-- "Pilota Vecchio, fa buon business"

SELECT 
full_name AS pilota, 
compenso_annuale, 
TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
FROM contratto
INNER JOIN pilota
ON contratto.numero_pilota = pilota.numero
HAVING eta >  
	(SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, data_nascita, CURDATE())),0) AS media_eta
	FROM pilota)
ORDER BY compenso_annuale DESC
LIMIT 1;


-- Team che ha pagato di piu i punti mondiali:
-- [Nome, Ammontare per Punto]
-- "Poca Resa, Molto Spesa"

SELECT 
ROUND((table1.money / table2.punti), 0) AS money_for_point, 
table1.team
FROM
	(SELECT 
    SUM(compenso_annuale) as money, 
    contratto.nome_team AS team
	FROM contratto
	GROUP BY contratto.nome_team) AS table1
INNER JOIN
	(SELECT 
    SUM(punti) AS punti, 
    con.nome_team AS team
	FROM classifica_piloti AS cp
	INNER JOIN contratto as con
	ON cp.numero_pilota = con.numero_pilota
	GROUP BY team) AS table2
ON table1.team = table2.team
ORDER BY money_for_point ASC
LIMIT 1;


-- Il Team che ha pagato di meno i punti mondiali:
-- [Ammontare per ogni Punto, Team]
-- "Spesi Bene!!!"

SELECT 
ROUND((table1.money / table2.punti), 0) AS money_for_point, 
table1.team
FROM
	(SELECT 
    SUM(compenso_annuale) as money, 
    contratto.nome_team AS team
	FROM contratto
	GROUP BY contratto.nome_team) AS table1
INNER JOIN
	(SELECT 
    SUM(punti) AS punti, 
    con.nome_team AS team
	FROM classifica_piloti AS cp
	INNER JOIN contratto as con
	ON cp.numero_pilota = con.numero_pilota
	GROUP BY team) AS table2
ON table1.team = table2.team
ORDER BY money_for_point DESC
LIMIT 1;


-- I migliori 3 Piloti che hanno recuperato più posizioni in una gara: 
-- [Pilota, Posizioni recuperate, Circuito]
-- "Il trio della riscossa da lontano"

SELECT
pilota.full_name AS pilota,
tb3.posizioni_recuperate,
tb3.circuito
FROM pilota
INNER JOIN 
  (SELECT
  tb2.posizioni_recuperate,
  circuito.nome AS circuito,
  tb2.numero_pilota
  FROM circuito
  INNER JOIN
    (SELECT 
    id_circuito,
    posizioni_recuperate,
    tb1.numero_pilota
    FROM
      (SELECT MAX(posizione_partenza - posizione_finale) AS posizioni_recuperate, 
      numero_pilota
      FROM gara
      GROUP BY numero_pilota
      ORDER BY posizioni_recuperate DESC
      LIMIT 3) AS tb1
    INNER JOIN gara
    ON gara.numero_pilota = tb1.numero_pilota
    WHERE tb1.posizioni_recuperate = (gara.posizione_partenza - gara.posizione_finale)
    ORDER BY posizioni_recuperate DESC) AS tb2
  ON tb2.id_circuito = circuito.id) AS tb3 
ON tb3.numero_pilota = pilota.numero;

-- Il circuito dove i piloti di casa hanno vinto: 
-- [Circuito, Nazione, Pilota, Posizione]
-- "Home Sweet Home"

SELECT 
nome AS circuito, 
table2.nazione, 
full_name as pilota,
posizione_finale AS posizione
FROM
	(SELECT 
   id, 
   nome, 
   nazione, 
   numero_pilota,
   posizione_finale
	FROM circuito 
	INNER JOIN
		(SELECT 
     id_circuito, 
     numero_pilota,
     posizione_finale
		FROM gara
		WHERE posizione_finale = 1) AS table1
	ON circuito.id = table1.id_circuito) table2
JOIN pilota
ON table2.numero_pilota = pilota.numero
WHERE table2.nazione = pilota.nazione;

-- Chi ha realizato più punti tra i piloti giovani e anziani. 
-- Essendo in 22, creare 2 gruppi di età da 11 piloti.
-- [Punti anziani, Punti giovani]  
-- "Vecchi contro Giovani"

SELECT * 
FROM (SELECT SUM(punti) AS old_point
	 		FROM
        (SELECT numero_pilota,
         TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
         FROM contratto
         INNER JOIN pilota
         ON contratto.numero_pilota = pilota.numero
         ORDER BY eta DESC
         LIMIT 11) AS tb1
	 			 JOIN classifica_piloti
	 			 ON tb1.numero_pilota = classifica_piloti.numero_pilota) AS old
INNER JOIN
     (SELECT SUM(punti) AS young_point
      FROM
         (SELECT numero_pilota,
          TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
          FROM contratto
          INNER JOIN pilota
          ON contratto.numero_pilota = pilota.numero
          ORDER BY eta ASC
          LIMIT 11) AS tb2
      		JOIN classifica_piloti
      		ON tb2.numero_pilota = classifica_piloti.numero_pilota) AS young;



-- I 3 piloti che sono partiti più spesso per ultimi: 
-- [Nome Pilota, Team]
-- "Abbonati alle retrovie"


SELECT 
 full_name AS pilota,
 COUNT(posizione_partenza) AS qt_partenza_ultimo
FROM gara
 LEFT JOIN pilota
 ON gara.numero_pilota = pilota.numero
 WHERE posizione_partenza = 20
 GROUP BY full_name
ORDER BY COUNT(posizione_partenza) DESC
LIMIT 3;


-- I 3 piloti con il contratto in scadenza, che hanno fatto piu punti: 
-- Nome Pilota, Team, Punti, Scadenza Contratto.
-- "Ultimo anno, Ma mi impegno!!!"

WITH prequery AS 
(SELECT 
nome_team,
full_name,
numero_pilota,
anno_ingaggio + 1 AS fine_contratto
FROM contratto
INNER JOIN pilota
ON contratto.numero_pilota = pilota.numero
WHERE durata = 1)
SELECT 
full_name AS pilota,
nome_team AS team,
punti,
fine_contratto
FROM classifica_piloti
INNER JOIN prequery
ON prequery.numero_pilota = classifica_piloti.numero_pilota
ORDER BY punti DESC
LIMIT 3;


-- Il podio dei piloti dei meno pagati: 
-- [Nome Pilota, Compenso Annuale, Punti]
-- "Sfida low cost!!!"

SELECT 
full_name AS pilota, 
compenso_annuale,
punti
FROM 
  (SELECT  
  full_name, 
  compenso_annuale,
  punti
  FROM contratto
  LEFT JOIN pilota
  ON pilota.numero = contratto.numero_pilota
  LEFT JOIN classifica_piloti
  ON contratto.numero_pilota = classifica_piloti.numero_pilota
  HAVING compenso_annuale < (SELECT ROUND(AVG(compenso_annuale),0) FROM contratto)
  ORDER BY compenso_annuale ASC
  LIMIT 3) AS tb1
ORDER BY punti DESC;