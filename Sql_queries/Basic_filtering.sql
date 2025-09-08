-- List all details of consumers who live in the city of 'Cuernavaca'.
select * from consumers
where City = "Cuernavaca";

-- Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
select Consumer_ID, Age, Occupation from consumers
where Occupation="Student" and Smoker="Yes";

-- List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
select Name, City, Alcohol_Service, Price from restaurants
where Alcohol_Service = 'Wine & Beer' and Price = "Medium";

-- Find the names and cities of all restaurants that are part of a 'Franchise'.
select Name, City from restaurants
where  Franchise = "Yes";

-- Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to thedata dictionary).
select Consumer_ID, Restaurant_ID, Overall_Rating from ratings
where Overall_Rating=2;


rename column ï»¿Consumer_ID to Consumer_ID;


