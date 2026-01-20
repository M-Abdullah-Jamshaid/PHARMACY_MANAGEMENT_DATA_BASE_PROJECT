
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE INVOICE_DETAILS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE INVOICES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE MEDICINE_SUPPLIERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE MEDICINES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE SUPPLIERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE CATEGORIES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PHARMACIST CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ADMIN CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/



CREATE TABLE ADMIN (
    AdminID       NUMBER(5),
    A_Name        VARCHAR2(50) NOT NULL UNIQUE,
    Password      VARCHAR2(50) NOT NULL,
    LastLogin     DATE,
    CONSTRAINT pk_admin PRIMARY KEY (AdminID)
);

CREATE TABLE PHARMACIST (
    PharmacistID  NUMBER(5),
    P_Name        VARCHAR2(50) NOT NULL UNIQUE,
    ShiftTime     VARCHAR2(20),
    CONSTRAINT pk_pharmacist PRIMARY KEY (PharmacistID)
);

CREATE TABLE CATEGORIES (
    CatID         NUMBER(3),
    Cat_Name      VARCHAR2(50) NOT NULL UNIQUE,
    Description   VARCHAR2(200),
    CONSTRAINT pk_categories PRIMARY KEY (CatID)
);

CREATE TABLE SUPPLIERS (
    SupplierID    NUMBER(5),
    CompName      VARCHAR2(100) NOT NULL,
    Phone         VARCHAR2(15),
    City          VARCHAR2(50),
    CONSTRAINT pk_suppliers PRIMARY KEY (SupplierID)
);

CREATE TABLE MEDICINES (
    MedID         NUMBER(10),
    MedName       VARCHAR2(100) NOT NULL,
    Price         NUMBER(10, 2),
    StockQty      NUMBER(5) DEFAULT 0,
    AddedBy_ID    NUMBER(5),
    CatID         NUMBER(3),
    CONSTRAINT pk_medicines PRIMARY KEY (MedID),
    CONSTRAINT fk_med_admin FOREIGN KEY (AddedBy_ID) REFERENCES ADMIN(AdminID),
    CONSTRAINT fk_med_cat FOREIGN KEY (CatID) REFERENCES CATEGORIES(CatID)
);

CREATE TABLE MEDICINE_SUPPLIERS (
    MedID         NUMBER(10),
    SupplierID    NUMBER(5),
    SupplyPrice   NUMBER(10, 2),
    QTY           NUMBER(5),
    CONSTRAINT pk_med_supp PRIMARY KEY (MedID, SupplierID),
    CONSTRAINT fk_ms_med FOREIGN KEY (MedID) REFERENCES MEDICINES(MedID),
    CONSTRAINT fk_ms_supp FOREIGN KEY (SupplierID) REFERENCES SUPPLIERS(SupplierID)
);

CREATE TABLE INVOICES (
    InvoiceID     NUMBER(10),
    TotalAmt      NUMBER(12, 2) DEFAULT 0,
    InvDate       DATE DEFAULT SYSDATE,
    GenBY         NUMBER(5),
    CONSTRAINT pk_invoices PRIMARY KEY (InvoiceID),
    CONSTRAINT fk_inv_pharm FOREIGN KEY (GenBY) REFERENCES PHARMACIST(PharmacistID)
);

CREATE TABLE INVOICE_DETAILS (
    DetailID      NUMBER(10),
    InvoiceID     NUMBER(10),
    MedID         NUMBER(10),
    QtySold       NUMBER(4),
    SubTotal      NUMBER(10, 2),
    CONSTRAINT pk_inv_details PRIMARY KEY (DetailID),
    CONSTRAINT fk_id_inv FOREIGN KEY (InvoiceID) REFERENCES INVOICES(InvoiceID),
    CONSTRAINT fk_id_med FOREIGN KEY (MedID) REFERENCES MEDICINES(MedID)
);



-- 1. Admins
INSERT INTO ADMIN (AdminID, A_Name, Password) VALUES (1, 'admin', '123');

-- 2. Pharmacists
INSERT INTO PHARMACIST (PharmacistID, P_Name, ShiftTime) VALUES (1, 'ali', 'Morning');
INSERT INTO PHARMACIST (PharmacistID, P_Name, ShiftTime) VALUES (2, 'sara', 'Evening');

-- 3. Categories
INSERT INTO CATEGORIES (CatID, Cat_Name, Description) VALUES (1, 'Tablet', 'Solid pills');
INSERT INTO CATEGORIES (CatID, Cat_Name, Description) VALUES (2, 'Syrup', 'Liquid');

-- 4. Suppliers
INSERT INTO SUPPLIERS (SupplierID, CompName, City) VALUES (1, 'Pfizer', 'Lahore');
INSERT INTO SUPPLIERS (SupplierID, CompName, City) VALUES (2, 'GSK', 'Karachi');

-- 5. Medicines
INSERT INTO MEDICINES (MedID, MedName, Price, StockQty, AddedBy_ID, CatID) 
VALUES (1, 'Panadol', 10, 100, 1, 1);
INSERT INTO MEDICINES (MedID, MedName, Price, StockQty, AddedBy_ID, CatID) 
VALUES (2, 'Brufen', 20, 50, 1, 2);
INSERT INTO MEDICINES (MedID, MedName, Price, StockQty, AddedBy_ID, CatID) 
VALUES (3, 'CoughSyrup', 120, 30, 1, 2);

-- 6. Medicine Suppliers Link
INSERT INTO MEDICINE_SUPPLIERS (MedID, SupplierID, SupplyPrice, QTY) VALUES (1, 1, 8, 500);

-- 7. Invoices (Sales History)
INSERT INTO INVOICES (InvoiceID, TotalAmt, GenBY) VALUES (1, 30, 1);
INSERT INTO INVOICES (InvoiceID, TotalAmt, GenBY) VALUES (2, 120, 2);

-- 8. Invoice Details (What was sold)
INSERT INTO INVOICE_DETAILS (DetailID, InvoiceID, MedID, QtySold, SubTotal) 
VALUES (1, 1, 1, 1, 10);
INSERT INTO INVOICE_DETAILS (DetailID, InvoiceID, MedID, QtySold, SubTotal) 
VALUES (2, 1, 2, 1, 20);
INSERT INTO INVOICE_DETAILS (DetailID, InvoiceID, MedID, QtySold, SubTotal) 
VALUES (3, 2, 3, 1, 120);

/* --- COMMIT IS REQUIRED TO SAVE DATA --- */
COMMIT;



-- A. CREATE VIEWS
CREATE OR REPLACE VIEW View_Stock_List AS
SELECT m.MedID, m.MedName, c.Cat_Name, m.Price, m.StockQty
FROM MEDICINES m
JOIN CATEGORIES c ON m.CatID = c.CatID;

CREATE OR REPLACE VIEW View_Sales_Summary AS
SELECT i.InvoiceID, i.InvDate, i.TotalAmt, p.P_Name
FROM INVOICES i
JOIN PHARMACIST p ON i.GenBY = p.PharmacistID;

-- B. SELECT QUERIES (Run these to see results)

-- Report 1: View All Stock
SELECT * FROM View_Stock_List;

-- Report 2: Sales Summary
SELECT * FROM View_Sales_Summary;

-- Report 3: Low Stock Alert (< 60)
SELECT MedName, StockQty 
FROM MEDICINES 
WHERE StockQty < 60;

-- Report 4: Detailed Receipt for Invoice #1
SELECT i.InvoiceID, m.MedName, d.QtySold, d.SubTotal
FROM INVOICE_DETAILS d
JOIN INVOICES i ON d.InvoiceID = i.InvoiceID
JOIN MEDICINES m ON d.MedID = m.MedID
WHERE i.InvoiceID = 1;