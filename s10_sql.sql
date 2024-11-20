--1. Отобразите все записи из таблицы company по компаниям, которые закрылись.
SELECT *
FROM company
WHERE status = 'closed';

--2. Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total.
SELECT funding_total
FROM company
WHERE category_code = 'news'
AND country_code = 'USA'
ORDER BY funding_total DESC;

--3. Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code='cash'
AND acquired_at BETWEEN '2011-01-01' AND '2013-12-31';

--4. Отобразите имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.
SELECT first_name,
last_name,
network_username
FROM people
WHERE network_username LIKE 'Silver%';

--5. Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.
SELECT *
FROM people
WHERE network_username LIKE '%money%'
AND last_name LIKE 'K%';

--6. Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране.
-- Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.
SELECT country_code,
SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

--7. Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
-- Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
SELECT CAST(funded_at AS date),
MIN(raised_amount),
MAX(raised_amount)
FROM funding_round
GROUP BY CAST(funded_at AS date)
HAVING MIN(raised_amount) != 0
AND MIN(raised_amount) != MAX(raised_amount);

--8. Создайте поле с категориями:
-- Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
-- Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
-- Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
-- Отобразите все поля таблицы fund и новое поле с категориями.
SELECT *,
CASE
    WHEN invested_companies >= 100 THEN 'high_activity'
    WHEN 20 <= invested_companies AND invested_companies < 100 THEN 'middle_activity'
    WHEN invested_companies < 20 THEN 'low_activity'
END
FROM fund;

--9. Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего
-- целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие.
-- Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.
SELECT
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
ROUND(AVG(investment_rounds), 0) AS avg
FROM fund
GROUP BY activity
ORDER BY avg;

--10. Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
-- Для каждой страны посчитайте минимальное, максимальное и среднее число компаний,
-- в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно.
-- Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
-- Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему.
-- Затем добавьте сортировку по коду страны в лексикографическом порядке.
SELECT country_code,
MIN(invested_companies),
MAX(invested_companies),
AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10;

--11. Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
SELECT first_name,
last_name,
instituition
FROM people
LEFT OUTER JOIN education ON people.id = education.person_id;

--12. Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов.
SELECT company.name,
COUNT(DISTINCT instituition)
FROM company
INNER JOIN people ON company.id = people.company_id
INNER JOIN education ON people.id = education.person_id
GROUP BY company.name
ORDER BY COUNT(DISTINCT instituition) DESC
LIMIT 5;

--13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
SELECT DISTINCT name
FROM company
INNER JOIN funding_round ON company.id = funding_round.company_id
WHERE is_first_round = 1
AND is_last_round = 1
AND company.status = 'closed';

--14. Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
SELECT DISTINCT people.id
FROM company
INNER JOIN funding_round ON company.id = funding_round.company_id
INNER JOIN people ON company.id = people.company_id
WHERE is_first_round = 1
AND is_last_round = 1
AND company.status = 'closed';

--15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
SELECT DISTINCT people.id,
education.instituition
FROM company
INNER JOIN funding_round ON company.id = funding_round.company_id
INNER JOIN people ON company.id = people.company_id
INNER JOIN education ON people.id = education.person_id
WHERE is_first_round = 1
AND is_last_round = 1
AND company.status = 'closed';

--16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.
SELECT people.id,
COUNT(education.instituition)
FROM people
LEFT JOIN education ON people.id = education.person_id
WHERE people.company_id IN
(SELECT company.id
FROM company
JOIN funding_round ON company.id = funding_round.company_id
WHERE status ='closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY company.id)
GROUP BY people.id
HAVING COUNT(DISTINCT education.instituition) > 0;

--17. Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных),
-- которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.
SELECT AVG(ct)
FROM (SELECT people.id,
COUNT(education.instituition) AS ct
FROM people
LEFT JOIN education ON people.id = education.person_id
WHERE people.company_id IN
(SELECT company.id
FROM company
JOIN funding_round ON company.id = funding_round.company_id
WHERE status ='closed'
AND is_first_round = 1
AND is_last_round = 1
GROUP BY company.id)
GROUP BY people.id
HAVING COUNT(DISTINCT education.instituition) > 0) AS id_ct;

--18. Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.
SELECT AVG(ct)
FROM (SELECT people.id,
COUNT(education.instituition) AS ct
FROM people
LEFT JOIN education ON people.id = education.person_id
WHERE people.company_id IN
(SELECT company.id
FROM company
JOIN funding_round ON company.id = funding_round.company_id
WHERE company.name = 'Socialnet'
GROUP BY company.id)
GROUP BY people.id
HAVING COUNT(DISTINCT education.instituition) > 0) AS id_ct;

--19. Составьте таблицу из полей:
-- name_of_fund — название фонда;
-- name_of_company — название компании;
-- amount — сумма инвестиций, которую привлекла компания в раунде.
-- В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
SELECT fund.name AS name_of_fund,
company.name AS name_of_company,
funding_round.raised_amount AS amount
FROM fund
INNER JOIN investment ON fund.id = investment.fund_id
INNER JOIN funding_round ON investment.funding_round_id = funding_round.id
INNER JOIN company ON investment.company_id = company.id
WHERE EXTRACT(YEAR FROM funded_at) BETWEEN 2012 AND 2013
AND company.milestones > 6;

--20. Выгрузите таблицу, в которой будут такие поля:
-- название компании-покупателя;
-- сумма сделки;
-- название компании, которую купили;
-- сумма инвестиций, вложенных в купленную компанию;
-- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
-- Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
-- Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.
WITH acquiring AS
(
    SELECT company.name AS acquiring,
    acquisition.price_amount,
    acquisition.id
    FROM acquisition
    LEFT JOIN company ON acquisition.acquiring_company_id = company.id
    WHERE acquisition.price_amount > 0
),

acquired AS 
(
    SELECT company.name AS acquired,
    company.funding_total,
    acquisition.id
    FROM acquisition
    LEFT JOIN company ON acquisition.acquired_company_id = company.id
    WHERE company.funding_total > 0 
)

SELECT 
acquiring.acquiring,
acquiring.price_amount,
acquired.acquired,
acquired.funding_total,
ROUND(acquiring.price_amount / acquired.funding_total, 0)
FROM acquiring
INNER JOIN acquired ON acquiring.id = acquired.id
ORDER BY acquiring.price_amount DESC, acquired.acquired
LIMIT 10;

--21. Выгрузите таблицу, в которую войдут названия компаний из категории social,
-- получившие финансирование с 2010 по 2013 год включительно.
-- Проверьте, что сумма инвестиций не равна нулю.
-- Выведите также номер месяца, в котором проходил раунд финансирования.
SELECT company.name,
EXTRACT(MONTH FROM funding_round.funded_at)
FROM company
INNER JOIN funding_round ON company.id = funding_round.company_id
WHERE category_code = 'social'
AND raised_amount > 0
AND EXTRACT(YEAR FROM funding_round.funded_at) BETWEEN 2010 AND 2013;

--22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
-- номер месяца, в котором проходили раунды;
-- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
-- количество компаний, купленных за этот месяц;
-- общая сумма сделок по покупкам в этом месяце.
WITH funds AS
(
    SELECT EXTRACT(MONTH FROM CAST(funding_round.funded_at AS DATE)) AS mn,
    COUNT(DISTINCT fund.id) AS fnd
    FROM fund
    LEFT JOIN investment ON fund.id = investment.fund_id
    LEFT JOIN funding_round ON investment.funding_round_id = funding_round.id
    WHERE EXTRACT(YEAR FROM funding_round.funded_at) BETWEEN 2010 AND 2013
    AND country_code = 'USA'
    GROUP BY EXTRACT(MONTH FROM funding_round.funded_at)
),

acqn AS
(
    SELECT EXTRACT(MONTH FROM acquisition.acquired_at) AS mn,
    COUNT(acquired_company_id) AS bought,
    SUM(price_amount) AS amount
    FROM acquisition
    WHERE EXTRACT(YEAR FROM acquisition.acquired_at) BETWEEN 2010 AND 2013
    GROUP BY EXTRACT(MONTH FROM acquisition.acquired_at)
)

SELECT funds.mn,
fnd,
bought,
amount
FROM funds
LEFT JOIN acqn ON funds.mn = acqn.mn;

--23. Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран,
-- в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах.
-- Данные за каждый год должны быть в отдельном поле.
-- Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.
WITH inv_2011 AS
(
    SELECT country_code,
    AVG(funding_total) AS y2011
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2011 AND 2013
    GROUP BY country_code,
    EXTRACT(YEAR FROM founded_at)
    HAVING EXTRACT(YEAR FROM founded_at) = '2011'
),  -- сформируйте первую временную таблицу

inv_2012 AS (
    SELECT country_code,
    AVG(funding_total) AS y2012
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2011 AND 2013
    GROUP BY country_code,
    EXTRACT(YEAR FROM founded_at)
    HAVING EXTRACT(YEAR FROM founded_at) = '2012'
),

inv_2013 AS (
    SELECT country_code,
    AVG(funding_total) AS y2013
    FROM company
    WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2011 AND 2013
    GROUP BY country_code,
    EXTRACT(YEAR FROM founded_at)
    HAVING EXTRACT(YEAR FROM founded_at) = '2013'
)

SELECT inv_2011.country_code,
       -- отобразите нужные поля
       y2011,
       y2012,
       y2013       
FROM inv_2011
INNER JOIN inv_2012 ON inv_2011.country_code = inv_2012.country_code-- укажите таблицу
INNER JOIN inv_2013 ON inv_2012.country_code = inv_2013.country_code-- присоедините таблицы
ORDER BY y2011 DESC;