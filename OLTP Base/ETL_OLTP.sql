
DELETE FROM staging_users s1
USING staging_users s2
WHERE s1.ctid < s2.ctid
  AND s1.Email = s2.Email;

DELETE FROM staging_users
WHERE Email IS NULL OR Email = '';

INSERT INTO Users (Email, FullName, RegistrationDate)
SELECT s.Email, s.FullName, s.RegistrationDate
FROM staging_users s
ON CONFLICT (Email) DO UPDATE
SET 
    FullName = EXCLUDED.FullName,
    RegistrationDate = EXCLUDED.RegistrationDate
WHERE 
    Users.FullName <> EXCLUDED.FullName
    OR Users.RegistrationDate <> EXCLUDED.RegistrationDate;


DELETE FROM staging_teams s1
USING staging_teams s2
WHERE s1.ctid < s2.ctid
  AND s1.TeamName = s2.TeamName;

DELETE FROM staging_teams
WHERE TeamName IS NULL OR TeamName = '';

DELETE FROM staging_teams s
WHERE NOT EXISTS (
    SELECT 1 FROM Users u WHERE u.Email = s.CaptainEmail
);

INSERT INTO Teams (TeamName, CreatedDate, CaptainUserID)
SELECT 
    s.TeamName,
    s.CreatedDate,
    u.UserID
FROM staging_teams s
JOIN Users u ON u.Email = s.CaptainEmail
ON CONFLICT (TeamName) DO UPDATE
SET 
    CreatedDate = EXCLUDED.CreatedDate,
    CaptainUserID = EXCLUDED.CaptainUserID
WHERE 
    Teams.CreatedDate <> EXCLUDED.CreatedDate
    OR Teams.CaptainUserID <> EXCLUDED.CaptainUserID;


DELETE FROM staging_team_members s1
USING staging_team_members s2
WHERE s1.ctid < s2.ctid
  AND s1.TeamID = s2.TeamID
  AND s1.UserID = s2.UserID;

DELETE FROM staging_team_members
WHERE TeamID IS NULL OR UserID IS NULL;

DELETE FROM staging_team_members s
WHERE NOT EXISTS (
    SELECT 1 FROM Teams t WHERE t.TeamID = s.TeamID
);

DELETE FROM staging_team_members s
WHERE NOT EXISTS (
    SELECT 1 FROM Users u WHERE u.UserID = s.UserID
);
DELETE FROM staging_team_members s
USING Teams t
WHERE s.TeamID = t.TeamID
  AND s.JoinDate <= t.CreatedDate;

-- 6. Загружаем данные в TeamMembers (UPSERT)
INSERT INTO TeamMembers (TeamID, UserID, JoinDate)
SELECT s.TeamID, s.UserID, s.JoinDate
FROM staging_team_members s
ON CONFLICT (TeamID, UserID) DO UPDATE
SET JoinDate = EXCLUDED.JoinDate
WHERE TeamMembers.JoinDate <> EXCLUDED.JoinDate;


DELETE FROM staging_sports
WHERE SportName IS NULL OR TRIM(SportName) = '';


DELETE FROM staging_sports s1
USING staging_sports s2
WHERE s1.ctid > s2.ctid
  AND s1.SportName = s2.SportName;


INSERT INTO Sports (SportName)
SELECT s.SportName
FROM staging_sports s
LEFT JOIN Sports t ON t.SportName = s.SportName
WHERE t.SportID IS NULL;


DELETE FROM staging_locations
WHERE Country IS NULL OR City IS NULL OR Address IS NULL;

DELETE FROM staging_locations s1
USING staging_locations s2
WHERE s1.ctid > s2.ctid
  AND s1.Country = s2.Country
  AND s1.City = s2.City
  AND s1.Address = s2.Address;

INSERT INTO Locations (Country, City, Address)
SELECT s.Country, s.City, s.Address
FROM staging_locations s
LEFT JOIN Locations t
  ON t.Country = s.Country
 AND t.City = s.City
 AND t.Address = s.Address
WHERE t.LocationID IS NULL;


DELETE FROM staging_event_statuses
WHERE StatusName IS NULL OR TRIM(StatusName) = '';

DELETE FROM staging_event_statuses s1
USING staging_event_statuses s2
WHERE s1.ctid > s2.ctid
  AND s1.StatusName = s2.StatusName;

INSERT INTO EventStatuses (StatusName)
SELECT s.StatusName
FROM staging_event_statuses s
LEFT JOIN EventStatuses t ON t.StatusName = s.StatusName
WHERE t.StatusID IS NULL;




DELETE FROM staging_events
WHERE SportID IS NULL
   OR LocationID IS NULL
   OR OrganizerTeamID IS NULL
   OR StatusID IS NULL;


DELETE FROM staging_events s
WHERE NOT EXISTS (SELECT 1 FROM Sports WHERE SportID = s.SportID)
   OR NOT EXISTS (SELECT 1 FROM Locations WHERE LocationID = s.LocationID)
   OR NOT EXISTS (SELECT 1 FROM Teams WHERE TeamID = s.OrganizerTeamID)
   OR NOT EXISTS (SELECT 1 FROM EventStatuses WHERE StatusID = s.StatusID);


DELETE FROM staging_events s1
USING staging_events s2
WHERE s1.ctid > s2.ctid
  AND s1.SportID = s2.SportID
  AND s1.LocationID = s2.LocationID
  AND s1.OrganizerTeamID = s2.OrganizerTeamID
  AND s1.EventDate = s2.EventDate;


INSERT INTO Events (SportID, LocationID, OrganizerTeamID, StatusID, EventDate, MaxParticipants, EntryFee)
SELECT s.*
FROM staging_events s
LEFT JOIN Events t
  ON t.SportID = s.SportID
 AND t.LocationID = s.LocationID
 AND t.OrganizerTeamID = s.OrganizerTeamID
 AND t.EventDate = s.EventDate
WHERE t.EventID IS NULL;




DELETE FROM staging_event_registrations
WHERE EventID IS NULL OR TeamID IS NULL;

DELETE FROM staging_event_registrations s
WHERE NOT EXISTS (SELECT 1 FROM Events WHERE EventID = s.EventID)
   OR NOT EXISTS (SELECT 1 FROM Teams WHERE TeamID = s.TeamID);

DELETE FROM staging_event_registrations s1
USING staging_event_registrations s2
WHERE s1.ctid > s2.ctid
  AND s1.EventID = s2.EventID
  AND s1.TeamID = s2.TeamID;

INSERT INTO EventRegistrations (EventID, TeamID, RegistrationDate)
SELECT s.*
FROM staging_event_registrations s
LEFT JOIN EventRegistrations t
  ON t.EventID = s.EventID
 AND t.TeamID = s.TeamID
WHERE t.RegistrationID IS NULL;



DELETE FROM staging_payments
WHERE RegistrationID IS NULL OR Amount IS NULL;

DELETE FROM staging_payments s
WHERE NOT EXISTS (SELECT 1 FROM EventRegistrations WHERE RegistrationID = s.RegistrationID);

DELETE FROM staging_payments s1
USING staging_payments s2
WHERE s1.ctid > s2.ctid
  AND s1.RegistrationID = s2.RegistrationID
  AND s1.PaymentDate = s2.PaymentDate;

INSERT INTO Payments (RegistrationID, Amount, PaymentDate, PaymentMethod, PaymentStatus)
SELECT s.*
FROM staging_payments s
LEFT JOIN Payments t
  ON t.RegistrationID = s.RegistrationID
 AND t.PaymentDate = s.PaymentDate
WHERE t.PaymentID IS NULL;



DELETE FROM staging_reviews
WHERE EventID IS NULL OR UserID IS NULL OR Rating IS NULL;

DELETE FROM staging_reviews s
WHERE NOT EXISTS (SELECT 1 FROM Events WHERE EventID = s.EventID)
   OR NOT EXISTS (SELECT 1 FROM Users WHERE UserID = s.UserID);

DELETE FROM staging_reviews s1
USING staging_reviews s2
WHERE s1.ctid > s2.ctid
  AND s1.EventID = s2.EventID
  AND s1.UserID = s2.UserID;

INSERT INTO Reviews (EventID, UserID, Rating, Comment, ReviewDate)
SELECT s.*
FROM staging_reviews s
LEFT JOIN Reviews t
  ON t.EventID = s.EventID
 AND t.UserID = s.UserID
WHERE t.ReviewID IS NULL;


