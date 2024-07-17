# Consulta nulos em amazon_product
SELECT
COUNTIF(product_id IS NULL) AS product_id,
  COUNTIF(product_name IS NULL) AS product_name,
  COUNTIF(category IS NULL) AS category,
  COUNTIF(discounted_price IS NULL) AS discounted_price,
  COUNTIF(actual_price IS NULL) AS actual_price,
  COUNTIF(discount_percentage IS NULL) AS discount_percentage,
  COUNTIF(about_product IS NULL) AS about_product
FROM `amazon.amazon_product`;


# Verificando quem são os nulos em about_product
SELECT
product_id,
product_name,
category,
about_product
FROM `amazon.amazon_product`
WHERE about_product IS NULL


# Consulta nulos em amazon_review
SELECT
  COUNTIF(user_id IS NULL) AS user_id,
  COUNTIF(user_name IS NULL) AS user_name,
  COUNTIF(review_id IS NULL) AS review_id,
  COUNTIF(review_title IS NULL) AS review_title,
  COUNTIF(review_content IS NULL) AS review_content,
  COUNTIF(img_link IS NULL) AS img_link,
  COUNTIF(product_link IS NULL) AS product_link,
  COUNTIF(product_id IS NULL) AS product_id,
  COUNTIF(rating IS NULL) AS rating,
  COUNTIF (rating_count IS NULL) AS rating_count
FROM `projeto04-amazon.amazon.amazon_review`

  
#Consulta duplicados em amazon_product
SELECT
  product_id,
  COUNT(*) AS num_duplicatas
FROM
  `amazon.amazon_product`
GROUP BY
  product_id
HAVING COUNT(*) > 1;
-- 96 id duplicados
SELECT
  COUNT(*) AS total_product_id_duplicados
FROM (
  SELECT
    product_id
  FROM
    `amazon.amazon_product`
  GROUP BY
    product_id
  HAVING COUNT(*) > 1
) AS duplicados;


#Consulta duplicados em amazon_review
SELECT
  product_id,
  COUNT(*) AS num_duplicatas
FROM
  `amazon.amazon_product`
GROUP BY
  product_id
HAVING COUNT(*) > 1;
-- 92 id duplicados
SELECT
  COUNT(*) AS total_product_id_duplicados
FROM (
  SELECT
    product_id
  FROM
    `amazon.amazon_product`
  GROUP BY
    product_id
  HAVING COUNT(*) > 1
) AS duplicados;

#Consulta para criar nova tabela amazon_product_limpa sem duplicados


CREATE TABLE `amazon.amazon_product_limpa` AS
WITH products_limpo AS (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY product_id) AS row_num
  FROM
    `amazon.amazon_product`
)
SELECT
  *
FROM
  products_limpo
WHERE
  row_num = 1;


#Consulta para criar nova tabela amazon_review_limpa sem duplicados
CREATE TABLE `amazon.amazon_review_limpa` AS
WITH review_limpo AS (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY product_id) AS row_num
  FROM
    `amazon.amazon_review`
)
SELECT
  *
FROM
  review_limpo
WHERE
  row_num = 1;


#Consulta para unir tabelas

CREATE TABLE `amazon.amazon_union` AS
SELECT
  up.product_id,
  up.product_name,
  up.category,
  up.discounted_price,
  up.actual_price,
  up.discount_percentage,
  up.about_product,
  ur.user_id,
  ur.user_name,
  ur.review_id,
  ur.review_title,
  ur.review_content,
  ur.img_link,
  ur.product_link,
  ur.rating,
  ur.rating_count
FROM
  `amazon.amazon_product_limpa` AS up
INNER JOIN
  `amazon.amazon_review_limpa` AS ur
ON
  up.product_id = ur.product_id;


#Criação de nova tabela com limpeza da categoria
  
CREATE TABLE amazon.amazon_clean AS
SELECT
  *,
  SPLIT(category, '|')[SAFE_OFFSET(0)] AS category_limpa
FROM
  amazon.amazon_union;


#Criação de dummys para img e product_link

CREATE OR REPLACE TABLE amazon.amazon_dummy AS
  SELECT
    *,
    CASE WHEN img_link IS NOT NULL THEN 1 ELSE 0 END AS img_link_dummy,
    CASE WHEN product_link IS NOT NULL THEN 1 ELSE 0 END AS product_link_dummy
  FROM
    amazon.amazon_clean

  
#Join para incluir score_sentimento

CREATE TABLE `amazon.amazon_tratada` AS
SELECT
  u.product_id,
  u.product_name,
  u.category_limpa,
  u.discounted_price,
  u.actual_price,
  u.discount_percentage,
  u.about_product,
  u.user_id,
  u.user_name,
  u.review_id,
  u.img_link_dummy,
  u.product_link_dummy,
  u.rating,
  u.rating_count,
  s.product_id,
  s.score_sentimento
FROM
  `amazon.amazon_dummy` AS u
INNER JOIN
  `amazon.amazon_sentimento` AS s
ON
  u.product_id = s.product_id;


# Consulta para quartis e segmentação

WITH discount_quartil AS (
  # Criação da nova variável discount_quartil na tabela amazon_completa
  SELECT
    product_id,
    product_name,
    category_limpa,
    discount_percentage,
    rating,
    score_sentimento,
    CASE
      WHEN discount_percentage < 0.10 THEN 1
      WHEN discount_percentage BETWEEN 0.10 AND 0.20 THEN 2
      WHEN discount_percentage BETWEEN 0.21 AND 0.40 THEN 3
      WHEN discount_percentage > 0.40 THEN 4
      ELSE NULL 
    END AS discount_quartil,
    CASE
      WHEN discount_percentage < 0.10 THEN 'baixo'
      WHEN discount_percentage BETWEEN 0.10 AND 0.20 THEN 'medio'
      WHEN discount_percentage BETWEEN 0.21 AND 0.40 THEN 'medio'
      WHEN discount_percentage > 0.40 THEN 'alto'
      ELSE NULL 
    END AS discount_seg
  FROM
    `amazon.amazon_tratada`
),
rating_quartil AS (
  # Criação da nova variável rating_quartil na tabela amazon_completa
  SELECT
    product_id,
    CASE
      WHEN rating BETWEEN 1.0 AND 2.0 THEN 1
      WHEN rating BETWEEN 2.1 AND 3.0 THEN 2
      WHEN rating BETWEEN 3.1 AND 4.0 THEN 3
      WHEN rating > 4.0 THEN 4
      ELSE NULL 
    END AS rating_quartil,
    CASE
      WHEN rating BETWEEN 1.0 AND 2.0 THEN 'baixo'
      WHEN rating BETWEEN 2.1 AND 3.0 THEN 'medio'
      WHEN rating BETWEEN 3.1 AND 4.0 THEN 'medio'
      WHEN rating > 4.0 THEN 'alto'
      ELSE NULL 
    END AS rating_seg
  FROM
    `amazon.amazon_tratada`
),
sentimento_quartil AS (
  # Criação da nova variável sentimento_quartil na tabela amazon_completa
  SELECT
    product_id,
    cast(NTILE(4) OVER (ORDER BY score_sentimento) as int) AS sentimento_quartil
  FROM
    `amazon.amazon_tratada`
),
score_seg AS (
  # Criando segmentação para variável score_sentimento
  SELECT
    product_id,
    CASE
      WHEN sentimento_quartil = 1 THEN 'ruim'
      WHEN sentimento_quartil IN (2, 3) THEN 'neutro'
      WHEN sentimento_quartil = 4 THEN 'positivo'
      ELSE NULL 
    END AS score_seg
  FROM
    sentimento_quartil
)
# Selecionando e sobrescrevendo a tabela amazon_completa com as novas variáveis
SELECT
  a.*,
  d.discount_quartil,
  d.discount_seg,
  r.rating_quartil,
  r.rating_seg,
  s.sentimento_quartil,
  ss.score_seg
FROM
  `amazon.amazon_tratada` a
LEFT JOIN discount_quartil d ON a.product_id = d.product_id
LEFT JOIN rating_quartil r ON a.product_id = r.product_id
LEFT JOIN sentimento_quartil s ON a.product_id = s.product_id
LEFT JOIN score_seg ss ON a.product_id = ss.product_id;
