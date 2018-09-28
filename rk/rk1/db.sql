-- 1
SELECT * FROM movie
  WHERE director = 'Steven Spielberg' ORDER BY title;

-- 2
SELECT DISTINCT movie.title, movie.year, AVG(stars) FROM movie
  JOIN rating r on movie.mid = r.mid
  GROUP BY (movie.mid)
  HAVING AVG(stars) >= 4
  ORDER BY (movie.year);

-- 3
SELECT T.title FROM
  (SELECT movie.title, AVG(stars) AS rating FROM movie
      LEFT JOIN rating R ON movie.mid = R.mid
      GROUP BY movie.mid) AS T
WHERE T.rating ISNULL

-- 4
SELECT DISTINCT reviewer.name FROM reviewer
  JOIN rating r on reviewer.rid = r.rid
  WHERE r.ratingdate ISNULL
ORDER BY reviewer.name

-- 5
SELECT re.name, m.title, r.stars, r.ratingdate FROM reviewer AS re
  JOIN rating r on re.rid = r.rid
  JOIN movie m on r.mid = m.mid
ORDER BY re.name, m.title, r.stars;

-- 6
SELECT movie.title, MAX(r.stars), MIN(r.stars) FROM movie
  JOIN rating r on movie.mid = r.mid
GROUP BY movie.title

-- 7
SELECT AVG(CASE WHEN year > 1980 THEN stars ELSE NULL END) -
        AVG(CASE WHEN year < 1980 THEN stars ELSE NULL END)
  FROM (
     SELECT m.mid, m.year, AVG(r.stars) as stars
      FROM movie m
             JOIN rating r on m.mid = r.mid
      GROUP BY m.mid
     ) AS SMTH

-- 8
SELECT DISTINCT rev.rid, rev.name FROM reviewer AS rev
  JOIN rating r on rev.rid = r.rid
  JOIN movie m on r.mid = m.mid
  WHERE m.title = 'Gone with the Wind'
  ORDER BY rev.name, rev.rid

-- 9
SELECT rev.name, m.title, r.stars
FROM reviewer AS rev
       JOIN rating r ON rev.rid = r.rid
       JOIN movie m ON M.director = rev.name
ORDER BY rev.name, m.title, r.stars;

-- 10
SELECT reviewer.name as name FROM reviewer
      UNION ALL
      SELECT movie.title FROM movie
ORDER BY name

-- 11
SELECT DISTINCT m2.title FROM reviewer
      JOIN rating r on reviewer.rid = r.rid
      JOIN movie m2 on r.mid = m2.mid
      WHERE reviewer.name != 'Chris Jackson'
--
-- 12
SELECT DISTINCT v1.name, v2.name
FROM reviewer v1
  JOIN rating r1 ON v1.rid = r1.rid
  JOIN rating r2 ON r1.mid = r2.mid
  JOIN reviewer v2 ON v2.rid = r2.rid
WHERE v1.name < v2.name
ORDER BY v1.name, v2.name;

-- 13
SELECT movie.title, AVG(r.stars) as stars FROM movie
JOIN rating r on movie.mid = r.mid
GROUP BY movie.title
ORDER BY 2, 1

-- 14
SELECT reviewer.name, COUNT(r.rid)  FROM reviewer
JOIN rating r on reviewer.rid = r.rid
GROUP BY reviewer.rid
HAVING COUNT(r.rid) > 2
ORDER BY 1

-- 15
SELECT string_agg(title, ',' ORDER BY title), director
FROM movie
GROUP BY director
HAVING COUNT(director) > 1
ORDER BY 2;

-- 16
SELECT r.name, mv.title
FROM rating r1
       JOIN rating r2 ON r1.mid = r2.mid
                           AND r1.rid = r2.rid
                           AND r1.ratingdate > r2.ratingdate
                           AND r1.stars > r2.stars
       JOIN movie mv ON r1.mid = mv.mid
       JOIN reviewer r on r1.rid = r.rid

ORDER BY 1, 2;

-- 17
SELECT rev.name, m.title
FROM rating r1
  JOIN rating r2 ON r1.mid = r2.mid AND r1.rid = r2.rid
  JOIN movie m ON m.mid = r1.mid
  JOIN reviewer rev ON rev.rid = r1.rid
WHERE r1.ratingdate > r2.ratingdate AND r1.stars > r2.stars
ORDER BY 1, 2;

-- #1 Найти имена всех студентов кто дружит с кем-то по имени Gabriel.
SELECT h2.name
FROM highschooler h1
       JOIN friend f ON h1.id = f.id1
       JOIN highschooler h2 ON h2.id = f.id2
WHERE h1.name = 'Gabriel';

-- #2 Для всех студентов, кому понравился кто-то на 2 или более классов младше,
-- чем он вывести имя этого студента и класс, а так же имя и класс студента
-- который ему нравится.
SELECT h1.name, h1.grade, h2.name, H2.grade
FROM highschooler h1
       JOIN likes l on h1.id = l.id1
       JOIN highschooler h2 on l.id2 = h2.id
WHERE h1.grade - h2.grade > 1

-- #3 Для каждой пары студентов, которые нравятся друг другу взаимно вывести
-- имя и класс обоих студентов.
-- Включать каждую пару только 1 раз с именами в алфавитном порядке.
SELECT h1.name, h1.grade, h2.name, h2.grade
FROM likes k1
       JOIN likes k2 ON k1.id1 = k2.id2 AND k1.id2 = k2.id1
       JOIN highschooler h1 ON h1.id = k1.id1
       JOIN highschooler h2 ON h2.id = k1.id2
WHERE h1.name < h2.name
ORDER BY 1, 3;

-- #4 Найти всех студентов, которые не встречаются в таблице лайков
-- (никому не нравится и ему никто не нравится), вывести их имя и класс.
-- Отсортировать по классу, затем по имени в классе.
SELECT h.name, h.grade
FROM highschooler AS h
       LEFT JOIN likes l on h.id = l.id1
       LEFT JOIN likes l2 on h.id = l2.id2
WHERE l.id2 ISNULL
  AND l2.id1 ISNULL
ORDER BY 2, 1;

-- #5 Для каждой ситуации, когда студенту A нравится студент B,
-- но B никто не нравится, вывести имена и классы A и B.

SELECT h.name, h.grade, h2.name, h2.grade
FROM highschooler AS h
       JOIN likes l on h.id = l.id1
       LEFT JOIN likes l2 on l2.id1 = l.id2
       JOIN highschooler h2 on l.id2 = h2.id
WHERE l2.id1 ISNULL
ORDER BY 1, 3;

-- #6 Найти имена и классы, которые имеют друзей только в том же классе.
-- Вернуть результат, отсортированный по классу, затем имени в классе.
SELECT h.name, h.grade
FROM highschooler h
  JOIN friend f ON h.id = f.id1
  LEFT JOIN highschooler o
    ON f.id2 = o.id AND h.grade <> o.grade
GROUP BY h.id, h.name, h.grade
HAVING COUNT(o.id) = 0
ORDER BY h.grade, h.name;

SELECT res.name, res.grade
FROM (
       SELECT frd_cnt.*, MAX(frd_cnt.cnt) OVER () AS max
       FROM (
              SELECT h.*, (COUNT(f.id2)) AS cnt
              FROM highschooler h
                LEFT JOIN friend f ON f.id1 = h.id
              GROUP BY h.id
            ) AS frd_cnt
     ) AS res
WHERE res.cnt = res.max
ORDER BY 1, 2;

SELECT frd_cnt.*, MAX(frd_cnt.cnt)  AS max
       FROM (
              SELECT h.*, (COUNT(f.id2)) AS cnt
              FROM highschooler h
                LEFT JOIN friend f ON f.id1 = h.id
              GROUP BY h.id
            ) AS frd_cnt