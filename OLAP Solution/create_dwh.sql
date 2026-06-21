
CREATE SCHEMA IF NOT EXISTS dwh;

-- 1.1 Dim_Date
DROP TABLE IF EXISTS dwh.Dim_Date CASCADE;
CREATE TABLE dwh.Dim_Date (
    DateID INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    Quarter INT NOT NULL,
    Year INT NOT NULL,
    IsWeekend BOOLEAN NOT NULL
);

-- 1.2 Dim_Sport
DROP TABLE IF EXISTS dwh.Dim_Sport CASCADE;
CREATE TABLE dwh.Dim_Sport (
    SportID INT PRIMARY KEY,
    SportName VARCHAR(100) NOT NULL
);

-- 1.3 Dim_Location
DROP TABLE IF EXISTS dwh.Dim_Location CASCADE;
CREATE TABLE dwh.Dim_Location (
    LocationID INT PRIMARY KEY,
    Country VARCHAR(100),
    City VARCHAR(100)
);

-- 1.4 Dim_User
DROP TABLE IF EXISTS dwh.Dim_User CASCADE;
CREATE TABLE dwh.Dim_User (
    UserID INT PRIMARY KEY,
    FullName VARCHAR(200),
    Email VARCHAR(200),
    RegistrationDate DATE
);

-- 1.5 Dim_TeamHistory (SCD2)
DROP TABLE IF EXISTS dwh.Dim_TeamHistory CASCADE;
CREATE TABLE dwh.Dim_TeamHistory (
    TeamHistoryID SERIAL PRIMARY KEY,
    TeamID INT NOT NULL,
    TeamName VARCHAR(200) NOT NULL,
    CaptainUserID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN NOT NULL
);

-- 1.6 Dim_Event
DROP TABLE IF EXISTS dwh.Dim_Event CASCADE;
CREATE TABLE dwh.Dim_Event (
    EventID INT PRIMARY KEY,
    SportID INT NOT NULL,
    LocationID INT NOT NULL,
    StatusID INT NOT NULL,
    MaxParticipants INT,
    EntryFee DECIMAL(10,2)
);

-- 1.7 Bridge_TeamMembers
DROP TABLE IF EXISTS dwh.Bridge_TeamMembers CASCADE;
CREATE TABLE dwh.Bridge_TeamMembers (
    TeamID INT NOT NULL,
    UserID INT NOT NULL,
    PRIMARY KEY (TeamID, UserID)
);

-- 1.8 Fact_EventParticipation
DROP TABLE IF EXISTS dwh.Fact_EventParticipation CASCADE;
CREATE TABLE dwh.Fact_EventParticipation (
    EventParticipationID SERIAL PRIMARY KEY,
    EventID INT NOT NULL,
    TeamID INT NOT NULL,
    DateID INT NOT NULL,
    ParticipantsCount INT NOT NULL
);

-- 1.9 Fact_Payments
DROP TABLE IF EXISTS dwh.Fact_Payments CASCADE;
CREATE TABLE dwh.Fact_Payments (
    PaymentFactID SERIAL PRIMARY KEY,
    RegistrationID INT NOT NULL,
    EventID INT NOT NULL,
    TeamID INT NOT NULL,
    DateID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(100)
);

