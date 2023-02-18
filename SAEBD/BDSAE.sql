CREATE TABLE Etudiant
(
id_etudiant integer PRIMARY KEY,
nom_etudiant varchar(10),
prenom_etudiant varchar(10),
nom_groupe varchar(10)
);

CREATE TABLE Matiere(
nom_matiere varchar(10) PRIMARY KEY,
id_enseignant integer,
coef_matiere float
);

CREATE TABLE Professeur
(
id_enseignant integer PRIMARY KEY,
nom_enseignant varchar(10) ,
prenom_enseignant varchar(10) ,
nom_groupe varchar(10),
nom_matiere varchar(10),
FOREIGN KEY (nom_matiere) REFERENCES Matiere(nom_matiere)
);

CREATE TABLE Controle (
id_controle integer PRIMARY KEY,
nom_controle varchar(20),
nom_matiere varchar(20), /*NEW*/
FOREIGN KEY (nom_matiere) REFERENCES Matiere(nom_matiere)
);

CREATE TABLE Note
(
note float NOT NULL,
id_etudiant integer, 
nom_matiere varchar(10) ,
coef_matiere float,
id_controle integer, /*FOREIGN NEW*/
FOREIGN KEY (id_etudiant) REFERENCES Etudiant(id_etudiant),
FOREIGN KEY (nom_matiere) REFERENCES Matiere(nom_matiere),
FOREIGN KEY (id_controle) REFERENCES Controle(id_controle)
);

CREATE TABLE Groupe 
(
nom_groupe varchar(20) NOT NULL PRIMARY KEY ,
taille_groupe integer,
nom_deleguer varchar(20)
);

CREATE TABLE EDT_controle
(
jour_controle date NOT NULL,
id_controle integer,
nom_controle varchar(20),
nom_groupe varchar(20),
FOREIGN KEY (id_controle) REFERENCES Controle(id_controle),
FOREIGN KEY (nom_groupe) REFERENCES Groupe(nom_groupe)
);

CREATE TABLE Absence_controle
(
jour_absence date NOT NULL,
id_controle integer,
id_etudiant integer,
FOREIGN KEY (id_etudiant) REFERENCES Etudiant(id_etudiant),
FOREIGN KEY (id_controle) REFERENCES Controle(id_controle)
);

------------------------------------------------------

/* INSERT */

INSERT INTO Etudiant values (5832,'Alloune','Aymen','Pegasus');
INSERT INTO Etudiant values (5733,'Chen','Patrick','Pegasus');
INSERT INTO Etudiant values (5266,'Prieto','Mauricio','Pegasus');
INSERT INTO Etudiant values (5183,'Dujardin','Jean','Draco');
INSERT INTO Etudiant values (5983,'Dupot','Jeanne','Draco');
INSERT INTO Etudiant values (5003,'Pierrot','Payera','Andromeda');


INSERT INTO Matiere values ('BD',8533,2.5);
INSERT INTO Matiere values ('Java',8749,4);
INSERT INTO Matiere values ('HTML',8652,3);

INSERT INTO Professeur values (8533,'Abir','Ab.','Pegasus','BD');
INSERT INTO Professeur values (8749,'Azzag','Az.','Pegasus','Java');
INSERT INTO Professeur values (8652,'Jean','Lassale','Draco','HTML');

INSERT INTO Controle values (1,'Test_BD','BD');
INSERT INTO Controle values (2,'Test_Java','Java');
INSERT INTO Controle values (3,'Test_HTML','HTML');

INSERT INTO Note values (16.5,5832,'BD',2.5,1);
INSERT INTO Note values (17,5832,'Java',4,2);
INSERT INTO Note values (15,5832,'HTML',3,3);
INSERT INTO Note values (19.99,5733,'Java',4,2);   /* GROUPE PEGASUS */
INSERT INTO Note values (20,5266,'HTML',3,3);

INSERT INTO note values (17,5183,'BD',2.5,1);
INSERT INTO note values (17.75,5983,'BD',2.5,1);      /* GROUPE DRACO */

INSERT INTO Note values (15.5,5003,'HTML',3,3);    /* GROUPE ANDROMEDA */
INSERT INTO note values (16.5,5003,'BD',2.5,1);


INSERT INTO Groupe values ('Pegasus',25,'Ony');
INSERT INTO Groupe values ('Draco',25,'Dujardin');
INSERT INTO Groupe values ('Andromeda',26,'Pierrot');

INSERT INTO EDT_controle values ('2022-04-19',1,'Test_BD','Pegasus');
INSERT INTO EDT_controle values ('2022-05-10',2,'Test_Java','Andromeda');
INSERT INTO EDT_controle values ('2022-05-26',3,'Test_HTML','Draco');

INSERT INTO Absence_controle values ('2022-04-19',1,5832);
INSERT INTO Absence_controle values ('2022-05-10',2,5183);
INSERT INTO Absence_controle values ('2022-05-10',2,5733);
INSERT INTO Absence_controle values ('2022-05-26',3,5003);

/* INSERT */

------------------------------------------------------

/* VIEW */

/*Regroupe les étudiant par groupe */
Create VIEW etudiant_groupe as select distinct e.nom_groupe,id_etudiant,nom_etudiant 
from Etudiant e, Professeur p  
where e.nom_groupe=p.nom_groupe;

/*Regroupe les etudiants par la moyenne qu'ils ont dans une matiere */
Create VIEW moy_matiere as select * from (
  select avg(note)as Note,e.id_etudiant,e.nom_etudiant,nom_matiere 
from Note n , Etudiant e where n.id_etudiant=e.id_etudiant  
group by nom_matiere,e.id_etudiant,e.nom_etudiant order by Note DESC
) as s order by nom_matiere DESC;


/*Regroupe les moyenne par groupe */
Create VIEW moy_groupe_note as select avg(note) as Note,nom_groupe 
from Note n, Etudiant e 
where n.id_etudiant=e.id_etudiant group by nom_groupe;

/*Regroupe les moyenne par deleguer */
Create VIEW moy_deleguer as select  avg(note) as Note,nom_deleguer,g.nom_groupe 
from Etudiant e , Note n , Groupe g 
where g.nom_deleguer=e.nom_etudiant and e.id_etudiant=n.id_etudiant 
group by nom_deleguer,g.nom_groupe order by Note DESC;

/*Regroupe les moyenne par groupe et controle */
Create view moy_groupe_controle as select avg(note) as Note,nom_groupe,c.id_controle 
from Note n, Controle c,Etudiant e 
where n.id_controle=c.id_controle and n.id_etudiant=e.id_etudiant  
group by c.id_controle,nom_groupe;

/*Regroupe les absence de controle par groupe */
CREATE VIEW absence_controle_groupe as SELECT count(jour_absence) as Jour_abs,nom_groupe 
from Absence_controle a,Etudiant e 
where a.id_etudiant=e.id_etudiant  group by nom_groupe order by Jour_abs DESC;

/*Compte les absence d'étudiants en ordre décroissant*/
CREATE VIEW abs_etudiant_desc as SELECT count(jour_absence),nom_etudiant 
from Absence_controle a , Etudiant e 
where a.id_etudiant=e.id_etudiant group by nom_etudiant order by nom_etudiant DESC;

/*Tri les moyenne d'étudiant en ordre décroissant */
CREATE VIEW moy_etudiant as SELECT avg(note) as Note,nom_etudiant 
from Etudiant e , Note n  
where e.id_etudiant=n.id_etudiant group by nom_etudiant order by Note DESC;

/*Regroupe les prof. les plus performants par la moyenne qu'on eu leur etudiant */
CREATE VIEW Prof_Perf as SELECT nom_enseignant,avg(note) as note
from Etudiant e, Professeur p , Note n
where p.nom_groupe=e.nom_groupe and e.id_etudiant=n.id_etudiant
group by nom_enseignant order by note DESC;


/*View*/

------------------------------------------------------

/* Procèdures */

/*Fonction qui renvoie les note calculer selon leur coefficients respectifs, prend en parametre un tableau de note et de coef.
  Nommer Note Coefficients Etudiants */

CREATE or REPLACE function Note_CE (in note float[],in coef float[])
RETURNS float
as
$$
DECLARE
note_calculer float;
n int;
som_notecoef float;
somme_coef float;
BEGIN

som_notecoef:=0;
somme_coef:=0;

IF(array_upper($1,1)!=array_upper($2,1) ) THEN 
note_calculer:=0;
raise notice'<!> La taille des tableaux est pas pareil <!>';
return note_calculer;
END IF;

/* Remplissage de la variable som_notecoef, en faisait la somme de chaque note multiplier par leur coefficients respectifs */

FOR n in 1 .. array_upper($1,1) LOOP
som_notecoef:=som_notecoef+($1[n]*$2[n]); 
END LOOP;

/* Remplissage de la variable somme_coef , ici on fait juste la somme de tout les coefs */

FOR n in 1 .. array_upper($2,1) LOOP
somme_coef:=somme_coef+coef[n]; 
END LOOP;

/* enfin le calcul final on divise som_notecoef par la somme des coefficients, somme_coef*/

note_calculer:=som_notecoef/somme_coef;
return note_calculer;

END;
$$ language plpgsql;



/* Fonction qui ne prend seulement en entrée l'id d'étudiant et calcule la moyenne de toutes ses notes avec le coef compris, elle utilise la fonction précèdente qui fait les calculs de coefs */

CREATE OR REPLACE function Moy_calculer(in id int,out moyenne float)
returns float 
as
$$
DECLARE 

/* Déclaration d'un curseur totalement lié pour une requête particulière */

curseur CURSOR FOR 
select note,coef_matiere from Note e, etudiant e2 where e.id_etudiant=e2.id_etudiant and e.id_etudiant=$1 order by note DESC;
note_array  float[]; 
note_coef float[];
tmp_note float;
tmp_coef float;
i int;
test_etudiant int;
BEGIN

with test_etudiant As(
  select id_etudiant from etudiant where id_etudiant=$1
)

select count(*) into test_etudiant from test_etudiant;
IF (test_etudiant=0) THEN 
raise notice '<!> Attention id_etudiant ne correspond a personne <!> 
            <!> Une erreur se produit , modifier id_etudiant <!>
';
END IF;
/* initialisation du compteur i */
i:=1;

/* On ouvre le curseur et on l'utilise pour remplir les tableaux note_array(représente les note simple) et note_coef */ 

OPEN curseur;
LOOP 
FETCH curseur into tmp_note,tmp_coef;

/* condition de sortie de la boucle */
EXIT WHEN NOT FOUND;

note_array:=array_append(note_array,tmp_note);
note_coef:=array_append(note_coef,tmp_coef);
i:=i+1;
END LOOP;
CLOSE curseur;

/* appel de la fonction précédente */
select * into moyenne from Note_CE(note_array,note_coef);
END;
$$ language plpgsql;


/* --------------------------------------------------------- */



/*Renvoie un aprecu des note d'un étudiant qui prend son id_etudiant en parametre et renvoie l'apercu*/

CREATE or REPLACE function apercu_note 
(int,out Nombre_note float,out Note_min float,  out Moy_note float, out Note_max float)
returns setof record
as
$$


With note_max As 
(select note as max from note where id_etudiant = $1 order by max DESC limit 1)

,note_min as 
(select note as min from note where id_etudiant = $1 order by min ASC limit 1)

,note_moy as 
(select avg(note) as moy from note where id_etudiant=$1)

,nombre_note as
(select count(note) as nbre from Note where id_etudiant=$1)


SELECT nbre,min,moy,max from nombre_note,note_min,note_moy,note_max;

$$language sql;


/*TEST : select * from apercu_note(5832); */



/* ----------------------------------------------------- */


/* Fonction qui test si le groupe donner est le meilleur , au niveau des notes , et prend en parametre un tableau de nom_groupe et retourne le resultat*/

CREATE OR REPLACE function meilleur_groupe 
(in varchar , out Resultat boolean,out Note_Groupe float,out Note_MeilleurGroupe float)
returns setof record
as 
$$
DECLARE
classement varchar;
note_m float;
BEGIN

/* On utilise deux CTE pour les utiliser juste apres, une pour la variable de test , une pour la note*/ 

WITH meilleur_groupe as 
(
select avg(note) as note,e.nom_groupe 
from Note n,Etudiant e,Groupe g 
where n.id_etudiant=e.id_etudiant and e.nom_groupe=g.nom_groupe 
group by e.nom_groupe order by e.nom_groupe DESC limit 1
)
,noteGroupe as (select avg(note) as note
from Note n,Etudiant e,Groupe g 
where n.id_etudiant=e.id_etudiant and e.nom_groupe=g.nom_groupe and g.nom_groupe=$1
order by note DESC limit 1)

SELECT nom_groupe,m.note,n.note into classement,Note_MeilleurGroupe,Note_Groupe from meilleur_groupe m ,noteGroupe n;

/* Ici le test pour la variable OUT Resultat */

IF classement=$1 THEN Resultat:=true;
            ELSE Resultat:=False; 
END IF;
return next;
END;
$$language plpgsql;


/*Fonction qui prend en compte l'id d'un controle et renvoie plusieurs informations nous permettant de regrouper toutes les info d'un seul controle donner */

CREATE or REPLACE function ControleInfo(in id int,out note float,out Nom_Matiere varchar,out nom_controle varchar,out Jour date,out nb_Abscent int)
returns setof record
as 
$$

select avg(note) as MoyenneNote,n.nom_matiere as Nom_Matiere,e.nom_controle as NomControle,e.jour_controle as Jour,count(a.id_etudiant) as nb_Abscent
from controle c,Note n,EDT_controle e,Absence_controle a
where c.id_controle=$1 and c.id_controle=n.id_controle and e.id_controle=$1 and a.id_controle=$1
group by n.Nom_Matiere,NomControle,Jour order by MoyenneNote DESC;

$$ language sql;


CREATE OR REPLACE function ProfesseurSearch(in NomMatiere varchar,out NomProf varchar,out MoyEleves float,out GroupeEleves varchar)
returns setof record
as
$$
DECLARE
test_presence int;
BEGIN

/* Ici test pour clarifier les erreurs humaines */

with ExisteOuPas as (
  select count(nom_matiere) from matiere where nom_matiere=$1
)
select * into test_presence from ExisteOuPas;
IF (test_presence=0) THEN 
    raise notice '<!> Le nom de la matiere existe pas <!>'; 
    return;
END IF;

/* On fait un select dans chaque variable OUT */

select nom_enseignant,avg(note),p.nom_groupe 
into NomProf,MoyEleves,GroupeEleves
from Professeur p , Matiere m , Etudiant e, Note n
where m.nom_matiere=p.nom_matiere and m.nom_matiere=$1 and e.id_etudiant=n.id_etudiant and p.nom_groupe=e.nom_groupe
group by nom_enseignant,p.nom_groupe ;

/* Return next car c'est un setof record et qu'il faut retourner qu'une seule ligne on a donc pas besoin de boucle */
return next;

END;
$$language plpgsql;


CREATE OR REPLACE function curseur_controle(in nom_controle varchar,out NombrePrésent int)
returns int
as
$$
DECLARE

/* Utilisation d'un curseur partiellement lié */
curseur_ctl CURSOR (nom_ctl varchar) IS
select id_etudiant,nom_etudiant,e.nom_groupe
from Etudiant e , Professeur p , Controle C , Matiere m
where e.nom_groupe=p.nom_groupe and m.id_enseignant=p.id_enseignant and m.nom_matiere=c.nom_matiere and c.nom_controle=nom_ctl
order by e.nom_groupe; 

IdEtudiant int; 
NomEtudiant varchar; 
i int;

BEGIN
i:=0;
OPEN curseur_ctl($1);
/* Première affichage pour rendre les notices compréhensible */

raise notice  E'%\t% <-- Dans ce controle , voici la liste des eleves present : ',$1,' '  ;
LOOP 
fetch curseur_ctl into IdEtudiant,NomEtudiant;
EXIT WHEN NOT FOUND;
/* Affichage de chaque élèves étant présent au controle donner en paramètre */ 
raise notice  E’%\t%’,IdEtudiant,NomEtudiant;
i:=i+1;
END LOOP;
CLOSE curseur_ctl;

NombrePrésent:=i;
END;
$$language plpgsql;

 
/* Procèdures */

/* Trigger */


/*
Un étudiant ne peut accèder que a ses info perso 
ses absences ,
que a son groupe
que a ses notes  
que a ses matiere/nom_matiere
que a ses nom_enseignant et pas l'id 
que a ses controle qu'il a fait 
ET que a son EDT;

Un prof a accèes que a ses éleves
a accèes a uniquement sa matiere
a accèes a uniquement ses info de prof
a accèes a ses controle dans sa matiere 
a le droit d'insert des notes 
info sur son ou ses groupe uniquement
a le droit de regarder son edt et les absences a ses controles uniquement;

   
*/

/* Les règle d'accèes de données pour etudiant */


CREATE OR REPLACE FUNCTION MesInfos(out id_etudiant int,out nom_etudiant varchar,out prenom_etudiant varchar,out nom_groupe varchar)
returns setof record 
as
$$
select id_etudiant,nom_etudiant,prenom_etudiant,nom_groupe
from Etudiant e 
where e.nom_etudiant=session_user; 

$$ language SQL
SECURITY DEFINER;



CREATE OR REPLACE FUNCTION MesAbsences(out jour_abs date,out id_controle int)
returns setof record 
as
$$
select jour_absence,id_controle 
from Absence_controle a , Etudiant e 
where a.id_etudiant=e.id_etudiant and e.nom_etudiant=session_user; 

$$ language SQL
SECURITY DEFINER;
 
CREATE OR REPLACE FUNCTION MonGroupe(out nom_groupe varchar,out taille_groupe int,out nom_deleguer varchar)
returns setof record
as 
$$

Select g.nom_groupe,taille_groupe,nom_deleguer
from Groupe g , etudiant e 
where g.nom_groupe=e.nom_groupe and e.nom_etudiant=session_user;

$$ language sql
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION MesNotes(out note float,out nom_matiere varchar,out nom_controle varchar,out coef_matiere float,out id_controle int)
returns setof record 
as
$$

select n.note,n.nom_matiere,c.nom_controle,n.coef_matiere,c.id_controle
from Note n, Etudiant e, Controle c
where n.id_etudiant=e.id_etudiant and e.nom_etudiant=session_user; 

$$ language sql
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION MesMatieres(out nom_matiere varchar,out nom_enseignant varchar,out coef_matiere float)
returns setof record 
as
$$

select m.nom_matiere,p.nom_enseignant,m.coef_matiere
from matiere m, Etudiant e,Professeur p
where  m.id_enseignant=p.id_enseignant and p.nom_groupe=e.nom_groupe and e.nom_etudiant=session_user; 

$$ language sql
SECURITY DEFINER;


CREATE OR REPLACE FUNCTION MonEDT(out JourControle date,out id_controle int,out nom_controle varchar,out jour_absence date)
returns setof record 
as
$$

SELECT jour_controle,edt.id_controle,nom_controle,jour_absence
from EDT_controle edt ,Absence_controle a, Etudiant e,Groupe g
where edt.nom_groupe=g.nom_groupe and g.nom_groupe=e.nom_groupe and e.nom_etudiant=session_user;


$$ language sql
SECURITY DEFINER;

/* ------------------------------------------------------------------------- */

/* Les règles d'accèes pour prof. */

CREATE OR REPLACE FUNCTION MesInfos_Prof(out id_enseignant int,out nom_enseignant varchar,out prenom_enseignant varchar,out nom_groupe varchar,out nom_matiere varchar)
returns setof record 
as
$$
select id_enseignant,nom_enseignant,prenom_enseignant,nom_groupe,nom_matiere
from professeur p 
where p.nom_enseignant=session_user; 

$$ language SQL
SECURITY DEFINER;



CREATE OR REPLACE FUNCTION MesEleves(out id_etudiant int,out nom_etudiant varchar,out prenom_etudiant varchar,out nom_groupe varchar)
returns setof record
as
$$

select id_etudiant,nom_etudiant,prenom_etudiant,e.nom_groupe
from Etudiant e, Professeur p 
where e.nom_groupe=p.nom_groupe and p.nom_enseignant=session_user;

$$language sql
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION MesMatieres_Prof(out MesMatieres varchar,out MesControles varchar,out coef_matiere float)
returns setof record
as
$$

select m.nom_matiere,c.nom_controle,m.coef_matiere
from Matiere m, Controle C, Professeur p 
where m.id_enseignant=p.id_enseignant and p.nom_enseignant=session_user;

$$language sql
SECURITY DEFINER;


CREATE OR REPLACE FUNCTION MonEDT_Prof(out JourControle date,out id_controle int,out nom_controle varchar,out NombreAbs int)
returns setof record
as
$$

select jour_controle,edt.id_controle,edt.nom_controle,count(jour_absence) as NombreAbs
from EDT_controle edt,Absence_controle a,Etudiant e ,Professeur p
where edt.nom_groupe=p.nom_groupe and a.id_etudiant=e.id_etudiant and e.nom_groupe=p.nom_groupe and p.nom_enseignant=session_user
group by jour_controle,edt.id_controle,edt.nom_controle order by NombreAbs Desc;

$$language sql
SECURITY DEFINER;

/* Fin des règles d'accèes pour profs */

/* ---------------------------------- */

/* Un enseignant peut ajouter des notes mais pas un étudiant */


CREATE OR REPLACE function AjoutNote()
returns trigger
as
$$
DECLARE
etudiant int;
prof int;
BEGIN 
with QuiEstCetEtudiant as (
  select count(nom_etudiant) as etud from etudiant where nom_etudiant=session_user
)

select etud into etudiant from QuiEstCetEtudiant;

IF(etudiant=1) THEN RETURN NULL;
END IF;

IF(TG_OP='DELETE') THEN RETURN OLD;
END IF;

return NEW;
END;
$$ language plpgsql
SECURITY DEFINER;

CREATE TRIGGER ajoutenote BEFORE
INSERT OR UPDATE OR DELETE 
on Note FOR EACH ROW EXECUTE PROCEDURE AjoutNote();

/* TEST */
insert into note values(13.75,5832,'BD',2.5,1);
update note set note=14 where id_etudiant=5832;
DELETE from note where id_etudiant=5832;
/* TEST */

/* Un enseignant peut ajouter des absence, mais pas un étudiant */


CREATE OR REPLACE function AjoutAbs()
returns trigger
as
$$
DECLARE
UnEtudiant int;
BEGIN

WITH EtudiantOuPas as(
  select count(nom_etudiant) as etudiant from etudiant where nom_etudiant=session_user
)
select etudiant into UnEtudiant from EtudiantOuPas;

IF (UnEtudiant=1) THEN RETURN NULL;
END IF;

IF(TG_OP='DELETE') THEN RETURN OLD;
END IF;

RETURN NEW;
END;
$$ language plpgsql
SECURITY DEFINER;

CREATE TRIGGER AjouteAbs BEFORE 
INSERT OR UPDATE OR DELETE 
on Absence_controle FOR EACH ROW EXECUTE PROCEDURE AjoutAbs();

/* TEST */
insert into absence_controle values('2022-10-19',1,5003);
update absence_controle set id_controle=2 where id_etudiant=5003;
DELETE from absence_controle where id_etudiant=5003;
/* TEST */

/* TRIGGER */