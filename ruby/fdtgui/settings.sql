DROP TABLE IF EXISTS "server";
CREATE TABLE "server" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "name" VARCHAR NOT NULL  UNIQUE , "description" TEXT, "type" VARCHAR, "ip" VARCHAR NOT NULL , "user" VARCHAR, "passwd" VARCHAR);
DROP TABLE IF EXISTS "setting";
CREATE TABLE "setting" ("id" INTEGER PRIMARY KEY  NOT NULL ,"name" VARCHAR NOT NULL ,"value" INTEGER);
