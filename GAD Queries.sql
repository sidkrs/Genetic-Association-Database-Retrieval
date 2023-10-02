-- GAD: The Genetic Association Database



use gad;

DROP TABLE IF EXISTS gad;

CREATE TABLE gad (
  gad_id int,
  association text,
  phenotype text,
  disease_class text,
  chromosome text,
  chromosome_band text,
  dna_start int,
  dna_end int,
  gene text,
  gene_name text,
  reference text,
  pubmed_id int,
  year int,
  population text
);

LOAD DATA LOCAL 
INFILE 'gad.csv'
INTO TABLE gad
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

-- Explore the content of the various columns in your gad table.
-- What are all genes that are "G protein-coupled" receptors
-- (These genes are often the target for new drugs, so are of particular interest)

SELECT gene, gene_name, chromosome
FROM gad
WHERE gene_name LIKE '%G protein-coupled%'
ORDER BY gene;


-- How many records are there for each disease class?
 
SELECT disease_class, count(*) AS num_records
FROM gad
GROUP BY disease_class
ORDER BY num_records DESC;


-- What are the distinct phenotypes related to the disease class "IMMUNE"

SELECT DISTINCT phenotype
FROM gad
WHERE disease_class = 'IMMUNE'
GROUP BY phenotype, disease_class
ORDER BY phenotype ASC;


-- Show the immune-related phenotypes based on the number of records reporting a 
-- positive association with that phenotype.
-- With a count of >60

SELECT phenotype, count(*) AS num_records
FROM gad
WHERE disease_class = 'IMMUNE' AND association = 'Y'
GROUP BY phenotype
HAVING num_records >= 60
ORDER BY num_records DESC;


-- List the gene symbol, gene name, and chromosome attributes related
-- to genes positively linked to asthma (association = Y).


SELECT DISTINCT gene, gene_name, chromosome
FROM gad
WHERE association = 'Y' AND phenotype LIKE '%asthma%'
GROUP BY gene, gene_name, chromosome
ORDER BY gene;


-- For each chromosome, over what range of nucleotides do we find genes mentioned in GAD?

SELECT gene, chromosome, min(dna_start) AS min_dna_start, max(dna_end) AS max_dna_end
FROM gad
WHERE dna_start > 0 AND chromosome != ''
GROUP BY chromosome, gene
ORDER BY chromosome ASC;


-- For each gene, what is the earliest and latest reported year involving a positive association

SELECT gene, min(year) AS min_year, max(year) AS max_year, count(*) AS num_records
FROM gad
WHERE year > 1000 AND association = 'Y'
GROUP BY gene
ORDER BY num_records DESC;


-- Which genes have a total of at least 100 positive association records (across all phenotypes)?

SELECT gene, gene_name, count(*) AS num_records
FROM gad
WHERE association = 'Y'
GROUP BY gene, gene_name
HAVING num_records >= 100
ORDER BY num_records DESC;



-- How many total GAD records are there for each population group?
-- What are the top 5?


SELECT population, COUNT(*) AS num_records
FROM gad
WHERE population != '' and population > 0
GROUP BY population
ORDER BY num_records DESC
LIMIT 5;



-- What are the gad records involving a positive association between ANY asthma-linked gene and ANY disease/phenotype

SELECT gene, gene_name, association, phenotype, disease_class, population
FROM gad
WHERE gene IN (
  SELECT gene
  FROM gad
  WHERE association = 'Y' AND phenotype LIKE '%asthma%'
)
ORDER BY phenotype ASC;



-- How many times each of these asthma-gene-linked phenotypes occurs in our output table produced by the previous query.
-- Top 5 excluding asthma

SELECT phenotype, count(*) AS num_records
FROM gad
WHERE gene IN (
  SELECT gene
  FROM gad
  WHERE association = 'Y' AND phenotype LIKE '%asthma%'
)
AND phenotype NOT LIKE '%asthma%'
GROUP BY phenotype
ORDER BY num_records DESC
LIMIT 5;


-- What are the the top 10 most frequent gene symobls with any phenotype containing alzheimer's
-- Where are their positions on the human genome

SELECT DISTINCT gene, gene_name, dna_start, dna_end, (dna_end - dna_start) AS dna_range, count(*) AS num_records
FROM gad
WHERE phenotype LIKE '%alzheimer%'
AND dna_start > 0
GROUP BY gene, gene_name, dna_start, dna_end
ORDER BY num_records DESC
LIMIT 10;