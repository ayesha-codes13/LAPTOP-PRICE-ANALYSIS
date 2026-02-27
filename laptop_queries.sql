drop table laptops;
CREATE TABLE laptops (
    product_id SERIAL PRIMARY KEY,
    product VARCHAR(255),
    type VARCHAR(100),
    inches NUMERIC(4,2),
    ram INT,
    os VARCHAR(50),
    weight NUMERIC(5,2),
    price NUMERIC(10,2),
    screen VARCHAR(50),
    screenw INT,
    screenh INT,
    touchscreen BOOLEAN,
    ipspanel BOOLEAN,
    retina BOOLEAN,
    cpu_brand VARCHAR(50),
    cpu_freq NUMERIC(4,2),
    cpu_model VARCHAR(50),
    primary_storage INT,
    secondary_storage INT,
    primary_storage_type VARCHAR(50),
    secondary_storage_type VARCHAR(50),
    gpu_brand VARCHAR(50),
    gpu_model VARCHAR(50),
    total_storage_gb INT,
    storage_type VARCHAR(50),
    cpu_generation VARCHAR(50),
    price_segment VARCHAR(50)
);
COPY laptops(
    product, type, inches, ram, os, weight, price, screen, screenw, screenh,
    touchscreen, ipspanel, retina, cpu_brand, cpu_freq, cpu_model,
    primary_storage, secondary_storage, primary_storage_type, secondary_storage_type,
    gpu_brand, gpu_model, total_storage_gb, storage_type, cpu_generation, price_segment
)
FROM 'C:\Users\Public\laptop prices analysis\laptop_prices_cleaned_final.csv'
DELIMITER ','
CSV HEADER;

select  * from laptops;

-- 1 Remove trailing spaces in product names
UPDATE laptops SET product = TRIM(product);

-- 2 Lowercase OS values
UPDATE laptops SET os = LOWER(os);

-- 3 Fix weight values with commas
UPDATE laptops SET weight = REPLACE(weight::text, ',', '.')::numeric;

-- 4 Standardize "Windows 10" variations
UPDATE laptops SET os = 'windows 10' WHERE os ILIKE '%win 10%';

-- 5 Replace missing OS with 'unknown'
UPDATE laptops SET os = 'unknown' WHERE os IS NULL OR os = '';

-- 6 Fix RAM values that are negative
UPDATE laptops SET ram = ABS(ram) WHERE ram < 0;

-- 7 Remove duplicate product names
DELETE FROM laptops WHERE product IN (
    SELECT product FROM laptops GROUP BY product HAVING COUNT(*) > 1
);

-- 8 Replace NULL retina values with FALSE
UPDATE laptops SET retina = FALSE WHERE retina IS NULL;

-- 9 Standardize storage_type text
UPDATE laptops SET storage_type = LOWER(TRIM(storage_type));

-- 10 Fix typos in price_segment
UPDATE laptops SET price_segment = 'budget' WHERE price_segment ILIKE 'budegt';

-- 11 Remove extra spaces in cpu_model
UPDATE laptops SET cpu_model = REGEXP_REPLACE(cpu_model, '\s+', ' ', 'g');

-- 12 Convert laptop type to lowercase
UPDATE laptops SET type = LOWER(type);

-- 13 Normalize gpu_brand names
UPDATE laptops SET gpu_brand = 'NVIDIA' WHERE gpu_brand ILIKE '%nvidia%';

-- 14 Convert touchscreen NULLs to false
UPDATE laptops SET touchscreen = FALSE WHERE touchscreen IS NULL;

-- 15 Fix negative screen sizes
UPDATE laptops SET inches = ABS(inches) WHERE inches < 0;

-- 16 Standardize CPU brand naming
UPDATE laptops SET cpu_brand = 'Intel' WHERE cpu_brand ILIKE 'intel%';

-- 17 Remove weird characters in product names
UPDATE laptops SET product = REGEXP_REPLACE(product, '[^a-zA-Z0-9\s-]', '', 'g');

-- 18 Replace NULL price with average price
UPDATE laptops
SET price = (SELECT AVG(price) FROM laptops)
WHERE price IS NULL;

-- 19 Clean gpu_model strange characters
UPDATE laptops SET gpu_model = TRIM(gpu_model);

-- 20 Fix screen resolution missing width or height
UPDATE laptops
SET screenw = 1920
WHERE screenw IS NULL OR screenw = 0;

-- 21 Replace blank cpu_generation with 'unknown'
UPDATE laptops SET cpu_generation = 'unknown' WHERE cpu_generation = '';

-- 22 Convert primary_storage_type to upper case
UPDATE laptops SET primary_storage_type = UPPER(primary_storage_type);

-- 23 Convert weight NULL to 0
UPDATE laptops SET weight = 0 WHERE weight IS NULL;

-- 24 Remove laptops with no model name
DELETE FROM laptops WHERE product IS NULL;

-- 25 Fill missing gpu_brand
UPDATE laptops SET gpu_brand = 'unknown' WHERE gpu_brand IS NULL;

-- 26 Create a new column price_per_gb
ALTER TABLE laptops ADD COLUMN price_per_gb NUMERIC;

-- 28 Create cpu_full column
ALTER TABLE laptops ADD COLUMN cpu_full VARCHAR(255);

-- 29 Update cpu_full
UPDATE laptops SET cpu_full = cpu_brand || ' ' || cpu_model;

-- 30 Create resolution column
ALTER TABLE laptops ADD COLUMN resolution VARCHAR(20);

-- 31 Fill resolution values
UPDATE laptops SET resolution = screenw || 'x' || screenh;

-- 32 Add storage_total column
ALTER TABLE laptops ADD COLUMN storage_total INT;

-- 33 Compute total storage
UPDATE laptops
SET storage_total = COALESCE(primary_storage,0) + COALESCE(secondary_storage,0);

-- 34 Create inch_category
ALTER TABLE laptops ADD COLUMN inch_category VARCHAR(20);

-- 35 Update inch categories
UPDATE laptops
SET inch_category =
    CASE
        WHEN inches < 14 THEN 'small'
        WHEN inches BETWEEN 14 AND 15.6 THEN 'medium'
        ELSE 'large'
    END;

-- 36 Create performance_score column
ALTER TABLE laptops ADD COLUMN performance_score NUMERIC;

-- 37 Compute performance score
UPDATE laptops
SET performance_score = (cpu_freq * ram) / weight;

-- 38 Remove invalid CPU frequencies
UPDATE laptops SET cpu_freq = NULL WHERE cpu_freq <= 0;

-- 39 Normalize boolean columns
UPDATE laptops SET touchscreen = COALESCE(touchscreen, FALSE);
UPDATE laptops SET ipspanel = COALESCE(ipspanel, FALSE);
UPDATE laptops SET retina = COALESCE(retina, FALSE);

-- 40 Standardize OS names
UPDATE laptops SET os = 'macos' WHERE os ILIKE '%mac%';

-- 41 Fix missing GPU model
UPDATE laptops SET gpu_model = 'integrated' WHERE gpu_model IS NULL;

-- 42 Fix broken product names with double spaces
UPDATE laptops SET product = REGEXP_REPLACE(product, ' +', ' ', 'g');

-- 43 Remove invalid negative prices
UPDATE laptops SET price = NULL WHERE price < 0;

-- 44 Standardize type values
UPDATE laptops SET type = 'ultrabook' WHERE type ILIKE '%ultra%';

-- 45 Extract CPU series number
ALTER TABLE laptops ADD COLUMN cpu_series VARCHAR(10);

-- 46 Populate CPU series (example: i5-8250U → i5)
UPDATE laptops
SET cpu_series = SUBSTRING(cpu_model FROM 'i[3579]');

-- 47 Top 10 most expensive laptops
SELECT * FROM laptops ORDER BY price DESC LIMIT 10;

-- 48 Average price by OS
SELECT os, AVG(price) FROM laptops GROUP BY os;

-- 49 Count laptops by cpu_brand
SELECT cpu_brand, COUNT(*) FROM laptops GROUP BY cpu_brand;

-- 50 Show all gaming laptops
SELECT * FROM laptops WHERE type ILIKE '%gaming%';

-- 51 Laptops with touchscreen & IPS panel
SELECT * FROM laptops WHERE touchscreen = TRUE AND ipspanel = TRUE;

-- 52 Price segment count
SELECT price_segment, COUNT(*) FROM laptops GROUP BY price_segment;

-- 53 Laptops with >= 16GB RAM
SELECT * FROM laptops WHERE ram >= 16;

-- 54 Find laptops with retina display
SELECT product, price FROM laptops WHERE retina = TRUE;

-- 55 Filter laptops lighter than 1.5 kg
SELECT * FROM laptops WHERE weight < 1.5;

-- 56 Resolution above Full HD
SELECT * FROM laptops WHERE screenw > 1920;

-- 57 CPU brands and average frequency
SELECT cpu_brand, AVG(cpu_freq) FROM laptops GROUP BY cpu_brand;

-- 58 Count ASUS laptops
SELECT COUNT(*) FROM laptops WHERE product ILIKE '%asus%';

-- 59 Storage > 1TB total
SELECT * FROM laptops WHERE total_storage_gb > 1024;

-- 60 Price bucket
SELECT
    CASE
        WHEN price < 40000 THEN 'budget'
        WHEN price < 70000 THEN 'midrange'
        ELSE 'premium'
    END AS price_class,
    COUNT(*)
FROM laptops
GROUP BY price_class;

-- 61 GPU brand average price
SELECT gpu_brand, AVG(price) FROM laptops GROUP BY gpu_brand;

-- 62 Highest performance score
SELECT product, performance_score
FROM laptops
ORDER BY performance_score DESC LIMIT 1;

select * from laptops

DO $$
DECLARE 
    col text;
    query text;
BEGIN
    FOR col IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'laptops'
          AND table_schema = 'public'
    LOOP
        EXECUTE format(
            'SELECT CASE WHEN EXISTS (SELECT 1 FROM laptops WHERE %I IS NOT NULL) THEN FALSE ELSE TRUE END',
            col
        ) INTO query;

        IF query = 't' THEN
            EXECUTE format('ALTER TABLE laptops DROP COLUMN %I;', col);
            RAISE NOTICE 'Dropped column: %', col;
        END IF;
    END LOOP;
END $$;

ALTER TABLE laptops
DROP COLUMN price_per_gb;

SELECT 
    product,
    screenw || 'x' || screenh AS resolution,
    CASE
        WHEN screenw = 1366 AND screenh = 768 THEN 'HD (720p)'
        WHEN screenw = 1600 AND screenh = 900 THEN 'HD+'
        WHEN screenw = 1920 AND screenh = 1080 THEN 'FHD (1080p)'
        WHEN screenw = 2560 AND screenh = 1440 THEN '2K / QHD'
        WHEN screenw = 2560 AND screenh = 1600 THEN 'WQXGA'
        WHEN screenw = 2880 AND screenh = 1800 THEN 'Retina / 2K+'
        WHEN screenw = 3000 AND screenh = 2000 THEN '3K'
        WHEN screenw = 3840 AND screenh = 2160 THEN '4K / UHD'
        ELSE 'Other / Unknown'
    END AS resolution_category
FROM laptops;

select * from laptops;

ALTER TABLE laptops
DROP COLUMN resolution,
DROP COLUMN storage_total,
DROP COLUMN inch_category,
DROP COLUMN cpu_series;

COPY laptops TO 'C:\Users\Public\laptops2_export.csv'
DELIMITER ','
CSV HEADER;