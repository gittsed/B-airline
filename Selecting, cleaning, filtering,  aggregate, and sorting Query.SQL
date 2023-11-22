/*Select all the flight IDs for flights that have no passengers on board, or that flew 0 distance*/

SELECT flight_id 
FROM ba_flights 
WHERE total_passengers = 0 
      OR distance_flown = 0 ;

/*Select the flight number, flight date, departure city, and arrival city
for flights that leave after May 1, 2023*/

SELECT flight_number, 
       actual_flight_date, 
       departure_city, 
       arrival_city 
FROM ba_flights 
WHERE actual_flight_date > '2023-05-01' ;

/*Select the unique arrival cities that British Airways is flying to when departing from London*/

SELECT DISTINCT arrival_city 
FROM ba_flights 
WHERE departure_city = 'London' ;

/*Select the flight IDs, number of bike bags, and baggage weight 
for flights that have a baggage revenue above £50,000*/

SELECT flight_ID, 
       bike_bags, 
       baggage_weight 
FROM ba_flights 
WHERE revenue_from_baggage > 50000 ;

/*Select the flight numbers, flight date, and depart city 
for flights that fly to Madrid, Lisbon, Port of Spain, or Tel Aviv*/


SELECT flight_number, 
       actual_flight_date, 
       departure_city 
FROM ba_flights 
WHERE arrival_city IN ('Madrid', 'Lisbon', 'Port of Spain', 'Tel Aviv') ;

/*Select the flight number and departure city for flights 
that are scheduled and that generated £0 revenue for baggage or have no passengers*/

SELECT flight_number, 
       departure_city 
FROM ba_flights 
WHERE status = 'Scheduled' 
      AND (revenue_from_baggage = 0 OR total_passengers = 0) ;


/*Select all the columns for flights that are canceled and
either depart from or arrive at Panama City*/

SELECT * 
FROM ba_flights 
WHERE status = 'Cancelled' 
      AND (departure_city = 'Panama City' OR arrival_city = 'Panama City') ;

/*Select the flight IDs and fuel consumption 
for flights that either have a baggage weight 
below 3000 or less than 200 passengers on the flight*/

SELECT flight_id,
       total_fuel_consumption
FROM ba_flights
WHERE baggage_weight < 3000
      OR total_passengers < 200;


/*What are the unique arrival cities that star with he capital letter 'L'*/

SELECT DISTINCT arrival_city 
FROM ba_flights
WHERE arrival_city LIKE 'L%';

/*can you identify all columns of flights that are scheduled to leave 
between April15 nd May 15 2023 and fly a distance less than 1000km*/

SELECT * 
FROM ba_flights
WHERE status='Scheduled' 
      AND (actual_flight_date BETWEEN 'April 15 2023' AND ' May 15 2023')
      AND distance_flown<1000

/*can you select the unique flights numbers and arrival cities of flights that either 
have more than 0 passsengers or morethan 0kg baggae weitght on board or that have flown morethan 
0km in distance for flights that depart from London*/

SELECT DISTINCT flight_number, 
       arrival_city
FROM ba_flights
WHERE (total_passengers>0  OR baggage_weight>0 OR distance_flown>0)
      AND departure_city='London'


/*select all the columns from flights that are scheduled and depart between April1 and April 30*/

SELECT * 
FROM ba_flights
WHERE status='Scheduled' 
      AND (actual_flight_date BETWEEN 'April-1-2023' AND 'April-30-2023')

/*Imagine you are looking for unique departure cities with the text 'City' but unsure which cities
include it. How do you pull the unique cities that include the text'City'*/

SELECT DISTINCT departure_city
FROM ba_flights
WHERE departure_city LIKE '%City%';

/*select the flight numbers departure city,and baggage weight
for flights that are scheduled to fly to Manila, Bangkok, Jakarta,
Muscat and revenue from baggage lessthan or equal to 7450 euro*/

SELECT flight_number, 
       departure_city, 
       baggage_weight 
FROM ba_flights
WHERE status='Scheduled' 
      AND revenue_from_baggage<=7450
      AND arrival_city IN ('Manila','Bangkok','Jakarta','Muscat') 



