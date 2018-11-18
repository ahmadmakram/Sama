--------------As SYS

GRANT CREATE ANY VIEW TO FIPORTAL;

GRANT SELECT ON tanfeeth.agcy_srvc_reqst to FIPORTAL
GRANT SELECT ON tanfeeth.involved_party  to FIPORTAL
GRANT insert ON fiportal.WORKFLOW_TASK to TANFEETH;
GRANT select ON fiportal.WORKFLOW_TASK to TANFEETH;
GRANT select ON fiportal.WORKFLOW_TASK_ID to TANFEETH;


------------------------- --------------As FIPortal add column -------------------------------

ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD EXETR_SRVC_TASK_ID NUMBER;
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (NOTES VARCHAR2(800) );
ALTER TABLE FIPORTAL.WORKFLOW_TASK ADD (CALL_BACK_STATUS VARCHAR2(8));

ALTER TABLE FIPORTAL.WORKFLOW_TASK DISABLE  constraint REQUEST_TASKS

-------------------------- TRIGGER -------------------------------
--   run as tanfeeth
--------------------------------------------------

create or replace TRIGGER FIPORTAL_WORKFLOW_TASK_TRG
AFTER INSERT ON Tanfeeth.EXETR_SRVC_TASK
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
INSERT
INTO FIPORTAL.WORKFLOW_TASK
  (
    ID,
    EXETR_SRVC_TASK_ID,
    REQUEST_METADATA_ID,
    FI_ID,
    CREATED_DATE_TIME
  )

  VALUES

  (
    FIPORTAL.WORKFLOW_TASK_ID.NEXTVAL,
    :new.EXETR_SRVC_TASK_ID,
    :new.AGCY_SRVC_REQST_ID,
    :new.FIN_INST_CD,
    sysdate

  );

END;





-----------------------------View ---------------------------
--   run as FIPORTAL
--------------------------------------------------

 CREATE OR REPLACE VIEW "FIPORTAL"."TANFEETH_TASK_FULL_VIEW" ("TASK_ID", "TASK_REQUEST_METADATA_ID", "SRN", "FI_ID", "TASK_CREATED_DATE_TIME", "ASSIGNED_DATE_TIME", "DUE_DATE_TIME", "ASSIGNED_TO", "ASSIGNED_BY", "ASSIGNED_BY_ROLE", "STATUS_ID", "SUB_STATUS_ID", "IS_BULK_PROCESSED", "REQUIRE_CHECKER", "APPROVED_DATE_TIME", "REQUEST_METADATA_ID", "SLA_MINUTES", "LAST_ASSIGNED_TO", "LAST_RETURN_DATE_TIME", "FI_CODES", "MAIN_SERVICE_TYPE_CODE", "SUB_SERVICE_TYPE_CODE", "REQUESTER_NAME", "REQUESTER_POSITION", "REQUESTER_GEO_LOC", "REQUESTER_GEO_LOC_DESC", "SENDER_SYS", "SENDER_SYS_IP", "CHANNEL_ID", "CONFIDENT_LEVEL_ID", "EXT_REF_NO", "REQUEST_CREATED_DATE_TIME", "REQUEST_CLASSIFICATION", "EXECUTED_BY_3", "EXECUTED_BY_6", "TASK_CLOSING_DATE_TIME3", "TASK_CLOSING_DATE_TIME4", "TASK_CLOSING_DATE_TIME6", "TASK_CLOSED_BY3", "TASK_CLOSING_DATE_TIME5", "ID", "ENTITY_GOV_ID", "NAME", "ID_TYPE_TITLE", "ID_TYPE", "ID_NO", "TYPE_CODE", "NATIONALITY_TITLE") AS 
  SELECT
        fiportal.workflow_task.id AS task_id,
        fiportal.workflow_task.request_metadata_id AS task_request_metadata_id,
        tanfeeth.agcy_srvc_reqst.srvc_reqst_cor_rn,
        fiportal.workflow_task.fi_id,
        fiportal.workflow_task.created_date_time AS TASK_CREATED_DATE_TIME,
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
		fiportal.WORKFLOW_TASK.SLA_MINUTES, -- From TASK_INBOX_view
		fiportal.WORKFLOW_TASK.LAST_ASSIGNED_TO, -- From TASK_INBOX_view
		fiportal.WORKFLOW_TASK.LAST_RETURN_DATE_TIME,   -- From TASK_INBOX_view
        tanfeeth.agcy_srvc_reqst.fi_codes,
        tanfeeth.agcy_srvc_reqst.PROCESS_TYPE_CD AS main_service_type_code,
        tanfeeth.agcy_srvc_reqst.SRVC_TYPE_CD,
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
        fiportal.get_executed_by_3(workflow_task.id) AS executed_by_3,
        GET_EXECUTED_BY_6(WORKFLOW_TASK.ID) AS EXECUTED_BY_6,-- From TASK_INBOX_view
        FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID, 3) AS TASK_CLOSING_DATE_TIME3,-- From TASK_INBOX_view
        FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID, 4) AS TASK_CLOSING_DATE_TIME4, -- From TASK_INBOX_view
        FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID, 6) AS TASK_CLOSING_DATE_TIME6, -- From TASK_INBOX_view
        FIPORTAL.GET_EXECUTED_BY(WORKFLOW_TASK.ID, 3) AS TASK_CLOSED_BY3, -- From TASK_INBOX_view
        FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID, 5) AS TASK_CLOSING_DATE_TIME5, -- From TASK_INBOX_view
        tanfeeth.involved_party.involved_party_id AS id,
        tanfeeth.agcy_srvc_reqst.REQSTR_CD AS ENTITY_GOV_ID,
      --  tanfeeth.involved_party.agcy_srvc_reqst_id AS request_metadata_id,
        tanfeeth.involved_party.full_name AS name,
        tanfeeth.involved_party.id_type_cd AS id_type_title,
        TANFEETH.INVOLVED_PARTY.id_type_cd AS ID_TYPE,
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
		
		
		-----------------------------------------------
		
		
--------------------------------------------------------
--  DDL for Table DENY_DEALING_RESPONSE
--------------------------------------------------------

  CREATE TABLE "FIPORTAL"."DENY_DEALING_RESPONSE" 
   (	"ID" NUMBER(*,0), 
	"TASK_ID" NUMBER(*,0), 
	"CUST_NAME" VARCHAR2(100 BYTE), 
	"CUST_ID" VARCHAR2(20 BYTE), 
	"CUST_IDTYPE" VARCHAR2(10 BYTE), 
	"EXE_DTTM" TIMESTAMP (6), 
	"IS_DELETED" VARCHAR2(3 BYTE) DEFAULT 'NO', 
	"CUST_NTNLTY" VARCHAR2(3 BYTE), 
	"CREATED_DATE_TIME" TIMESTAMP (6)
   );
--------------------------------------------------------
--  DDL for Index DENY_RESP_ID
--------------------------------------------------------

  CREATE UNIQUE INDEX "FIPORTAL"."DENY_RESP_ID" ON "FIPORTAL"."DENY_DEALING_RESPONSE" ("ID")  ;
--------------------------------------------------------
--  DDL for Index DENY_RESP_REQ_ID
--------------------------------------------------------

  CREATE INDEX "FIPORTAL"."DENY_RESP_REQ_ID" ON "FIPORTAL"."DENY_DEALING_RESPONSE" ("TASK_ID") ;
--------------------------------------------------------
--  Constraints for Table DENY_DEALING_RESPONSE
--------------------------------------------------------

  ALTER TABLE "FIPORTAL"."DENY_DEALING_RESPONSE" ADD CONSTRAINT "DENY_RESP_ID" PRIMARY KEY ("ID");
  ALTER TABLE "FIPORTAL"."DENY_DEALING_RESPONSE" MODIFY ("ID" NOT NULL ENABLE);


  CREATE SEQUENCE  "FIPORTAL"."DENYDEALING_TASK_SQID"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 
   INCREMENT BY 1 START WITH 61 CACHE 20 NOORDER  NOCYCLE ;

   
--------------------------------------------------------
--  DDL for Table BAN_DEALING_RESPONSE
--------------------------------------------------------

  CREATE TABLE "FIPORTAL"."BAN_DEALING_RESPONSE" 
   (	"ID" NUMBER(*,0), 
	"CUST_NAME" VARCHAR2(100 BYTE), 
	"CUST_ID" VARCHAR2(20 BYTE), 
	"CUST_IDTYPE" VARCHAR2(10 BYTE), 
	"CUST_NTNLTY" VARCHAR2(3 BYTE), 
	"EXE_DTTM" TIMESTAMP (6), 
	"IS_DELETED" VARCHAR2(3 BYTE) DEFAULT 'NO', 
	"TASK_ID" NUMBER(*,0), 
	"CREATED_DATE_TIME" TIMESTAMP (6)
   ) ;
--------------------------------------------------------
--  DDL for Index BAN_RESP_ID1
--------------------------------------------------------

  CREATE UNIQUE INDEX "FIPORTAL"."BAN_RESP_ID1" ON "FIPORTAL"."BAN_DEALING_RESPONSE" ("ID")  ;
--------------------------------------------------------
--  Constraints for Table BAN_DEALING_RESPONSE
--------------------------------------------------------

  ALTER TABLE "FIPORTAL"."BAN_DEALING_RESPONSE" ADD CONSTRAINT "BAN_DEALING_RESPONSE_PK" PRIMARY KEY ("ID");
  ALTER TABLE "FIPORTAL"."BAN_DEALING_RESPONSE" MODIFY ("TASK_ID" NOT NULL ENABLE);
  ALTER TABLE "FIPORTAL"."BAN_DEALING_RESPONSE" MODIFY ("ID" NOT NULL ENABLE);

  
  --------------------------------------------------------
--  DDL for Sequence BANDEALING_TASK_SQID
--------------------------------------------------------

   CREATE SEQUENCE  "FIPORTAL"."BANDEALING_TASK_SQID"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 41 CACHE 20 NOORDER  NOCYCLE ;
  

--------------------------------------------------------------------------------------------------------------------------------------------------  
ALTER TABLE "FIPORTAL"."DENY_DEALING_RESPONSE" ADD CONSTRAINT "ddrFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);
ALTER TABLE "FIPORTAL"."BAN_DEALING_RESPONSE" ADD CONSTRAINT "bdrFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);
ALTER TABLE "FIPORTAL"."BALANCE_INFO_SHERINFO" ADD CONSTRAINT "bisrFKY" FOREIGN KEY ("TASK_ID") REFERENCES "FIPORTAL".WORKFLOW_TASK (ID);

--------------------------------------------------------------------------



  CREATE TABLE "FIPORTAL"."AUDIT_LOG_PORTAL" 
   ("ID" NUMBER NOT NULL ENABLE, 
	"INSERT_TIME" TIMESTAMP (6), 
	"EVENT_TIME" TIMESTAMP (6), 
	"LOG_LEVEL" VARCHAR2(10 BYTE), 
	"APPLICATION" VARCHAR2(50 BYTE), 
	"FLOW_NAME" VARCHAR2(50 BYTE), 
	"NODE_NAME" VARCHAR2(50 BYTE), 
    "TASK_ID" VARCHAR2(20 BYTE), 
	"SRN" VARCHAR2(50 BYTE), 
	"MESSAGE" VARCHAR2(2000 BYTE), 
	"MSGUID" VARCHAR2(50 BYTE), 
	"PID" VARCHAR2(20 BYTE), 
	"INTEGRATION_NODE_NAME" VARCHAR2(20 BYTE), 	
	"CLIENT_IP" VARCHAR2(20 BYTE), 
	"SERVER_IP" VARCHAR2(20 BYTE), 
	"STATUS_CODE" VARCHAR2(50 BYTE), 
    "MESSAGE_DATA" CLOB);
	 
--------------------------------------------New View for all tasks------------------------------------------------------------------------------------------------------------------------
 
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "FIPORTAL"."TANFEETH_ALL_TASKS_VIEW" ("TASK_ID", "TASK_REQUEST_METADATA_ID", "SRN", "FI_ID", "TASK_CREATED_DATE_TIME", "ASSIGNED_DATE_TIME", "DUE_DATE_TIME", "ASSIGNED_TO", "ASSIGNED_BY", "STATUS_ID", "SUB_STATUS_ID", "IS_BULK_PROCESSED", "APPROVED_DATE_TIME", "REQUEST_METADATA_ID", "SLA_MINUTES", "EXECUTED_BY", "MAIN_SERVICE_TYPE_CODE", "SUB_SERVICE_TYPE_CODE", "TASK_CLOSING_DATE_TIME3", "TASK_CLOSING_DATE_TIME4", "TASK_CLOSING_DATE_TIME5", "ENTITY_GOV_ID", "TYPE_CODE") AS 
  SELECT
        fiportal.workflow_task.id AS task_id,
        fiportal.workflow_task.request_metadata_id AS task_request_metadata_id,
        tanfeeth.agcy_srvc_reqst.srvc_reqst_cor_rn,
        fiportal.workflow_task.fi_id,
        fiportal.workflow_task.created_date_time AS TASK_CREATED_DATE_TIME,
        fiportal.workflow_task.assigned_date_time,
        fiportal.workflow_task.due_date_time,
        fiportal.workflow_task.assigned_to,
        fiportal.workflow_task.assigned_by,
        fiportal.workflow_task.status_id,
        fiportal.workflow_task.sub_status_id,
        fiportal.workflow_task.is_bulk_processed,
        fiportal.workflow_task.approved_date_time,
        fiportal.workflow_task.request_metadata_id AS request_metadata_id,
		fiportal.WORKFLOW_TASK.SLA_MINUTES, -- From TASK_INBOX_view
		fiportal.WORKFLOW_TASK.EXECUTED_BY, -- From TASK_INBOX_view
        tanfeeth.agcy_srvc_reqst.PROCESS_TYPE_CD AS main_service_type_code,
        tanfeeth.agcy_srvc_reqst.SRVC_TYPE_CD,
        FIPORTAL.WORKFLOW_TASK.OFFICER_EXECUTED_DATE AS TASK_CLOSING_DATE_TIME3,-- From TASK_INBOX_view
        FIPORTAL.WORKFLOW_TASK.LAST_RETURN_DATE_TIME AS TASK_CLOSING_DATE_TIME4, -- From TASK_INBOX_view
        --FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID, 6) AS TASK_CLOSING_DATE_TIME6, -- From TASK_INBOX_view
        --FIPORTAL.GET_EXECUTED_BY(WORKFLOW_TASK.ID, 3) AS TASK_CLOSED_BY3, -- From TASK_INBOX_view
        FIPORTAL.WORKFLOW_TASK.MODIFICATION_DATE AS TASK_CLOSING_DATE_TIME5, -- From TASK_INBOX_view //APPROVED_DATE_TIME
        FIPORTAL.GET_LOOKUP_NAME_AR(35,tanfeeth.agcy_srvc_reqst.REQSTR_CD) AS ENTITY_GOV_ID,
      --  tanfeeth.involved_party.agcy_srvc_reqst_id AS request_metadata_id,
        tanfeeth.agcy_srvc_reqst.inqrd_party_cd AS type_code
    FROM
        fiportal.workflow_task,
        tanfeeth.agcy_srvc_reqst
    WHERE
        tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = fiportal.workflow_task.request_metadata_id(+);
        
         
--------------------------------------------------------------------------Add new function to reterive GOV entity name by code -------------------------------------
create or replace FUNCTION "GET_LOOKUP_NAME_AR" (LOV_PARENT VARCHAR2, CODE VARCHAR2)
RETURN VARCHAR2 IS ENTITY_NAME VARCHAR2(1000);
BEGIN
SELECT ATTRIBUTE_1 INTO ENTITY_NAME FROM WCR.LOOKUP_VALUES WHERE LOV_PARENT = LOV_PARENT AND LOV_CODE=CODE AND ROWNUM=1;
RETURN (ENTITY_NAME);
END;
--------------------------------------------------------------------------NEW GETALLATSKS Script------------------------------------------------------------------------------------------------------
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
        fiportal.workflow_task.sla_minutes, -- From TASK_INBOX_view
        fiportal.workflow_task.executed_by, -- From TASK_INBOX_view
        fiportal.get_lookup_name_ar(15,tanfeeth.agcy_srvc_reqst.process_type_cd) AS main_service_type_name,
        fiportal.get_lookup_name_ar(32,tanfeeth.agcy_srvc_reqst.bus_srvc_cd) AS sub_service_type_name,
        tanfeeth.agcy_srvc_reqst.process_type_cd AS main_service_type_code,
        tanfeeth.agcy_srvc_reqst.bus_srvc_cd AS sub_service_type_code,
        fiportal.workflow_task.officer_executed_date AS task_closing_date_time3,-- From TASK_INBOX_view
        fiportal.workflow_task.last_return_date_time AS task_closing_date_time4, -- From TASK_INBOX_view
        --FIPORTAL.GET_EVENT_DATE_TIME(WORKFLOW_TASK.ID, 6) AS TASK_CLOSING_DATE_TIME6, -- From TASK_INBOX_view
        --FIPORTAL.GET_EXECUTED_BY(WORKFLOW_TASK.ID, 3) AS TASK_CLOSED_BY3, -- From TASK_INBOX_view
        fiportal.workflow_task.modification_date AS task_closing_date_time5, -- From TASK_INBOX_view //APPROVED_DATE_TIME
        fiportal.get_lookup_name_ar(35,tanfeeth.agcy_srvc_reqst.reqstr_cd) AS entity_gov_id,
      --  tanfeeth.involved_party.agcy_srvc_reqst_id AS request_metadata_id,
        tanfeeth.agcy_srvc_reqst.inqrd_party_cd AS type_code
    FROM
        fiportal.workflow_task,
        tanfeeth.agcy_srvc_reqst
    WHERE
        tanfeeth.agcy_srvc_reqst.agcy_srvc_reqst_id = fiportal.workflow_task.request_metadata_id (+);
	 
	  

		