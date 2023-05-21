
/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  both first name and last name are in upper case, customer email id,  customer creation year and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Hint: Use CASE statement, no permanent change in the table is required. 
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
*/  
USE orders;
## Answer 1.
 
SELECT CUSTOMER_ID,
	CONCAT(
    CASE 
		WHEN CUSTOMER_GENDER = 'F' THEN 'Ms' 
        ELSE 'Mr' 
	END,
    ' ',UPPER(CUSTOMER_FNAME),' ',UPPER(CUSTOMER_LNAME)) AS CUSTOMER_FULL_NAME,CUSTOMER_EMAIL,YEAR(CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR,
    CASE
	
            WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
            WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
            WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'Category C'
            ELSE 'Invalid date'
	END AS CUSTOMER_CATEGORY
FROM online_customer;

/* Q2. Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, inventory values ( product_quantity_avail * product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Hint: Use CASE statement, no permanent change in table required. 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */

## Answer 2.

SELECT P.PRODUCT_ID, 
       P.PRODUCT_DESC, 
       P.PRODUCT_QUANTITY_AVAIL, 
       P.PRODUCT_PRICE, 
       (P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE, 
       CASE 
           WHEN P.PRODUCT_PRICE > 20000 THEN P.PRODUCT_PRICE * 0.8 
           WHEN P.PRODUCT_PRICE > 10000 THEN P.PRODUCT_PRICE * 0.85 
           ELSE P.PRODUCT_PRICE * 0.9 
       END AS NEW_PRICE 
FROM PRODUCT P
LEFT JOIN ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE OI.ORDER_ID IS NULL
ORDER BY INVENTORY_VALUE DESC;

/* Q3. Write a query to display Product_class_code, Product_class_description, 
Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price).
Information should be displayed for only those product_class_code which
 have more than 1,00,000 Inventory Value. Sort the output with respect to
 decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS] */

## Answer 3.

SELECT PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC, COUNT(P.PRODUCT_ID) AS PRODUCT_TYPE_COUNT, 
SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE 
FROM PRODUCT P 
JOIN PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE 
GROUP BY PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC
HAVING SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000 
ORDER BY  INVENTORY_VALUE DESC;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
 [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER] */
 
## Answer 4.

SELECT 
  OC.CUSTOMER_ID, 
  CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
  OC.CUSTOMER_EMAIL,
  OC.CUSTOMER_PHONE,
  AD.COUNTRY
FROM 
  ONLINE_CUSTOMER OC
  INNER JOIN ADDRESS AD ON OC.ADDRESS_ID = AD.ADDRESS_ID
WHERE 
    OC.CUSTOMER_ID IN (
  SELECT 
      CUSTOMER_ID
    FROM 
      ORDER_HEADER 
    WHERE 
      ORDER_STATUS = 'Cancelled'
	AND CUSTOMER_ID = OC.CUSTOMER_ID
	GROUP BY
	CUSTOMER_ID
    HAVING
		COUNT(*) = (
			SELECT 
				COUNT(*)
			FROM
				ORDER_HEADER
			WHERE
				CUSTOMER_ID = OC.CUSTOMER_ID
			)
  );
  
/* Q5. Write a query to display Shipper name, City to which it is catering,
 num of customer catered by the shipper in the city , number of consignment
 delivered to that city for Shipper DHL 
Hint: The answer should only be based on Shipper_Name -- DHL.
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */

## Answer 5.

SELECT 
  S.SHIPPER_NAME, 
  A.CITY, 
  COUNT(DISTINCT O.CUSTOMER_ID) AS NUM_CUSTOMERS, 
  COUNT(DISTINCT O.ORDER_ID) AS NUM_CONSIGNMENTS
FROM 
  SHIPPER S
  JOIN ORDER_HEADER O ON S.SHIPPER_ID = O.SHIPPER_ID
  JOIN ONLINE_CUSTOMER C ON O.CUSTOMER_ID = C.CUSTOMER_ID
  JOIN ADDRESS A ON C.ADDRESS_ID = A.ADDRESS_ID
WHERE 
  S.SHIPPER_NAME = 'DHL'
GROUP BY 
  S.SHIPPER_NAME, 
  A.CITY;
  
/* Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, 
need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
  [NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] */

## Answer 6.

SELECT 
P.PRODUCT_ID,
P.PRODUCT_DESC,
P.PRODUCT_QUANTITY_AVAIL,
SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
CASE
	WHEN PC.PRODUCT_CLASS_DESC IN ('Electronics','Computer') THEN
		CASE 
        WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
        WHEN P.PRODUCT_ID NOT IN (SELECT PRODUCT_ID FROM ORDER_ITEMS) THEN 'No Sales in past, give discount to reduce inventory'
        WHEN P.PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
        WHEN P.PRODUCT_QUANTITY_AVAIL < 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
        ELSE 'Sufficient inventory'
		END
    WHEN PC.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
      CASE 
        WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
        WHEN P.PRODUCT_ID NOT IN (SELECT PRODUCT_ID FROM ORDER_ITEMS) THEN 'No Sales in past, give discount to reduce inventory'
        WHEN P.PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
        WHEN P.PRODUCT_QUANTITY_AVAIL < 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
        ELSE 'Sufficient inventory'
      END
ELSE
      CASE 
        WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
        WHEN P.PRODUCT_ID NOT IN (SELECT PRODUCT_ID FROM ORDER_ITEMS) THEN 'No Sales in past, give discount to reduce inventory'
        WHEN P.PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
        WHEN P.PRODUCT_QUANTITY_AVAIL < 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
		ELSE 'Sufficient inventory'
      END
END AS INVENTORY_STATUS
FROM 
  product P
  JOIN product_class PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
  LEFT JOIN order_items OI ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY 
  P.PRODUCT_ID, 
  P.PRODUCT_DESC,
  P.PRODUCT_QUANTITY_AVAIL,
  PC.PRODUCT_CLASS_DESC;
  
/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

## Answer 7.
  
SELECT OI.ORDER_ID,SUM(P.LEN * P.WIDTH * P.HEIGHT * OI.PRODUCT_QUANTITY) AS ORDER_VOLUME
FROM ORDER_ITEMS OI
JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE OI.ORDER_ID IN (
	SELECT OI.ORDER_ID
    FROM ORDER_ITEMS OI
    JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
    GROUP BY OI.ORDER_ID
    HAVING SUM(P.LEN*P.WIDTH*P.HEIGHT*OI.PRODUCT_QUANTITY) <= (
    SELECT C.LEN*C.WIDTH*C.HEIGHT AS CARTON_VOLUME
    FROM CARTON C
    WHERE C.CARTON_ID = 10)
)
GROUP BY OI.ORDER_ID
ORDER BY ORDER_VOLUME DESC
LIMIT 1;

/* Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

## Answer 8.


SELECT C.CUSTOMER_ID, CONCAT(C.CUSTOMER_FNAME, ' ', C.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,
SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY, SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE
FROM ONLINE_CUSTOMER C
JOIN ORDER_HEADER OH ON C.CUSTOMER_ID = OH.CUSTOMER_ID
JOIN ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE OH.PAYMENT_MODE = 'Cash' AND C.CUSTOMER_LNAME LIKE 'G%'
GROUP BY C.CUSTOMER_ID, CUSTOMER_FULL_NAME;

/* Q9. Write a query to display product_id, product_desc and total quantity of products
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty. 
Expected 6 rows in final output

Hint:  (USE SUB-QUERY)
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]*/

## Answer 9.
  
SELECT P.PRODUCT_ID, P.PRODUCT_DESC, SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM ORDER_ITEMS OI
JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
JOIN ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID
JOIN ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE OI.ORDER_ID IN (
  SELECT OI1.ORDER_ID
  FROM ORDER_ITEMS OI1 
  WHERE OI1.PRODUCT_ID = 201
)
AND A.CITY NOT IN ('Bangalore', 'New Delhi')
AND OI.PRODUCT_ID != 201
GROUP BY P.PRODUCT_ID, P.PRODUCT_DESC
ORDER BY TOTAL_QUANTITY DESC
LIMIT 5;

/* Q10. Write a query to display the order_id, customer_id and customer fullname,
 total quantity of products shipped for order ids which are even and shipped to
 address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS] */

## Answer 10.
  
SELECT OH.ORDER_ID, OH.CUSTOMER_ID, CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME, 
SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED
FROM ORDER_HEADER OH
JOIN ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE OH.ORDER_ID % 2 = 0 AND SUBSTR(A.PINCODE, 1, 1) != '5'
GROUP BY OH.ORDER_ID, OH.CUSTOMER_ID, CUSTOMER_FULLNAME
ORDER BY OH.ORDER_ID ASC
LIMIT 15;
