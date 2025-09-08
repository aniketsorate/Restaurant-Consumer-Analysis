/*1. Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID,
Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.*/

with defined_city as (
		select Consumer_ID, Age from consumers
        where City = 'San Luis Potosi'
        )
select distinct c.Consumer_ID, c.Age, r.Name
from defined_city c
join ratings rt on c.Consumer_ID=rt.Consumer_ID
join restaurants r on r.Restaurant_ID=rt.Restaurant_ID
join restaurant_cuisines rc on rc.Restaurant_ID=r.Restaurant_ID
where rc.Cuisine = 'Mexican' and rt.Overall_Rating=2;


/*2. For each Occupation, find the average age of consumers. Only consider consumers who
have made at least one rating. (Use a derived table to get consumers who have rated).*/
SELECT  Occupation, AVG(Age) AS AvgAge
FROM
    (SELECT c.Occupation, c.Age
    FROM consumers c
    JOIN ratings rt 
		ON rt.Consumer_ID = c.Consumer_ID) AS atleast_one_rating
GROUP BY Occupation;


/*3. Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each
restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID,
Overall_Rating, and the RatingRank.*/

with RestaurantRanking as(
		select r.Restaurant_ID, rt.Consumer_ID, rt.Overall_Rating
        from ratings rt
        join restaurants r 
			on rt.Restaurant_ID = r.Restaurant_ID
		where r.City = 'Cuernavaca' )
select Restaurant_ID, Consumer_ID, Overall_Rating,
	rank() over( 
		partition by Restaurant_ID 
			order by Overall_Rating desc ) as RatingRank 
from RestaurantRanking;


/*4. For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the
average Overall_Rating given by that specific consumer across all their ratings.*/

select Consumer_ID, Restaurant_ID, Overall_Rating,
 avg(Overall_Rating) over(
	partition by Consumer_ID) AS AvgRatingByConsumer
 from ratings ;
 
 
 /*5. Using a CTE, identify students who have a 'Low' budget. Then, for each of these students,
list their top 3 most preferred cuisines based on the order they appear in the
Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID,
Preferred_Cuisine to define order for ROW_NUMBER).*/

with LowBudgetStudent as(
		select Consumer_ID from consumers
        where Occupation = 'Student'
			and Budget = 'Low' ),
RankedCuisines as (
    select cp.Consumer_ID,
           cp.Preferred_Cuisine,
           row_number() over (
               partition by cp.Consumer_ID
               order by cp.Consumer_ID, cp.Preferred_Cuisine
           ) as rn
    from Consumer_Preferences cp
    join LowBudgetStudent lbs
      on cp.Consumer_ID = lbs.Consumer_ID
)
select Consumer_ID, Preferred_Cuisine
from RankedCuisines
where rn <= 3
order by Consumer_ID, rn;


/*6. Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the
Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if
any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use a
derived table to filter for the consumer's ratings first.*/

with Con_U1008 as (
		select *
        from ratings
        where Consumer_ID = 'U1008' )
select Restaurant_ID, Overall_Rating,
	lead(Restaurant_ID) over(order by Restaurant_ID) as NextRestaurant,
    lead(Overall_Rating) over (order by Restaurant_ID) as NextOverallRating
from Con_U1008;


/*7. Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name,
and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.*/

CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT r.Restaurant_ID, r.Name, r.City, AVG(rt.Overall_Rating) AS AvgRating
FROM restaurants r
JOIN restaurant_cuisines rc 
	ON r.Restaurant_ID = rc.Restaurant_ID
JOIN ratings rt 
	ON r.Restaurant_ID = rt.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(rt.Overall_Rating) > 1.5;


/*8. First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to
find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have
not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.*/

with PreferredMexicanCuisine as(
		select c.Consumer_ID
        from consumers c
        join consumer_preferences cp
			on cp.Consumer_ID = c.Consumer_ID
		where cp.Preferred_Cuisine = 'Mexican'
)
select pmc.Consumer_ID
from PreferredMexicanCuisine pmc
where not exists (
	select 1
	from ratings rt
	join HighlyRatedMexicanRestaurants hrmr
		on rt.Restaurant_ID = hrmr.Restaurant_ID
	where pmc.Consumer_ID = rt.Consumer_ID
)
order by pmc.Consumer_ID;


/*9. Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a
Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID,
Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating
meets or exceeds the threshold.*/

DROP PROCEDURE IF EXISTS GetRestaurantRatingsAboveThreshold;

DELIMITER //
create procedure GetRestaurantRatingsAboveThreshold(
	in Res_ID int,
    in Rating int 
)
begin
		select Consumer_ID, Overall_Rating, Food_Rating, Service_Rating 
        from ratings
        where Restaurant_ID = Res_ID
			and Overall_Rating >= Rating ;
end //
DELIMITER ;

call GetRestaurantRatingsAboveThreshold(132608, 1);


/*10. Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there
are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and
Overall_Rating.*/

with HighestRatedRestaurants as (
		select rc.Cuisine ,r.Name , r.City, rt.Overall_Rating,
				dense_rank() over(
						partition by rc.Cuisine 
						order by rt.Overall_Rating desc
					) as RestaurantRank
		from restaurants r
		join restaurant_cuisines rc
			on rc.Restaurant_ID = r.Restaurant_ID
		join ratings rt
			on rt.Restaurant_ID = r.Restaurant_ID
		)
 select *
 from HighestRatedRestaurants
  where RestaurantRank <= 2;    
		
		
/*11. First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their
average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their
average overall rating. For these top 5 consumers, list their Consumer_ID, their average
rating, and the number of 'Mexican' restaurants they have rated.*/

create view ConsumerAverageRatings as (
		select distinct  Consumer_ID,
				avg(Overall_Rating)  as AvgOverallRating
		from ratings
        group by Consumer_ID
);
select * from ConsumerAverageRatings;

with TopFiveConsumer as(
		select Consumer_ID,AvgOverallRating,
				row_number()	 over(order by AvgOverallRating desc) as ConsumerRank
        from consumeraverageratings
)
select tfc.Consumer_ID, tfc.AvgOverallRating,
		count(case 
				when rc.Cuisine = 'Mexican' 
				then 1 else null end
		) as MexicanRestaurantRated
from TopFiveConsumer tfc
join ratings rt
	on tfc.Consumer_ID = rt.Consumer_ID
join restaurant_cuisines rc
	on rc.Restaurant_ID  = rt.Restaurant_ID
where ConsumerRank <=5
group by tfc.Consumer_ID, tfc.AvgOverallRating;
        

/*12. Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that
accepts a Consumer_ID as input.
The procedure should:
1. Determine the consumer's "Spending Segment" based on their Budget:
○ 'Low' -> 'Budget Conscious'
○ 'Medium' -> 'Moderate Spender'
○ 'High' -> 'Premium Spender'
○ NULL or other -> 'Unknown Budget'
2. For all restaurants rated by this consumer:
○ List the Restaurant_Name.
○ The Overall_Rating given by this consumer.
○ The average Overall_Rating this restaurant has received from all consumers
(not just the input consumer).
○ A "Performance_Flag" indicating if the input consumer's rating for that
restaurant is 'Above Average', 'At Average', or 'Below Average' compared to
the restaurant's overall average rating.
○ Rank these restaurants for the input consumer based on the Overall_Rating
they gave (highest rating = rank 1).*/        

delimiter //
create procedure GetConsumerSegmentAndRestaurantPerformance(
	in Con_ID varchar(20) 
)
begin
	select c.Consumer_Id,
		case 
			when c.Budget = 'Low' then 'Budget Conscious'
            when c.Budget = 'Medium' then 'Moderate Spender'
            when c.Budget = 'High' then 'Premium Spender'
            else 'Unknown Budget' 
		end as SpendingSegment,
		r.Name as RestaurantName,
		rt.Overall_Rating as OverallRestaurantRating,
        AvgRating.AvgRestaurantRating,
			case
				when rt.Overall_Rating > AvgRating.AvgRestaurantRating
					then 'Above Average'
				when rt.Overall_Rating = AvgRating.AvgRestaurantRating
					then 'At Average'
				else
					'Below Average'
			end as PerformanceFlag,
        dense_rank() over(
				partition by rt.Consumer_ID 
                order by  rt.Overall_Rating desc
			) as RestaurantRank
	from consumers c
	join ratings rt
		on rt.Consumer_ID = c.Consumer_Id
	join restaurants r
		on r.Restaurant_ID = rt.Restaurant_ID
	join (
        select Restaurant_ID, avg(Overall_Rating) as AvgRestaurantRating
        from ratings
        group by Restaurant_ID
    ) AvgRating
        on AvgRating.Restaurant_ID = r.Restaurant_ID
	where c.Consumer_Id = Con_ID ;
end //
delimiter ;


call GetConsumerSegmentAndRestaurantPerformance('U1008');



