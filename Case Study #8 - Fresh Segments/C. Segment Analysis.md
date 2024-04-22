# Case Study #8 - Fresh Segments

## C. Segment Analysis

### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
``` sql
WITH cte AS(
	SELECT interest_id,
		MAX(composition) AS max_composition,
        RANK() OVER(ORDER BY MAX(composition) DESC) AS top,
        RANK() OVER(ORDER BY MAX(composition)) AS bottom
	FROM interest_metrics_filtered
	GROUP BY interest_id)
SELECT m.interest_id, interest_name, interest_summary, month_year, composition, percentile_ranking
FROM cte
INNER JOIN interest_metrics m
	ON cte.interest_id = m.interest_id AND cte.max_composition = m.composition
INNER JOIN interest_map p
	ON cte.interest_id = p.id
WHERE top <= 10 OR bottom <= 10
ORDER BY composition DESC;
```
Result:
| interest_id | interest_name                     | interest_summary                                                                                                                                 | month_year | composition | percentile_ranking |
| :---------- | :-------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- | :--------- | :---------- | :----------------- |
| 21057       | Work Comes First Travelers        | People looking to book a hotel who travel frequently for business and vacation.                                                                  | 2018-12-01 | 21.2        | 97.89              |
| 6284        | Gym Equipment Owners              | People researching and comparing fitness trends and techniques. These consumers are more likely to spend money on gym equipment for their homes. | 2018-07-01 | 18.82       | 81.89              |
| 39          | Furniture Shoppers                | Consumers shopping for major home furnishings.                                                                                                   | 2018-07-01 | 17.44       | 81.07              |
| 77          | Luxury Retail Shoppers            | Consumers shopping for high end fashion apparel and accessories.                                                                                 | 2018-07-01 | 17.19       | 79.42              |
| 12133       | Luxury Boutique Hotel Researchers | Consumers comparing or purchasing accommodations at luxury, boutique hotels.                                                                     | 2018-10-01 | 15.15       | 97.08              |
| 5969        | Luxury Bedding Shoppers           | Consumers shopping for luxury bedding.                                                                                                           | 2018-12-01 | 15.05       | 94.87              |
| 171         | Shoe Shoppers                     | Consumers shopping for mass market shoes.                                                                                                        | 2018-07-01 | 14.91       | 97.67              |
| 4898        | Cosmetics and Beauty Shoppers     | Consumers comparing and shopping for cosmetics and beauty products.                                                                              | 2018-07-01 | 14.23       | 60.91              |
| 6286        | Luxury Hotel Guests               | High income individuals researching and booking hotel rooms.                                                                                     | 2018-07-01 | 14.1        | 96.57              |
| 4           | Luxury Retail Researchers         | Consumers researching luxury product reviews and gift ideas.                                                                                     | 2018-07-01 | 13.97       | 98.08              |
| 58          | Budget Wireless Shoppers          | Consumers researching discount wireless service plans.                                                                                           | 2018-07-01 | 2.18        | 5.62               |
| 36138       | Haunted House Researchers         | People researching and planning to visit haunted houses across the US.                                                                           | 2019-02-01 | 2.18        | 9.46               |
| 34085       | Oakland Raiders Fans              | People reading news about the Oakland Raiders and watching games. These consumers are more likely to spend money on team gear.                   | 2019-08-01 | 2.14        | 33.16              |
| 22408       | Super Mario Bros Fans             | People reading news and product releases for Super Mario Bros games and merchandise.                                                             | 2018-07-01 | 2.12        | 2.47               |
| 42011       | League of Legends Video Game Fans | People reading League of Legends news and following gaming trends.                                                                               | 2019-01-01 | 2.09        | 0.82               |
| 37421       | Budget Mobile Phone Researchers   | Consumers researching budget mobile phones and wireless plans.                                                                                   | 2019-08-01 | 2.09        | 9.66               |
| 19591       | Camaro Enthusiasts                | People researching and comparing Camaro vehicles. These consumers are more likely to spend money on a new or used car.                           | 2018-10-01 | 2.08        | 7.35               |
| 19635       | Xbox Enthusiasts                  | People reading news about Xbox and researching games for the system.                                                                             | 2018-07-01 | 2.05        | 3.16               |
| 19599       | Dodge Vehicle Shoppers            | People researching and comparing Dodge vehicles. These consumers are more likely to spend money on a new or used car.                            | 2019-03-01 | 1.97        | 4.84               |
| 37412       | Medieval History Enthusiasts      | People researching medieval history and purchasing history books and products.                                                                   | 2018-10-01 | 1.94        | 7.93               |
| 33958       | Astrology Enthusiasts             | People reading daily horoscopes and astrology content.                                                                                           | 2018-08-01 | 1.88        | 3.52               |

### 2. Which 5 interests had the lowest average ranking value?
``` sql
SELECT interest_id, interest_name, interest_summary, AVG(percentile_ranking) AS avg_ranking
FROM interest_metrics_filtered f
INNER JOIN interest_map p
	ON f.interest_id = p.id
GROUP BY interest_id
ORDER BY avg_ranking
LIMIT 5;
```
Result:
| interest_id | interest_name                     | interest_summary                                                   | avg_ranking          |
| :---------- | :-------------------------------- | :----------------------------------------------------------------- | :------------------- |
| 21245       | Readers of Honduran Content       | People reading news from Honduran media sources.                   | 0.051999999582767485 |
| 2           | Gamers                            | Consumers researching game reviews and cheat codes.                | 0.4854545369744301   |
| 42011       | League of Legends Video Game Fans | People reading League of Legends news and following gaming trends. | 0.4857142897588866   |
| 6065        | Solar Energy Researchers          | Consumers researching products and services to use solar energy.   | 0.565000000099341    |
| 6050        | Readers of Malayalam Content      | People reading news from Malayalam media sources.                  | 0.8300000093877316   |

### 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
``` sql
SELECT interest_id, interest_name, interest_summary, ROUND(STD(percentile_ranking), 2) AS std_percentile
FROM interest_metrics_filtered f
INNER JOIN interest_map p
	ON f.interest_id = p.id
GROUP BY interest_id
ORDER BY std_percentile DESC
LIMIT 5;
```
Result:
| interest_id | interest_name                          | interest_summary                                                                                                                             | std_percentile |
| :---------- | :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------- | :------------- |
| 23          | Techies                                | Readers of tech news and gadget reviews.                                                                                                     | 27.55          |
| 38992       | Oregon Trip Planners                   | People researching attractions and accommodations in Oregon. These consumers are more likely to spend money on travel and local attractions. | 26.87          |
| 20764       | Entertainment Industry Decision Makers | Professionals reading industry news and researching trends in the entertainment industry.                                                    | 26.45          |
| 43546       | Personalized Gift Shoppers             | Consumers shopping for gifts that can be personalized.                                                                                       | 24.55          |
| 103         | Live Concert Fans                      | Consumers researching live concerts and music festivals.                                                                                     | 23.45          |

### 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
``` sql
WITH cte AS (
	SELECT 
		interest_id, 
		ROUND(STD(percentile_ranking), 2) AS std_percentile,
		MIN(percentile_ranking) AS min_percentile,
		MAX(percentile_ranking) AS max_percentile
	FROM interest_metrics_filtered
	GROUP BY interest_id
	ORDER BY std_percentile DESC
	LIMIT 5)
SELECT cte.interest_id, interest_name, interest_summary, std_percentile, m1.month_year AS min_month_year, min_percentile, m2.month_year AS max_month_year, max_percentile
FROM cte
INNER JOIN interest_map p
	ON cte.interest_id = p.id
INNER JOIN interest_metrics m1
	ON cte.interest_id = m1.interest_id AND cte.min_percentile = m1.percentile_ranking
INNER JOIN interest_metrics m2
	ON cte.interest_id = m2.interest_id AND cte.max_percentile = m2.percentile_ranking
ORDER BY std_percentile DESC;
```
Result:
| interest_id | interest_name                          | interest_summary                                                                                                                             | std_percentile | min_month_year | min_percentile | max_month_year | max_percentile |
| :---------- | :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------- | :------------- | :------------- | :------------- | :------------- | :------------- |
| 23          | Techies                                | Readers of tech news and gadget reviews.                                                                                                     | 27.55          | 2019-08-01     | 7.92           | 2018-07-01     | 86.69          |
| 38992       | Oregon Trip Planners                   | People researching attractions and accommodations in Oregon. These consumers are more likely to spend money on travel and local attractions. | 26.87          | 2019-07-01     | 2.2            | 2018-11-01     | 82.44          |
| 20764       | Entertainment Industry Decision Makers | Professionals reading industry news and researching trends in the entertainment industry.                                                    | 26.45          | 2019-08-01     | 11.23          | 2018-07-01     | 86.15          |
| 43546       | Personalized Gift Shoppers             | Consumers shopping for gifts that can be personalized.                                                                                       | 24.55          | 2019-06-01     | 5.7            | 2019-03-01     | 73.15          |
| 103         | Live Concert Fans                      | Consumers researching live concerts and music festivals.                                                                                     | 23.45          | 2019-07-01     | 18.75          | 2018-07-01     | 95.61          |

To see more clearly what is happening for these 5 interests, let's see their percentile ranking in all month_year:
```sql
WITH cte AS (
	SELECT 
		interest_id, 
		ROUND(STD(percentile_ranking), 2) AS std_percentile,
		MIN(percentile_ranking) AS min_percentile,
		MAX(percentile_ranking) AS max_percentile
	FROM interest_metrics_filtered
	GROUP BY interest_id
	ORDER BY std_percentile DESC
	LIMIT 5)
SELECT
	cte.interest_id,
    interest_name, 
    month_year,
    percentile_ranking,
    CASE
		WHEN percentile_ranking = min_percentile THEN 'min percentile'
        WHEN percentile_ranking = max_percentile THEN 'max percentile'
	END AS min_max_percentile
FROM cte
INNER JOIN interest_map p
	ON cte.interest_id = p.id
INNER JOIN interest_metrics m
	ON cte.interest_id = m.interest_id 
ORDER BY std_percentile DESC, month_year;
```
Result:
| interest_id | interest_name                          | month_year | percentile_ranking | min_max_percentile |
| :---------- | :------------------------------------- | :--------- | :----------------- | :----------------- |
| 23          | Techies                                | 2018-07-01 | 86.69              | max percentile     |
| 23          | Techies                                | 2018-08-01 | 30.9               |                    |
| 23          | Techies                                | 2018-09-01 | 23.85              |                    |
| 23          | Techies                                | 2019-02-01 | 9.46               |                    |
| 23          | Techies                                | 2019-03-01 | 9.68               |                    |
| 23          | Techies                                | 2019-08-01 | 7.92               | min percentile     |
| 38992       | Oregon Trip Planners                   | 2018-11-01 | 82.44              | max percentile     |
| 38992       | Oregon Trip Planners                   | 2018-12-01 | 58.79              |                    |
| 38992       | Oregon Trip Planners                   | 2019-01-01 | 63.31              |                    |
| 38992       | Oregon Trip Planners                   | 2019-02-01 | 78.32              |                    |
| 38992       | Oregon Trip Planners                   | 2019-03-01 | 22.45              |                    |
| 38992       | Oregon Trip Planners                   | 2019-04-01 | 22.75              |                    |
| 38992       | Oregon Trip Planners                   | 2019-05-01 | 26.72              |                    |
| 38992       | Oregon Trip Planners                   | 2019-06-01 | 14.93              |                    |
| 38992       | Oregon Trip Planners                   | 2019-07-01 | 2.2                | min percentile     |
| 38992       | Oregon Trip Planners                   | 2019-08-01 | 25.41              |                    |
| 20764       | Entertainment Industry Decision Makers | 2018-07-01 | 86.15              | max percentile     |
| 20764       | Entertainment Industry Decision Makers | 2018-08-01 | 16.04              |                    |
| 20764       | Entertainment Industry Decision Makers | 2018-10-01 | 18.67              |                    |
| 20764       | Entertainment Industry Decision Makers | 2019-02-01 | 22.12              |                    |
| 20764       | Entertainment Industry Decision Makers | 2019-03-01 | 11.53              |                    |
| 20764       | Entertainment Industry Decision Makers | 2019-08-01 | 11.23              | min percentile     |
| 43546       | Personalized Gift Shoppers             | 2019-01-01 | 63.31              |                    |
| 43546       | Personalized Gift Shoppers             | 2019-02-01 | 58.61              |                    |
| 43546       | Personalized Gift Shoppers             | 2019-03-01 | 73.15              | max percentile     |
| 43546       | Personalized Gift Shoppers             | 2019-04-01 | 63.51              |                    |
| 43546       | Personalized Gift Shoppers             | 2019-05-01 | 33.14              |                    |
| 43546       | Personalized Gift Shoppers             | 2019-06-01 | 5.7                | min percentile     |
| 43546       | Personalized Gift Shoppers             | 2019-07-01 | 9.38               |                    |
| 43546       | Personalized Gift Shoppers             | 2019-08-01 | 27.94              |                    |
| 103         | Live Concert Fans                      | 2018-07-01 | 95.61              | max percentile     |
| 103         | Live Concert Fans                      | 2018-08-01 | 77.97              |                    |
| 103         | Live Concert Fans                      | 2018-09-01 | 78.97              |                    |
| 103         | Live Concert Fans                      | 2018-10-01 | 81.21              |                    |
| 103         | Live Concert Fans                      | 2018-11-01 | 70.91              |                    |
| 103         | Live Concert Fans                      | 2018-12-01 | 45.23              |                    |
| 103         | Live Concert Fans                      | 2019-01-01 | 41.52              |                    |
| 103         | Live Concert Fans                      | 2019-02-01 | 43.44              |                    |
| 103         | Live Concert Fans                      | 2019-03-01 | 35.39              |                    |
| 103         | Live Concert Fans                      | 2019-04-01 | 27.3               |                    |
| 103         | Live Concert Fans                      | 2019-07-01 | 18.75              | min percentile     |
| 103         | Live Concert Fans                      | 2019-08-01 | 49.17              |                    |

The data show that the above interests' popularity are not consistent. They are all drop significantly at the end of the dataset's period.

### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
Based off their composition and ranking values, these customers seem to be interested in luxury products and services, fitness, wellness and home furnishings. They are likely to be high-income individuals who travel frequently for both business and leisure. Accordingly, we should show them more offer about luxury hotels, high-end fashion and cosmetic, fitness equipment, and luxury home furnishings. We could also offer services related to travel and wellness, such as spa treatments or personal training sessions.

On the other hand, we should avoid offering low-price products and services like budget wireless plan or mobile phones as well as gaming products and content since customers are inattentive with these suggestions.

<br>

***
Let's move to [D. Index Analysis](./D.%20Index%20Analysis.md).
