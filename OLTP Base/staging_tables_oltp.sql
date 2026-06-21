
CREATE TABLE IF NOT EXISTS staging.staging_users (
    Email VARCHAR(100),
    FullName VARCHAR(100),
    RegistrationDate DATE
);

CREATE TABLE IF NOT EXISTS staging.staging_teams (
    TeamName VARCHAR(100),
    CreatedDate DATE,
    CaptainEmail VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS staging.staging_team_members (
    TeamID INT,
    UserID INT,
    JoinDate DATE
);

CREATE TABLE IF NOT EXISTS staging.staging_sports (
    SportName VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS staging.staging_locations (
    Country VARCHAR(100),
    City VARCHAR(100),
    Address VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS staging.staging_event_statuses (
    StatusName VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging.staging_events (
    SportID INT,
    LocationID INT,
    OrganizerTeamID INT,
    StatusID INT,
    EventDate DATE,
    MaxParticipants INT,
    EntryFee DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS staging.staging_event_registrations (
    EventID INT,
    TeamID INT,
    RegistrationDate DATE
);

CREATE TABLE IF NOT EXISTS staging.staging_payments (
    RegistrationID INT,
    Amount DECIMAL(10,2),
    PaymentDate DATE,
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging.staging_reviews (
    EventID INT,
    UserID INT,
    Rating INT,
    Comment TEXT,
    ReviewDate DATE
);
