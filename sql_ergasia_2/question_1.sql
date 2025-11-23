-- 1) Ποιοι συντελεστές/ηθοποιοί συμμετέχουν
SELECT n.primaryname, n.primaryprofession
FROM name_basics n
WHERE n.knownfortitles IS NOT NULL
  AND 'tt0111161' = ANY(string_to_array(n.knownfortitles, ','));

  EXPLAIN ANALYSE 
SELECT n.primaryname, n.primaryprofession
FROM name_basics n
WHERE n.knownfortitles IS NOT NULL
  AND 'tt0111161' = ANY(string_to_array(n.knownfortitles, ','));


-- 2) Κατηγορία παραγωγής & είδη
SELECT t.primarytitle, t.titletype, t.genres
FROM title_basics AS t
WHERE t.tconst = 'tt0806910';

 EXPLAIN ANALYSE 
 SELECT t.primarytitle, t.titletype, t.genres
FROM title_basics AS t
WHERE t.tconst = 'tt0806910';


-- 3) Μέση βαθμολογία παραγωγών στις οποίες έχει συμμετάσχει ένας συγκεκριμένος συντελεστής
SELECT n.primaryname, AVG(r.averagerating) AS avg_rating
FROM name_basics n
JOIN title_ratings r
  ON r.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.primaryname = 'Brad Pitt'
GROUP BY n.primaryname;

EXPLAIN ANALYSE
SELECT n.primaryname, AVG(r.averagerating) AS avg_rating
FROM name_basics n
JOIN title_ratings r
  ON r.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.primaryname = 'Brad Pitt'
GROUP BY n.primaryname;


-- 4) Σε ποιες παραγωγές ένας πρωταγωνιστής είχε και άλλο ρόλο
SELECT n.primaryname, t.primarytitle, n.primaryprofession
FROM name_basics n
JOIN title_basics t
  ON t.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.nconst = 'nm0020404'
  AND (
        ('actor'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR
         'actress' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
        AND
        ('director' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'producer' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'writer'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
      )
ORDER BY t.primarytitle;

EXPLAIN ANALYSE 
SELECT n.primaryname, t.primarytitle, n.primaryprofession
FROM name_basics n
JOIN title_basics t
  ON t.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.nconst = 'nm0020404'
  AND (
        ('actor'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR
         'actress' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
        AND
        ('director' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'producer' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'writer'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
      )
ORDER BY t.primarytitle;





-- 5) Δημοφιλέστερη παραγωγή κάθε δεκαετίας (numVotes)
WITH joined AS (
  SELECT t.tconst, t.primarytitle, t.startyear, tr.numvotes,
         (t.startyear/10)*10 AS decade
  FROM title_basics AS t
  JOIN title_ratings AS tr ON tr.tconst = t.tconst
  WHERE t.startyear IS NOT NULL
),
ranked AS (
  SELECT j.*,
         ROW_NUMBER() OVER (PARTITION BY decade ORDER BY numvotes DESC NULLS LAST) AS rn
  FROM joined AS j
)
SELECT decade, tconst, primarytitle, numvotes
FROM ranked
WHERE rn = 1
ORDER BY decade;


EXPLAIN ANALYSE 
WITH joined AS (
  SELECT t.tconst, t.primarytitle, t.startyear, tr.numvotes,
         (t.startyear/10)*10 AS decade
  FROM title_basics AS t
  JOIN title_ratings AS tr ON tr.tconst = t.tconst
  WHERE t.startyear IS NOT NULL
),
ranked AS (
  SELECT j.*,
         ROW_NUMBER() OVER (PARTITION BY decade ORDER BY numvotes DESC NULLS LAST) AS rn
  FROM joined AS j
)
SELECT decade, tconst, primarytitle, numvotes
FROM ranked
WHERE rn = 1
ORDER BY decade;




--Queries 2-5 μετά τα partitions


-- 2) Κατηγορία παραγωγής & είδη
SELECT t.primarytitle, t.titletype, t.genres
FROM title_basics_part AS t
WHERE t.tconst = 'tt0806910';

EXPLAIN ANALYSE 
SELECT t.primarytitle, t.titletype, t.genres
FROM title_basics_part AS t
WHERE t.tconst = 'tt0806910';


-- 3) Μέση βαθμολογία παραγωγών στις οποίες έχει συμμετάσχει ένας συγκεκριμένος συντελεστής
SELECT n.primaryname, AVG(r.averagerating) AS avg_rating
FROM name_basics n
JOIN title_ratings r
  ON r.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.primaryname = 'Brad Pitt'
GROUP BY n.primaryname;

EXPLAIN ANALYSE
SELECT n.primaryname, AVG(r.averagerating) AS avg_rating
FROM name_basics n
JOIN title_ratings r
  ON r.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.primaryname = 'Brad Pitt'
GROUP BY n.primaryname;


-- 4) Σε ποιες παραγωγές ένας πρωταγωνιστής είχε και άλλο ρόλο
SELECT n.primaryname, t.primarytitle, n.primaryprofession
FROM name_basics n
JOIN title_basics_part t
  ON t.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.nconst = 'nm0020404'
  AND (
        ('actor'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR
         'actress' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
        AND
        ('director' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'producer' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'writer'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
      )
ORDER BY t.primarytitle;

EXPLAIN ANALYSE 
SELECT n.primaryname, t.primarytitle, n.primaryprofession
FROM name_basics n
JOIN title_basics_part t
  ON t.tconst = ANY (regexp_split_to_array(coalesce(n.knownfortitles,''), ',\s*'))
WHERE n.nconst = 'nm0020404'
  AND (
        ('actor'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR
         'actress' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
        AND
        ('director' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'producer' = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
         OR 'writer'   = ANY (regexp_split_to_array(lower(coalesce(n.primaryprofession,'')), ',\s*'))
        )
      )
ORDER BY t.primarytitle;


-- 5) Δημοφιλέστερη παραγωγή κάθε δεκαετίας (numVotes)
WITH joined AS (
  SELECT t.tconst, t.primarytitle, t.startyear, tr.numvotes,
         (t.startyear/10)*10 AS decade
  FROM title_basics_part AS t
  JOIN title_ratings AS tr ON tr.tconst = t.tconst
  WHERE t.startyear IS NOT NULL
),
ranked AS (
  SELECT j.*,
         ROW_NUMBER() OVER (PARTITION BY decade ORDER BY numvotes DESC NULLS LAST) AS rn
  FROM joined AS j
)
SELECT decade, tconst, primarytitle, numvotes
FROM ranked
WHERE rn = 1
ORDER BY decade;

EXPLAIN ANALYSE 
WITH joined AS (
  SELECT t.tconst, t.primarytitle, t.startyear, tr.numvotes,
         (t.startyear/10)*10 AS decade
  FROM title_basics_part AS t
  JOIN title_ratings AS tr ON tr.tconst = t.tconst
  WHERE t.startyear IS NOT NULL
),
ranked AS (
  SELECT j.*,
         ROW_NUMBER() OVER (PARTITION BY decade ORDER BY numvotes DESC NULLS LAST) AS rn
  FROM joined AS j
)
SELECT decade, tconst, primarytitle, numvotes
FROM ranked
WHERE rn = 1
ORDER BY decade;

--Δικό μας παράδειγμα, φίλτρο με βάση τη δεκαετία

EXPLAIN ANALYZE
SELECT t.primarytitle, tr.numvotes
FROM title_basics_part t
JOIN title_ratings tr ON tr.tconst = t.tconst
WHERE t.startyear >= 1990 AND t.startyear < 2000
ORDER BY tr.numvotes DESC
LIMIT 1;


