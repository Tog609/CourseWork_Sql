-- Все будущие события по указанному городу
SELECT 
    e.EventID,
    e.EventDate,
    s.SportName,
    l.City,
    l.Country
FROM Events e
JOIN Sports s ON s.SportID = e.SportID
JOIN Locations l ON l.LocationID = e.LocationID
WHERE e.EventDate > CURRENT_DATE
ORDER BY e.EventDate;


-- Топ пользователей по количеству оставленных отзывов
SELECT 
    u.UserID,
    u.FullName,
    COUNT(r.ReviewID) AS ReviewCount
FROM Users u
LEFT JOIN Reviews r ON r.UserID = u.UserID
GROUP BY u.UserID, u.FullName
ORDER BY ReviewCount DESC
LIMIT 10;

-- События, по которым нет ни одной оплаты
SELECT 
    e.EventID,
    e.EventDate,
    s.SportName,
    l.City
FROM Events e
JOIN Sports s ON s.SportID = e.SportID
JOIN Locations l ON l.LocationID = e.LocationID
LEFT JOIN EventRegistrations r ON r.EventID = e.EventID
LEFT JOIN Payments p ON p.RegistrationID = r.RegistrationID
WHERE p.PaymentID IS NULL
ORDER BY e.EventDate;
