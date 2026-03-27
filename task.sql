--liquibase formatted sql

--changeset mate.acamemy:1 labels:0.0.1
CREATE TABLE Countries (
    ID INT,
    Name VARCHAR(50),
    PRIMARY KEY (ID)
);
--rollback DROP TABLE Countries;

--changeset mate.acamemy:2 labels:0.0.1
CREATE TABLE Products (
    ID INT AUTO_INCREMENT,
    Name VARCHAR(50),
    PRIMARY KEY (ID)
);
--rollback DROP TABLE Products;

--changeset mate.acamemy:3 labels:0.0.1
CREATE TABLE Warehouses (
    ID INT AUTO_INCREMENT,
    Name VARCHAR(50),
    Address VARCHAR(50),
    CountryID INT,
	FOREIGN KEY (CountryID) REFERENCES Countries(ID) ON DELETE NO ACTION,
    PRIMARY KEY (ID)
);
--rollback DROP TABLE Warehouses;

--changeset mate.acamemy:4 labels:0.0.1
CREATE TABLE ProductInventory (
    ID INT,
    ProductID INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ID) ON DELETE NO ACTION,
    WarehouseAmount INT,
    WarehouseID INT,
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(ID) ON DELETE NO ACTION,
    PRIMARY KEY (ID)
);
--rollback DROP TABLE ProductInventory;

--changeset aisen:1 labels:0.0.2
CREATE TABLE Users (
    ID INT AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(50),
    PRIMARY KEY (ID)
);
--rollback DROP TABLE Users;

--changeset aisen:2 labels:0.0.3
CREATE INDEX Email ON Users (Email);
--rollback ALTER TABLE Users DROP INDEX Email;