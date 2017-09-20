Birthyear:

SELECT name,year FROM movies WHERE year=1992

1982:


SELECT COUNT(*) FROM movies WHERE year=1982

Stacktors:

SELECT * FROM actors WHERE last_name LIKE '%stack%'

SELECT first_name, COUNT(*) FROM actors WHERE COUNT(*) > 50 GROUP BY first_name ORDER BY COUNT(*) DESC;


Fake Name Game:

SELECT first_name, count
FROM (SELECT first_name, COUNT(*) AS 'count'
      FROM actors
      GROUP BY first_name)
ORDER BY count DESC
LIMIT 10;

SELECT last_name, COUNT(*) AS 'count' FROM actors GROUP BY last_name ORDER BY count DESC LIMIT 10;


SELECT first_name, last_name, COUNT(*) AS 'count' FROM actors GROUP BY first_name, last_name ORDER BY count DESC LIMIT 10;


SELECT (first_name || ' ' || last_name) as full_name COUNT(*) AS 'count' FROM actors GROUP BY first_name, last_name ORDER BY count DESC LIMIT 10;


Prolific:
Involve (inner?) joining the roles and actors tables where actors.id = roles.actor_id
counting stuff like above
selecting the 100 actors with the greatest count from that

SELECT a.first_name, a.last_name, COUNT(*) AS count FROM actors AS a JOIN roles AS r ON a.id = r.actor_id GROUP BY a.first_name, a.last_name ORDER BY count DESC LIMIT 100;


Bottom of the Barrel:
How many movies does IMDB have of each genre, ordered by least popular genre?
still display at the end genre and num of movies that are in that genre
join with movies in order to make sure there are legit movies

SELECT genre, COUNT(*) AS count FROM movies_genres as g JOIN movies as m ON g.movie_id = m.id GROUP BY genre ORDER BY count;


Braveheart:
List the first and last names of all the actors who played in the 1995 movie 'Braveheart', arranged alphabetically by last name.

to get all the actors from braveheart...
  get braveheart from movies tables
  join with roles table to get all actor ids
  join that with actors table to get all their names
  and then select first and last names and order by last name


SELECT first_name, last_name FROM actors JOIN (
  SELECT b.id as movieID, r.actor_id as actID FROM ( SELECT * FROM movies WHERE name = 'Braveheart' and year = 1995) as b JOIN roles as r ON b.id = r.movie_id
) as bans ON bans.actID = actors.id ORDER BY last_name;


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

get all movies after 2000 and their actor ids   then actor names and ids
join those two where actorIDs and include  their actor IDs and count (groupby)
join that with actors and select their names









Busy Filming:
Find actors that played five or more roles in the same movie after the year 1990. Notice that ROLES may have occasional duplicates, but we are not interested in these: we want actors that had five or more distinct (cough cough) roles in the same movie. Write a query that returns the actors names, the movie name, and the number of distinct roles that they played in that movie (which will be ≥ 5).

