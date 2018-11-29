

--------------------------- run as WCR --------------------
GRANT select ON WCR.LOOKUP_VALUES to FIPORTAL;

----------------------------------- run as FIPORTAL  -----------------------------------------------
----------------------------------------------------------------------------------------------
ALTER TABLE FIPORTAL.WORKFLOW_TASK RENAME  COLUMN  LAST_ASSIGNED_TO to EXECUTED_BY
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (MODIFICATION_DATE TIMESTAMP(6));
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (NOTES VARCHAR2(800) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (EXECUTED_BY_MANAGER VARCHAR2(800) );




 GRANT select ON fiportal.audit_log_portal to WCR;
 GRANT insert ON fiportal.audit_log_portal to WCR;
 GRANT select ON fiportal.audit_seq to WCR;
	
-------------------------------------FUNCTION GET_LOOKUP_NAME_AR--------------------------------------------

CREATE OR REPLACE FUNCTION "GET_LOOKUP_NAME_AR" (lov_parent_var VARCHAR2,code VARCHAR2) 
RETURN VARCHAR2 IS entity_name   VARCHAR2(1000);
BEGIN
    SELECT  attribute_1  INTO entity_name   FROM  wcr.lookup_values
    WHERE
        lov_parent = lov_parent_var
        AND   lov_code = code
        AND   ROWNUM = 1;	

		

--------------------------   TASK_DETAILS_VIEW      ----------------------

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "FIPORTAL"."TANFEETH_TASK_DETAILS_VIEW" (
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
    "APPROVED_DATE_TIME",
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
    "NATIONALITY_TITLE"
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
        fiportal.workflow_task.approved_date_time,
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
        tanfeeth.involved_party.nat_cd AS nationality_title
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
 
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "FIPORTAL"."TANFEETH_ALL_TASKS_VIEW" (
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
    "APPROVED_DATE_TIME",
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
    "ENTITY_GOV_ID",
    "TYPE_CODE"
) AS
    SELECT
        fiportal.workflow_task.id AS task_id,
        fiportal.workflow_task.request_metadata_id AS task_request_metadata_id,
        tanfeeth.agcy_srvc_reqst.srvc_reqst_cor_rn,
        fiportal.workflow_task.fi_id,
        fiportal.workflow_task.created_date_time AS task_created_date_time,
        fiportal.workflow_task.assigned_date_time,
        fiportal.workflow_task.due_date_time,
        fiportal.workflow_task.assigned_to,
        fiportal.workflow_task.assigned_by,
        fiportal.workflow_task.status_id,
        fiportal.workflow_task.sub_status_id,
        fiportal.workflow_task.is_bulk_processed,
        fiportal.workflow_task.approved_date_time,
        fiportal.workflow_task.request_metadata_id AS request_metadata_id,
        fiportal.workflow_task.sla_minutes,-- From TASK_INBOX_view
        fiportal.workflow_task.executed_by,-- From TASK_INBOX_view
        fiportal.get_lookup_name_ar(
            15,
            tanfeeth.agcy_srvc_reqst.process_type_cd
        ) AS main_service_type_name,
        fiportal.get_lookup_name_ar(
            32,
            tanfeeth.agcy_srvc_reqst.bus_srvc_cd
        ) AS sub_service_type_name,
        tanfeeth.agcy_srvc_reqst.process_type_cd AS main_service_type_code,
        tanfeeth.agcy_srvc_reqst.bus_srvc_cd AS sub_service_type_code,
        fiportal.workflow_task.officer_executed_date AS task_closing_date_time3,-- From TASK_INBOX_view
        fiportal.workflow_task.officer_executed_date AS task_closing_date_time4,-- From TASK_INBOX_view
        fiportal.workflow_task.last_return_date_time,
        --FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID,6) AS TASK_CLOSING_DATE_TIME6,-- From TASK_INBOX_view
        --FIPORTAL.GET_EXECUTED_BY(WORKFLOW_TASK.ID,3) AS TASK_CLOSED_BY3,-- From TASK_INBOX_view
        fiportal.workflow_task.modification_date AS task_closing_date_time5,-- From TASK_INBOX_view //APPROVED_DATE_TIME
        fiportal.get_lookup_name_ar(
            35,
            tanfeeth.agcy_srvc_reqst.reqstr_cd
        ) AS entity_gov_id,
      --  tanfeeth.involved_party.agcy_srvc_reqst_id AS request_metadata_id,
        tanfeeth.agcy_srvc_reqst.inqrd_party_cd AS type_code
    FROM
        fiportal.workflow_task,
        tanfeeth.agcy_srvc_reqst
    WHERE
        tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = fiportal.workflow_task.request_metadata_id;
		
		
---------------------------------------TRIGGER UPDATE_TASK_DATES --------------------------------------------------------------------
CREATE OR REPLACE TRIGGER "FIPORTAL"."UPDATE_TASK_DATES" BEFORE
    UPDATE ON fiportal.workflow_task
    FOR EACH ROW
BEGIN
        :new.MODIFICATION_DATE := SYSDATE;
END;



-----------------------------------------TRIGGER UPDATE_TASK_HISTORY-------------------------------------------------------------------------------------

create or replace TRIGGER FIPORTAL_UPDATE_TASK_HISTORY
AFTER UPDATE  ON FIPORTAL.WORKFLOW_TASK
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
INSERT
INTO FIPORTAL.WORKFLOW_STATUS_EVENT_HISTORY
  (
   ID, TASK_ID, STATUS_ID, SUB_STATUS_ID, EVENT_DATE_TIME, EXECUTED_BY, EXECUTED_BY_ROLE,NOTES
  )

  VALUES

  (
    FIPORTAL.EVENT_HISTORY_ID.NEXTVAL,
    :new.ID,
    :new.STATUS_ID,
    :new.SUB_STATUS_ID,
     sysdate,
    :new.ASSIGNED_BY,
    :new.ASSIGNED_BY_ROLE,
    :new.NOTES
  );

END

---------------------------------------GI services update------------------------------------



DELETE FROM WORKFLOW_STATUS_EVENT_HISTORY; 
DELETE FROM WORKFLOW_TASK;  

DELETE FROM BALANCE_INFO_USER ;
DELETE FROM BALANCE_INFO_SHERINFO;
DELETE FROM BALANCE_INFO_RESERVE ;
DELETE FROM ACCOUNT_INFO_USER ; 
DELETE FROM ACCOUNT_INFO_RESERVE;
DELETE FROM DEPOSIT_INFO_USER;
DELETE FROM LIABILITY_INFO_USER;
DELETE FROM SAFE_INFO_USER;

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




----------------------------------

CREATE TABLE "FIPORTAL"."PRD_USR_LST" 
   ("PRD_USR_LST_ID" NUMBER DEFAULT "FIPORTAL"."PRD_USR_LST_SEQ"."NEXTVAL", 
	"PRD_ID" NUMBER NOT NULL ENABLE, 
	"PRD_TYPE" VARCHAR2(20 CHAR) NOT NULL ENABLE, 
	"PRD_USER_ID" VARCHAR2(24 CHAR), 
	"PRD_USER_ID_TYPE" VARCHAR2(20 CHAR), 
	"PRD_USER_TYPE" VARCHAR2(20 CHAR), 
	"PRD_USER_NAME" VARCHAR2(150 CHAR), 
	 CONSTRAINT "PRD_USR_LST_PK" PRIMARY KEY ("PRD_USR_LST_ID")
	 
	 )
	 
	 
	---------------------------------
	 
	 CREATE TABLE "FIPORTAL"."PRD_USR_LST" 
   (	"PRD_USR_LST_ID" NUMBER DEFAULT "FIPORTAL"."PRD_USR_LST_SEQ"."NEXTVAL", 
	"PRD_ID" NUMBER NOT NULL ENABLE, 
	"PRD_TYPE" VARCHAR2(20 CHAR) NOT NULL ENABLE, 
	"PRD_USER_ID" VARCHAR2(24 CHAR), 
	"PRD_USER_ID_TYPE" VARCHAR2(20 CHAR), 
	"PRD_USER_TYPE" VARCHAR2(20 CHAR), 
	"PRD_USER_NAME" VARCHAR2(150 CHAR), 
	 CONSTRAINT "PRD_USR_LST_PK" PRIMARY KEY ("PRD_USR_LST_ID")
	 )
--------------------------------------------------------
--  DDL for Sequence PRD_SHRS_SEQ
----------

----------------------------------------------

   CREATE SEQUENCE  "FIPORTAL"."PRD_SHRS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 21 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

--------------------------------------------------------
--  DDL for Sequence PRD_USR_LST_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "FIPORTAL"."PRD_USR_LST_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 701 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;


		