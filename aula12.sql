DROP TABLE PERSONAGEM;
CREATE TABLE PERSONAGEM(
    ID NUMBER PRIMARY KEY,
    NOME VARCHAR2(120) NOT NULL,
    SALARIO NUMBER(10,2) NOT NULL
);

INSERT INTO PERSONAGEM(ID, NOME, SALARIO)
VALUES(1, 'JOÃƒO', 1000);
INSERT INTO PERSONAGEM(ID, NOME, SALARIO)
VALUES(2, 'MARIA', 2000);
INSERT INTO PERSONAGEM(ID, NOME, SALARIO)
VALUES(3, 'CLAUDIO', 500);
COMMIT;

DROP TABLE LOG_PERSONAGEM;
CREATE TABLE LOG_PERSONAGEM(
    ID_LOG NUMBER PRIMARY KEY,
    ID NUMBER NOT NULL,
    SALARIO_VELHO NUMBER(10,2) NOT NULL,
    SALARIO_NOVO NUMBER(10,2) NOT NULL,
    USUARIO VARCHAR2(30) NOT NULL,
    DATAHORA DATE NOT NULL,
    CONSTRAINT FK_PERS_LOGPERS FOREIGN KEY (ID) REFERENCES PERSONAGEM(ID)
);


CREATE OR REPLACE 
FUNCTION FUNC_AUMENTOSALPERSONAGEM (PID IN NUMBER, PNOVOSALARIO IN NUMBER)
RETURN NUMBER
IS
    RETORNO NUMBER(3) := 0;
    QTDE NUMBER(1);
    VSALARIO PERSONAGEM.SALARIO%TYPE;
    VPARAMETROS VARCHAR2(4000);
    VNUMERRO NUMBER(6);
    VDESCRERRO VARCHAR2(4000);
BEGIN
    IF PNOVOSALARIO > 0 AND PNOVOSALARIO < 99999999.99 THEN
        SELECT COUNT(*) INTO QTDE FROM PERSONAGEM WHERE ID = PID;
        IF QTDE = 1 THEN
            SELECT SALARIO INTO VSALARIO FROM PERSONAGEM WHERE ID = PID;
            UPDATE PERSONAGEM SET SALARIO = PNOVOSALARIO WHERE ID = PID;
            INSERT INTO LOG_PERSONAGEM (ID_LOG, ID, SALARIO_VELHO,
            SALARIO_NOVO, USUARIO, DATAHORA )
            VALUES(SEQ_LOG_PROGEXEC.NEXTVAL, PID, VSALARIO,PNOVOSALARIO,
            USER, SYSDATE);
        ELSE
            RETORNO := -998;
        END IF;
    ELSE
        RETORNO := -999;
    END IF;
    COMMIT;
    RETURN RETORNO;
EXCEPTION
    WHEN OTHERS THEN 
        ROLLBACK;
        VPARAMETROS := 'PID = ' || PID || ', '
                    || 'PNOVOSALARIO = ' || PNOVOSALARIO;
        VNUMERRO := SQLCODE;
        VDESCRERRO := SQLERRM;
        INSERT INTO LOG_PROGRAMACAOEXECUCAO (ID_LOG,
            NOME_DO_CODIGO,PARAMETROS,NUMERO_ERRO,DESCRICAO_ERRO,
            NUMERO_LINHA_ERRO, USUARIO,DATAHORA,
            STATUS,DESCRICAO_SOLUCAO) VALUES(SEQ_LOG_PROGEXEC.NEXTVAL,
            'FUNC_AUMENTOSALPERSONAGEM', VPARAMETROS, VNUMERRO, VDESCRERRO, 
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()  , 
            USER, SYSDATE, 'E', NULL);
        COMMIT;
        RETURN SQLCODE;
END;


DECLARE
    X NUMBER;
BEGIN
    X := FUNC_AUMENTOSALPERSONAGEM(1,3999);
    DBMS_OUTPUT.PUT_LINE('RESULTADO: '||X);
END;

SELECT * FROM LOG_PERSONAGEM WHERE ID = 1 ORDER BY DATAHORA ASC;

SELECT * FROM PERSONAGEM;

--------------------------------------------------------------


CREATE OR REPLACE TRIGGER TRG_PERS_UPSAL
BEFORE UPDATE OF SALARIO
ON PERSONAGEM
FOR EACH ROW
BEGIN
    INSERT INTO LOG_PERSONAGEM (ID_LOG,ID,SALARIO_VELHO,
                    SALARIO_NOVO,USUARIO,DATAHORA)
              VALUES(SEQ_LOG_PROGEXEC.NEXTVAL, :OLD.ID, 
               :OLD.SALARIO, :NEW.SALARIO, USER, SYSDATE);
END;


UPDATE PERSONAGEM SET SALARIO = SALARIO * 1.15;
COMMIT;

----------------------------------------------------------------



DROP TABLE LOG_PERSONAGEM;
CREATE TABLE LOG_PERSONAGEM(
    ID_LOG NUMBER PRIMARY KEY,
    ID NUMBER NOT NULL,
    SALARIO_VELHO NUMBER(10,2),
    SALARIO_NOVO NUMBER(10,2),
    USUARIO VARCHAR2(30) NOT NULL,
    DATAHORA DATE NOT NULL,
    OPERACAO CHAR(1) NOT NULL
);


CREATE OR REPLACE TRIGGER TRG_PERS_UPSAL
BEFORE INSERT OR DELETE OR UPDATE OF SALARIO
ON PERSONAGEM
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO LOG_PERSONAGEM (ID_LOG,ID,SALARIO_VELHO,
                SALARIO_NOVO,USUARIO,DATAHORA, OPERACAO)
            VALUES(SEQ_LOG_PROGEXEC.NEXTVAL, :NEW.ID, 
        :OLD.SALARIO, :NEW.SALARIO, USER, SYSDATE, 'I');
    END IF;
    IF DELETING THEN
        INSERT INTO LOG_PERSONAGEM (ID_LOG,ID,SALARIO_VELHO,
                SALARIO_NOVO,USUARIO,DATAHORA, OPERACAO)
            VALUES(SEQ_LOG_PROGEXEC.NEXTVAL, :OLD.ID, 
        :OLD.SALARIO, :NEW.SALARIO, USER, SYSDATE, 'D');
    END IF;
  IF UPDATING THEN
    INSERT INTO LOG_PERSONAGEM (ID_LOG,ID,SALARIO_VELHO,
                SALARIO_NOVO,USUARIO,DATAHORA, OPERACAO)
            VALUES(SEQ_LOG_PROGEXEC.NEXTVAL, :OLD.ID, 
        :OLD.SALARIO, :NEW.SALARIO, USER, SYSDATE, 'U');
  END IF;
END;

INSERT INTO PERSONAGEM(ID, NOME, SALARIO)
VALUES(4, 'ANA', 2300);
COMMIT;

DELETE FROM PERSONAGEM WHERE ID = 4;
COMMIT;

UPDATE PERSONAGEM SET SALARIO = 4444 WHERE ID =2;
COMMIT;


SELECT * FROM LOG_PERSONAGEM;

-------------------------------


CREATE OR REPLACE 
FUNCTION FUNC_AUMENTOSALPERSONAGEM (PID IN NUMBER, PNOVOSALARIO IN NUMBER)
RETURN NUMBER
IS
    RETORNO NUMBER(3) := 0;
    QTDE NUMBER(1);
    VSALARIO PERSONAGEM.SALARIO%TYPE;
    VPARAMETROS VARCHAR2(4000);
    VNUMERRO NUMBER(6);
    VDESCRERRO VARCHAR2(4000);
BEGIN
    IF PNOVOSALARIO > 0 AND PNOVOSALARIO < 99999999.99 THEN
        SELECT COUNT(*) INTO QTDE FROM PERSONAGEM WHERE ID = PID;
        IF QTDE = 1 THEN
            SELECT SALARIO INTO VSALARIO FROM PERSONAGEM WHERE ID = PID;
            UPDATE PERSONAGEM SET SALARIO = PNOVOSALARIO WHERE ID = PID;
        ELSE
            RETORNO := -998;
        END IF;
    ELSE
        RETORNO := -999;
    END IF;
    COMMIT;
    RETURN RETORNO;
EXCEPTION
    WHEN OTHERS THEN 
        ROLLBACK;
        VPARAMETROS := 'PID = ' || PID || ', '
                    || 'PNOVOSALARIO = ' || PNOVOSALARIO;
        VNUMERRO := SQLCODE;
        VDESCRERRO := SQLERRM;
        INSERT INTO LOG_PROGRAMACAOEXECUCAO (ID_LOG,
            NOME_DO_CODIGO,PARAMETROS,NUMERO_ERRO,DESCRICAO_ERRO,
            NUMERO_LINHA_ERRO, USUARIO,DATAHORA,
            STATUS,DESCRICAO_SOLUCAO) VALUES(SEQ_LOG_PROGEXEC.NEXTVAL,
            'FUNC_AUMENTOSALPERSONAGEM', VPARAMETROS, VNUMERRO, VDESCRERRO, 
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()  , 
            USER, SYSDATE, 'E', NULL);
        COMMIT;
        RETURN SQLCODE;
END;
