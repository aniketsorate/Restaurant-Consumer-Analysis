-- 1. List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. Show only students who have rated more than 2 restaurants.
select c.Consumer_ID, count(rt.Restaurant_ID) as No_of_restaurant_rated
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
where c.Occupation = 'Student'
group by c.Consumer_ID
having count(rt.Restaurant_ID)>2
order by No_of_restaurant_rated;


/*2. We want to categorize consumers by an 'Engagement_Score' which is their Age divided by
10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but
only for consumers whose Engagement_Score would be exactly 2 and who use 'Public'
transportation*/

select Consumer_ID, Age, (Age/10) as Engagement_Score
from consumers
where (Age/10)=2 and Transportation_Method = "Public"
order by Engagement_Score;


/* 3.For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name,
City, and its calculated average Overall_Rating, but only for restaurants located in
'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.*/

select r.Name, r.City, avg(rt.Overall_Rating) as AvgOverallRating
from ratings rt
join restaurants r on r.Restaurant_ID = rt.Restaurant_ID 
where r.City = "Cuernavaca"
group by r.Name, R.city
having AvgOverallRating>1.0;


/* 4. Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any
restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings
where the Overall_Rating was 2. */

select distinct c.Consumer_ID, c.Age
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
where c.Marital_Status = "Married" 
	and rt.Food_Rating = rt.Service_Rating 
    and rt.Overall_Rating=2;
    
    
/* 5. List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers
who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in
'Ciudad Victoria'. */

select c.Consumer_Id, c.Age, r.Name
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
join restaurants r on r.Restaurant_ID = rt.Restaurant_ID
where c.Occupation = 'Employed' 
	and (rt.Food_Rating = 0
    and r.City = 'Ciudad Victoria'
    );