【第十章】触发器和事件
Triggers and Events (时长22分钟)

1. 触发器
Triggers (7:31)

小结

触发器是在插入、更新或删除语句前后自动执行的一段SQL代码（A block of SQL code that automatically gets executed before or after an insert, update or delete statement）通常我们使用触发器来保持数据的一致性

创建触发器的语法要点：命名三要素，触发条件语句和触发频率语句，主体中 OLD/NEW 的使用

案例

在 sql_invoicing 库中，发票表中同一个发票记录可以对应付款表中的多次付款记录，发票表中的付款总额应该等于这张发票所有付款记录之和，为了保持数据一致性，可以通过触发器让每一次付款表中新增付款记录时，发票表中相应发票的付款总额（payement_total）自动增加相应数额

语法上，和创建储存过程等类似，要暂时更改分隔符，用 CREATE 关键字，用 BEGIN 和 END 包裹的主体

几个关键点：

1. 命名习惯（三要素）：触发表_before/after(SQL语句执行之前或之后触发)_触发的SQL语句类型

2. 触发条件语句：BEFORE/AFTER INSERT/UPDATE/DELETE ON 触发表

3. 触发频率语句：这里 FOR EACH ROW 表明每一个受影响的行都会启动一次触发器。其它有的DBMS还支持表级别的触发器，即不管插入一行还是五行都只启动一次触发器，到Mosh录制为止MySQL还不支持这样的功能

4. 主体：主体里可以对各种表的数据进行修改以保持数据一致性，但注意唯一不能修改的表是触发表，否则会引发无限循环（“触发器自燃”），主体中最关键的是使用 NEW/OLD 关键字来指代受影响的新/旧行（若INSERT用NEW，若DELETE用OLD，若UPDATE似乎两个都可以用？）并可跟 '点+字段' 以引用这些行的相应属性

DELIMITER $$

CREATE TRIGGER payments_after_insert
    AFTER INSERT ON payments
    FOR EACH ROW
BEGIN
    UPDATE invoices
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
END$$

DELIMITER ;
测试：往 payments 里新增付款记录，发现 invoices 表对应发票的付款总额确实相应更新

INSERT INTO payments
VALUES (DEFAULT, 5, 3, '2019-01-01', 10, 1)
练习

创建一个和刚刚的触发器作用刚好相反的触发器，每当有付款记录被删除时，自动减少发票表中对应发票的付款总额

DELIMITER $$

CREATE TRIGGER payments_after_delete
    AFTER DELETE ON payments
    FOR EACH ROW
BEGIN
    UPDATE invoices
    SET payment_total = payment_total - OLD.amount
    WHERE invoice_id = OLD.invoice_id;
END$$

DELIMITER ;
测试：删掉付款表里刚刚的那个给3号发票支付10美元的付款记录，则果然发票表里3号发票的付款总额相应减少10美元.

DELETE FROM payments
WHERE payment_id = 9
2. 查看触发器
Viewing Triggers (1:20)

用以下命令来查看已存在的触发器及其各要素

SHOW TRIGGERS
如果之前创建时遵行了三要素命名习惯，这里也可以用 LIKE 关键字来筛选特定表的触发器

SHOW TRIGGERS LIKE 'payments%'
3. 删除触发器
Dropping Triggers (0:52)

和删除储存过程的语句一样

DROP TRIGGER [IF EXISTS] payments_after_insert
-- IF EXISTS 是可选的，但一般最好加上
最佳实践

最好将删除和创建数据库/视图/储存过程/触发器的语句放在同一个脚本中（即将删除语句放在创建语句前，DROP IF EXISTS + CREATE，用于创建或更新数据库/视图/储存过程/触发器，等效于 CREATE OR REPLACE）并将脚本录入源码库中，这样不仅团队都可以创建相同的数据库，还都能查看数据库的所有修改历史

DELIMITER $$

DROP TRIGGER IF EXISTS payments_after_insert;
/*
实验了一下好像这里用$$也可以,
但为什么可以用;啊？
*/

CREATE TRIGGER payments_after_insert
    AFTER INSERT ON payments
    FOR EACH ROW
BEGIN
    UPDATE invoices
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
END$$

DELIMITER ;
4. 使用触发器进行审核
Using Triggers for Auditing (4:52)

导航

之前已经学习了如何用触发器来保持数据一致性，触发器的另一个常见用途是为了审核的目的将修改数据的操作记录在日志里。

小结

建立一个审核表（日志表）以记录谁在什么时间做了什么修改，实现方法就是在触发器里加上创建日志记录的语句，日志记录应包含修改内容信息和操作信息两部分。

案例

用 create-payments-table.sql 创建 payments_audit 表，记录所有对 payements 表的增删操作，注意该表包含 client_id, date, amount 字段来记录修改的内容信息（方便之后恢复操作，如果需要的话）和 action_type, action_date 字段来记录操作信息。注意这是个简化了的 audit 表以方便理解。

具体实现方法是，重建在 payments 表里的的增删触发器 payments_after_insert 和 payments_after_delete，在触发器里加上往 payments_audit 表里添加日志记录的语句

具体而言：

往 payments_after_insert 的主体里加上这样的语句：

INSERT INTO payments_audit
VALUES (NEW.client_id, NEW.date, NEW.amount, 'insert', NOW());
往 payments_after_delete 的主体里加上这样的语句：

INSERT INTO payments_audit
VALUES (OLD.client_id, OLD.date, OLD.amount, 'delete', NOW());
测试：

-- 增：
INSERT INTO payments
VALUES (DEFAULT, 5, 3, '2019-01-01', 10, 1);

-- 删：
DELETE FROM payments
WHERE payment_id = 10
发现 payments_audit 表里果然多了两条记录以记录这两次增和删的操作

注意

实际运用中不会为数据库中的每张表建立一个审核表，相反，会有一个整体架构，通过一个总审核表来记录，这在之后设计数据库中会讲到。

导航

下节课学习事件

5. 事件
Events (4:33)

事件是一段根据计划执行的代码，可以执行一次，或者按某种规律执行，比如每天早上10点或每月一次

通过事件我们可以自动化数据库维护任务，比如删除过期数据、将数据从一张表复制到存档表 或者 汇总数据生成报告，所以事件十分有用。

首先，需要打开MySQL事件调度器（event_scheduler），这是一个时刻寻找需要执行的事件的后台程序

查看MySQL所有系统变量：

SHOW VARIABLES;
SHOW VARIABLES LIKE 'event%';
-- 使用 LIKE 操作符查找以event开头的系统变量
-- 通常为了节约系统资源而默认关闭
用SET语句开启或关闭,不想用事件时可关闭以节省资源，这样就不会有一个不停寻找需要执行的事件的后台程序

SET GLOBAL event_scheduler = ON/OFF
案例

创建这样一个 yearly_delete_stale_audit_row 事件，每年删除过期的（超过一年的）日志记录（stale adj. 陈腐的；不新鲜的）

DELIMITER $$

CREATE EVENT yearly_delete_stale_audit_row

-- 设定事件的执行计划：
ON SCHEDULE  
    EVERY 1 YEAR [STARTS '2019-01-01'] [ENDS '2029-01-01']    

-- 主体部分：（注意 DO 关键字）
DO BEGIN
    DELETE FROM payments_audit
    WHERE action_date < NOW() - INTERVAL 1 YEAR;
END$$

DELIMITER ;
关键点：

1. 命名：用时间间隔（频率）开头，可以方便之后分类检索，时间间隔（频率）包括 【once】/hourly/daily/monthly/yearly 等等

2. 执行计划：

规律性周期性执行用 EVERY 关键字，可以是 EVERY 1 HOUR / EVERY 2 DAY 等等
若只执行一次就用 AT 关键字，如：AT '2019-05-01'
开始 STARTS 和结束 ENDS 时间都是可选的
另外：

NOW() - INTERVAL 1 YEAR 等效于 DATE_ADD(NOW(), INTERVAL -1 YEAR) 或 DATE_SUB(NOW(), INTERVAL 1 YEAR)，但感觉不用DATEADD/DATESUB函数，直接相加减（但INTERVAL关键字还是要用）还简单直白点

小结

查看和开启/关闭事件调度器（event_scheduler）：

SHOW VARIABLES LIKE 'event%';
SET GLOBAL event_scheduler = ON/OFF
创建事件：

……
CREATE EVENT 以频率打头的命名
ON SCHEDULE
    EVERY 时间间隔 / AT 特定时间 [STARTS 开始时间][ENDS 结束时间]
DO BEGIN
……
END$$
……
6. 查看、删除和更改事件
Viewing, Dropping and Altering Events (2:04)

导航

上节课讲的是创建事件，即“增”，这节课讲如何对事件进行“查、删、改”，说来说去其实任何对象都是这四种操作

查（SHOW）和删（DROP）和之前的类似：

SHOW EVENTS 
-- 可看到各个数据库的事件
SHOW EVENTS [LIKE 'yearly%'];  
-- 之前命名以时间间隔开头这里才能这样筛选
DROP EVENT IF EXISTS yearly_delete_stale_audit_row;
“改” 要特殊一些，这里首次用到 ALTER 关键字，而且有两种用法：

如果要修改事件内容（包括执行计划和主体内容），直接把 ALTER 当 CREATE 用（或者说更像是REPLACE）直接重建语句
暂时地启用或停用事件（用 DISABLE 和 ENABLE 关键字）
ALTER EVENT yearly_delete_stale_audit_row DISABLE/ENABLE
小结

SHOW、DROP、ALTER、ENABLE、DISABLE

