
--------------------------- run as TANFEETH  --------------------

GRANT select ON TANFEETH.AGCY_SRVC_REQST to FIPORTAL;
GRANT select ON TANFEETH.INVOLVED_PARTY to FIPORTAL;

--------------------------- run as WCR --------------------
GRANT select ON WCR.LOOKUP_VALUES to FIPORTAL;

----------------------------------- run as FIPORTAL  -----------------------------------------------
----------------------------------------------------------------------------------------------

GRANT INSERT ON FIPORTAL.WORKFLOW_TASK to TANFEETH;

GRANT SELECT ON ACCOUNT_BALANCE_INFO_RESPONSE TO WCR;
GRANT SELECT ON ACCOUNT_INFO_RESERVE TO WCR;
GRANT SELECT ON ACCOUNT_INFO_RESPONSE TO WCR;
GRANT SELECT ON BALANCE_INFO_RESERVE TO WCR;
GRANT SELECT ON DEPOSIT_INFO_RESPONSE TO WCR;
GRANT SELECT ON LIABILITY_INFO_RESPONSE TO WCR;
GRANT SELECT ON PRD_USR_LST TO WCR;
GRANT SELECT ON PRODUCT_SHARE TO WCR;
GRANT SELECT ON SAFE_INFO_RESPONSE TO WCR;
GRANT SELECT ON WORKFLOW_TASK TO WCR;


ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (OFFICER_EXECUTED_DATE TIMESTAMP(6));
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (MODIFICATION_DATE TIMESTAMP(6));
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (NOTES VARCHAR2(800) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (EXECUTED_BY_MANAGER VARCHAR2(800) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (EXECUTED_BY VARCHAR2(200) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (MSGUID VARCHAR2(50) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK RENAME  COLUMN  APPROVED_DATE_TIME to MANAGER_ACTION_DATE;



ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (SRN VARCHAR2(50) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (PROCESS_TYPE_CD VARCHAR2(20) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (SRVC_TYPE_CD VARCHAR2(20) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (BUS_SRVC_CD VARCHAR2(20) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (REQSTR_CD VARCHAR2(50) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (PHASH VARCHAR2(128) );

ALTER TABLE FIPORTAL.WORKFLOW_TASK MODIFY (SUB_STATUS_ID DEFAULT 0);


------------------------------------ Tanfeeth TRIGGER-------------------------------------

create or replace TRIGGER EXTR_SRVC_TRIG_UPD_STATUS

AFTER UPDATE ON EXETR_SRVC_TASK

REFERENCING NEW AS NEW

FOR EACH ROW

BEGIN

INSERT

INTO EXETR_SRVC_TASK_STATUS

  (
    EXETR_SRVC_TASK_STATUS_ID,
    EXETR_SRVC_TASK_ID,
    DELIV_STATUS_CD,
    DELIV_TIME
  )

  VALUES

  (
    EXETR_SRVC_TASK_STAT_SEQ.NEXTVAL,
    :new.EXETR_SRVC_TASK_ID,
    :new.TRANS_STATUS,
    sysdate

  );

if :NEW.TRANS_STATUS = 'DELIV' then 

  INSERT
INTO ACTV_SLA_INSTANCE
  (
    ACTV_SLA_INSTANCE_ID,
    SLA_INSTANCE_REF_ID,
    SLA_INSTANCE_REF_TYPE,
    SLA_INSTANCE_CRN,
    SLA_INSTANCE_DUEDATE,
    SLA_INSTANCE_CURR_REPET,
    SLA_INSTANCE_MAX_REPET,
    SLA_ENTITY_ID
  )
  (select ACTV_SLA_INSTANCE_SEQ.NEXTVAL,
    :NEW.AGCY_SRVC_REQST_ID,
    'FI_'||:NEW.CHANNEL_CD,
    SRVC_REQST_COR_RN,
    GET_SLA_DUEDATE(SRVC_TYPE_CD,'FI',:NEW.CHANNEL_CD,'0'),
    0,
    3,
    :NEW.FIN_INST_CD 
    from AGCY_SRVC_REQST where AGCY_SRVC_REQST_ID=:NEW.AGCY_SRVC_REQST_ID
    );
  end if;


if :NEW.TRANS_STATUS = 'DELIV'  and  :NEW.CHANNEL_CD = 'Portal' then 

   INSERT INTO FIPORTAL.WORKFLOW_TASK 
  (
    ID,
    EXETR_SRVC_TASK_ID,
    REQUEST_METADATA_ID,
    FI_ID,
    CREATED_DATE_TIME,
    MSGUID,
    SRN,
    PROCESS_TYPE_CD,
    SRVC_TYPE_CD,
    BUS_SRVC_CD,
    REQSTR_CD,
    PHASH,
    DUE_DATE_TIME
  )
  
    (select FIPORTAL.WORKFLOW_TASK_ID.NEXTVAL,
    :new.EXETR_SRVC_TASK_ID,
    :new.AGCY_SRVC_REQST_ID,
    :new.FIN_INST_CD,
    sysdate,
    :new.EXETR_REF_NO,
    SRVC_REQST_COR_RN,
    PROCESS_TYPE_CD,
    SRVC_TYPE_CD,
    BUS_SRVC_CD,
    REQSTR_CD,
    PHASH,
    GET_SLA_DUEDATE(SRVC_TYPE_CD,'FIP','Portal',0)
    from TANFEETH.AGCY_SRVC_REQST where AGCY_SRVC_REQST_ID=:new.AGCY_SRVC_REQST_ID
    );
  end if;

END;
	
-------------------------------------FUNCTION GET_LOOKUP_NAME_AR--------------------------------------------

CREATE OR REPLACE FUNCTION "GET_LOOKUP_NAME_AR" (lov_parent_var VARCHAR2,code VARCHAR2) 
RETURN VARCHAR2 IS entity_name   VARCHAR2(1000);
BEGIN
    SELECT  attribute_1  INTO entity_name   FROM  wcr.lookup_values
    WHERE
        lov_parent = lov_parent_var
        AND   lov_code = code
        AND   ROWNUM = 1;	
RETURN (entity_name);
END:
		
--------------------------   TASK_DETAILS_VIEW      ----------------------

CREATE OR REPLACE VIEW "FIPORTAL"."TANFEETH_TASK_DETAILS_VIEW" (
    "TASK_ID",
    "TASK_REQUEST_METADATA_ID",
    "FI_ID",
    "TASK_CREATED_DATE_TIME",
    "ASSIGNED_DATE_TIME",
    "DUE_DATE_TIME",
    "ASSIGNED_TO",
    "ASSIGNED_BY",
    "ASSIGNED_BY_ROLE",
    "STATUS_ID",
    "SUB_STATUS_ID",
    "IS_BULK_PROCESSED",
    "REQUIRE_CHECKER",
    "MANAGER_ACTION_DATE",
    "REQUEST_METADATA_ID",
    "ENTITY_GOV_ID",
    "FI_CODES",
    "MAIN_SERVICE_TYPE_CODE",
    "SUB_SERVICE_TYPE_CODE",
    "REQUESTER_NAME",
    "REQUESTER_POSITION",
    "REQUESTER_GEO_LOC",
    "REQUESTER_GEO_LOC_DESC",
    "SENDER_SYS",
    "SENDER_SYS_IP",
    "CHANNEL_ID",
    "CONFIDENT_LEVEL_ID",
    "EXT_REF_NO",
    "REQUEST_CREATED_DATE_TIME",
    "REQUEST_CLASSIFICATION",
    "SRN",
    "RRN",
    "EXECUTED_BY_3",
    "ID",
    "NAME",
    "ID_TYPE_TITLE",
    "ID_TYPE",
    "ID_NO",
    "TYPE_CODE",
    "NATIONALITY_TITLE",
    "MSGUID",
    "BPM_REF_ID",
    "REQST_MOD",
    "CALL_BACK_STATUS"
) AS
    SELECT
        fiportal.workflow_task.id AS task_id,
        fiportal.workflow_task.request_metadata_id AS task_request_metadata_id,
        fiportal.workflow_task.fi_id,
        fiportal.workflow_task.created_date_time AS task_created_date_time,
        fiportal.workflow_task.assigned_date_time,
        fiportal.workflow_task.due_date_time,
        fiportal.workflow_task.assigned_to,
        fiportal.workflow_task.assigned_by,
        fiportal.workflow_task.assigned_by_role,
        fiportal.workflow_task.status_id,
        fiportal.workflow_task.sub_status_id,
        fiportal.workflow_task.is_bulk_processed,
        fiportal.workflow_task.require_checker,
        fiportal.workflow_task.MANAGER_ACTION_DATE,
        fiportal.workflow_task.request_metadata_id AS request_metadata_id,
        tanfeeth.agcy_srvc_reqst.reqstr_cd AS entity_gov_id,
        fiportal.workflow_task.fi_id,
        tanfeeth.agcy_srvc_reqst.process_type_cd AS main_service_type_code,
        tanfeeth.agcy_srvc_reqst.bus_srvc_cd,
        tanfeeth.agcy_srvc_reqst.reqstr_person_name,
        tanfeeth.agcy_srvc_reqst.position,
        tanfeeth.agcy_srvc_reqst.geo_loc,
        tanfeeth.agcy_srvc_reqst.geo_loc_desc,
        tanfeeth.agcy_srvc_reqst.sender_sys,
        tanfeeth.agcy_srvc_reqst.mac_ip,
        tanfeeth.agcy_srvc_reqst.channel_cd,
        tanfeeth.agcy_srvc_reqst.confidn_level_cd,
        tanfeeth.agcy_srvc_reqst.ext_ref_no,
        tanfeeth.agcy_srvc_reqst.reqst_recv_time AS request_created_date_time,
        tanfeeth.agcy_srvc_reqst.reqst_clasf,
        tanfeeth.agcy_srvc_reqst.srvc_reqst_cor_rn,
        tanfeeth.agcy_srvc_reqst.reqstr_ref_no,
        fiportal.workflow_task.executed_by AS executed_by_3,
        tanfeeth.involved_party.involved_party_id AS id,
        tanfeeth.involved_party.full_name AS name,
        tanfeeth.involved_party.id_type_cd AS id_type_title,
        tanfeeth.involved_party.id_type_cd AS id_type,
        tanfeeth.involved_party.id_no AS id_no,
        tanfeeth.agcy_srvc_reqst.inqrd_party_cd AS type_code,
        tanfeeth.involved_party.nat_cd AS nationality_title,
        fiportal.workflow_task.msguid,
        tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id AS bpm_ref_id,
        tanfeeth.agcy_srvc_reqst.reqst_mod AS reqst_mod,
        fiportal.workflow_task.call_back_status AS call_back_status
    FROM
        fiportal.workflow_task,
        tanfeeth.agcy_srvc_reqst,
        tanfeeth.involved_party
    WHERE
        tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = fiportal.workflow_task.request_metadata_id
        AND   tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = tanfeeth.involved_party.agcy_srvc_reqst_id (+);
		
		
-------------------------- TASK_BULK_VIEW ----------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW "FIPORTAL"."TASK_BULK_VIEW" (
    "TASK_ID",
    "REQUEST_METADATA_ID",
    "FI_ID",
    "SRN",
    "SUB_SERVICE_TYPE_CODE",
    "SUB_SERVICE_TYPE_NAME",
    "INVOLVED_ENTITY_NAME",
    "INVOLVED_ENTITY_ID_NO",
    "INVOLVED_ENTITY_ID_TYPE",
    "ENTITY_GOV_NAME",
    "REQUEST_CREATED_DATE_TIME",
    "STATUS_ID",
    "SUB_STATUS_ID",
    "ASSIGNED_TO",
    "IS_BULK_PROCESSED",
    "DUE_DATE_TIME",
    "REQUIRE_CHECKER",
    "ENTITY_GOV_ID",
    "EXECUTED_BY_3"
) AS
    SELECT
        fiportal.workflow_task.id AS task_id,
        fiportal.workflow_task.request_metadata_id,
        fiportal.workflow_task.fi_id,
        tanfeeth.agcy_srvc_reqst.srvc_reqst_cor_rn,
        tanfeeth.agcy_srvc_reqst.bus_srvc_cd,
        fiportal.get_lookup_name_ar(32,tanfeeth.agcy_srvc_reqst.bus_srvc_cd) AS SUB_SERVICE_TYPE_NAME,
        tanfeeth.involved_party.full_name AS involved_entity_name,
        tanfeeth.involved_party.id_no AS involved_entity_id_no,
        fiportal.get_lookup_name_ar(2,tanfeeth.involved_party.id_type_cd) AS id_type,
        fiportal.get_lookup_name_ar(13,tanfeeth.agcy_srvc_reqst.reqstr_cd) AS entity_gov_name,
        tanfeeth.agcy_srvc_reqst.reqst_recv_time AS request_created_date_time,
        fiportal.workflow_task.status_id,
        fiportal.workflow_task.sub_status_id,
        fiportal.workflow_task.assigned_to,
        fiportal.workflow_task.is_bulk_processed,
        fiportal.workflow_task.due_date_time,
        fiportal.workflow_task.require_checker,
        tanfeeth.agcy_srvc_reqst.reqstr_cd AS entity_gov_id,
        fiportal.workflow_task.executed_by AS executed_by_3
    FROM
        fiportal.workflow_task,
        tanfeeth.agcy_srvc_reqst,
        tanfeeth.involved_party
    WHERE
        tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = fiportal.workflow_task.request_metadata_id
        AND   tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = tanfeeth.involved_party.agcy_srvc_reqst_id (+);
		
--------------------------------------------_ALL_TASKS_VIEW------------------------------------------------------------------------------------------------------------------------
 
 CREATE OR REPLACE VIEW "FIPORTAL"."TANFEETH_ALL_TASKS_VIEW" (
    "TASK_ID",
    "TASK_REQUEST_METADATA_ID",
    "SRN",
    "FI_ID",
    "TASK_CREATED_DATE_TIME",
    "ASSIGNED_DATE_TIME",
    "DUE_DATE_TIME",
    "ASSIGNED_TO",
    "ASSIGNED_BY",
    "STATUS_ID",
    "SUB_STATUS_ID",
    "IS_BULK_PROCESSED",
    "MANAGER_ACTION_DATE",
    "REQUEST_METADATA_ID",
    "SLA_MINUTES",
    "EXECUTED_BY",
    "MAIN_SERVICE_TYPE_NAME",
    "SUB_SERVICE_TYPE_NAME",
    "MAIN_SERVICE_TYPE_CODE",
    "SUB_SERVICE_TYPE_CODE",
    "TASK_CLOSING_DATE_TIME3",
    "TASK_CLOSING_DATE_TIME4",
    "LAST_RETURN_DATE_TIME",
    "TASK_CLOSING_DATE_TIME5",
    "ENTITY_GOV_NAME",
    "EXECUTED_BY_MANAGER",
    "ENTITY_GOV_ID",
    "LAST_ASSIGNED_TO",
    "INVOLVED_ENTITY_NAME",
    "INVOLVED_ENTITY_ID_NO",
    "INVOLVED_ENTITY_ID_TYPE_CD",
    "INVOLVED_ENTITY_ID_TYPE"
) AS
    SELECT
        fiportal.workflow_task.id AS task_id,
        fiportal.workflow_task.request_metadata_id AS task_request_metadata_id,
        fiportal.workflow_task.srn,
        fiportal.workflow_task.fi_id,
        fiportal.workflow_task.created_date_time AS task_created_date_time,
        fiportal.workflow_task.assigned_date_time,
        fiportal.workflow_task.due_date_time,
        fiportal.workflow_task.assigned_to,
        fiportal.workflow_task.assigned_by,
        fiportal.workflow_task.status_id,
        fiportal.workflow_task.sub_status_id,
        fiportal.workflow_task.is_bulk_processed,
        fiportal.workflow_task.manager_action_date,
        fiportal.workflow_task.request_metadata_id AS request_metadata_id,
        fiportal.workflow_task.sla_minutes,
        fiportal.workflow_task.executed_by,
        fiportal.get_lookup_name_ar(15,fiportal.workflow_task.process_type_cd) AS main_service_type_name,
        fiportal.get_lookup_name_ar(32,fiportal.workflow_task.bus_srvc_cd) AS sub_service_type_name,
        fiportal.workflow_task.process_type_cd AS main_service_type_code,
        fiportal.workflow_task.bus_srvc_cd AS sub_service_type_code,
        fiportal.workflow_task.officer_executed_date AS task_closing_date_time3,
        fiportal.workflow_task.officer_executed_date AS task_closing_date_time4,
        fiportal.workflow_task.last_return_date_time,
        fiportal.workflow_task.modification_date AS task_closing_date_time5,
        fiportal.get_lookup_name_ar(35,fiportal.workflow_task.reqstr_cd) AS entity_gov_name,
        fiportal.workflow_task.executed_by_manager AS executed_by_manager,
        fiportal.workflow_task.reqstr_cd AS entity_gov_id,
        fiportal.workflow_task.last_assigned_to AS last_assigned_to,
        tanfeeth.involved_party.full_name AS involved_entity_name,
        tanfeeth.involved_party.id_no AS involved_entity_id_no,
        tanfeeth.involved_party.id_type_cd AS id_type_cd,
        fiportal.get_lookup_name_ar(2,tanfeeth.involved_party.id_type_cd) AS id_type
    FROM
        fiportal.workflow_task,
        tanfeeth.involved_party
    WHERE
        fiportal.workflow_task.request_metadata_id = tanfeeth.involved_party.agcy_srvc_reqst_id (+);
		

-----------------------------------------TRIGGER UPDATE_TASK_HISTORY-------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER fiportal_update_task_history AFTER
    UPDATE ON fiportal.workflow_task
    REFERENCING
            NEW AS new
            OLD AS old
    FOR EACH ROW
BEGIN
    INSERT INTO fiportal.workflow_status_event_history (
        id,
        task_id,
        status_id,
        sub_status_id,
        event_date_time,
        assigned_to,
        executed_by,
        executed_by_role,
        notes
    ) VALUES (
        fiportal.event_history_id.nextval,
        :new.id,
        :new.status_id,
        :new.sub_status_id,
        SYSDATE,
        :new.assigned_to,
        :old.assigned_to,
        :new.assigned_by_role,
        :new.notes
    );

END;

---------------------------------------GI services update------------------------------------



DELETE FROM WORKFLOW_STATUS_EVENT_HISTORY; 
DELETE FROM WORKFLOW_TASK;  

--DELETE FROM BALANCE_INFO_USER ;
--DELETE FROM BALANCE_INFO_SHERINFO;
--DELETE FROM BALANCE_INFO_RESERVE ;
--DELETE FROM ACCOUNT_INFO_USER ; 
--DELETE FROM ACCOUNT_INFO_RESERVE;
--DELETE FROM DEPOSIT_INFO_USER;
--DELETE FROM LIABILITY_INFO_USER;
--DELETE FROM SAFE_INFO_USER;

DELETE FROM ACCOUNT_BALANCE_INFO_RESPONSE;
DELETE FROM ACCOUNT_INFO_RESPONSE;
DELETE FROM DEPOSIT_INFO_RESPONSE;
DELETE FROM LIABILITY_INFO_RESPONSE;
DELETE FROM SAFE_INFO_RESPONSE;
---------------------------------------------------------------------------------

ALTER TABLE  "FIPORTAL"."ACCOUNT_BALANCE_INFO_RESPONSE" DROP CONSTRAINT ACC_BAL_INFO_RESPONSE;
ALTER TABLE  "FIPORTAL"."SHARE_INFO_RESPONSE" DROP CONSTRAINT SHARE_INFO_RESP;
ALTER TABLE  "FIPORTAL"."ACCOUNT_INFO_RESPONSE" DROP CONSTRAINT ACC_INFO_RESPONSE;
ALTER TABLE  "FIPORTAL"."DEPOSIT_INFO_RESPONSE" DROP CONSTRAINT DEP_INFO_RESPONSE;
ALTER TABLE  "FIPORTAL"."LIABILITY_INFO_RESPONSE" DROP CONSTRAINT LIAB_INFO_RESPONSE;
ALTER TABLE  "FIPORTAL"."SAFE_INFO_RESPONSE" DROP CONSTRAINT SAFE_INFO_RESPONSE;


ALTER TABLE "FIPORTAL"."SAFE_INFO_RESPONSE" RENAME COLUMN REQUEST_ID TO Task_ID ;
ALTER TABLE "FIPORTAL"."ACCOUNT_BALANCE_INFO_RESPONSE" RENAME COLUMN REQUEST_ID TO Task_ID ;
ALTER TABLE "FIPORTAL"."ACCOUNT_INFO_RESPONSE" RENAME COLUMN REQUEST_ID TO Task_ID ;
ALTER TABLE "FIPORTAL"."DEPOSIT_INFO_RESPONSE" RENAME COLUMN REQUEST_ID TO Task_ID ;
ALTER TABLE "FIPORTAL"."LIABILITY_INFO_RESPONSE" RENAME COLUMN REQUEST_ID TO Task_ID ;
ALTER TABLE "FIPORTAL"."BALANCE_INFO_SHERINFO" RENAME COLUMN REQUEST_ID TO Task_ID ;
ALTER TABLE "FIPORTAL"."SHARE_INFO_RESPONSE" RENAME COLUMN REQUEST_ID TO Task_ID ;


ALTER TABLE "FIPORTAL"."ACCOUNT_BALANCE_INFO_RESPONSE" ADD CONSTRAINT "abirFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);
ALTER TABLE "FIPORTAL"."ACCOUNT_INFO_RESPONSE" ADD CONSTRAINT "airFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);
ALTER TABLE "FIPORTAL"."DEPOSIT_INFO_RESPONSE" ADD CONSTRAINT "dirFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);
ALTER TABLE "FIPORTAL"."LIABILITY_INFO_RESPONSE" ADD CONSTRAINT "lirFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);
ALTER TABLE "FIPORTAL"."SAFE_INFO_RESPONSE" ADD CONSTRAINT "sirFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);



ALTER TABLE ACCOUNT_INFO_RESPONSE DROP COLUMN FI_ID;
ALTER TABLE ACCOUNT_BALANCE_INFO_RESPONSE DROP COLUMN FI_ID;
ALTER TABLE DEPOSIT_INFO_RESPONSE DROP COLUMN FI_ID;
ALTER TABLE LIABILITY_INFO_RESPONSE DROP COLUMN FI_ID;
ALTER TABLE SAFE_INFO_RESPONSE DROP COLUMN FI_ID;

ALTER TABLE ACCOUNT_INFO_RESPONSE DROP COLUMN IS_DELETED;
ALTER TABLE ACCOUNT_BALANCE_INFO_RESPONSE DROP COLUMN IS_DELETED;
ALTER TABLE DEPOSIT_INFO_RESPONSE DROP COLUMN IS_DELETED;
ALTER TABLE LIABILITY_INFO_RESPONSE DROP COLUMN IS_DELETED;
ALTER TABLE SAFE_INFO_RESPONSE DROP COLUMN IS_DELETED;


-----------------------------------drop old tables-------------------------------

DROP trigger FIPORTAL.UPDATE_TASK_LAST_ASSIGNED_TO;
DROP trigger FIPORTAL.LOG_RESPONSE_DISPATCH_JOB;

ALTER TABLE FIPORTAL.WORKFLOW_TASK DROP constraint REQUEST_TASKS;

DROP view FIPORTAL.TASK_INBOX;
DROP view FIPORTAL.TASK_FULL_VIEW;
DROP view FIPORTAL.TANFEETH_TASK_FULL_VIEW;
DROP view FIPORTAL.RESPONSE_DISPATCH_JOB_DETAIL;

DROP TABLE FIPORTAL.ACCOUNT_INFO_REQUEST;
DROP TABLE FIPORTAL.ACCOUNT_BALANCE_INFO_REQUEST;
DROP TABLE FIPORTAL.DEPOSIT_INFO_REQUEST;
DROP TABLE FIPORTAL.LIABILITY_INFO_REQUEST;
DROP TABLE FIPORTAL.SAFE_INFO_REQUEST;
DROP TABLE FIPORTAL.RESPONSE_DISPATCH_JOB;
DROP TABLE FIPORTAL.FI_ENTITY;
DROP TABLE FIPORTAL.FI_USER;
DROP TABLE FIPORTAL.REQUEST_METADATA;
DROP TABLE FIPORTAL.GOV_ENTITY;
DROP TABLE FIPORTAL.INVOLVED_ENTITY;
DROP TABLE FIPORTAL.SHARE_INFO_RESPONSE;
DROP TABLE FIPORTAL.BALANCE_INFO_SHERINFO;
DROP TABLE FIPORTAL.ACCOUNT_INFO_USER;
DROP TABLE FIPORTAL.BALANCE_INFO_USER;
DROP TABLE FIPORTAL.DEPOSIT_INFO_USER;
DROP TABLE FIPORTAL.SAFE_INFO_USER;
DROP TABLE FIPORTAL.LIABILITY_INFO_USER;
DROP TABLE FIPORTAL.LOOKUPS;
DROP TABLE FIPORTAL.WORKFLOW_TASK_OWNER_HISTORY;

-------------------------------------- 1.5 changes -----------------------------

ALTER TABLE LIABILITY_INFO_RESPONSE ADD (INSTAL_REPEAT_TIMES NUMBER );

ALTER TABLE LIABILITY_INFO_RESPONSE RENAME COLUMN INSTALLEMENT_REP_INTERVAL TO INSTAL_REPEAT;

ALTER TABLE LIABILITY_INFO_RESPONSE  MODIFY (INSTAL_REPEAT VARCHAR2(10 CHAR) );

ALTER TABLE LIABILITY_INFO_RESPONSE DROP COLUMN REQUEST_ID;

ALTER TABLE ACCOUNT_INFO_RESPONSE DROP COLUMN AVAILABLE_BALANCE;

ALTER TABLE ACCOUNT_INFO_RESPONSE DROP COLUMN TOTAL_BALANCE;

ALTER TABLE ACCOUNT_INFO_RESPONSE DROP COLUMN BALANCE_DATE;

-----------------------------------------------------------------------------------
--------------------------------------------------------
--  DDL for Sequence PRD_SHRS_SEQ
----------
 CREATE SEQUENCE  "FIPORTAL"."PRD_SHRS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 ;

-------------------------------------------------------------------------------------------------
--  DDL for Sequence PRD_USR_LST_SEQ
---------------------------------------------------------------------------------------------------------------

 CREATE SEQUENCE  "FIPORTAL"."PRD_USR_LST_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 ;

------------------------------------------------------------

CREATE TABLE "FIPORTAL"."PRD_USR_LST" 
   ("PRD_USR_LST_ID" NUMBER DEFAULT "FIPORTAL"."PRD_USR_LST_SEQ"."NEXTVAL", 
	"PRD_ID" NUMBER NOT NULL ENABLE, 
	"PRD_TYPE" VARCHAR2(20 CHAR) NOT NULL ENABLE, 
	"PRD_USER_ID" VARCHAR2(24 CHAR), 
	"PRD_USER_ID_TYPE" VARCHAR2(20 CHAR), 
	"PRD_USER_TYPE" VARCHAR2(20 CHAR), 
	"PRD_USER_NAME" VARCHAR2(150 CHAR), 
	"TASK_ID" NUMBER NOT NULL ENABLE, 
	 CONSTRAINT "PRD_USR_LST_PK" PRIMARY KEY ("PRD_USR_LST_ID")
	 
	 )
	 
	 
	---------------------------------
	
	CREATE TABLE "FIPORTAL"."PRODUCT_SHARE" 
   ("PRD_SHRS_ID" NUMBER DEFAULT "TANFEETH"."PRD_SHRS_SEQ"."NEXTVAL", 
	"TASK_ID" NUMBER NOT NULL ENABLE, 
	"PRD_TYPE" VARCHAR2(20 CHAR) NOT NULL ENABLE, 
	"COMP_NAME" VARCHAR2(100 CHAR), 
	 CONSTRAINT "PRD_SHRS_PK" PRIMARY KEY ("PRD_SHRS_ID")
	 )
	


------------------------------------------Audit --------------------------------------------
  
  CREATE SEQUENCE  "FIPORTAL"."AUDIT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 ;		
		
		CREATE TABLE "FIPORTAL"."AUDIT_LOG_PORTAL" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"INSERT_TIME" TIMESTAMP (6), 
	"EVENT_TIME" TIMESTAMP (6), 
	"APPLICATION" VARCHAR2(50 BYTE), 
	"FLOW_NAME" VARCHAR2(50 BYTE), 
	"NODE_NAME" VARCHAR2(50 BYTE), 
	"TASK_ID" VARCHAR2(20 BYTE), 
	"SRN" VARCHAR2(50 BYTE), 
	"MSGUID" VARCHAR2(50 BYTE), 
	"PID" VARCHAR2(20 BYTE), 
	"EXECUTED_BY" VARCHAR2(50 BYTE), 
	"STATUS_CODE" VARCHAR2(50 BYTE), 
	"MESSAGE" VARCHAR2(2000 BYTE), 
	"INTEGRATION_NODE_NAME" VARCHAR2(100 BYTE), 
	"CLIENT_IP" VARCHAR2(20 BYTE), 
	"SERVER_IP" VARCHAR2(20 BYTE), 
	"MESSAGE_DATA" CLOB
   )
   
   
  
	
GRANT select ON fiportal.audit_log_portal to WCR;
GRANT insert ON fiportal.audit_log_portal to WCR;
GRANT select ON fiportal.audit_seq to WCR;
