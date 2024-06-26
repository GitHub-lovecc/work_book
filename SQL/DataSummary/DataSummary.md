# 数据概要

*    课程总共用到四个数据库，分别是：
 
     sql_store （商店数据库），sql_invoicing （发票数据库），sql_hr （人力资源数据库），sql_inventory （存货数据库）。

其中，主要是前两个数据库用的比较多，结构也花哨一些，后两个数据库只是在讲特定主题时用到过一两次，结构也比较简单
下面是各个数据库的详细介绍：

## 1.sql_store

  sql_store（商店数据库）是课程前半段用的最多的一个数据库，其结构如下图所示（点击可放大）：
可以看作以中间的orders表（订单表）为核心，然后……

### 1.通过customer_id（顾客编号）与customers表（顾客表）相联
### 2.通过status_id（状态编号）与order_statuses表（订单状态表）相联
### 3.通过shipper_id（运货商编号）与shippers表（运货商表）相联
### 4.通过order_id（订单编号）与order_items表（订单项目表）相联

  其中：
1.customers 表提供了每个顾客的详细信息
2.order_statuses 表提供了每种订单状态编号的含义（包括：processed 已处理、shipped 已寄出、delivered 已送达）
3.shippers 表提供了每个运货商的详细信息
4.order_items 表列明了每个订单包含的具体产品项目。
这几个表（顾客表、订单状态表、运货商表、订单项目表）充当了订单表的“查询表”（lookup table），为订单提供了各个角度的更详细信息。
以顾客表为例，相较于“在订单表的每个订单里都详细记录顾客的信息”，像现在这样只记录顾客id而把顾客的详细信息单独分离出来作为查询表可以减少数据的冗余和重复性，
还能方便顾客信息的更改，这在第十三章设计数据库里会讲到
同理，orders_items（订单项目表）里的商品都只记录product_id（商品编号），商品的详细信息保存在products表（商品表）里，
后者可看作是前者的查询表，两者通过product_id相联系。右下角还有一个order_item_notes表（订单项目备注表）本来也该是orders_items表的查询表的，
但实际上，如图可见，并没有和orders_items表联系起来，这是Mosh为了课程讲解的需要故意保留的一个设计错误

## 2.sql_invoicing

sql_invoicing（发票数据库）是课程后半段用的最多的一个数据库，其中最重要的三张表clients表（客户表）、
invoices表（发票表）和payments表（支付记录表）是通过client_id（客户编号）和invoice_id（发票记录编号）两个字段来相互联系的，如图所示：
对这三张表我个人的理解是：客户表记录客户的详细信息，发票表记录的是某次交易的应付款总额（一次交易对应一次发票记录），
而支付记录表记录的是客户为特定发票进行付款的记录。之后课程中会常常要将特定发票的应付款总额与已付款总额相减来得到该发票的balance（剩余欠款）
另外右下角还有一个payment_methods表（付款方式表），充当查询表为payments表提供各种付款方式的详细信息，两表通过payment_method_id相联系。

## 3.sql_hr

sql_hr（人力资源数据库）结构很简单，就两个表，offices表（办公室表）和employees表（雇员表），
offices表充当查询表为employees表提供雇员所在办公室的详细信息，这两张表通过office_id（办公室编号）相联系
值得注意的是employees表本身的一个特性：它的reports_to（向谁汇报）字段引用了该表本身的emploee_id（雇员编号字段），
毕竟，雇员的上级也是该公司的雇员。正因为这个特性，这个表在之后讲解 “self join 自链接” 时被当作素材。

## 4.sql_inventory

sql_inventory （存货数据库）只有一张products表（商品表），其实和sql_store里商品表是一样的，这个数据库在整个课程中只在讲解 “跨数据库连接” 时用到了一次。

