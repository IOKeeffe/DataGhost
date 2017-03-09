CREATE TABLE spaceships (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES alien(id)
);

CREATE TABLE aliens (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  planet_id INTEGER,

  FOREIGN KEY(planet_id) REFERENCES alien(id)
);

CREATE TABLE planets (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  planets (id, name)
VALUES
  (1, "Ziblorp"), (2, "Migrax");

INSERT INTO
  aliens (id, fname, lname, planet_id)
VALUES
  (1, "Gorf", "Lizixx", 1),
  (2, "Prasm", "Eggsplo", 1),
  (3, "Candizz", "Framble", 2),
  (4, "Quisster", "Mrim", NULL);

INSERT INTO
  spaceships (id, name, owner_id)
VALUES
  (1, "The Tin Jay", 1),
  (2, "Z-Wing", 2),
  (3, "Servant-1", 3),
  (4, "The Health Star", 3),
  (5, "The Lonely Spider", NULL);
