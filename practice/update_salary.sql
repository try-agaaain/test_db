DROP PROCEDURE IF EXISTS update_employee_salary;
DELIMITER $$
CREATE PROCEDURE update_employee_salary(IN p_emp_no INT, IN new_salary INT)
BEGIN
    -- 声明变量用于存储当前薪水记录的to_date值
    DECLARE current_to_date DATE;
    
    -- 从salaries表中获取当前薪水记录的to_date值
    SELECT to_date INTO current_to_date
    FROM salaries
    WHERE emp_no = p_emp_no
    ORDER BY from_date DESC
    LIMIT 1;
    
    -- 如果找到记录，更新当前薪水记录的to_date为当前日期，并插入新的薪水记录
    IF current_to_date IS NOT NULL THEN
        UPDATE salaries
        SET to_date = CURRENT_DATE()
        WHERE emp_no = p_emp_no AND to_date = current_to_date;
        
        INSERT INTO salaries (emp_no, salary, from_date, to_date)
        VALUES (p_emp_no, new_salary, CURRENT_DATE(), '9999-01-01');
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS delete_updated_latest_employee_salary;
DELIMITER $$
CREATE PROCEDURE delete_updated_latest_employee_salary(IN p_emp_no INT)
BEGIN
    -- 声明两个临时变量来存储最新和次新的to_date值
    DECLARE v_max_to_date DATE;
    DECLARE v_second_max_date DATE;

    -- 从salaries表中获取最新的to_date值，并存储在变量中（考虑到最新的记录可能已经被更新）
    SELECT MAX(to_date) INTO v_max_to_date
    FROM salaries
    WHERE emp_no = p_emp_no;

    -- 如果最新记录的to_date是当前日期，那么找出次新的to_date值
    IF v_max_to_date = CURRENT_DATE() THEN
        SELECT MAX(to_date) INTO v_second_max_date
        FROM salaries
        WHERE emp_no = p_emp_no AND to_date < v_max_to_date;

        -- 更新次新记录的to_date为'9999-01-01'
        UPDATE salaries
        SET to_date = '9999-01-01'
        WHERE emp_no = p_emp_no AND to_date = v_second_max_date;
    END IF;

    -- 删除最新的薪水记录（不论它是不是被更新为当前日期的记录）
    DELETE FROM salaries
    WHERE emp_no = p_emp_no AND to_date = v_max_to_date;
END$$

DELIMITER ;


SET profiling = 1;

CALL update_employee_salary1(10001, 60001);
-- SELECT * FROM salaries WHERE emp_no = 10001 ORDER BY from_date DESC;
CALL delete_updated_latest_employee_salary(10001);

SHOW PROFILES;
