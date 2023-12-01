/*Afficher la liste des factures avec leur montant*/

SELECT bi.id, bi.ref, bi.date,  SUM(li.quantity * pr.unit_price) AS total_amount
FROM bill bi
	JOIN line_item li ON bi.id = li.bill_id
    JOIN product pr ON pr.id = li.product_id
GROUP BY bi.id
ORDER BY bi.id
;

/*Calculer la moyenne d'age des clients*/
SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())), 0)
FROM customer
;


/*Par année de naissance la somme des factures de mes clients */
(SELECT YEAR(cu.date_of_birth) AS Annee, SUM(li.quantity * pr.unit_price) AS total_amount
FROM customer cu
    JOIN bill bi ON cu.id = bi.customer_id
	JOIN line_item li ON bi.id = li.bill_id
    JOIN product pr ON pr.id = li.product_id
GROUP BY YEAR(cu.date_of_birth)
ORDER BY YEAR(cu.date_of_birth))

UNION ALL

(SELECT bi.is_paid, SUM(li.quantity * pr.unit_price) AS total_amount
FROM customer cu
    JOIN bill bi ON cu.id = bi.customer_id
	JOIN line_item li ON bi.id = li.bill_id
    JOIN product pr ON pr.id = li.product_id
GROUP BY bi.is_paid
ORDER BY bi.is_paid)
;



SELECT 
	YEAR(cu.date_of_birth) AS Annee, 
    CASE WHEN GROUPING(bi.is_paid) = 0 
    THEN 
			CASE WHEN bi.is_paid = 1 THEN 'Payé'
            ELSE 'Non payé'
            END
            ELSE 'Sous-total'END, 
    SUM(li.quantity * pr.unit_price) AS total_amount
FROM customer cu
    JOIN bill bi ON cu.id = bi.customer_id
	JOIN line_item li ON bi.id = li.bill_id
    JOIN product pr ON pr.id = li.product_id
GROUP BY YEAR(cu.date_of_birth), bi.is_paid WITH ROLLUP
ORDER BY YEAR(cu.date_of_birth)
;

/*->Créer une requête qui affiche le montant des factures 
par Catégorie et par Produit

-> ajouter des sous-totaux pour chaque catégorie

-> Faire en sorte qu'à la place de null s'affiche 
"Total"*/

SELECT CASE WHEN 
			GROUPING(ca.label) = 1 
		THEN 'Toutes les catégories' 
        ELSE ca.label 
        END AS categorie, 
		CASE WHEN GROUPING(pr.name) = 1 THEN 'Total' ELSE pr.name END AS produit, 
        SUM(li.quantity * pr.unit_price) AS amount
FROM bill bi
	JOIN line_item li ON bi.id = li.bill_id
    JOIN product pr ON pr.id = li.product_id
    JOIN category ca ON ca.id = pr.category_id
GROUP BY ca.label, pr.name WITH ROLLUP
ORDER BY ca.label
;


SELECT * FROM customer;
DESCRIBE line_item;


CREATE VIEW view_product_with_category AS
SELECT *
FROM product pr 
	JOIN category ca ON ca.id = pr.category_id;
    
    DELETE FROM category 
    WHERE id = 22;



SELECT * FROM view_product_with_category;



SELECT CASE WHEN 
			GROUPING(vpr.category_label) = 1 
		THEN 'Toutes les catégories' 
        ELSE vpr.category_label 
        END AS categorie, 
		CASE WHEN GROUPING(vpr.name) = 1 THEN 'Total' ELSE vpr.name END AS produit, 
        SUM(li.quantity * vpr.unit_price) AS amount
FROM bill bi
	JOIN line_item li ON bi.id = li.bill_id
    JOIN view_product_with_category vpr ON vpr.id = li.product_id
GROUP BY vpr.category_label, vpr.name WITH ROLLUP
ORDER BY vpr.category_label
;





SELECT CASE WHEN 
			GROUPING(ca.label) = 1 
		THEN 'Toutes les catégories' 
        ELSE ca.label 
        END AS categorie, 
		YEAR(bi.date) AS Annee, 
        SUM(li.quantity * pr.unit_price) AS amount
FROM bill bi
	JOIN line_item li ON bi.id = li.bill_id
    JOIN product pr ON pr.id = li.product_id
    JOIN category ca ON ca.id = pr.category_id
GROUP BY ca.label, YEAR(bi.date) WITH ROLLUP
ORDER BY ca.label, YEAR(bi.date)
;

CREATE DATABASE netflix;
USE netflix;

CREATE TABLE movie(
   id INT NOT NULL AUTO_INCREMENT,
   title VARCHAR(255),
   release_year DATE,
   description LONGTEXT,
   director_id INT NOT NULL,
   PRIMARY KEY(id)
);

CREATE TABLE director(
   id INT NOT NULL AUTO_INCREMENT,
   lastname VARCHAR(255),
   firstname VARCHAR(255),
   PRIMARY KEY(id)
);

ALTER TABLE movie 
	ADD CONSTRAINT FK_movie_director
    FOREIGN KEY movie(director_id)
    REFERENCES director(id);
    
    
CREATE TABLE actor (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	lastname VARCHAR(255),
	firstname VARCHAR(255)
);


CREATE TABLE actor_movie (
	actor_id INT NOT NULL,
    movie_id INT NOT NULL,
    PRIMARY KEY (actor_id, movie_id)
);


ALTER TABLE actor_movie 
	ADD CONSTRAINT FK_actor_movie_movie
    FOREIGN KEY actor_movie(movie_id)
    REFERENCES movie(id);
    
ALTER TABLE actor_movie 
	ADD CONSTRAINT FK_actor_movie_actor
    FOREIGN KEY actor_movie(actor_id)
    REFERENCES actor(id);
    

CREATE TABLE import_netflix (
	show_id VARCHAR(250),
	type VARCHAR(250),
	title VARCHAR(250),
	director VARCHAR(250),
	cast TEXT,
	country VARCHAR(250),
	date VARCHAR(250),
	year VARCHAR(250),
	release_year VARCHAR(250),
	rating VARCHAR(250),
	duration VARCHAR(250),
	listed_in TEXT,
	description TEXT
);
    
    
SET GLOBAL local_infile=1;

USE netflix;

LOAD DATA LOCAL INFILE 'C:\\formations\\SQL\\netflix.csv'
INTO TABLE import_netflix
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

SELECT * FROM import_netflix;

DESCRIBE movie;

INSERT INTO director (lastname, firstname)
VALUES('general', 'director');

SELECT * FROM director;


DELETE FROM movie;

INSERT INTO movie ( title, release_year, description, director_id)
SELECT 
	i.title as title,
	CAST(i.release_year AS DECIMAL) as release_year,
	i.description as description,
    1 as director_id
FROM import_netflix i
WHERE i.type = 'Movie'
AND i.release_year REGEXP '^[0-9]+$' = 1
;

SELECT * FROM movie;
SELECT * FROM director;
SELECT * FROM import_netflix;

SELECT * FROM import_netflix;
SELECT * FROM director;

/*
CASE WHEN condition
  THEN
     comportement si vrai
   ELSE 
      Comportement si faux
END*/



SELECT director,
       SUBSTRING_INDEX(director, ' ', -1)  AS lastname,
       SUBSTRING_INDEX(director, ' ', 1) AS firstname
FROM import_netflix
WHERE type = 'Movie'
AND director <> ''
;

DELETE FROM movie;

SELECT movie.*, lastname, firstname FROM movie JOIN director ON movie.director_id = director.id;
SELECT * FROM director;

START TRANSACTION;

DELETE FROM movie;
DELETE FROM director;


INSERT INTO director (lastname, firstname)
SELECT 
       SUBSTRING_INDEX(director, ' ', -1)  AS lastname,
       SUBSTRING_INDEX(director, ' ', 1) AS firstname
FROM import_netflix
WHERE type = 'Movie'
AND director <> ''
GROUP BY lastname, firstname
;


INSERT INTO movie ( title, release_year, description, director_id)
SELECT 
	i.title as title,
	CAST(i.release_year AS DECIMAL) as release_year,
	i.description as description,
    di.id as director_id
FROM import_netflix i
	JOIN director di ON i.director = CONCAT(di.firstname, ' ', di.lastname)
WHERE i.type = 'Movie'
AND i.release_year REGEXP '^[0-9]+$' = 1
AND director <> ''
;

COMMIT;


DELIMITER //
CREATE PROCEDURE init_netflix_movies()
BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
	BEGIN
		ROLLBACK;
		SELECT ('Une erreur est survenue durant le traitement de la table d\'import.') AS Warning;
	END;
  
	START TRANSACTION;

	DELETE FROM movie;
	DELETE FROM director;


	INSERT INTO director (lastname, firstname)
	SELECT 
		   SUBSTRING_INDEX(director, ' ', -1)  AS lastname,
		   SUBSTRING_INDEX(director, ' ', 1) AS firstname
	FROM import_netflix
	WHERE type = 'Movie'
	AND director <> ''
	GROUP BY lastname, firstname
	;
    
    SET @nb_directors = (SELECT COUNT(*) FROM director);
    
    IF @nb_directors = 0
		THEN ROLLBACK;
    END IF;


	INSERT INTO movie ( title, release_year, description, director_id)
	SELECT 
		i.title as title,
		CAST(i.release_year AS DECIMAL) as release_year,
		i.description as description,
		di.id as director_id
	FROM import_netflix i
		JOIN director di ON i.director = CONCAT(di.firstname, ' ', di.lastname)
	WHERE i.type = 'Movie'
    AND i.release_year REGEXP '^[0-9]+$' = 1
	AND director <> ''
	;

	COMMIT;

END//



DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `lastname` varchar(255) default NULL,
  `firstname` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `date` varchar(255),
  PRIMARY KEY (`id`)
) AUTO_INCREMENT=1;

INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Sexton","Nicholas","eu.tempor@google.com","08-24-93"),
  ("Finley","Joel","consectetuer.cursus@google.com","01-11-92"),
  ("Lyons","Nolan","mattis.velit@aol.com","04-13-77"),
  ("Burgess","Liberty","duis.ac@outlook.com","04-25-84"),
  ("Wallace","Brent","a.felis@outlook.com","05-26-99"),
  ("Yates","Kuame","sed.nunc@outlook.couk","02-18-96"),
  ("Poole","Dillon","sociosqu@outlook.edu","11-21-78"),
  ("Greer","Tamara","nullam.nisl@icloud.org","09-05-99"),
  ("Combs","Ronan","penatibus.et.magnis@google.ca","05-16-94"),
  ("Kirby","Aimee","nec.urna@aol.ca","11-02-94");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Valdez","Dawn","at@protonmail.couk","02-13-89"),
  ("Marsh","Phillip","pharetra.ut@google.org","09-22-77"),
  ("Callahan","Mariko","at@aol.net","09-17-76"),
  ("Ortiz","Kiona","etiam.bibendum@outlook.com","07-10-91"),
  ("Jenkins","Alma","semper.cursus@hotmail.org","02-22-97"),
  ("Middleton","Kenyon","dui@aol.org","08-01-83"),
  ("Finch","Hedley","ultricies.adipiscing@icloud.com","08-18-81"),
  ("Bird","Jermaine","ridiculus@icloud.net","05-21-97"),
  ("Boone","Berk","donec.est.nunc@aol.com","12-16-93"),
  ("Shannon","Beau","vitae.sodales@icloud.org","10-12-80");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Waller","Rinah","lobortis@outlook.couk","06-26-82"),
  ("Phelps","Hammett","duis.sit.amet@yahoo.edu","07-11-90"),
  ("Jensen","Penelope","blandit.at.nisi@google.couk","09-24-83"),
  ("Aguirre","Jameson","ullamcorper.duis.cursus@hotmail.ca","12-18-97"),
  ("Harrell","Lyle","suspendisse.commodo@outlook.edu","11-05-94"),
  ("Everett","Donovan","ac.facilisis@hotmail.net","02-02-96"),
  ("Snyder","Logan","quam.curabitur@outlook.couk","11-22-90"),
  ("Head","Hamilton","lorem.ac@yahoo.couk","08-07-84"),
  ("Burks","Kareem","amet.orci@aol.org","06-07-92"),
  ("Clark","Tashya","ipsum@protonmail.couk","11-02-80");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Browning","Blake","proin@protonmail.com","01-12-77"),
  ("Walls","Fletcher","dui.nec@hotmail.ca","02-05-96"),
  ("Watson","Keiko","sit.amet@outlook.org","07-20-83"),
  ("Baxter","Ryder","iaculis@hotmail.com","02-01-86"),
  ("Rush","Lenore","sapien.imperdiet@aol.com","09-22-00"),
  ("Chen","Merritt","curabitur.vel.lectus@google.ca","10-22-83"),
  ("Simmons","Jada","consectetuer.rhoncus.nullam@yahoo.com","04-09-91"),
  ("Wolf","Uma","lacus.nulla@outlook.com","09-28-82"),
  ("Witt","Medge","dapibus.gravida.aliquam@icloud.edu","05-10-98"),
  ("Mcknight","Carlos","fames@aol.edu","10-08-81");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Burnett","Adam","volutpat.nulla@yahoo.ca","04-03-94"),
  ("Vasquez","Cassandra","tincidunt.nibh.phasellus@google.ca","08-02-94"),
  ("Banks","Vaughan","euismod.enim@outlook.ca","10-17-91"),
  ("Brock","Keane","euismod.et.commodo@yahoo.couk","11-03-00"),
  ("Brennan","Roth","suspendisse@google.edu","09-14-76"),
  ("Briggs","Brenna","tortor.nibh.sit@icloud.org","02-08-79"),
  ("Hardin","Yuli","eleifend.egestas.sed@hotmail.org","11-12-85"),
  ("Willis","Lara","tincidunt.aliquam@google.net","09-25-81"),
  ("Dixon","Bevis","mauris.aliquam@protonmail.com","09-08-85"),
  ("Hines","Noel","vulputate.lacus@aol.org","06-11-95");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Kane","Hollee","fames.ac.turpis@yahoo.com","12-01-83"),
  ("Castillo","Ali","auctor.odio@google.org","12-09-84"),
  ("Mcgee","Lewis","ad.litora@outlook.net","08-18-81"),
  ("Roberson","April","mattis.cras@yahoo.org","06-28-88"),
  ("Franklin","Brody","egestas.fusce@protonmail.net","05-29-97"),
  ("Poole","Ebony","a.tortor@outlook.ca","04-17-94"),
  ("Bullock","Armando","suspendisse.aliquet@google.couk","12-09-83"),
  ("Daugherty","Quinlan","orci.ut.sagittis@hotmail.com","12-27-77"),
  ("Joseph","Haviva","turpis@hotmail.couk","10-25-88"),
  ("Dean","Angela","ac.facilisis.facilisis@icloud.ca","08-02-92");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Watson","George","non@outlook.edu","11-20-78"),
  ("Duran","Gavin","in@google.ca","10-16-81"),
  ("Mathews","Dennis","et.ultrices@protonmail.org","10-22-77"),
  ("Giles","Georgia","neque.non@google.ca","07-13-00"),
  ("Richmond","Aspen","conubia.nostra@yahoo.ca","10-23-98"),
  ("Duncan","Alden","nunc.ullamcorper@protonmail.net","02-06-79"),
  ("Bradley","Harper","sem.vitae@outlook.org","06-02-98"),
  ("Baird","Allistair","ut.pharetra@protonmail.org","01-01-00"),
  ("Franklin","Melissa","nec.malesuada.ut@yahoo.couk","02-02-91"),
  ("Grimes","Katelyn","nascetur@google.couk","01-27-85");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Hanson","Wallace","posuere@protonmail.ca","05-24-00"),
  ("Holcomb","Kylie","non.dui.nec@yahoo.com","05-10-81"),
  ("Guzman","Oleg","mattis.ornare@outlook.com","10-22-97"),
  ("Beck","Illana","natoque.penatibus@hotmail.com","01-10-89"),
  ("Oliver","Rachel","leo.vivamus@hotmail.org","04-11-99"),
  ("Graham","Bevis","orci@google.couk","08-01-85"),
  ("Dillard","Josephine","pede.suspendisse.dui@aol.org","05-25-82"),
  ("Browning","Randall","erat@aol.org","10-15-87"),
  ("Bernard","Hadley","turpis.nec@hotmail.net","06-07-76"),
  ("Galloway","Thomas","consectetuer.cursus.et@icloud.edu","05-25-88");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Pruitt","Otto","euismod.et@yahoo.couk","07-26-94"),
  ("Estes","Harper","consequat.purus.maecenas@aol.edu","11-09-84"),
  ("Pope","Melissa","sed.hendrerit@google.couk","05-03-85"),
  ("Davenport","Carson","nascetur@aol.edu","01-11-96"),
  ("Cash","April","justo.sit@outlook.ca","11-27-76"),
  ("Mcguire","Kieran","per.conubia@icloud.edu","03-21-86"),
  ("Howard","Hayley","ullamcorper.velit.in@google.ca","01-17-77"),
  ("Cherry","Adrian","sem.eget@aol.org","09-02-94"),
  ("Anderson","Chanda","non.egestas@yahoo.net","04-14-99"),
  ("Munoz","Keely","natoque.penatibus.et@outlook.com","03-10-94");
INSERT INTO `user` (`lastname`,`firstname`,`email`,`date`)
VALUES
  ("Sharpe","Declan","libero.dui.nec@hotmail.com","08-30-80"),
  ("May","Micah","ridiculus@yahoo.edu","02-06-98"),
  ("Alexander","Harper","consectetuer.cursus.et@aol.com","09-22-99"),
  ("Mccarty","Fredericka","urna.ut.tincidunt@icloud.org","12-19-82"),
  ("Stewart","Sybill","tempor.diam@aol.couk","08-08-76"),
  ("Hayden","Declan","sem.magna.nec@icloud.net","05-16-83"),
  ("Brennan","Kylan","dictum.augue.malesuada@outlook.couk","09-26-94"),
  ("Cleveland","Charde","interdum.enim@icloud.com","09-12-90"),
  ("Dorsey","Kasper","sapien.aenean@protonmail.ca","07-19-91"),
  ("Lambert","Boris","sem.semper@google.com","12-24-96");
  
  CREATE TABLE viewing (
	user_id INT NOT NULL,
	movie_id INT NOT NULL
);


DELIMITER //
CREATE PROCEDURE generate_viewings()
BEGIN

	SET @i = 0;
	REPEAT
		SET @rand_user_id = (SELECT id FROM user ORDER BY RAND() LIMIT 1);
		SET @rand_movie_id = (SELECT id FROM movie ORDER BY RAND() LIMIT 1);
		
		INSERT INTO viewing (user_id, movie_id)
		VALUES(@rand_user_id, @rand_movie_id);
        
        SET @i = @i + 1;
	UNTIL @i > nb_viewing
	END REPEAT;
END//

SELECT * FROM viewing;
SELECT * FROM import_netflix;

CALL generate_viewings(20);

SET @@SESSION.max_sp_recursion_depth = 250;

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_viewings`(nb_viewing INT)
BEGIN
		SET @rand_user_id = (SELECT id FROM user ORDER BY RAND() LIMIT 1);
		SET @rand_movie_id = (SELECT id FROM movie ORDER BY RAND() LIMIT 1);
		
		INSERT INTO viewing (user_id, movie_id)
		VALUES(@rand_user_id, @rand_movie_id);
        
        IF nb_viewing > 1
			THEN
				CALL generate_viewings(nb_viewing - 1);
		END IF;
END


CREATE DEFINER=`root`@`localhost` PROCEDURE `init_netflix_movies`()
BEGIN

	DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
	BEGIN
		ROLLBACK;
		SELECT ('Une erreur est survenue durant le traitement de la table d\'import.') AS Warning;
	END;
  
	START TRANSACTION;

	DELETE FROM movie;
	DELETE FROM director;


	INSERT INTO director (lastname, firstname)
	SELECT 
		   SUBSTRING_INDEX(director, ' ', -1)  AS lastname,
		   SUBSTRING_INDEX(director, ' ', 1) AS firstname
	FROM import_netflix
	WHERE type = 'Movie'
	AND director <> ''
	GROUP BY lastname, firstname
	;
    
    SET @nb_directors = (SELECT COUNT(*) FROM director);
    
    IF @nb_directors = 0
		THEN 
			ROLLBACK;
			SELECT ('Pas de réalisateurs créés.') AS Warning;
    END IF;


	INSERT INTO movie ( title, release_year, description, director_id)
	SELECT 
		i.title as title,
		CAST(i.release_year AS DECIMAL) as release_year,
		i.description as description,
		di.id as director_id
	FROM import_netflix i
		JOIN director di ON i.director = CONCAT(di.firstname, ' ', di.lastname)
	WHERE i.type = 'Movie'
    AND i.release_year REGEXP '^[0-9]+$' = 1
	AND director <> ''
	;
    
    
    IF (SELECT COUNT(*) FROM movie) = 0
		THEN 
			ROLLBACK;
            SELECT 'Aucun film n\'a été importé !';
    END IF;
    
    /*IF (SELECT COUNT(*) FROM movie WHERE title LIKE '%Naruto%') <> 0
		THEN 
			ROLLBACK;
            SELECT 'Attention il y a des Narutos qui ce sont glissé dans la selection.';
    END IF;*/
    
    
    

	COMMIT;

END


DELIMITER //
CREATE PROCEDURE insert_new_actor(actor varchar(200))
BEGIN
	INSERT INTO actor (lastname, firstname)
    VALUES (SUBSTRING_INDEX(TRIM(actor), ' ', -1), SUBSTRING_INDEX(TRIM(actor), ' ', 1));
END//

CALL insert_new_actor('Tom Cruise');

SELECT * FROM actor;


DELIMITER //
CREATE PROCEDURE parse_a_group_of_actors(actors text)
BEGIN
		 /*tom cruise, brad pitt, tom hanks*/
         REPEAT
			 SET @actor = SUBSTRING_INDEX(actors, ",", 1);
			 CALL insert_new_actor(@actor);
			 
			 SET actors = REPLACE(actors, CONCAT(@actor, ',') , '');
			 /*  tom hanks*/
			 
			 UNTIL actors = @actor
         END REPEAT;
END//

SELECT * FROM import_netflix;
SELECT * FROM actor;

CALL parse_a_group_of_actors('Sami Bouajila, Tracy Gotoas, Samuel Jouy, Nabiha Akkari, Sofia Lesaffre, Salim Kechiouche, Noureddine Farihi, Geert Van Rampelberg, Bakary Diombera');




