-- Сумма платежей по виду спорта и году
SELECT 
    s.SportName,
    d.Year,
    SUM(f.Amount) AS TotalAmount
FROM dwh.Fact_Payments f
JOIN dwh.Dim_Event e ON e.EventID = f.EventID
JOIN dwh.Dim_Sport s ON s.SportID = e.SportID
JOIN dwh.Dim_Date d ON d.DateID = f.DateID
GROUP BY s.SportName, d.Year
ORDER BY d.Year, TotalAmount DESC;


-- Количество участников по локациям
SELECT 
    l.City,
    l.Country,
    SUM(f.ParticipantsCount) AS TotalParticipants
FROM dwh.Fact_EventParticipation f
JOIN dwh.Dim_Event e ON e.EventID = f.EventID
JOIN dwh.Dim_Location l ON l.LocationID = e.LocationID
GROUP BY l.City, l.Country
ORDER BY TotalParticipants DESC;

-- Средний рейтинг по виду спорта
SELECT 
    s.SportName,
    AVG(r.Rating) AS AvgRating
FROM Reviews r
JOIN Events e ON e.EventID = r.EventID
JOIN dwh.Dim_Sport s ON s.SportID = e.SportID
GROUP BY s.SportName
ORDER BY AvgRating DESC;
