-- Keep a log of any SQL queries you execute as you solve the mystery.

-- check the schema of crime_scene_reports
.schema crime_scene_reports

-- Select rows from crime_scene_reports where month is 7 day is 28 and street is Humphrey Street
SELECT * FROM crime_scene_reports WHERE month = 7 AND day = 28 AND street = 'Humphrey Street';

-- The theft took place at 10:15 PM at Humphrey Street bakery

-- checking the schema of interviews
.schema interviews

-- checking the interviews taken on day 28 and month 7
SELECT * FROM interviews WHERE day = 28 AND month = 7;
-- withen 10 mins from 10:15 PM, the theif took the car from the bakery and left.
-- the thief was withdrawing money from the ATM earlier that day at Leggett Street
-- the thief asked someone to purchase a ticket out of fiftyville the next day

-- check schema of bakery_security_logs
.schema bakery_security_logs

-- Select rows from bakery_security_logs where day is 28 and month is 7 with in 10 mins of 10:15 AM
SELECT * FROM bakery_security_logs WHERE day = 28 AND month = 7 AND hour = 10 AND minute > 15 AND minute < 25;
-- I got a bunch of licence plates

-- checking the atm transactions on day 28 and month 7 before 10:15 AM for transaction_type = 'withdraw' at atm_location = 'Emma's Bakery'
SELECT * FROM atm_transactions WHERE day = 28 AND month = 7 AND transaction_type = 'withdraw' AND atm_location = 'Leggett Street';
-- I found a bunch of account numbers and ids

-- sellecting all flights on day = 29 month = 7 with origin airport being fiftyville
SELECT * FROM flights
JOIN airports ON flights.origin_airport_id = airports.id
WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'
ORDER BY flights.hour, flights.minute
LIMIT 1;
-- i found a list of flights leaving fiftyville on day 29 month 7 with

-- sellecting all passengers with flight_id = id from above query
SELECT * FROM passengers
WHERE flight_id IN
    (SELECT flights.id FROM flights
    JOIN airports ON flights.origin_airport_id = airports.id
WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'
ORDER BY flights.hour, flights.minute
LIMIT 1
    );
-- I got a list of passport numbers.

-- Now i will sellect all people with passport numbers from above query
SELECT * FROM people
WHERE passport_number IN
    (SELECT passengers.passport_number FROM passengers
    WHERE flight_id IN
        (SELECT flights.id FROM flights
        JOIN airports ON flights.origin_airport_id = airports.id
        WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'
        ORDER BY flights.hour, flights.minute
LIMIT 1
        )
    );
-- I now have a list of names with their passport numbers and license plate numbers

-- Now i will sellect all people with the licence plate that were at the bakery on day 28 month 7
SELECT * FROM people
JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
WHERE passport_number IN
    (SELECT passengers.passport_number FROM passengers
    WHERE flight_id IN
        (SELECT flights.id FROM flights
        JOIN airports ON flights.origin_airport_id = airports.id
        WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville' ORDER BY flights.hour, flights.minute
LIMIT 1
        )
    )
AND bakery_security_logs.day = 28 AND bakery_security_logs.month = 7 AND bakery_security_logs.hour = 10 AND bakery_security_logs.minute > 15 AND bakery_security_logs.minute < 25
GROUP BY people.license_plate;
-- I got a list of names with their passport numbers and license plate numbers who are leaving fiftyville on day 29 month 7 and were also at the bakery on day 28 month 7 at 10:15 AM

-- Sellect bank accounts with account numbers who have made transactions at the atm on day 28 month 7 at Leggett Street
SELECT * FROM bank_accounts
WHERE account_number IN
    (SELECT atm_transactions.account_number FROM atm_transactions
    WHERE day = 28 AND month = 7 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
    );

-- Now i will find the names of people with the above bank accounts
SELECT * FROM people
WHERE id IN
    (SELECT bank_accounts.person_id FROM bank_accounts
    WHERE account_number IN
        (SELECT atm_transactions.account_number FROM atm_transactions
        WHERE day = 28 AND month = 7 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
        )
    );

-- Now i will find the person who withdrew money from the atm on day 28 month 7 at Leggett Street and is also leaving fiftyville on day 29 month 7 and was at the bakery on day 28 month 7 at 10:15 AM
SELECT * FROM people
WHERE id IN
    (SELECT bank_accounts.person_id FROM bank_accounts
    WHERE account_number IN
        (SELECT atm_transactions.account_number FROM atm_transactions
        WHERE day = 28 AND month = 7 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
        )
    )
AND name IN
    (SELECT people.name FROM people
JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
WHERE passport_number IN
    (SELECT passengers.passport_number FROM passengers
    WHERE flight_id IN
        (SELECT flights.id FROM flights
        JOIN airports ON flights.origin_airport_id = airports.id
        WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'ORDER BY flights.hour, flights.minute
LIMIT 1
        )
    )
AND bakery_security_logs.day = 28 AND bakery_security_logs.month = 7 AND bakery_security_logs.hour = 10 AND bakery_security_logs.minute > 15 AND bakery_security_logs.minute < 25
GROUP BY people.license_plate);
-- I got a list of three people who are leaving fiftyville on day 29 month 7 and were also at the bakery on day 28 month 7 at 10:15 AM and withdrew money from the atm on day 28 month 7 at Leggett Street

-- Now i will look at the phone calls made by the above people on day 28 month 7
SELECT * FROM phone_calls
WHERE caller IN
   (
    SELECT people.phone_number FROM people
    WHERE id IN
    (SELECT bank_accounts.person_id FROM bank_accounts
        WHERE account_number IN
        (SELECT atm_transactions.account_number FROM atm_transactions
        WHERE day = 28 AND month = 7 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
        )
    )
    AND name IN
    (SELECT people.name FROM people
    JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
    WHERE passport_number IN
        (SELECT passengers.passport_number FROM passengers
        WHERE flight_id IN
            (SELECT flights.id FROM flights
            JOIN airports ON flights.origin_airport_id = airports.id
            WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'ORDER BY flights.hour, flights.minute
LIMIT 1
            )
        )
    AND bakery_security_logs.day = 28 AND bakery_security_logs.month = 7 AND bakery_security_logs.hour = 10 AND bakery_security_logs.minute > 15 AND bakery_security_logs.minute < 25
    GROUP BY people.license_plate
    )
   )
   AND month = 7 AND day = 28;

-- i found a list of phone calls made by the three people on day 28 month 7

-- I will now see if the receiver is on the flight
SELECT * FROM phone_calls
WHERE caller IN
   (
    SELECT people.phone_number FROM people
WHERE id IN
    (SELECT bank_accounts.person_id FROM bank_accounts
    WHERE account_number IN
        (SELECT atm_transactions.account_number FROM atm_transactions
        WHERE day = 28 AND month = 7 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
        )
    )
AND name IN
    (SELECT people.name FROM people
JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
WHERE passport_number IN
    (SELECT passengers.passport_number FROM passengers
    WHERE flight_id IN
        (SELECT flights.id FROM flights
        JOIN airports ON flights.origin_airport_id = airports.id
        WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'ORDER BY flights.hour, flights.minute
LIMIT 1
        )
    )
AND bakery_security_logs.day = 28 AND bakery_security_logs.month = 7 AND bakery_security_logs.hour = 10 AND bakery_security_logs.minute > 15 AND bakery_security_logs.minute < 25
GROUP BY people.license_plate)
   )
AND receiver IN
   (
    SELECT people.phone_number FROM people
WHERE passport_number IN
    (SELECT passengers.passport_number FROM passengers
    WHERE flight_id IN
        (SELECT flights.id FROM flights
        JOIN airports ON flights.origin_airport_id = airports.id
        WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'ORDER BY flights.hour, flights.minute
LIMIT 1
        )
    )
   );

--Finding destination airport
SELECT * FROM airports
WHERE id IN
    (SELECT flights.destination_airport_id FROM flights
JOIN airports ON flights.origin_airport_id = airports.id
WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'
ORDER BY flights.hour, flights.minute
LIMIT 1);

-- name of the person who made the phone call
SELECT * FROM people
WHERE phone_number IN
    (SELECT phone_calls.caller FROM phone_calls
WHERE caller IN
   (
    SELECT people.phone_number FROM people
    WHERE id IN
    (SELECT bank_accounts.person_id FROM bank_accounts
        WHERE account_number IN
        (SELECT atm_transactions.account_number FROM atm_transactions
        WHERE day = 28 AND month = 7 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw'
        )
    )
    AND name IN
    (SELECT people.name FROM people
    JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
    WHERE passport_number IN
        (SELECT passengers.passport_number FROM passengers
        WHERE flight_id IN
            (SELECT flights.id FROM flights
            JOIN airports ON flights.origin_airport_id = airports.id
            WHERE flights.day = 29 AND flights.month = 7 AND airports.city = 'Fiftyville'ORDER BY flights.hour, flights.minute
LIMIT 1
            )
        )
    AND bakery_security_logs.day = 28 AND bakery_security_logs.month = 7 AND bakery_security_logs.hour = 10 AND bakery_security_logs.minute > 15 AND bakery_security_logs.minute < 25
    GROUP BY people.license_plate
    )
   )
   AND month = 7 AND day = 28
    );