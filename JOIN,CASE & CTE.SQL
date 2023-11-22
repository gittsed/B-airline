/*Create a list of flights, showing the flight ID, departure city, arrival city, 
manufacturer, and aircraft sub-type that will be used for each flightShow the results 
for all flights that are available even if not all information is available for all flights.*/

SELECT flight.flight_id, 
       route.departure_city, 
       route.arrival_city, 
       aircraft.manufacturer, 
       aircraft.ac_subtype 
FROM ba_flights flight 
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     LEFT JOIN ba_aircraft aircraft ON flight.flight_id = aircraft.flight_id ;

/*What is the maximum number of passengers that have been on every available aircraft 
(manufacturer and sub-type) for flights that have been completed? 
If the manufacturer and sub-type are not available for flights, 
we do not need to show the results of these flights*/

SELECT aircraft.manufacturer, 
       aircraft.ac_subtype, 
       MAX(flight.total_passengers) AS max_passengers 
FROM ba_flights flight 
     INNER JOIN ba_aircraft aircraft ON flight.flight_id = aircraft.flight_id 
WHERE flight.status = 'Completed' 
GROUP BY aircraft.manufacturer,aircraft.ac_subtype

/*Since only some aircraft are capable of flying long distances overseas, 
we want to filter out the planes that only do shorter distances. 
What aircraft (manufacturer and sub-type) have completed flights of a distance of more than 7,000 km? 
If the manufacturer and sub-type are not available for flights, 
we do not need to show the results of these flights.*/


SELECT DISTINCT aircraft.manufacturer, 
       aircraft.ac_subtype 
FROM ba_flights flight 
     INNER JOIN ba_aircraft aircraft ON flight.flight_id = aircraft.flight_id 
     INNER JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
WHERE flight.status = 'Completed' AND route.distance_flown > 7000 
--The same answer can be achieved using GROUP BY 
--LEFT JOIN would work for the ba_flight_routes join as well

/*What is the most used aircraft (manufacturer and sub-type) for flights departing 
from London and arriving in Basel, Trondheim, or Glasgow? 
Include the number of flights that the aircraft was used for. 
If the manufacturer and sub-type are not available for flights,
we do not need to show the results of these flights.
*/

SELECT aircraft.manufacturer, 
       aircraft.ac_subtype, 
       COUNT(flight.flight_id) AS total_flights 
FROM ba_flights flight 
     INNER JOIN ba_aircraft aircraft ON flight.flight_id = aircraft.flight_id 
     INNER JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
WHERE route.departure_city = 'London' 
      AND route.arrival_city IN ('Basel', 'Trondheim', 'Glasgow')
GROUP BY aircraft.manufacturer, aircraft.ac_subtype
ORDER BY total_flights DESC LIMIT 1 ;

/* For the flight routes highlighted in question 4 combined, 
would there have been an aircraft that, on average, 
would use less fuel on the flight routes? 
The fuel used in liters per flight can be calculated by multiplying the fuel efficiency metric by distance,
baggage weight, and number of passengers. What aircraft (manufacturer and sub-type) 
would you recommend to use for each of these flight routes if you use the average fuel consumption as
your guiding metric? If the manufacturer and sub-type are not available for flights,
we do not need to show the results of these flights.*/


SELECT aircraft.manufacturer, 
       aircraft.ac_subtype, 
       AVG(fuel.fuel_efficiency * flight.total_passengers * flight.baggage_weight * route.distance_flown) AS avg_fuel_usage 
FROM ba_flights flight 
     INNER JOIN ba_aircraft aircraft ON flight.flight_id = aircraft.flight_id 
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     LEFT JOIN ba_fuel_efficiency fuel ON aircraft.ac_subtype = fuel.ac_subtype 
WHERE route.departure_city = 'London' 
      AND route.arrival_city IN ('Basel', 'Trondheim', 'Glasgow') 
GROUP BY aircraft.manufacturer, aircraft.ac_subtype 
ORDER BY avg_fuel_usage ; 
--INNER JOINS would work as well for the ba_flight_routes and ba_fuel_efficiency tables

/*
The fuel used in liters per flight can be calculated by multiplying the fuel efficiency
metric by distance, baggage weight, and number of passengers.
Calculate the total amount of fuel used per kilometer flown of completed flights per manufacturer.
What manufacturer has used less fuel per km in total?
If flights do not have data available about the aircraft type, you can exclude the flights from the analysis.
*/
SELECT aircraft.manufacturer,
       SUM(fuel.fuel_efficiency * flight.total_passengers * flight.baggage_weight * route.distance_flown)/SUM(distance_flown) AS avg_fuel_usage
FROM ba_flights flight
     INNER JOIN ba_aircraft aircraft ON flight.flight_id = aircraft.flight_id
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number
     LEFT JOIN ba_fuel_efficiency fuel ON aircraft.ac_subtype = fuel.ac_subtype
WHERE flight.status = 'Completed'
GROUP BY aircraft.manufacturer;
--INNER JOINS would work as well for the ba_flight_routes and ba_fuel_efficiency tables

/*To get started with analysis, create a summary of how many short-haul versus long-haul flights happen.
A typical short-haul flight in Europe has a maximum distance of 2,000 km. 
How many flights are scheduled or completed for both short-haul and long-haul flights in 2023?
-- Note flight_id should be unique in table ba_flights. 
We are adding a DISTINCT clause just in case there is a data issue and flight_id is duplicated. 
Depending on the quality of your data pipelines and data engineering team,
this may not be necessary as an analyst */

SELECT CASE WHEN route.distance_flown <= 2000 THEN 'Short-haul' 
            WHEN route.distance_flown > 2000 THEN 'Long-haul' ELSE 'Error' END AS flight_length,
            COUNT(DISTINCT flight.flight_id) AS total_flights 
FROM ba_flights flight
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
WHERE flight.status IN ('Completed', 'Scheduled') 
      AND flight.actual_flight_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY flight_length ; 
--INNER JOIN would work for the join as well

/*We can calculate how full flights were by comparing the number of passengers on the flight against 
the capacity of the aircraft. Calculate the average number of empty seats for the short-haul and long-haul flights. 
Additionally, can you also calculate the average number of empty seats as a percentage of
the maximum number of passengers? If the manufacturer and sub-type are not available for flights,
we do not need to show the results of these flights.*/

SELECT CASE WHEN route.distance_flown <= 2000 THEN 'Short-haul'
            WHEN route.distance_flown > 2000 THEN 'Long-haul' ELSE 'Error' END AS flight_length, 
            AVG(fuel.capacity - flight.total_passengers) AS avg_empty_seat, 
            AVG((fuel.capacity - flight.total_passengers)/fuel.capacity) AS avg_empty_seat_perc 
FROM ba_flights flight 
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     INNER JOIN ba_aircraft aircraft ON aircraft.flight_id = flight.flight_id 
     LEFT JOIN ba_fuel_efficiency fuel ON fuel.ac_subtype = aircraft.ac_subtype 
GROUP BY flight_length ; 
--INNER JOINS would work as well for ba_flight_routes and ba_fuel_efficiency


/*To get started with analysis, create a summary of how many short-haul versus long-haul flights happen.
A typical short-haul flight in Europe has a maximum distance of 2,000 km. 
How many flights are scheduled or completed for both short-haul and long-haul flights in 2023?
-- Note flight_id should be unique in table ba_flights. 
We are adding a DISTINCT clause just in case there is a data issue and flight_id is duplicated. 
Depending on the quality of your data pipelines and data engineering team,
this may not be necessary as an analyst */

SELECT CASE WHEN route.distance_flown <= 2000 THEN 'Short-haul' 
            WHEN route.distance_flown > 2000 THEN 'Long-haul' ELSE 'Error' END AS flight_length,
            COUNT(DISTINCT flight.flight_id) AS total_flights 
FROM ba_flights flight
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
WHERE flight.status IN ('Completed', 'Scheduled') 
      AND flight.actual_flight_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY flight_length ; 
--INNER JOIN would work for the join as well

/*We can calculate how full flights were by comparing the number of passengers on the flight against 
the capacity of the aircraft. Calculate the average number of empty seats for the short-haul and long-haul flights. 
Additionally, can you also calculate the average number of empty seats as a percentage of
the maximum number of passengers? If the manufacturer and sub-type are not available for flights,
we do not need to show the results of these flights.*/

SELECT CASE WHEN route.distance_flown <= 2000 THEN 'Short-haul'
            WHEN route.distance_flown > 2000 THEN 'Long-haul' ELSE 'Error' END AS flight_length, 
            AVG(fuel.capacity - flight.total_passengers) AS avg_empty_seat, 
            AVG((fuel.capacity - flight.total_passengers)/fuel.capacity) AS avg_empty_seat_perc 
FROM ba_flights flight 
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     INNER JOIN ba_aircraft aircraft ON aircraft.flight_id = flight.flight_id 
     LEFT JOIN ba_fuel_efficiency fuel ON fuel.ac_subtype = aircraft.ac_subtype 
GROUP BY flight_length ; 
--INNER JOINS would work as well for ba_flight_routes and ba_fuel_efficiency

/*Calculate the total number of scheduled flights used with more than 100 empty seats in the plane.
Split the flights by short-haul and long-haul flights. Exclude the flights where the manufacturer 
and sub-type are not available*/

SELECT CASE WHEN route.distance_flown <= 2000 THEN 'Short-haul' 
            WHEN route.distance_flown > 2000 THEN 'Long-haul' ELSE 'Error' 
            END AS flight_length, COUNT(DISTINCT flight.flight_id) AS total_flights 
FROM ba_flights flight
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     INNER JOIN ba_aircraft aircraft ON aircraft.flight_id = flight.flight_id 
     LEFT JOIN ba_fuel_efficiency fuel ON fuel.ac_subtype = aircraft.ac_subtype 
WHERE (fuel.capacity - flight.total_passengers) > 100 AND flight.status = 'Scheduled' 
GROUP BY flight_length ; 
--INNER joins also work for the ba_fuel_efficiency and ba_flight_routes tables

/*What short-haul flight routes that have been completed have the highest average number of empty seats? 
Include the flight number, departure city, arrival city, number of completed flights,
and average empty seats in your results. Make sure to include all flights that are available in the data even 
if the capacity information for some flights might be missing.*/

SELECT route.flight_number, 
       route.departure_city, 
       route.arrival_city, 
       COUNT(DISTINCT flight.flight_id) AS total_flights, 
       AVG(fuel.capacity - flight.total_passengers) AS average_empty_seats 
FROM ba_flights flight 
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     LEFT JOIN ba_aircraft aircraft ON aircraft.flight_id = flight.flight_id
     LEFT JOIN ba_fuel_efficiency fuel ON fuel.ac_subtype = aircraft.ac_subtype
WHERE flight.status = 'Completed' 
      AND route.distance_flown <= 2000 
GROUP BY route.flight_number, route.departure_city, route.arrival_city 
ORDER BY average_empty_seats DESC ; 
--INNER joins also work for the ba_fuel_efficiency and ba_flight_routes tables

/*What are the short-haul flight routes and the average number of seats for short-haul flight routes
that only have been completed 2 or fewer times? Include the flight number, departure city, arrival city,
and average empty seats in your results. Make sure to include all flights that are available in the data even 
if the capacity information for some flights might be missing.*/

SELECT route.flight_number,
       route.departure_city, 
       route.arrival_city, 
       AVG(fuel.capacity - flight.total_passengers) AS average_empty_seats 
FROM ba_flights flight 
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number 
     LEFT JOIN ba_aircraft aircraft ON aircraft.flight_id = flight.flight_id 
     LEFT JOIN ba_fuel_efficiency fuel ON fuel.ac_subtype = aircraft.ac_subtype 
WHERE flight.status = 'Completed' 
      AND route.distance_flown <= 2000 
GROUP BY route.flight_number, route.departure_city, route.arrival_city 
HAVING COUNT(DISTINCT flight.flight_id) <= 2 ;
--INNER joins also work for the ba_fuel_efficiency and ba_flight_routes tables

/*What are the short-haul flight routes and the average number of seats for short-haul flight routes 
that only have been completed 2 or fewer times that either depart or arrive in London? Include the flight number,
departure city, arrival city, and average empty seats in your results. 
Make sure to include all flights that are available in the data even if the capacity information 
for some flights might be missing.*/

SELECT 
			 route.flight_number,
			 route.departure_city,
       route.arrival_city,
       AVG(fuel.capacity - flight.total_passengers) AS average_empty_seats
FROM ba_flights flight
     LEFT JOIN ba_flight_routes route ON flight.flight_number = route.flight_number
     LEFT JOIN ba_aircraft aircraft ON aircraft.flight_id = flight.flight_id
     LEFT JOIN ba_fuel_efficiency fuel ON fuel.ac_subtype = aircraft.ac_subtype
WHERE flight.status = 'Completed'
			AND route.distance_flown <= 2000
      AND (route.departure_city = 'London' OR route.arrival_city = 'London')
GROUP BY route.flight_number, route.departure_city, route.arrival_city
HAVING COUNT(DISTINCT flight.flight_id) <= 2;
--INNER joins also work for the ba_fuel_efficiency and ba_flight_routes tables
