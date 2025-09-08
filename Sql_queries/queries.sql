-- View: Highly Rated Mexican Restaurants
CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT r.Restaurant_ID, r.Name, r.City, AVG(rt.Overall_Rating) AS AvgRating
FROM restaurants r
JOIN restaurant_cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
JOIN ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(rt.Overall_Rating) > 1.5;

-- Stored Procedure: Consumer Performance
DELIMITER //
CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(IN consumer_id VARCHAR(20))
BEGIN
    SELECT 
        c.Consumer_ID,
        CASE 
            WHEN c.Budget = 'Low' THEN 'Budget Conscious'
            WHEN c.Budget = 'Medium' THEN 'Moderate Spender'
            WHEN c.Budget = 'High' THEN 'Premium Spender'
            ELSE 'Unknown Budget'
        END AS SpendingSegment,
        r.Name AS Restaurant_Name,
        rt.Overall_Rating,
        (SELECT AVG(Overall_Rating) 
         FROM ratings WHERE Restaurant_ID = rt.Restaurant_ID) AS Restaurant_Avg,
        CASE 
            WHEN rt.Overall_Rating > (SELECT AVG(Overall_Rating) 
                                      FROM ratings WHERE Restaurant_ID = rt.Restaurant_ID) 
                 THEN 'Above Average'
            WHEN rt.Overall_Rating = (SELECT AVG(Overall_Rating) 
                                      FROM ratings WHERE Restaurant_ID = rt.Restaurant_ID) 
                 THEN 'At Average'
            ELSE 'Below Average'
        END AS Performance_Flag
    FROM ratings rt
    JOIN consumers c ON c.Consumer_ID = rt.Consumer_ID
    JOIN restaurants r ON r.Restaurant_ID = rt.Restaurant_ID
    WHERE c.Consumer_ID = consumer_id
    ORDER BY rt.Overall_Rating DESC;
END //
DELIMITER ;


