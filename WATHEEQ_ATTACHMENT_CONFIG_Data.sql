--------------------------------------------------------
--  File created - Monday-June-15-2020   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table WATHEEQ_ATTACHMENT_CONFIG
--------------------------------------------------------

  CREATE TABLE "WATHEEQ_ATTACHMENT_CONFIG" 
   (	"ID" NUMBER(*,0), 
	"PID" VARCHAR2(255 BYTE), 
	"SERVICE_CODE" VARCHAR2(255 BYTE), 
	"FILE_TYPE" VARCHAR2(255 BYTE)
   ) ;
Insert into SBMDB.WATHEEQ_ATTACHMENT_CONFIG (ID,PID,SERVICE_CODE,FILE_TYPE) values (1,'10100','20','PDF');
Insert into SBMDB.WATHEEQ_ATTACHMENT_CONFIG (ID,PID,SERVICE_CODE,FILE_TYPE) values (2,'10100','20','Word');
Insert into SBMDB.WATHEEQ_ATTACHMENT_CONFIG (ID,PID,SERVICE_CODE,FILE_TYPE) values (3,'10200','20','Excel');
Insert into SBMDB.WATHEEQ_ATTACHMENT_CONFIG (ID,PID,SERVICE_CODE,FILE_TYPE) values (4,'10100','20','PDF00');
