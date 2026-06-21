
CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    Email VARCHAR(100) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    RegistrationDate DATE NOT NULL
);
CREATE TABLE Teams (
    TeamID SERIAL PRIMARY KEY,
    TeamName VARCHAR(100) UNIQUE NOT NULL,
    CreatedDate DATE NOT NULL,
    CaptainUserID INT NOT NULL,

    CONSTRAINT fk_teams_captain
        FOREIGN KEY (CaptainUserID) REFERENCES Users(UserID)
);
CREATE TABLE TeamMembers (
    TeamID INT NOT NULL,
    UserID INT NOT NULL,
    JoinDate DATE NOT NULL,

    CONSTRAINT pk_teammembers PRIMARY KEY (TeamID, UserID),

    CONSTRAINT fk_teammembers_team
        FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),

    CONSTRAINT fk_teammembers_user
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
CREATE TABLE Sports (
    SportID SERIAL PRIMARY KEY,
    SportName VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Locations (
    LocationID SERIAL PRIMARY KEY,
    Country VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL
);
CREATE TABLE EventStatuses (
    StatusID SERIAL PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL
);
CREATE TABLE Events (
    EventID SERIAL PRIMARY KEY,
    SportID INT NOT NULL,
    LocationID INT NOT NULL,
    OrganizerTeamID INT NOT NULL,
    StatusID INT NOT NULL,
    EventDate DATE NOT NULL,
    MaxParticipants INT NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_events_sport
        FOREIGN KEY (SportID) REFERENCES Sports(SportID),

    CONSTRAINT fk_events_location
        FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),

    CONSTRAINT fk_events_team
        FOREIGN KEY (OrganizerTeamID) REFERENCES Teams(TeamID),

    CONSTRAINT fk_events_status
        FOREIGN KEY (StatusID) REFERENCES EventStatuses(StatusID)
);
CREATE TABLE EventRegistrations (
    RegistrationID SERIAL PRIMARY KEY,
    EventID INT NOT NULL,
    TeamID INT NOT NULL,
    RegistrationDate DATE NOT NULL,

    CONSTRAINT fk_reg_event
        FOREIGN KEY (EventID) REFERENCES Events(EventID),

    CONSTRAINT fk_reg_team
        FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
CREATE TABLE Payments (
    PaymentID SERIAL PRIMARY KEY,
    RegistrationID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    PaymentStatus VARCHAR(50) NOT NULL,

    CONSTRAINT fk_payments_registration
        FOREIGN KEY (RegistrationID) REFERENCES EventRegistrations(RegistrationID)
);
CREATE TABLE Reviews (
    ReviewID SERIAL PRIMARY KEY,
    EventID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT NOT NULL,
    Comment TEXT,
    ReviewDate DATE NOT NULL,

    CONSTRAINT fk_reviews_event
        FOREIGN KEY (EventID) REFERENCES Events(EventID),

    CONSTRAINT fk_reviews_user
        FOREIGN KEY (UserID) REFERENCES Users(UserID),

    CONSTRAINT chk_rating CHECK (Rating BETWEEN 1 AND 5)
);
