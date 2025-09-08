-- 1. List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
select distinct r.Name, r.City from restaurants r
inner join ratings on  r.Restaurant_ID = ratings.Restaurant_ID
where Overall_Rating = 2;


-- 2.Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
select distinct c.Consumer_ID, c.Age from consumers c
right join ratings r on c.Consumer_ID = r.Consumer_ID
inner join restaurants re on re.Restaurant_ID = r.Restaurant_ID
where re.City = 'San Luis Potosi'
order by c.Consumer_ID asc;


-- 3. List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select r.Name 
from restaurants r
join restaurant_cuisines rc on r.Restaurant_ID = rc.Restaurant_ID
join ratings rt on r.Restaurant_ID = rt.Restaurant_ID
where rc.Cuisine='Mexican' and rt.Consumer_ID='U1001';


-- 4.Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
select c.* 
from consumers c
join  consumer_preferences cp on cp.Consumer_ID = c.Consumer_ID
where cp.Preferred_Cuisine = 'American' and C.Budget = 'Medium';


--  5. List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
select r.Name, r.City
from  restaurants r
join ratings rt on r.Restaurant_ID = rt.Restaurant_ID
group by r.Name, r.City
having avg(rt.Food_Rating)<(
		select avg(Food_Rating) from ratings);


-- 6. Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
select distinct c.consumer_ID, c.Age, c.Occupation 
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
where c.Consumer_ID not in (
	select rt2.Consumer_ID from ratings rt2
    join restaurant_cuisines rc on rc.Restaurant_ID = rt2.Restaurant_ID
    where rc.Cuisine = 'Italian')
order by c.Consumer_ID;

-- 7. List restaurants (Name) that have received ratings from consumers older than 30.
select distinct Name
from restaurants 
where Restaurant_ID in (
	select rt.Restaurant_ID
	from ratings rt
	join consumers c on c.Consumer_ID = rt.Consumer_ID
	where c.Age > 30)
order by Name ;


-- 8. Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican'and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
select distinct c.Consumer_Id, c.Occupation
from consumers c
join consumer_preferences cp on c.Consumer_ID = cp.Consumer_ID
join ratings rt on rt.Consumer_ID = c.Consumer_ID
where cp.Preferred_Cuisine = "Mexican"
	and Overall_Rating=0
order by Consumer_ID;


-- 9. List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
select distinct r.Name, r.City
from restaurants r
join restaurant_cuisines rc on r.Restaurant_ID = rc.Restaurant_ID
where rc.Cuisine = 'Pizzeria'
  and r.City in (
      select distinct City
      from consumers
      where Occupation = 'Student'
  )
order by r.Name;


-- 10. Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking
select distinct c.Consumer_Id, c.Age 
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
join restaurants r on r.Restaurant_ID = rt.Restaurant_ID
where c.Drink_Level = 'Social Drinker'
		and r.Parking = "No";