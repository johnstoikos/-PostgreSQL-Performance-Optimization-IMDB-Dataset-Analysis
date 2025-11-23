-- μέγεθος
SELECT pg_size_pretty(pg_total_relation_size('title_basics')) AS title_basics_size;

DROP TABLE IF EXISTS title_basics_part CASCADE;

CREATE TABLE title_basics_part
(
    LIKE title_basics INCLUDING DEFAULTS INCLUDING GENERATED
)
PARTITION BY RANGE (startyear);

-- < 1900
CREATE TABLE IF NOT EXISTS title_basics_part_before_1900
  PARTITION OF title_basics_part
  FOR VALUES FROM (MINVALUE) TO (1900);

-- 1900–1949
CREATE TABLE IF NOT EXISTS title_basics_part_1900_1950
  PARTITION OF title_basics_part
  FOR VALUES FROM (1900) TO (1950);

--  1950–1999
CREATE TABLE IF NOT EXISTS title_basics_part_1950_2000
  PARTITION OF title_basics_part
  FOR VALUES FROM (1950) TO (2000);

-- 2000–2024
CREATE TABLE IF NOT EXISTS title_basics_part_2000_2025
  PARTITION OF title_basics_part
  FOR VALUES FROM (2000) TO (2025) 

-- 2025+ 
CREATE TABLE IF NOT EXISTS title_basics_part_after_2025
  PARTITION OF title_basics_part
  FOR VALUES FROM (2025) TO (MAXVALUE);

--  DEFAULT για rows με startyear IS NULL
CREATE TABLE IF NOT EXISTS title_basics_part_nulls
  PARTITION OF title_basics_part
  DEFAULT;


  -- Γέμισμα
INSERT INTO title_basics_part
SELECT * FROM title_basics;

--indexes 
CREATE INDEX IF NOT EXISTS idx_title_basics_part_tconst
  ON title_basics_part (tconst);

CREATE INDEX IF NOT EXISTS idx_title_basics_part_startyear
  ON title_basics_part (startyear);

VACUUM ANALYZE title_basics_part;

--Γρήγορος έλεγχος 
SELECT (SELECT count(*) FROM title_basics) AS orig_rows,
       (SELECT count(*) FROM title_basics_part) AS part_rows;


--Πόσες γραμμές έχει κάθε partition
SELECT relname AS partition_name, n_live_tup AS estimated_rows
FROM pg_stat_user_tables
WHERE relname ILIKE 'title_basics_part%'
ORDER BY relname;


