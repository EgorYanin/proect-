CREATE TABLE Company (
        company_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city TEXT NOT NULL,
        office_rating INTEGER CHECK (office_rating BETWEEN 1 AND 10),
        parent_company TEXT,
        FOREIGN KEY (parent_company) REFERENCES Company(company_id)
            ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Internship (
        internship_id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        salary INTEGER CHECK (salary >= 0),
        duration_months INTEGER CHECK (duration_months > 0),
        FOREIGN KEY (company_id) REFERENCES Company(company_id)
            ON DELETE CASCADE ON UPDATE CASCADE
);
	
CREATE TABLE Contact (
        contact_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        company_id INTEGER NOT NULL,
        FOREIGN KEY (company_id) REFERENCES Company(company_id)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Event (
        event_id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        event_date DATE NOT NULL,
        format TEXT CHECK (format IN ('онлайн', 'офлайн')),
        FOREIGN KEY (company_id) REFERENCES Company(company_id)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Skill (
        skill_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        difficulty_level TEXT CHECK (difficulty_level IN ('начальный', 'средний', 'продвинутый'))
);

CREATE TABLE Task (
        task_number INTEGER NOT NULL,
        internship_id INTEGER NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        PRIMARY KEY (task_number, internship_id),
        FOREIGN KEY (internship_id) REFERENCES Internship(internship_id)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Required (
        internship_id INTEGER NOT NULL,
        skill_id INTEGER NOT NULL,
        PRIMARY KEY (internship_id, skill_id),
        FOREIGN KEY (internship_id) REFERENCES Internship(internship_id)
            ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (skill_id) REFERENCES Skill(skill_id)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE InternshipEventParticipation (
        internship_id INTEGER NOT NULL,
        contact_id INTEGER NOT NULL,
        event_id INTEGER NOT NULL,
        PRIMARY KEY (internship_id, contact_id, event_id),
        FOREIGN KEY (internship_id) REFERENCES Internship(internship_id)
            ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (contact_id) REFERENCES Contact(contact_id)
            ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (event_id) REFERENCES Event(event_id)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Course (
        course_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
  		platform TEXT NOT NULL,
        course_url TEXT NOT NULL,
  		skill_id,
  		FOREIGN KEY (skill_id) REFERENCES Skill(skill_id)
  			ON DELETE CASCADE ON UPDATE CASCADE
);	

CREATE TABLE Certificate (
  		certificate_id INTEGER PRIMARY KEY AUTOINCREMENT,
  		duration_months INTEGER CHECK (duration_months > 0),
  		prestige REAL CHECK (prestige <= 10 AND prestige >= 0)
 );
 
 CREATE TABLE CertificateCourse (
   		course_id INTEGER NOT NULL,
   		certificate_id INTEGER NOT NULL,
   		PRIMARY KEY(course_id, certificate_id),
   		FOREIGN KEY(course_id) REFERENCES Course(course_id),
   		FOREIGN KEY(certificate_id) REFERENCES Certificate(certificate_id)
 );
 
 /*Создадим таблицу логгер изменения зарплат у вакансий*/
CREATE TABLE salary_log (
  log_id INTEGER PRIMARY KEY AUTOINCREMENT,
  log_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  internship_id INTEGER NOT NULL,
  prev_salary INTEGER,
  new_salary INTEGER,
  FOREIGN KEY(internship_id) REFERENCES Internship(internship_id)
);
 
CREATE TRIGGER salary_logger AFTER UPDATE OF salary ON Internship
FOR EACH ROW WHEN OLD.salary != NEW.salary
BEGIN
INSERT INTO salary_log(internship_id, prev_salary, new_salary)
VALUES(NEW.internship_id, OLD.salary, NEW.salary);
END;
 
 
 
INSERT INTO Company (name, city, office_rating, parent_company) 
VALUES ('КРОК', 'Москва', 8, NULL),
       ('Т-Банк', 'Санкт-Петербург', 7, NULL),
       ('Супер-банк', 'Казань', 9, NULL),
       ('Техно-групп', 'Новосибирск', 6, 'КРОК'),
       ('TheBank', 'Владивосток', 5, 'Т-Банк'),
       ('Unknown', 'Unknowmn', 2, NULL),
       ('Noir', 'NewYork', 10, NULL);

INSERT INTO Internship (company_id, title, salary, duration_months) 
VALUES (1, 'аналитик данных', 70000, 3),
	   (1, 'аналитик разработчик', 60000, 4),
       (2, 'бизнес аналитик', 50000, 4),
       (3, 'системный аналитик', 45000, 6),
       (3, 'ИТ аналитик', 50000, 3),
       (4, 'продуктовый аналитик', 30000, 2),
       (5, 'дата-инженер', 60000, 5);
    
INSERT INTO Contact (name, position, company_id) 
VALUES ('Иван Иванов', 'HR', 1),
       ('Алексей Королёв', 'HR', 1),
       ('Мария Петрова', 'Менеджер проектов', 2),
       ('Алексей Смирнов', 'Team Lead', 3),
       ('Пётр Анисимов', 'Аналитик', 3),
       ('Ольга Кузнецова', 'HR', 4),
       ('Дмитрий Соколов', 'Координатор', 5);
    
INSERT INTO Event (company_id, title, event_date, format) 
VALUES (1, 'Хакатон по аналитике', '2025-05-10', 'офлайн'),
	   (1, 'IT Career Fest', '2025-05-12', 'офлайн'),
       (2, 'День открытых дверей', '2025-06-01', 'онлайн'),
       (3, 'Карьерная лекция', '2025-06-15', 'онлайн'),
       (3, 'Битва кейсов: Финансовые решения под прицелом', '2025-07-20', 'офлайн'),
       (4, 'Финансы будущего: Карьера в цифровом банкинге', '2025-07-01', 'офлайн'),
       (5, 'Tech Meetup', '2025-06-20', 'онлайн');
    
INSERT INTO Skill (name, difficulty_level)
VALUES ('SQL', 'средний'),
       ('Python', 'продвинутый'),
       ('Excel', 'начальный'),
       ('Power BI', 'средний'),
       ('ML', 'продвинутый');
    
INSERT INTO Task (task_number, internship_id, description, type) 
VALUES (1, 1, 'Написать SQL-запрос', 'SQL'),
       (2, 1, 'Оптимизировать базу данных', 'SQL'),
       (1, 5, 'Реализовать API на Flask', 'кодинг'),
       (2, 5, 'Написать юнит-тесты', 'кодинг'),
       (1, 7, 'Построить модель классификации', 'ML'),
       (2, 7, 'Подобрать гиперпараметры', 'ML'),
       (1, 4, 'Составить BPMN-диаграмму текущего бизнес-процесса по обработке заявки клиента', 'исследование'),
       (2, 4, 'Составить Use Case диаграмму', 'исследование'),
       (1, 3, 'Анализ набора данных', 'исследование'),
       (2, 3, 'Визуализация данных', 'исследование'),
       (1, 6, 'Построить воронку прохождения ключевого сценария', 'исследование'),
       (1, 2, 'Спроектировать и реализовать pipeline для загрузки и трансформации данных из внешнего API в хранилище данных компании', 'кодинг');

INSERT INTO Required (internship_id, skill_id) 
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 2),
       (6, 1),
       (7, 5),
       (5, 5);
    
INSERT INTO InternshipEventParticipation (internship_id, contact_id, event_id) 
VALUES (1, 1, 1),
	   (1, 2, 1),
       (2, 1, 1),
       (2, 2, 2),
       (3, 3, 3),
       (4, 4, 4),
       (5, 5, 5),
       (6, 6, 6),
       (7, 7, 7);
    
INSERT INTO Course (name, platform, course_url, skill_id) 
VALUES ('SQL', 'Stepik', 'https://stepik.org/course/sql', 1),
       ('ML', 'Coursera', 'https://coursera.org/ml', 5),
       ('ML', 'Stepik', 'https://stepik.org/course/ml', 5),
       ('Python_cool', 'Udemy', 'https://udemy.com/python', 2),
       ('Excel is cool too', 'Skillbox', 'https://skillbox.ru/excel', 3),
       ('Power BI is okay', 'GeekBrains', 'https://gb.ru/powerbi', 4);
       
INSERT INTO Certificate (duration_months, prestige)
VALUES (12, 4.6), 
	   (24, 9), 
       (23, 10),
       (36, 9),
       (44, 3.4);

INSERT INTO CertificateCourse (certificate_id, course_id)
VALUES (1, 1),
	   (2, 3),
       (3, 2),
       (4, 4),
       (5, 6);

/*1. вывести id и названия всех компаний, количество позиций стажировок у которых = 0, 
но при этом которые не участвовали ни в одном ивенте, отсортированные по алфавиту.
Запрос показывает малоактивные компании*/
SELECT company_id, Company.name
FROM Company LEFT JOIN Internship USING(company_id)
GROUP BY company_id, Company.name
HAVING count(internship_id) = 0
EXCEPT 
SELECT DISTINCT company_id, Company.name
FROM Event NATURAL JOIN Company
ORDER BY Company.name;

/*2. Вывести ссылки на курсы, у которых есть сертификаты, а также качество сертификатов этого курса.
Качество определяется по факту того, выше ли престиж сертификата среднего престижа всех сертификатов, или же он ниже
Запрос позволяет выбрать качественные курсы*/
SELECT course_url, 'качественный' AS quality
FROM Course 
INNER JOIN CertificateCourse USING(course_id)
INNER JOIN Certificate USING(certificate_id)
WHERE prestige >= (SELECT AVG(prestige) FROM Certificate)
UNION
SELECT course_url, 'некачественный' AS quality
FROM Course 
INNER JOIN CertificateCourse USING(course_id)
INNER JOIN Certificate USING(certificate_id)
WHERE prestige < (SELECT AVG(prestige) FROM Certificate);

/*3. Вывести все скиллы, на которые есть курсы с престижем сертификата выше 5,
а также которые встречаются больше чем в одной вакансии стажировки
Запрос позволяет определить, какие скиллы можно обрести, используя качественные курсы*/
SELECT Skill.name
FROM Skill 
INNER JOIN Required USING(skill_id)
GROUP BY Skill.name
HAVING COUNT(internship_id) > 1
INTERSECT
SELECT Skill.name
FROM Skill
INNER JOIN Course USING(skill_id)
INNER JOIN CertificateCourse USING(course_id)
INNER JOIN Certificate USING(certificate_id)
GROUP BY Skill.name
HAVING MAX(prestige) > 5;

/*4. Вывести название стажировки, названия нужных для неё скилов 
и минимальный престиж сертификата среди курсов для скилла. 
А если нет курса или сертификата по скиллу, то вывести -1.
Позволяет оценить востребованность различных направлений стажировки*/
SELECT title, Skill.name, 
CASE 
	WHEN MIN(prestige) IS NULL THEN -1
    ELSE MIN(prestige)
END AS min_prestige
FROM Internship 
InNER JOIN Required USING(internship_id)
INNER JOIN Skill USING(skill_id)
LEFT JOIN Course USING(skill_id)
LEFT JOIN CertificateCourse USING(course_id)
LEFT JOIN Certificate USING(certificate_id)
GROUP BY title, Skill.name;

/*5. Почтитать количество представителей компании, и если у компании их нет, 
то в отдельном столбце вывести "нехватка персонала", 'персонала достаточно' в противном случае.
Компании вывести в обратном алфавитном порядке
Позволяет оценить достаточность представителей у компании*/
SELECT Company.name, COUNT(contact_id), 
IIF(COUNT(contact_id) = 0, 'нехватка персонала', 'работников достаточно') AS enough_workers
FROM Company LEFT JOIN Contact USING(company_id)
GROUP BY Company.name
ORDER BY Company.name DESC;

/*6. Нужно найти, сколько компания ожидает потратить в месяц всего на своих стажеров в случае заполнения всех вакансий.
вывести компанию и сумму, которую она ожидает потратить.
Отсортировать по убыванию суммы*/
SELECT Company.name, IIF(SUM(salary) is NULL, 0, SUM(salary))  AS expected_spendings
FROM Company LEFT JOIN Internship USING(company_id)
GROUP BY Company.name
ORDER BY SUM(salary) DESC;

/*7. Нужно проиндексировать все зарплаты в вакансиях стажеров компаний только с 1 открытой позицией на половину среднего значения зарплаты тех вакансий*/
SELECT title, salary FROM Internship;

UPDATE Internship 
SET salary = salary + 
(SELECT AVG(salary)
  FROM Internship 
  GROUP BY company_id
  HAVING COUNT(*) = 1
 ) / 2
WHERE company_id IN (
  SELECT company_id 
  FROM Internship 
  GROUP BY company_id
  HAVING COUNT(*) = 1
  );
  
SELECT title, salary FROM Internship;

/*проверка, занеслись ли изменения в лог*/
SELECT * FROM salary_log;


/*8. Добавитьв таблицу Contact столбец с электронной почтой, длина которой не может превышать 50 символов, но должна быть не менее 3. Столбец не может принимать значение NULL, но по умолчанию
в столбце должно хранится 'None'.*/
SELECT * FROM Contact;

ALTER TABLE Contact
ADD email VARCHAR(50) NOT NULL DEFAULT 'None'
CHECK (LENGTH(Email) >= 3);

SELECT * FROM Contact;

/*9. Вычислить среднюю зарплату стажировок по городам, где рейтинг офиса компании выше 5. 
Результаты группируются по городу, сортируются по убыванию средней зарплаты. */
SELECT Company.city AS Город, AVG(Internship.salary) AS Средняя_зарплата, COUNT(Internship.internship_id) AS Количество_стажировок
FROM Company 
INNER JOIN Internship ON Company.company_id = Internship.company_id
WHERE Company.office_rating > 5
GROUP BY Company.city
ORDER BY Средняя_зарплата DESC;

/*10. Найти все стажировки аналитиков с зарплатой выше средней по всем стажировкам аналитиков. 
Вложенный подзапрос вычисляет среднюю зарплату аналитиков для сравнения. */
SELECT Internship.title AS Название, Internship.salary AS Зарплата, Company.name AS Название_компании, (SELECT AVG(salary) FROM Internship WHERE title LIKE '%аналитик%') AS Средняя_зп_аналитика
FROM Internship 
INNER JOIN Company ON Internship.company_id = Company.company_id
WHERE Internship.salary > (SELECT AVG(salary) FROM Internship WHERE title LIKE '%аналитик%')
      AND Internship.title LIKE '%аналитик%'
ORDER BY Internship.salary DESC;

/*11. Классифицировать стажировки по уровню зарплаты (низкая, средняя, высокая) и подсчитать количество 
задач для каждой стажировки. В результат попадают только стажировки с более чем одной задачей. */
SELECT Internship.title AS Название, Internship.salary AS Зарплата, Company.name AS Название_компании,
    CASE 
        WHEN Internship.salary < 35000 THEN 'Низкая'
        WHEN Internship.salary BETWEEN 35000 AND 50000 THEN 'Средняя'
        ELSE 'Высокая'
    END AS Категория_зарплаты,
    COUNT(Task.task_number) AS Количество_задач
FROM Internship 
LEFT JOIN Company ON Internship.company_id = Company.company_id
LEFT JOIN Task ON Internship.internship_id = Task.internship_id
GROUP BY Internship.internship_id
HAVING COUNT(Task.task_number) > 1
ORDER BY Internship.salary DESC;

/*12. Классифицировать компании на родительские и дочерние, а также подсчитать количества стажировок для каждой компании */
SELECT Company.name AS Название_компании, Company.city AS Город, 
    CASE 
        WHEN Company.parent_company IS NULL THEN 'Родительская'
        ELSE 'Дочерняя'
    END AS Тип_компании,
    COUNT(Internship.internship_id) AS Количество_стажировок
FROM Company
LEFT JOIN Internship ON Company.company_id = Internship.company_id
GROUP BY Company.company_id, Company.name, Company.city, Company.parent_company
ORDER BY Тип_компании DESC, Количество_стажировок DESC, Название_компании ASC;

/*13. Показать какие навыки требуются в высокооплачиваемых (зарплата > 45000) и долгосрочных (длительность > 3 месяцев) стажировках,  
и как часто они встречаются, фильтруя только востребованные навыки (требующиеся более чем в одной стажировке). */
SELECT Skill.name AS Навык, Skill.difficulty_level AS Уровень, COUNT(Required.internship_id) AS Количество
FROM Skill 
INNER JOIN Required ON Skill.skill_id = Required.skill_id
WHERE 
    Skill.skill_id IN (
        SELECT skill_id FROM Required WHERE internship_id IN (
            SELECT internship_id FROM Internship WHERE salary > 45000
        )
        INTERSECT
        SELECT skill_id FROM Required WHERE internship_id IN (
            SELECT internship_id FROM Internship WHERE duration_months > 3
        )
    )
GROUP BY Skill.skill_id, Skill.name, Skill.difficulty_level
HAVING COUNT(Required.internship_id) > 1
ORDER BY Skill.difficulty_level DESC, Количество DESC, Skill.name ASC;

/*14. Проанализировать онлайн-мероприятия, подсчитав количество участников. */
SELECT Event.title AS Название_мероприятия, Event.event_date AS Дата, Event.format AS Формат, COUNT(InternshipEventParticipation.contact_id) AS Количество_участников
FROM Event 
LEFT JOIN InternshipEventParticipation ON Event.event_id = InternshipEventParticipation.event_id
LEFT JOIN Company ON Event.company_id = Company.company_id
GROUP BY Event.event_id
HAVING Event.format = 'онлайн'
ORDER BY Event.event_date, Количество_участников DESC;

/*15. Вывести названия компаний, у которых есть стажировки, требующие больше всего разных навыков (по сравнению с другими), 
и для каждой — посчитать общее количество таких навыков, плюс присвоить категорию: 'навыкоёмкая' или 'обычная'  */
SELECT 
    Company.name AS Название,
    COUNT(DISTINCT Required.skill_id) AS Навыки,
        CASE 
        WHEN COUNT(DISTINCT Required.skill_id) = (
            SELECT MAX(skill_count)
            FROM (
                SELECT COUNT(DISTINCT skill_id) AS skill_count
                FROM Required
                GROUP BY internship_id
            ) AS skill_counts
        )
        THEN 'навыкоёмкая'
        ELSE 'обычная'
    END AS Тип
FROM Company 
INNER JOIN Internship ON Company.company_id = Internship.company_id
LEFT JOIN Required ON Internship.internship_id = Required.internship_id
GROUP BY Company.company_id, Company.name
HAVING COUNT(DISTINCT Required.skill_id) > 0
ORDER BY Навыки DESC;


/*16. Выбрать представителей компаний, которые представляли конкретную стажировку на мероприятиях больше всего раз, 
а также вывести наибольшее единоразовое изменение зарплаты по этой стажировке. Если стажировку ни разу не представляли, то её выводить не нужно*/
WITH max_change AS (
  SELECT internship_id, MAX(ABS(new_salary - prev_salary)) as change
  FROM salary_log
  GROUP BY internship_id),
representation AS (
  SELECT internship_id, contact_id, count(*) as times
  FROM InternshipEventParticipation
  GROUP BY internship_id, contact_id
),
max_representation AS (
  SELECT r.internship_id, r.contact_id
  FROM representation as r
  WHERE r.times = (SELECT MAX(times) FROM representation WHERE internship_id = r.internship_id)
)
SELECT title, Contact.name AS contact_name, Company.name AS company_name, change
FROM max_change LEFT JOIN max_representation USING(internship_id)
LEFT JOIN Contact USING(contact_id)
LEFT JOIN Internship USING(internship_id)
LEFT JOIN Company ON Contact.company_id = Company.company_id;

--Оконные функции

/*1. Вывести все доступные вакансии, их название, зарплату и максимальную зарплату по компании, для которых требуется знание питона*/
WITH max_salary_per_company AS (
SELECT internship_id, title, salary, MAX(salary) OVER (PARTITION BY company_id) AS max_salary
FROM Internship)
SELECT title, salary, max_salary
FROM max_salary_per_company
WHERE internship_id in (
  SELECT internship_id 
  FROM Internship LEFT JOIN Required USING(internship_id)
  LEFT JOIN Skill USING(skill_id)
  WHERE Skill.name = 'Python');

/*2. Составить топ всеx курсов относительно престижа их сертификатов, выведя скиллы, на которые направлены эти курсы*/
SELECT DENSE_RANK() OVER (ORDER BY prestige DESC) AS rank, prestige, course_url, Skill.name AS skill_name
FROM Certificate NATURAL JOIN CertificateCourse
NATURAL JOIN Course LEFT JOIN Skill USING(skill_id);

/*3. Поделить и вывести ожидаемое знавчение выплаты после каждого задания, предположив, что все задания в рамках стажировки приносят одинаковое количество
и что их нужно выполнять по порядку их номеров за 1 зарплатный период*/
WITH amount_per_task AS (
  SELECT internship_id, title, task_number, type, salary / COUNT(*) OVER (PARTITION BY internship_id) AS expected_payout
  FROM Task left join Internship USING(internship_id)
)
SELECT title, task_number, type, SUM(expected_payout) OVER (PARTITION BY internship_id ORDER BY task_number) AS expected_payout
FROM amount_per_task;





   