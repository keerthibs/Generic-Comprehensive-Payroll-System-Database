CREATE OR REPLACE PROCEDURE RETIREMENT(V_EMPID EMPLOYEE.EMP_ID%TYPE) IS
V_RETIREMENT RETIREMENT_ACCOUNT%ROWTYPE;
V_EL LEAVES.EL%TYPE;
V_GROSSPAY NUMBER;
V_MONTH NUMBER(2);
V_YEAR NUMBER(2);
V_ELPAY NUMBER(10);
V_LOANID NUMBER(10);
V_LOANS NUMBER(10);
V_CURRENT_BALANCE NUMBER(10);
V_STATUS EMPLOYEE.EMPLOYMENT_STATUS%TYPE;
BEGIN
SELECT EMPLOYMENT_STATUS INTO V_STATUS FROM EMPLOYEE WHERE EMP_ID=V_EMPID;
IF (V_STATUS='ACTIVE') THEN
SELECT * INTO V_RETIREMENT FROM RETIREMENT_ACCOUNT WHERE EMP_ID=V_EMPID;
SELECT EXTRACT(MONTH FROM SYSDATE),EXTRACT(YEAR FROM SYSDATE) INTO V_MONTH,V_YEAR FROM DUAL;
    IF(SQL%NOTFOUND) THEN
        DBMS_OUTPUT.PUT_LINE('Please check the Employee number');
    ELSE

      SELECT LOAN_ID,CURRENT_BALANCE,LOAN_AMOUNT INTO V_LOANID,V_CURRENT_BALANCE,V_LOANS 
        FROM SOFT_LOANS 
          WHERE EMP_ID=V_EMPID AND CURRENT_BALANCE!=0;

      IF(SQL%FOUND) THEN
        V_RETIREMENT.PF_BALANCE:=V_RETIREMENT.PF_BALANCE-V_CURRENT_BALANCE;        
        UPDATE SOFT_LOANS SET CURRENT_BALANCE=0,DUE_DATE=SYSDATE WHERE LOAN_ID=V_LOANID;
        
       SELECT GROSSPAY INTO V_GROSSPAY FROM PAYROLL_PAYMENTS WHERE MONTH=V_MONTH-1 AND YEAR=V_YEAR AND EMP_ID=V_EMPID; 
       SELECT EL INTO V_EL FROM LEAVES WHERE EMP_ID=V_EMPID;
    
       IF (V_EL>0) THEN
       V_ELPAY:=V_GROSSPAY/30*V_EL;
       END IF;
         
        DBMS_OUTPUT.PUT_LINE('TOTAL RETIREMENT CORPUS PAYABLE TO THE EMPLOYEE');
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');  
        DBMS_OUTPUT.PUT_LINE('PROVIDENT FUND : '||V_RETIREMENT.PF_BALANCE);
        DBMS_OUTPUT.PUT_LINE('PENSION FUND : '||V_RETIREMENT.PENSION_BALANCE);
        DBMS_OUTPUT.PUT_LINE('VOL. PROVIDENT FUND : '||V_RETIREMENT.VPF_BALANCE);
        DBMS_OUTPUT.PUT_LINE('EL ENCASHED '||V_ELPAY);
          
        UPDATE EMPLOYEE SET EMPLOYMENT_STATUS='RETIRED' WHERE EMP_ID=V_EMPID; 
        UPDATE RETIREMENT_ACCOUNT SET PF_BALANCE=0,PENSION_BALANCE=0,VPF_BALANCE=0 WHERE EMP_ID=V_EMPID;
      END IF;
END IF;
END IF;
COMMIT;
END;
