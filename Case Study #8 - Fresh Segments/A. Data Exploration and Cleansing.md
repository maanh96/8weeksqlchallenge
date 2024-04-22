# Case Study #8 - Fresh Segments

## A. Data Exploration and Cleansing

### 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
``` sql
ALTER TABLE interest_metrics
MODIFY COLUMN month_year VARCHAR(10);

UPDATE interest_metrics
SET month_year = STR_TO_DATE(CONCAT('01-', month_year), "%d-%m-%Y")
WHERE month_year IS NOT NULL;

ALTER TABLE interest_metrics
MODIFY COLUMN month_year DATE;

SELECT * FROM interest_metrics;
```
Result:
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
| :----- | :---- | :--------- | :---------- | :---------- | :---------- | :------ | :----------------- |
| 7      | 2018  | 2018-07-01 | 32486       | 11.89       | 6.19        | 1       | 99.86              |
| 7      | 2018  | 2018-07-01 | 6106        | 9.93        | 5.31        | 2       | 99.73              |
| 7      | 2018  | 2018-07-01 | 18923       | 10.85       | 5.29        | 3       | 99.59              |
| 7      | 2018  | 2018-07-01 | 6344        | 10.32       | 5.1         | 4       | 99.45              |
| 7      | 2018  | 2018-07-01 | 100         | 10.77       | 5.04        | 5       | 99.31              |
| 7      | 2018  | 2018-07-01 | 69          | 10.82       | 5.03        | 6       | 99.18              |
| 7      | 2018  | 2018-07-01 | 79          | 11.21       | 4.97        | 7       | 99.04              |
| 7      | 2018  | 2018-07-01 | 6111        | 10.71       | 4.83        | 8       | 98.9               |
| 7      | 2018  | 2018-07-01 | 6214        | 9.71        | 4.83        | 8       | 98.9               |
| 7      | 2018  | 2018-07-01 | 19422       | 10.11       | 4.81        | 10      | 98.63              |
| ...    |

### 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
``` sql
SELECT month_year, COUNT(*) AS total_records
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;
```
Result:
| month_year | total_records |
| :--------- | :------------ |
|            | 1194          |
| 2018-07-01 | 729           |
| 2018-08-01 | 767           |
| 2018-09-01 | 780           |
| 2018-10-01 | 857           |
| 2018-11-01 | 928           |
| 2018-12-01 | 995           |
| 2019-01-01 | 973           |
| 2019-02-01 | 1121          |
| 2019-03-01 | 1136          |
| 2019-04-01 | 1099          |
| 2019-05-01 | 857           |
| 2019-06-01 | 824           |
| 2019-07-01 | 864           |
| 2019-08-01 | 1149          |

### 3. What do you think we should do with these null values in the fresh_segments.interest_metrics
First let's check the total number of null values.
``` sql
SELECT 
	COUNT(*) AS total_null,
    COUNT(*) / (SELECT COUNT(*) FROM interest_metrics)*100 AS null_percent
FROM interest_metrics
WHERE CONCAT(_month, _year, month_year, interest_id, composition, index_value) IS NULL;
```
Result:
| total_null | null_percent |
| :--------- | :----------- |
| 1194       | 8.3654       |

```sql
SELECT *
FROM interest_metrics
WHERE CONCAT(_month, _year, month_year, interest_id, composition, index_value) IS NULL;
```
Result:
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
| :----- | :---- | :--------- | :---------- | :---------- | :---------- | :------ | :----------------- |
|        |       |            |             | 6.12        | 2.85        | 43      | 96.4               |  |  |  |  |
|        |       |            |             | 7.13        | 2.84        | 45      | 96.23              |  |  |  |  |
|        |       |            |             | 6.82        | 2.84        | 45      | 96.23              |  |  |  |  |
|        |       |            |             | 5.96        | 2.83        | 47      | 96.06              |  |  |  |  |
|        |       |            |             | 7.73        | 2.82        | 48      | 95.98              |  |  |  |  |
| ...    |

There are 1194 null values, which are accounted for 8.37% of total rows and appear in the `_month`, `_year`, `month_year` and `interest_id` columns. In our case this information is crucial and without it, the records are not much useful so we will delete these rows from our table.

```sql
DELETE FROM interest_metrics WHERE month_year IS NULL;
```

### 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
``` sql
-- count number of interest_id in interest_metrics but not in interest_map

SELECT COUNT(*) AS not_in_map
FROM interest_metrics e
LEFT JOIN interest_map m
	ON e.interest_id = m.id
WHERE m.id IS NULL;
```
Result:
| not_in_map |
| :--------- |
| 0          |

```sql
-- count number of interest_id in interest_map but not in interest_metrics

SELECT COUNT(*) AS not_in_metrics
FROM interest_metrics e
RIGHT JOIN interest_map m
	ON e.interest_id = m.id
WHERE e.interest_id IS NULL;
```
Result:
| not_in_metrics |
| :------------- |
| 7              |

### 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
``` sql
SELECT COUNT(*) AS total_records, COUNT(DISTINCT id) AS total_id
FROM interest_map;
```
Result:
| total_records | total_id |
| :------------ | :------- |
| 1209          | 1209     |

### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
From previous question, we know that there are 7 id exist in `interest_map` but not in `interest_metrics`. Since our main data is `interest_metrics` table, we could use INNER JOIN / LEFT JOIN with `interest_metrics` as base or INNER  / RIGHT JOIN with `interest_map` as base.

``` sql
SELECT e.*, interest_name, interest_summary, created_at, last_modified
FROM interest_metrics e
INNER JOIN interest_map m
	ON e.interest_id = m.id
WHERE interest_id = 21246;
```
Result:
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking | interest_name                    | interest_summary                                      | created_at          | last_modified       |
| :----- | :---- | :--------- | :---------- | :---------- | :---------- | :------ | :----------------- | :------------------------------- | :---------------------------------------------------- | :------------------ | :------------------ |
| 7      | 2018  | 2018-07-01 | 21246       | 2.26        | 0.65        | 722     | 0.96               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 8      | 2018  | 2018-08-01 | 21246       | 2.13        | 0.59        | 765     | 0.26               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 9      | 2018  | 2018-09-01 | 21246       | 2.06        | 0.61        | 774     | 0.77               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 10     | 2018  | 2018-10-01 | 21246       | 1.74        | 0.58        | 855     | 0.23               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 11     | 2018  | 2018-11-01 | 21246       | 2.25        | 0.78        | 908     | 2.16               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 12     | 2018  | 2018-12-01 | 21246       | 1.97        | 0.7         | 983     | 1.21               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 1      | 2019  | 2019-01-01 | 21246       | 2.05        | 0.76        | 954     | 1.95               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 2      | 2019  | 2019-02-01 | 21246       | 1.84        | 0.68        | 1109    | 1.07               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 3      | 2019  | 2019-03-01 | 21246       | 1.75        | 0.67        | 1123    | 1.14               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |
| 4      | 2019  | 2019-04-01 | 21246       | 1.58        | 0.63        | 1092    | 0.64               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04 | 2018-06-11 17:50:04 |

### 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
``` sql
-- select records with month_year before created_at

SELECT month_year, created_at
FROM interest_metrics e
INNER JOIN interest_map m
	ON e.interest_id = m.id
WHERE month_year < created_at;
```
Result:
| month_year | created_at          |
| :--------- | :------------------ |
| 2018-07-01 | 2018-07-06 14:35:04 |
| 2018-07-01 | 2018-07-17 10:40:03 |
| 2018-07-01 | 2018-07-06 14:35:04 |
| 2018-07-01 | 2018-07-06 14:35:03 |
| 2018-07-01 | 2018-07-06 14:35:04 |
| ...        |

```sql
-- select records with month of month_year < month of created_at

SELECT month_year, created_at
FROM interest_metrics e
INNER JOIN interest_map m
	ON e.interest_id = m.id
WHERE MONTH(month_year) < MONTH(created_at) AND YEAR(month_year) <= YEAR(created_at);
```
Result:
| month_year | created_at |
| :--------- | :--------- |
| &nbsp;     |

There are records with `month_year` values before `created_at` values but they are still valid since they are all within the same month and the `month_year` column was set to be the first day of the month.

<br>

***
Let's move to [B. Interest Analysis](./B.%20Interest%20Analysis.md).
