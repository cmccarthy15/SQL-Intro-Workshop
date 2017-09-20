Birthyear:

SELECT name, year
FROM movies
WHERE year = 1992;

1982:


SELECT COUNT(*)
FROM movies
WHERE year = 1982;

Stacktors:

SELECT *
FROM actors
WHERE last_name
LIKE '%stack%';

...?
SELECT first_name, COUNT(*)
FROM actors
WHERE COUNT(*) > 50
GROUP BY first_name
ORDER BY COUNT(*) DESC;


Fake Name Game:

SELECT first_name, COUNT(*) count
FROM actors
GROUP BY first_name
ORDER BY count DESC
LIMIT 10;

SELECT last_name, COUNT(*) AS 'count'
FROM actors
GROUP BY last_name
ORDER BY count DESC
DESC LIMIT 10;


SELECT first_name, last_name, COUNT(*) AS 'count'
FROM actors
GROUP BY first_name, last_name
ORDER BY count DESC
LIMIT 10;


SELECT (first_name || ' ' || last_name) as full_name, COUNT(*) AS 'count'
FROM actors
GROUP BY full_name
ORDER BY count DESC
LIMIT 10;


Prolific:
Involve (inner?) joining the roles and actors tables where actors.id = roles.actor_id
counting stuff like above
selecting the 100 actors with the greatest count from that


SELECT first_name, last_name, COUNT(*) AS num_roles
FROM actors AS a
JOIN roles AS r
ON a.id = r.actor_id
GROUP BY a.id
ORDER BY num_roles DESC
LIMIT 100;


Bottom of the Barrel:
How many movies does IMDB have of each genre, ordered by least popular genre?
still display at the end genre and num of movies that are in that genre
join with movies in order to make sure there are legit movies

SELECT genre, COUNT(*) AS num_movies
FROM movies_genres as g
JOIN movies as m
ON g.movie_id = m.id
GROUP BY genre
ORDER BY num_movies;


Braveheart:
List the first and last names of all the actors who played in the 1995 movie 'Braveheart', arranged alphabetically by last name.

to get all the actors from braveheart...
  get braveheart from movies tables
  join with roles table to get all actor ids
  join that with actors table to get all their names
  and then select first and last names and order by last name


/* SELECT first_name, last_name
FROM actors
JOIN ( SELECT b.id as movieID, r.actor_id as actID
      FROM ( SELECT *
            FROM movies
            WHERE name = 'Braveheart' and year = 1995) as b
      JOIN roles as r
      ON b.id = r.movie_id) as bans
ON bans.actID = actors.id
ORDER BY last_name;
*/

SELECT first_name, last_name
FROM actors
  INNER JOIN roles ON actors.id = roles.actor_id
  INNER JOIN movies
    ON roles.movie_id = movies.id
    AND movies.name = 'Braveheart'
    AND movies.year = 1995
ORDER BY last_name;


Leap Noir:
List all the directors who directed a 'Film-Noir'-genre movie in a leap year (for the sake of this challenge, pretend that all years divisible by 4 are leap years — which is not true in real life). Your query should return director name, the movie name, and the year, sorted by movie name.


all film noir movies from leap years with id,name,year,genre =
SELECT m.id, m.name, m.year, g.genre
FROM movies_genres as g
JOIN movies as m ON m.id = g.movie_id
WHERE genre = 'Film-Noir' and (m.year % 4) = 0;


directors with movieIds =
SELECT md.movie_id, d.first_name, d.last_name
FROM directors as d
JOIN movies_directors as md
ON md.director_id = d.id;

SELECT d.first_name, d.last_name, fnm.name, fnm.year
FROM (SELECT m.id, m.name, m.year, g.genre
      FROM movies_genres as g
      JOIN movies as m ON m.id = g.movie_id
      WHERE genre = 'Film-Noir' and (m.year % 4) = 0) as fnm
JOIN (SELECT md.movie_id, d.first_name, d.last_name
      FROM directors as d
      JOIN movies_directors as md
      ON md.director_id = d.id ) as d
ON fnm.id = d.movie_id
ORDER BY fnm.name;

/* REVIEW SOLUTION */
/* need directors, movies_directors, movies_genres, and movies tables */

SELECT first_name, last_name, m.name, m.year
FROM movies as m
  INNER JOIN movies_genres as mg
  ON m.id = mg.movie_id
  AND mg.genre = 'Film-Noir'
    INNER JOIN movies_directors as md
    ON m.id = md.movie_id
      INNER JOIN directors as d
      ON md.director_id = d.id
WHERE year % 4 = 0
ORDER BY m.name;



*Bacon:
List all the actors that have worked with Kevin Bacon in Drama movies (include the movie name). Please exclude Mr. Bacon himself from the results.
Its not your imagination; these queries are getting a bit more challenging at this stage!


COMMENT --> select Kevin Bacon from actors

SELECT m.name, first_name, last_name
FROM (SELECT id, first_name, last_name, movieID
      FROM (SELECT actor_id, movieID
            FROM (SELECT kb, movieID, genre
                  FROM (SELECT kb.id as kb, r.movie_id as movieID
                        FROM (SELECT *
                              FROM actors
                              WHERE first_name = 'Kevin' and last_name = 'Bacon') as kb
                        JOIN roles as r
                        ON kb.id = r.actor_id ) as kbMovies
                  JOIN (SELECT * FROM movies_genres WHERE genre = 'Drama') as mg
                  ON kbMovies.movieID = mg.movie_id ) as drama
            JOIN roles as r
            ON r.movie_id = movieID
            WHERE r.actor_id <> kb
            ORDER BY actor_id DESC ) as dramaActors
      JOIN actors as a
      ON a.id = actor_id )
JOIN movies as m
ON m.id = movieID
ORDER BY m.name DESC;


COMMENT --> and join that to the roles table to get all movies he acted in - table should include his actorId and movieIds

COMMENT --> join that with movies_genres and select KBs actorId, movieIds where genre is drama

COMMENT --> join that back with the roles table to get all the actorIds of people in those movies besides his own - that table should include actorIds (except his) and movieIds

COMMENT --> join that with actors to get a table with actor names, actorIds, movieIds

COMMENT --> join that with movies to get actor names, movie names


/* REVIEW SOLUTION */
/* Will need actors, movies, movies_genres, roles */
/* DOES NOT WORK YET  */

CREATE VIEW bacon AS
  SELECT m2.id
  FROM movies AS m2
    INNER JOIN roles AS r2 ON r2.movie_id = m2.id
    INNER JOIN actors AS a2
      ON r2.actor_id = a2.id
      AND a2.first_name = 'Kevin'
      AND a2.last_name = 'Bacon'

SELECT m.name, a.first_name || " " || a.last_name AS full_name
FROM actors as a
  INNER JOIN roles as r
    ON r.actor_id = a.id
  INNER JOIN movies as m
    ON r.movie_id = m.id
  INNER JOIN movies_genres as mg
    ON mg.movie_id = m.id
    AND mg.genre = 'Drama';
WHERE m.id IN bacon
AND full_name != 'Kevin Bacon'
ORDER BY a.last_name ASC
LIMIT 100;





Immortal Actors:
Which actors have acted in a film before 1900 and also in a film after 2000? NOTE: we are not asking you for all the pre-1900 and post-2000 actors — we are asking for each actor who worked in both eras!

actors, roles, movies


get all movies before 1900 and their actor ids  then actor names and ids  --- id actor names
  movies to filter by year... roles to get actor ids and then actors to get names and ids

SELECT a.id, a.first_name, a.last_name
FROM( SELECT actor_id
      FROM movies as m
      JOIN roles as r
      ON id = movie_id
      WHERE m.year < 1990) as ids
JOIN actors as a
ON a.id = actor_id
INTERSECT
SELECT act.id, act.first_name, act.last_name
FROM( SELECT *
      FROM movies
      JOIN roles as r
      ON id = movie_id
      WHERE movies.year > 2000) as actIds
JOIN actors as act
ON act.id = actor_id
ORDER BY act.id DESC
LIMIT 100;

/* REVIEW SOLUTION */

/* Will need actors, roles, movies */

SELECT actors.id, actors.first_name, actors.last_name
FROM actors
  INNER JOIN roles ON roles.actor_id = actors.id
  INNER JOIN movies ON movies.id = roles.movie_id
WHERE movies.year < 1900
INTERSECT
SELECT actors.id, actors.first_name, actors.last_name
FROM actors
  INNER JOIN roles ON roles.actor_id = actors.id
  INNER JOIN movies ON movies.id = roles.movie_id
WHERE movies.year > 2000;






Busy Filming:
Find actors that played five or more roles in the same movie after the year 1990. Notice that ROLES may have occasional duplicates, but we are not interested in these: we want actors that had five or more distinct (cough cough) roles in the same movie. Write a query that returns the actors names, the movie name, and the number of distinct roles that they played in that movie (which will be ≥ 5).

/* REVIEW SOLUTION */

/* Will need actors, roles, movies */


SELECT
  actors.first_name,
  actors.last_name,
  movies.name,
  movies.year,
  COUNT (DISTINCT roles.role) AS num_roles_in_movies
FROM actors
INNER JOIN roles
  ON roles.actor_id = actors.id
INNER JOIN movies
  ON roles.movie_id = movies.id
WHERE movies.year > 1990
GROUP BY actors.id, movies.id
HAVING num_roles_in_movies > 4;













♀ :

For each year, count the number of movies in that year that had only female actors. You might start by including movies with no cast, but your ultimate goal is to narrow your query to only movies that have a cast.


/* REVIEW SOLUTION */

/* Will need   */
SELECT movies.year, COUNT(*) movies_in_year
FROM movies
WHERE movies.id NOT IN (
  SELECT DISTINCT movies.id
  FROM movies
    INNER JOIN roles ON movies.id = roles.movie_id
    INNER JOIN actors
      ON roles.actor_id = actors.id
      AND actors.gender = 'M'
);

GROUP BY movies.year;

SELECT DISTINCT movies.id
FROM movies
  INNER JOIN ROLES
