DROP TABLE Patient CASCADE CONSTRAINTS;
CREATE TABLE Patient (
Patient_ID CHAR (4),
DOB DATE NOT NULL,
Name VARCHAR2(15) NOT NULL,
Address VARCHAR2(15),
CONSTRAINT PatientPK PRIMARY Key (Patient_ID));

DROP TABLE Department CASCADE CONSTRAINTS;
CREATE TABLE Department (
Department_ID CHAR(3),
Name VARCHAR2(30) NOT NULL,
Location VARCHAR2(45),
CONSTRAINT DepPK PRIMARY KEY (Department_ID));

DROP TABLE Doctor CASCADE CONSTRAINTS;
CREATE TABLE Doctor(
Doctor_ID CHAR(4),
specialty VARCHAR2(30),
name VARCHAR2(30) NOT NULL,
Dep_ID CHAR(3),
CONSTRAINT doctorPK PRIMARY KEY (Doctor_ID),
CONSTRAINT depFK FOREIGN KEY (Dep_ID) REFERENCES Department(Department_ID));

DROP TABLE Appointment CASCADE CONSTRAINTS;
CREATE TABLE Appointment (
App_no CHAR(4),
DDate DATE NOT NULL,
TTime DATE NOT NULL,
Patient_ID CHAR(4),
Doctor_ID CHAR(4),
CONSTRAINT AppPK PRIMARY KEY (App_no),
CONSTRAINT patientID_FK FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
CONSTRAINT doctorID_FK FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID));


DROP TABLE Medication CASCADE CONSTRAINTS;
CREATE TABLE Medication(
Medication_ID CHAR(4),
name VARCHAR2(30) NOT NULL,
price NUMBER(10),
Age_Limit Number(30), 
CONSTRAINT MedPK PRIMARY KEY(Medication_ID));

DROP TABLE prescribe CASCADE CONSTRAINTS;
CREATE TABLE prescribe (
    Patient_ID CHAR(4),
    Medication_ID CHAR(4),
    CONSTRAINT fk_prescribe_patient FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    CONSTRAINT fk_prescribe_med FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID)
);
 
ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENGLISH';
INSERT INTO Patient VALUES ('1234', TO_DATE('15-MAY-2005','DD-MON-YYYY'),'jorry','riyadh');
INSERT INTO Patient VALUES ('5678',TO_DATE('10-SEP-2002','DD-MON-YYYY'),'nour','riyadh');  
INSERT INTO Patient VALUES ('9123',TO_DATE('30-NOV-2004','DD-MON-YYYY'),'ahlam','riyadh');
 
INSERT INTO Department VALUES ('101','Pediatrics','Riyadh');
INSERT INTO Department VALUES ('102','Psychiatry','Jeddah');
INSERT INTO Department VALUES ('103','Dermatology','Dammam');

INSERT INTO Doctor VALUES ('5515','EmergencyDepartment','Ohoud','103');
INSERT INTO Doctor VALUES ('5545','EmergencyDepartment','Khaled', '103');
INSERT INTO Doctor VALUES ('5555','EmergencyDepartment','jweedh', '103');
INSERT INTO Doctor VALUES ('5525','Neurology','Bader','102');
INSERT INTO Doctor VALUES ('5535','Radiology','noura','101');


INSERT INTO Appointment VALUES ('1115', TO_DATE('25-JUL-2024','DD-MON-YYYY'), TO_DATE('25-JUL-2024 12:30 PM','DD-MON-YYYY HH:MI AM'), '1234', '5515');
INSERT INTO Appointment VALUES ('1114', TO_DATE('26-FEB-2024','DD-MON-YYYY'), TO_DATE('26-FEB-2024 11:45 AM','DD-MON-YYYY HH:MI AM'), '5678', '5525');
INSERT INTO Appointment VALUES ('1113', TO_DATE('27-MAR-2024','DD-MON-YYYY'), TO_DATE('27-MAR-2024 06:30 PM','DD-MON-YYYY HH:MI AM'), '9123', '5535');

 INSERT INTO Medication VALUES ('123','Zyrtec',39,31);
 INSERT INTO Medication VALUES ('345','Brufen',30,28);
 INSERT INTO Medication VALUES ('678','Panadol',25,18);

 
INSERT INTO prescribe VALUES ('1234', '678');
INSERT INTO prescribe VALUES ('5678', '345');
INSERT INTO prescribe VALUES ('9123', '678');



-- commit the data
COMMIT;

SELECT * FROM Patient;
SELECT * FROM Department;
SELECT * FROM Doctor;
SELECT * FROM Appointment;
SELECT * FROM prescribe;

 
--DROP 
DROP ROLE role_admin;
DROP ROLE role_doctor;
DROP ROLE role_reception;

DROP USER admin_account CASCADE;
DROP USER dr_salem CASCADE;
DROP USER frontdesk_emp CASCADE;  


-- Step 1: Create roles for each type of user
CREATE ROLE role_admin;
CREATE ROLE role_doctor;
CREATE ROLE role_reception;

-- Step 2: Grant privileges to each role

-- Admin: full access
GRANT ALL ON Patient TO role_admin;
GRANT ALL ON Doctor TO role_admin;
GRANT ALL ON Department TO role_admin;
GRANT ALL ON Appointment TO role_admin;
GRANT ALL ON Medication TO role_admin;
GRANT CONNECT, RESOURCE TO role_admin;
-- Doctor: access to view patients, update appointments, add medications
GRANT CONNECT TO role_doctor;
GRANT SELECT ON Patient TO role_doctor;
GRANT SELECT, UPDATE ON Appointment TO role_doctor;
GRANT INSERT, SELECT ON Medication TO role_doctor;


-- Receptionist: manage appointments, view patients
GRANT CONNECT TO role_reception;
GRANT SELECT, INSERT, UPDATE ON Appointment TO role_reception;
GRANT SELECT ON Patient TO role_reception;

-- Step 3: Create users and set their passwords
CREATE USER admin_account IDENTIFIED BY "admin123";
CREATE USER dr_salem IDENTIFIED BY "doctor123";
CREATE USER frontdesk_emp IDENTIFIED BY "reception123";

-- Step 4: Grant roles to users
GRANT role_admin TO admin_account;
GRANT role_doctor TO dr_salem;
GRANT role_reception TO frontdesk_emp;



SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN ('ADMIN_ACCOUNT', 'DR_SALEM', 'FRONTDESK_EMP')
ORDER BY grantee;

-- Show table privileges granted to each role
SELECT role, table_name, privilege
FROM role_tab_privs
WHERE role IN ('ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_RECEPTION')
ORDER BY role, table_name;

-- Show system privileges for roles (if any)
SELECT * 
FROM role_sys_privs 
WHERE role IN ('ROLE_ADMIN', 'ROLE_DOCTOR', 'ROLE_RECEPTION');



--CREATE PROCEDURE 
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE Show_All_Appointments IS
  CURSOR app_cursor IS
    SELECT App_no, patient_id FROM Appointment;

  v_App_no Appointment.App_no%TYPE;
  v_patient_id Appointment.patient_id%TYPE;
  v_patient_name Patient.Name%TYPE;
BEGIN
  OPEN app_cursor;

  LOOP
    FETCH app_cursor INTO v_App_no, v_patient_id;
    EXIT WHEN app_cursor%NOTFOUND;

    SELECT Name INTO v_patient_name
    FROM Patient
    WHERE patient_id = v_patient_id;

    DBMS_OUTPUT.PUT_LINE('Appointment Number: '   ||v_App_no   ||' Patient: ' || v_patient_name);
  END LOOP;

  CLOSE app_cursor;
END;
/

--run 
BEGIN
  Show_All_Appointments;
END;
/

--CREATE function 
create or replace function count_doctors(dep_id varchar2)
return number 
Is
  v_totalDoc NUMBER;
BEGIN
  select Count(*) into v_totalDoc
  From Doctor
  Where Dep_ID =dep_id ;
  return v_totalDoc;
END;
/
SET SERVEROUTPUT ON;

DECLARE
   v_count NUMBER;
BEGIN
   v_count := count_doctors('102');
   DBMS_OUTPUT.PUT_LINE('Number of doctors in the department: ' || v_count);
END;
/ 



--CREATE TRIGGER 
CREATE OR REPLACE TRIGGER trg_check_medication
BEFORE INSERT OR UPDATE ON Medication
FOR EACH ROW
BEGIN
  IF :NEW.name = 'Zyrtec' THEN
    IF :NEW.Age_Limit IS NULL OR :NEW.Age_Limit < 12 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Warning!! Zyrtec must be stored in a cool place and is only suitable for patients aged 12 and above.');
    END IF;
  END IF;
END;
/


--DROP INDEX idx_med_name
DROP INDEX idx_med_name;

--CREATE INDEX
 CREATE INDEX idx_med_name ON Medication(name);
SELECT * FROM Medication WHERE name = 'Panadol';

  SELECT name
  FROM Patient
  WHERE Patient_ID IN (
    SELECT Patient_ID
    FROM prescribe
    WHERE Medication_ID IN (
        SELECT Medication_ID
        FROM Medication
        WHERE name = 'Panadol'
    )
);

--Optimized Query (JOIN Approach)
SELECT p.name AS Patient_Name
FROM Patient p
JOIN prescribe pr ON p.Patient_ID = pr.Patient_ID
JOIN Medication m ON pr.Medication_ID = m.Medication_ID
WHERE m.name = 'Panadol';