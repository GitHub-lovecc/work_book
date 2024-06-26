【十二章】数据类型
Data Types (时长35分钟)

背景知识：关于储存单位

一个晶体管可开和关，表示0或1两个值，代表最小储存单位，叫一位（bit）
一字节（Byte）有8位，可表示2^8个值，即256个值
字节（B）、千字节（KB）、兆字节（GB）、太字节（TB）相邻两者之间的换算比率是2^10，即1024，约1000.
1. 介绍
Introduction (0:43)

知道MySQL支持的数据类型并且知道什么时候该用什么是很重要的

MySQL的数据分为以下几个大类：
1. String Types 字符串类型
2. Numeric Types 数字类型
3. Date and Time Types 日期和时间类型
4. Blog Types 存放二进制的数据类型
5. Spatial Types 存放地理数据的类型

接下来将学习每一大类中的具体数据类型

2. 字符串类型
String Types (2:25)

最常用的两个字符串类型

CHAR() 固定长度的字符串，如州（'CA', 'NY', ……）就是 CHAR(2)
VARCHAR() 可变字符串
Mosh习惯用 VARCHAR(50) 来记录用户名和密码这样的短文本 以及 用 VARCHAR(255) 来记录像地址这样较长一些的文本，保持这样的习惯能够简化数据库设计，不必每次都想每一列该用多长的 VARCHAR
VARCHAR 最多能储存 64KB, 也就是最多约 65k 个字符（如果都是英文即每个字母只占一字节的话），超出部分会被截断
字符串类型也可以用来储存邮编，电话号码这样的特殊的数字型数据，因为它们不会用来做数学运算而且常常包含‘-’或括号等分隔符号

储存较大文本的两个类型

MEDIUMTEXT 最大储存16MB（约16百万的英文字符），适合储存JSON对象，CS视图字符串，中短长度的书籍
LONGTEXT 最大储存4GB，适合储存书籍和以年记的日志
还有两个用的少一些的

TINYTEXT 最大储存 255 Bytes
TEXT 最大储存 64KB，最大储存长度和 VARCHAR 一样，但最好用 VARCHAR，因为 VARCHAR 可以使用索引（之后会讲，索引可以提高查询速度）
国际字符

所有这些字符串类型都支持国际字符，其中：

英文字符占1个字节
欧洲和中东语言字符占2个字节
像中日这样的亚洲语言的字符占3个字节
所以，如果一列数据的类型为 CHAR(10)，MySQL会预留30字节给那一列的值

导航

下节课讲整数

3. 整数类型
Integer Types (2:52)

我们用整数类型来保存没有小数的数字，MySQL里共有5种常用的整数类型，它们的区别在于占用的空间和能记录的数字范围

整数类型	占用储存	记录的数字范围
TINYINT	1B	[-128,127]
SMALLINT	2B	[-32K,32K]
MEDIUMINT	3B	[-8M,8M]
INT	4B	[-2B,2B]
BIGINT	8B	[-9Z,9Z]
属性1. 不带符号 UNSIGNED
这些整数可以选择不带符号，加上 UNSIGNED 则只储存非负数
如最常用的 UNSIGNED TINYINT，占用空间和 TINYINT 一样也是1B，但表示的数字范围不是 [-128-127] 而是 [0-255]，适合储存像年龄这样的数据，可以防止意外输入负数

属性2. 填零 ZEROFILL
整数类型的另一个属性是填零（Zerofill），主要用于当你需要给数字前面添加零让它们位数保持一致时
我们用括号表示显示位数，如 INT(4) => 0001，注意这只影响MySQL如何显示数字而不影响如何保存数字

方法

不用强行去记，谷歌 mysql integer types 即可查阅

注意

如果试图存入超出范围的数字，MySQL会抛出异常 'The value is out of range'

最佳实践

总是使用能满足你需求的最小整数类型，如储存人的年龄用 UNSIGNED TINYINT 就足够了，至少可见的未来内没人能活过255岁
数据需要在磁盘和内存间传输，虽然不同类型间只有几个字节的差异，但数据量大了以后对空间和查询效率的影响就很大了，所以在数据量较大时，有意识地分配每一字节，保持数据最小化是很有必要的。

4. 定点数类型和浮点数类型
Fixedpoint and Floatingpoint Types (1:42)

这节主要讲储存小数的数据类型，有定点数和浮点数两种类型

Fixedpoint Types 定点数类型

DECIMAL(p, s) 两个参数分别指定最大的有效数字位数和小数点后小数位数（小数位数固定）
如：DECIMAL(9, 2) => 1234567.89 总共最多9位，小数点后两位，整数部分最多7位

DECIMAL 还有几个别名：DEC / NUMERIC / FIXED，最好就使用 DECIMAL 以保持一致性，但其它几个也要眼熟，别人用了要认识

Floatingpoint Types 浮点数类型

进行科学计算，要计算特别大或特别小的数时，就会用到浮点数类型，浮点数不是精确值而是近似值，这也正是它能表示更大范围数值的原因
具体有两个类型：

FLOAT 浮点数类型，占用4B
DOUBLE 双精度浮点数，占用8B，显然能比前者储存更大范围的数值
小结

如果需要记录精确的数字，比如货币金额，就是用 DECIMAL 类型
如果要进行科学计算，要处理很大或很小的数据，而且精确值不重要的话，就用 FLOAT 或 DOUBLE

5. 布尔类型
Boolean Types (0:46)

有时我们需要储存 是/否 型数据，如 “这个博客是否发布了？”，这里我们就要用到布林值，来表示真或假

MySQL里有个数据类型叫 BOOL / BOOLEAN

案例

UPDATE posts 
SET is_published = TRUE / FALSE
或
SET is_published = 1 / 0
注意

布林值其实本质上就是 微整数 TINYINT 的另一种表现形式，TRUE / FALSE 实质上就是 1 / 0，但 Mosh 个人觉得写成 TRUE / FALSE 表意更清楚

6. 枚举和集合类型
Enum and Set Types (3:36)

enumeration n. 枚举

有时我们希望某个字段从固定的一系列值中取值，我们就可以用到 ENUM() 和 SET() 类型，前者是取一个值，后者是取多个值

ENUM()

从固定一系列值中取一个值

案例

例如，我们希望 sql_store.products（产品表）里多一个size（尺码）字段，取值为 small/medium/large 中的一个，可以打开产品表的设计模式，添加size列，数据类型设置为 ENUM('small','medium','large')，然后apply

则产品表会增加一个尺码列，可将其中的值设为small/medium/large(大小写无所谓)，但若设为其他值会报错

SET()

SET和ENUM类似，区别是，SET是从固定一系列值中取多个值而非一个值

注意

讲解 ENUM 和 SET 只是为了眼熟，最好不要用这两个数据类型，问题很多：
1. 修改可选的值（如想增加一个'extra large'）会重建整个表，耗费资源
2. 想查询可选值的列表或者想用可选值当作一个下拉列表都会比较麻烦
3. 难以在其它表里复用，其它地方要用只有重建相同的列，之后想修改就要多处修改，又会很麻烦

最佳实践

像这种某个字段是从固定的一系列值中取值的情况，不应该使用 ENUM 和 SET 而应该用这一系列的可选值另外建一个 “查询表” (lookup table)

例如，上面案例中，应该为尺码另外专门建一个 size表（可选尺码表）

又如，sql_invoicing 里为支付方式另外专门建了一个 payment_methods 可选支付方式表

这样就解决了上面的所有问题，既方便查询可选值的列表，也方便作为下拉选项，也方便复用和更改

导航

下一章设计数据库讲里讲 normalization（标准化/归一化）时会更详细地讲解这个问题

7. 日期和时间类型
Date and Time Types (0:44)

MySQL 有4种储存日期事件的类型：
1. DATE 有日期没时间
2. TIME 有时间没日期
3. DATETIME 包含日期和时间
4. TIMESTAMP 时间戳，常用来记录一行数据的的插入或最后更新时间

最后两个的区别是：

TIMESTAMP 占4B，最晚记录2038年，被称为“2038年问题”
DATETIME 占8B，如果要储存超过2038年的日期时间，就要用 DATETIME
另外，还有一个 YEAR 类型专门储存四位的年份

8. 二进制大对象类型
Blob Types (1:17)

我们用 Blob 类型来储存大的二进制数据，包括PDF，图像，视频等等几乎所有的二进制的文件
具体来说，MySQL里共有4种 Blob 类型，它们的区别在于可储存的最大文件大小：

占用储存	最大可储存
TINYBOLB	255B
BLOB	65KB
MEDIUM BLOB	16MB
LONG BLOB	4GB
注意

通常应该将二进制文件存放在数据库之外，关系型数据库是设计来专门处理结构化关系型数据而非二进制文件的

如果将文件储存在数据库内，会有如下问题：

数据库的大小将迅速增长
备份会很慢
性能问题，因为从数据库中读取图片永远比直接从文件系统读取慢
需要额外的读写图像的代码
所以，尽量别用数据库来存文件，除非这样做确实有必要而且上面这些问题已经被考虑到了

9. JSON类型
JSON Type (10:24)

背景：关于JSON

MySQL还可以储存 JSON 文件，JSON 是 JavaScript Object Notation（JavaScript 对象标记法）的简称
简单讲，JSON 是一种在互联网上储存和传播数据的简便格式（Lightweight format for storing and transferring data over the Internet）
JSON 在网络和移动应用中被大量使用，多数时候你的手机应用向后端传输数据都是使用 JSON 格式
语法结构：

{
    "key1": value1,
    "key2": value2,
    ……
}
JSON 用大括号{}表示一个对象，里面有多对键值对
键 key 必须用引号包裹（而且似乎必须是双引号，不能用单引号）
值 value 可以是数值，布林值，数组，文本， 甚至另一个对象（形成嵌套 JSON 对象）
案例

用 sql_store 数据库，在 products 商品表里，在设计模式下新增一列 properties，设定为 JSON 类型，注意在Workbench里，要将 Eidt-Preferences-Modeling-MySQL-Default Target MySQL Version 设定为 8.0 以上，不然设定 JSON 类型会报错 （我Workbench 里 Default Target MySQL Version 确实设定为 8.0 以上，但我电脑里的 MySQL 装的是 5.7 版本，似乎也没影响之后操作都很顺利，为什么？）

这里的 properties 记录每件产品附加的独特属性，注意这里每件产品的独特属性是不一样的，如衣服是颜色和尺码，而电视机是的重量和尺寸，把所有可能的属性都作为不同的列添加进表是很糟糕的设计，因为每个商品都只能用到所有这些属性的一部分（一个子集），相反，通过增加一列 JSON 类型的 properties 列，我们可以利用 JSON 里的键值对很方便的储存每个商品独特的属性

现在我们已经有了一个 JSON 类型的列，接下来从 增 删 改 查 各角度来看看如何操作使用 JSON 类型的列，注意这里的 增删查改 主要针对的是 properties 列里的特定键值对，即如何 增删查改 某些特定的具体属性

增

给1号商品增加一系列属性，有两种方法

法1：

用单引号包裹（注意不能是双引号），里面用 JSON 的标准格式：

双引号包裹键 key（注意不能是单引号）
值 value 可以是数、数组、甚至另一个用 {} 包裹的JSON对象
键值对间用逗号隔开
USE sql_store;
UPDATE products
SET properties = '
{
    "dimensions": [1, 2, 3], 
    "weight": 10,
    "manufacturer": {"name": "sony"}
}
'
WHERE product_id = 1;
法2：

也可以用 MySQL 里的一些针对 JSON 的内置函数来创建商品属性：

UPDATE products
SET properties = JSON_OBJECT(
    'weight', 10,
    -- 注意用函数的话，键值对中间是逗号而非冒号
    'dimensions', JSON_ARRAY(1, 2, 3),
    'manufacturer', JSON_OBJECT('name', 'sony')
)
WHERE product_id = 1;
两个方法是等效的

查

现在来讲如何查询 JSON 对象里的特定键值对，这是将某一列设为 JSON 对象的优势所在，如果 properties 列是字符串类型如 VARCHAR 等，是很难获取特定的键值对的

有两种方法：

法1 :

使用 JSON_EXTRACT(JSON对象, '路径') 函数，其中：

第1参数指明 JSON 对象
第2参数是用单引号包裹的路径，路径中 $ 表示当前对象，点操作符 . 表示对象的属性
SELECT product_id, JSON_EXTRACT(properties, '$.weight') AS weight
FROM products
WHERE product_id = 1;
法2

更简便的方法，使用列路径操作符 -> 和 ->>，后者可以去掉结果外层的引号

用法是：JSON对象 -> '路径'

SELECT properties -> '$.weight' AS weight
FROM products
WHERE product_id = 1;
-- 结果为：10

SELECT properties -> '$.dimensions' 
……
-- 结果为：[1, 2, 3]

SELECT properties -> '$.dimensions[0]' 
-- 用中括号索引切片，且序号从0开始，与Python同
……
-- 结果为：1

SELECT properties -> '$.manufacturer'
……
-- 结果为：{"name": "sony"}

SELECT properties -> '$.manufacturer.name'
……
-- 结果为："sony"

SELECT properties ->> '$.manufacturer.name'
……
-- 结果为：sony
通过路径操作符来获取 JSON 对象的特定属性不仅可以用在 SELECT 选择语句中，也可以用在 WHERE 筛选语句中，如：
筛选出制造商名称为 sony 的产品：

SELECT 
    product_id, 
    properties ->> '$.manufacturer.name' AS manufacturer_name
FROM products
WHERE properties ->/->> '$.manufacturer.name' = 'sony'
结果为：

product_id	manufacturer_name
1	sony
Mosh说最后这个查询的 WHERE 条件语句里用路径获取制作商名字时必须用双箭头 ->> 才能去掉结果的双引号，才能使得比较运算成立并最终查找出符合条件的1号产品，但实验发现用单箭头 -> 也可以，但另一方面在 SELECT 选择语句中用单双箭头确实会使得显示的结果带或不带双引号，所以综合来看，单双箭头应该是只影响路径结果 "sony" 是否【显示】外层的引号，但不会改变其实质，所以不会影响其比较运算结果，即单双箭头得出的sony都是 = 'sony' 的

改

如果我们是要重新设置整个 JSON 对象就用前面 增 里讲到的 JSON_OBJECT() 函数，但如果是想修改已有 JSON 对象里的一些属性，就要用 JSON_SET() 函数

USE sql_store;
UPDATE products
SET properties = JSON_SET(
    properties,
    '$.weight', 20,  -- 修改weight属性
    '$.age', 10  -- 增加age属性
)
WHERE product_id = 1;
注意 JSON_SET() 是选择已有的 JSON 对象并修改部分属性然后返回修改后新的 JSON 对象，所以其第1参数是要修改的 JSON 对象，并且可以用

SET porperties = JSON_SET(properties, ……)
的语法结构来实现对 properties 的修改

删

可以用 JSON_REMOVE() 函数实现对已有 JSON 对象特性属性的删除，原理和 JSON_SET() 一样

USE sql_store;
UPDATE products
SET properties = JSON_REMOVE(
    properties,
    '$.weight',
    '$.age'
)
WHERE product_id = 1;
小结

感觉JSON对象就是个储存键值对的字典，可以嵌套，标准格式为：{"key":value,……}

增：利用标准格式或利用 JSON_OBJECT, JSON_ARRAY 等函数
查：JSON_EXTRACT 或 ->/-->，注意表达路径时单引号、 $ 和 . 的使用
改：JSON_SET，注意其原理
删：JSON_REMOVE，原理同上
