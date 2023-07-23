/* Week 1 */
SHOW SCHEMAS;
USE littlelemondb;
SHOW TABLES;

/* WEEK 2 */ 
-- Task 1: create OrdersView
CREATE VIEW littlelemondb.OrdersView AS (
    SELECT OrderID, Quantity, Cost 
    FROM Orders 
)

-- Task 2: all customers with orders that cost more than $150
SELECT 
  c.CustomerID,
  c.FullName,
  o.OrderID,
  o.Cost,
  m.MenuName,
  mi.CourseName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID 
INNER JOIN Menus m ON o.MenuID = m.MenuID 
INNER JOIN MenuItems mi ON m.MenuItemID = mi.MenuItemID
WHERE o.Cost > 150 
ORDER BY Cost ASC;

-- Task 3: all menu name for which more than 2 orders have been placed 
SELECT 
  MenuName 
FROM Menus 
WHERE MenuID = ANY (
    SELECT 
      MenuID
    FROM Orders 
    GROUP BY MenuID 
    HAVING COUNT(DISTINCT OrdersID) > 2
);

-------------------------------

-- Task 1: GetMaxQuantity()
CREATE PROCEDURE GetMaxQuantity()
SELECT MAX(Quantity)
FROM Orders;

CALL GetMaxQuantity();

-- Task 2: GetOrderDetail
SET @id = 1;
PREPARE GetOrderDetail 'SELECT OrderID, Quantity, Cost From Orders WHEN CustomerID = ?'
EXECUTE GetOrderDetail USING @id; 

-- Task 3: CancelOrder
DELIMITER //

CREATE PROCEDURE CancelOrder (IN @OrderID_In INT) 
BEGIN 
DELETE FROM Orders WHERE OrderID = @OrderID_In;
SELECT CONCAT('Order ', @OrderID_In, ' is cancelled') Confirmation;
END //

DELIMITER;

-------------------------------

-- Task 1: insert bookings
START TRANSACTION; 
INSERT INTO Bookings (BookingID, BookingDate, TableNumber, CustomerID)
VALUES (1, DATE('2022-10-10'), 5, 1)
       (2, DATE('2022-11-12'), 3, 3)
       (3, DATE('2022-10-11'), 2, 2)
       (4, DATE('2022-10-13'), 2, 1);
COMMIT;

-- Task 2: CheckBooking
DELIMITER //

CREATE PROCEDURE CheckBooking (IN @BookingDate_In VARCHAR(45), IN @TableNumber_In INT) 
BEGIN 
SELECT
  CONCAT('Table ', TableNumber, 'is already booked') AS "Booking status"
FROM Bookings 
WHERE BookingDate = DATE('@BookingDate_In')
  AND TableNumber = @TableNumber_In
END //

DELIMITER;

-- Task 3: AddValidBooking
DELIMITER //

CREATE PROCEDURE CheckBooking (IN @BookingDate_In VARCHAR(45), IN @TableNumber_In INT) 
BEGIN 
START TRANSACTION; 
IF (SELECT COUNT(1) FROM Bookings WHERE BookingDate = DATE('@BookingDate_In') AND TableNumber = @TableNumber_In) > 1
THEN 
  INSERT INTO Bookings (BookingDate, TableNumber)
  VALUE (@BookingDate_In, @TableNumber_In);
ELSE 
  SELECT CONCAT('Table ', @TableNumber_In, ' is already booked - booking cancelled');
END;
COMMIT;
END //

DELIMITER;

-- Task 1: AddBooking
DELIMITER //

CREATE PROCEDURE AddBooking (IN @BookingID_In INT, IN @CustomerID_In INT, IN @TableNumber_In INT, IN @BookingDate_In VARCHAR(45)) 
START TRANSACTION; 
INSERT INTO Bookings (BookingID, CustomerID, TableNumber, BookingDate)
VALUES (@BookingID_In, @CustomerID_In, @TableNumber_In, @BookingDate_In);
COMMIT;
END //

DELIMITER;

-- Task 2: UpdateBooking
DELIMITER //

CREATE PROCEDURE UpdateBooking (IN @BookingID_In INT, IN @BookingDate_In VARCHAR(45)) 
START TRANSACTION; 
UPDATE Bookings
SET BookingDate = @BookingDate_In
WHERE BookingID = @BookingID_In
END //

DELIMITER;

-- Task 2: CancelBooking
DELIMITER //

CREATE PROCEDURE CancelBooking (IN @BookingID_In INT) 
START TRANSACTION; 
DELETE FROM Bookings
WHERE BookingID = @BookingID_In
END //

DELIMITER;

