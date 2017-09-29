-- MOVE DATABASE SCHEMA V1.0
-- NOTE: Important changes coming soon!

-- Dropping all existing tables if exist from schema
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS country_profile;
DROP TABLE IF EXISTS continent;
DROP TABLE IF EXISTS theme;
DROP TABLE IF EXISTS document;
DROP TABLE IF EXISTS document_tag;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS subcategory;

-- Table for user - for login purposes
CREATE TABLE user (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT, -- sequence
  first_name  VARCHAR(20),
  middle_name VARCHAR(20),
  last_name   VARCHAR(20),
  user_name   VARCHAR(20) UNIQUE,
  email       VARCHAR(20) UNIQUE,
  password    VARCHAR(30),
  description VARCHAR(20),
  country_id  VARCHAR(20), -- fk
  role        VARCHAR(20) DEFAULT 'MEMBER', -- ADMIN OR MEMBER
  user_created TIMESTAMP,
  user_updated TIMESTAMP,
  PRIMARY KEY(id)
);

-- Table for Country
CREATE TABLE country (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT, -- sequence
  continent_id  INT UNSIGNED NOT NULL, -- fk
  name          VARCHAR(20),
  short_name    VARCHAR(3),
  PRIMARY KEY(id)
);

-- Table for Country
CREATE TABLE country_profile (
  country_id    INT UNSIGNED NOT NULL, -- fk
  currency      VARCHAR(20),
  population    VARCHAR(20)
);

-- Table for Continents
CREATE TABLE continent (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT, -- sequence
  name  VARCHAR(20) NOT NULL UNIQUE,
  PRIMARY KEY(id)
);

-- Table for theme
CREATE TABLE theme (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT, -- sequence
  name        VARCHAR(20) NOT NULL UNIQUE,
  description VARCHAR(20),
  PRIMARY KEY(id)
);

-- Table for document
CREATE TABLE document (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT, -- sequence
  title           VARCHAR(20),
  description     VARCHAR(20),
  file_extension  VARCHAR(20),
  visibility      VARCHAR(10) DEFAULT 'PUBLIC',
  type            VARCHAR(20),
  user_id         INT UNSIGNED NOT NULL, -- fk
  category_id     INT UNSIGNED NOT NULL, -- fk
  country_id      INT UNSIGNED NOT NULL, -- fk
  theme_id        INT UNSIGNED NOT NULL, -- fk
  date_published  TIMESTAMP,
  date_updated    TIMESTAMP,
  PRIMARY KEY(id)
);

-- Table for document tag
CREATE TABLE document_tag (
  document_id INT UNSIGNED NOT NULL, -- fk
  tag         VARCHAR(20) NOT NULL,
  PRIMARY KEY (document_id, tag)
);

-- Table for category
CREATE TABLE category (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT, -- sequence
  name        VARCHAR(20) NOT NULL,
  description VARCHAR(20),
  PRIMARY KEY(id)
);

-- Table for subcategory
CREATE TABLE subcategory (
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(20),
  value VARCHAR(20),
  PRIMARY KEY (category_id, name)
);

-- Adding foreign keys for country
ALTER TABLE country ADD CONSTRAINT fk_country_continent_id
FOREIGN KEY (continent_id) REFERENCES continent(id);

-- Adding foreign keys for country profile
ALTER TABLE country_profile ADD CONSTRAINT fk_country_profile_id
FOREIGN KEY (country_id) REFERENCES country(id);

-- Adding foreign keys for document table
ALTER TABLE document ADD CONSTRAINT fk_document_user_id
FOREIGN KEY (user_id) REFERENCES user(id);

ALTER TABLE document ADD CONSTRAINT fk_document_category_id
FOREIGN KEY (category_id) REFERENCES category(id);

ALTER TABLE document ADD CONSTRAINT fk_document_country_id
FOREIGN KEY (country_id) REFERENCES country(id);

ALTER TABLE document ADD CONSTRAINT fk_document_theme_id
FOREIGN KEY (theme_id) REFERENCES theme(id);

-- Adding foreign key to document tag
ALTER TABLE document_tag ADD CONSTRAINT fk_document_tag_id
FOREIGN KEY (document_id) REFERENCES document(id);

-- Adding foreign key to subcategory
ALTER TABLE subcategory ADD CONSTRAINT fk_subcategory_id
FOREIGN KEY (category_id) REFERENCES category(id);

-- Changing the start values of AUTO_INCREMENT Columns
ALTER TABLE user AUTO_INCREMENT       = 300000;
ALTER TABLE country AUTO_INCREMENT    = 200000;
ALTER TABLE continent AUTO_INCREMENT  = 205000;
ALTER TABLE document AUTO_INCREMENT   = 100000;
ALTER TABLE theme AUTO_INCREMENT      = 100000;
ALTER TABLE category AUTO_INCREMENT   = 100000;

-- Adding extra constraints
-- Constraint for user role: GUEST, MEMBER, ADMIN or SUPER_ADMIN only!
ALTER TABLE user ADD CONSTRAINT chk_user_role
CHECK (role in ('GUEST', 'MEMBER', 'ADMIN', 'SUPER_ADMIN'));

-- Constraint for document visibility: PUBLIC or PRIVATE
ALTER TABLE document ADD CONSTRAINT chk_document_visibility
CHECK (visibility in ('PUBLIC', 'PRIVATE'));

-- Constraint for document type
ALTER TABLE document ADD CONSTRAINT chk_document_type
CHECK (type in ('TEXT', 'IMAGE', 'VIDEO', 'CHART', 'DATA', 'AUDIO'));

-- Dropping triggers
DROP TRIGGER IF EXISTS trg_check_existing_user;

-- Adding triggers
-- check if user exists or not
CREATE TRIGGER trg_check_existing_user
BEFORE INSERT ON user
FOR EACH ROW
BEGIN
  DECLARE counter INT;
  SELECT COUNT(*) FROM user
  WHERE email = NEW.email AND password = NEW.password INTO counter;

  IF (counter = 1) THEN
    SET @msg := "The user already exists!";
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
  END IF;
END;
