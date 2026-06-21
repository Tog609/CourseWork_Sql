INSERT INTO dwh.Dim_Date (DateID, FullDate, Day, Month, MonthName, Quarter, Year, IsWeekend)
SELECT
    EXTRACT(YEAR FROM d)::INT * 10000 +
    EXTRACT(MONTH FROM d)::INT * 100 +
    EXTRACT(DAY FROM d)::INT AS DateID,
    d,
    EXTRACT(DAY FROM d),
    EXTRACT(MONTH FROM d),
    TO_CHAR(d, 'Month'),
    EXTRACT(QUARTER FROM d),
    EXTRACT(YEAR FROM d),
    CASE WHEN EXTRACT(ISODOW FROM d) IN (6,7) THEN TRUE ELSE FALSE END
FROM generate_series('2024-01-01'::date, '2028-12-31'::date, '1 day'::interval) d
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Dim_Date dd
    WHERE dd.DateID =
        EXTRACT(YEAR FROM d)::INT * 10000 +
        EXTRACT(MONTH FROM d)::INT * 100 +
        EXTRACT(DAY FROM d)::INT
);
INSERT INTO dwh.Dim_Sport (SportID, SportName)
SELECT s.SportID, s.SportName
FROM public.Sports s
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Dim_Sport d WHERE d.SportID = s.SportID
);
INSERT INTO dwh.Dim_Location (LocationID, Country, City)
SELECT l.LocationID, l.Country, l.City
FROM public.Locations l
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Dim_Location d WHERE d.LocationID = l.LocationID
);
INSERT INTO dwh.Dim_User (UserID, FullName, Email, RegistrationDate)
SELECT u.UserID, u.FullName, u.Email, u.RegistrationDate
FROM public.Users u
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Dim_User d WHERE d.UserID = u.UserID
);

UPDATE dwh.Dim_TeamHistory d
SET EndDate = CURRENT_DATE, IsCurrent = FALSE
FROM public.Teams t
WHERE d.TeamID = t.TeamID
  AND d.IsCurrent = TRUE
  AND (d.TeamName <> t.TeamName OR d.CaptainUserID <> t.CaptainUserID);

INSERT INTO dwh.Dim_TeamHistory (TeamID, TeamName, CaptainUserID, StartDate, EndDate, IsCurrent)
SELECT t.TeamID, t.TeamName, t.CaptainUserID, CURRENT_DATE, NULL, TRUE
FROM public.Teams t
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Dim_TeamHistory d
    WHERE d.TeamID = t.TeamID AND d.IsCurrent = TRUE
);


INSERT INTO dwh.Dim_Event (EventID, SportID, LocationID, StatusID, MaxParticipants, EntryFee)
SELECT e.EventID, e.SportID, e.LocationID, e.StatusID, e.MaxParticipants, e.EntryFee
FROM public.Events e
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Dim_Event d WHERE d.EventID = e.EventID
);

INSERT INTO dwh.Bridge_TeamMembers (TeamID, UserID)
SELECT tm.TeamID, tm.UserID
FROM public.TeamMembers tm
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Bridge_TeamMembers b
    WHERE b.TeamID = tm.TeamID AND b.UserID = tm.UserID
);
INSERT INTO dwh.Fact_EventParticipation (EventID, TeamID, DateID, ParticipantsCount)
SELECT
    r.EventID,
    r.TeamID,
    EXTRACT(YEAR FROM r.RegistrationDate)::INT * 10000 +
    EXTRACT(MONTH FROM r.RegistrationDate)::INT * 100 +
    EXTRACT(DAY FROM r.RegistrationDate)::INT,
    1
FROM public.EventRegistrations r
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Fact_EventParticipation f
    WHERE f.EventID = r.EventID
      AND f.TeamID = r.TeamID
      AND f.DateID =
            EXTRACT(YEAR FROM r.RegistrationDate)::INT * 10000 +
            EXTRACT(MONTH FROM r.RegistrationDate)::INT * 100 +
            EXTRACT(DAY FROM r.RegistrationDate)::INT
);



INSERT INTO dwh.Fact_Payments (RegistrationID, EventID, TeamID, DateID, Amount, PaymentMethod)
SELECT
    p.RegistrationID,
    r.EventID,
    r.TeamID,
    EXTRACT(YEAR FROM p.PaymentDate)::INT * 10000 +
    EXTRACT(MONTH FROM p.PaymentDate)::INT * 100 +
    EXTRACT(DAY FROM p.PaymentDate)::INT,
    p.Amount,
    p.PaymentMethod
FROM public.Payments p
JOIN public.EventRegistrations r ON r.RegistrationID = p.RegistrationID
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.Fact_Payments f
    WHERE f.RegistrationID = p.RegistrationID
);





