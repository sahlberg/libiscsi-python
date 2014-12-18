/*
   Copyright (C) 2014 by Ronnie Sahlberg <ronniesahlberg@gmail.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation; either version 2.1 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

%module libiscsi

%{
#include <iscsi/iscsi.h>
#include <iscsi/scsi-lowlevel.h>
%}

%include <stdint.i>
%include <cpointer.i>
/*
%pointer_functions(struct nfsfh *, NFSFileHandle)
%pointer_functions(uint64_t, uint64_t_ptr)
*/
%apply char*  {unsigned char*};

struct iscsi_context;
struct sockaddr;

extern int iscsi_get_fd(struct iscsi_context *iscsi);
extern int iscsi_which_events(struct iscsi_context *iscsi);
extern int iscsi_service(struct iscsi_context *iscsi, int revents);
extern int iscsi_queue_length(struct iscsi_context *iscsi);
extern int iscsi_set_timeout(struct iscsi_context *iscsi, int timeout);
extern int iscsi_set_tcp_keepalive(struct iscsi_context *iscsi, int idle, int count, int interval);

#define MAX_STRING_SIZE (255)

struct iscsi_url {
       char portal[MAX_STRING_SIZE + 1];
       char target[MAX_STRING_SIZE + 1];
       char user[MAX_STRING_SIZE + 1];
       char passwd[MAX_STRING_SIZE + 1];
       int lun;
       struct iscsi_context *iscsi;
};

enum iscsi_immediate_data {
	ISCSI_IMMEDIATE_DATA_NO  = 0,
	ISCSI_IMMEDIATE_DATA_YES = 1
};

extern int iscsi_set_immediate_data(struct iscsi_context *iscsi, enum iscsi_immediate_data immediate_data);

enum iscsi_initial_r2t {
	ISCSI_INITIAL_R2T_NO  = 0,
	ISCSI_INITIAL_R2T_YES = 1
};

extern int iscsi_set_initial_r2t(struct iscsi_context *iscsi, enum iscsi_initial_r2t initial_r2t);

extern struct iscsi_url *iscsi_parse_full_url(struct iscsi_context *iscsi, const char *url);
extern void iscsi_destroy_url(struct iscsi_url *iscsi_url);

extern struct iscsi_url *
iscsi_parse_portal_url(struct iscsi_context *iscsi, const char *url);

extern const char *iscsi_get_error(struct iscsi_context *iscsi);

extern struct iscsi_context *iscsi_create_context(const char *initiator_name);

extern int iscsi_destroy_context(struct iscsi_context *iscsi);

extern int iscsi_set_alias(struct iscsi_context *iscsi, const char *alias);

extern int iscsi_set_targetname(struct iscsi_context *iscsi, const char *targetname);

extern const char *iscsi_get_target_address(struct iscsi_context *iscsi);

enum iscsi_session_type {
	ISCSI_SESSION_DISCOVERY = 1,
	ISCSI_SESSION_NORMAL    = 2
};

extern int iscsi_set_session_type(struct iscsi_context *iscsi, enum iscsi_session_type session_type);

enum iscsi_header_digest {
	ISCSI_HEADER_DIGEST_NONE        = 0,
	ISCSI_HEADER_DIGEST_NONE_CRC32C = 1,
	ISCSI_HEADER_DIGEST_CRC32C_NONE = 2,
	ISCSI_HEADER_DIGEST_CRC32C      = 3,
	ISCSI_HEADER_DIGEST_LAST        = ISCSI_HEADER_DIGEST_CRC32C
};

extern int iscsi_set_header_digest(struct iscsi_context *iscsi, enum iscsi_header_digest header_digest);

extern int iscsi_set_initiator_username_pwd(struct iscsi_context *iscsi, const char *user, const char *passwd);

extern int iscsi_is_logged_in(struct iscsi_context *iscsi);


enum scsi_status {
	SCSI_STATUS_GOOD                 = 0,
	SCSI_STATUS_CHECK_CONDITION      = 2,
	SCSI_STATUS_CONDITION_MET        = 4,
	SCSI_STATUS_BUSY                 = 8,
	SCSI_STATUS_RESERVATION_CONFLICT = 0x18,
	SCSI_STATUS_TASK_SET_FULL        = 0x28,
	SCSI_STATUS_ACA_ACTIVE           = 0x30,
	SCSI_STATUS_TASK_ABORTED         = 0x40,
	SCSI_STATUS_REDIRECT             = 0x101,
	SCSI_STATUS_CANCELLED            = 0x0f000000,
	SCSI_STATUS_ERROR                = 0x0f000001,
	SCSI_STATUS_TIMEOUT              = 0x0f000002
};

extern int iscsi_connect_sync(struct iscsi_context *iscsi, const char *portal);

extern int iscsi_full_connect_sync(struct iscsi_context *iscsi, const char *portal, int lun);

extern int iscsi_disconnect(struct iscsi_context *iscsi);

extern int iscsi_reconnect(struct iscsi_context *iscsi);

extern int iscsi_login_sync(struct iscsi_context *iscsi);

extern int iscsi_logout_sync(struct iscsi_context *iscsi);

struct iscsi_target_portal {
       struct iscsi_target_portal *next;
       const char *portal;
};

struct iscsi_discovery_address {
       struct iscsi_discovery_address *next;
       const char *target_name;
       struct iscsi_target_portal *portals;
};

struct scsi_iovector;
struct scsi_allocated_memory;

struct scsi_task;

enum iscsi_task_mgmt_funcs {
     ISCSI_TM_ABORT_TASK        = 0x01,
     ISCSI_TM_ABORT_TASK_SET    = 0x02,
     ISCSI_TM_CLEAR_ACA         = 0x03,
     ISCSI_TM_CLEAR_TASK_SET    = 0x04,
     ISCSI_TM_LUN_RESET         = 0x05,
     ISCSI_TM_TARGET_WARM_RESET = 0x06,
     ISCSI_TM_TARGET_COLD_RESET = 0x07,
     ISCSI_TM_TASK_REASSIGN     = 0x08
};

extern int
iscsi_task_mgmt_sync(struct iscsi_context *iscsi,
		     int lun, enum iscsi_task_mgmt_funcs function,
		     uint32_t ritt, uint32_t rcmdscn);

extern int
iscsi_task_mgmt_abort_task_sync(struct iscsi_context *iscsi, struct scsi_task *task);

extern int
iscsi_task_mgmt_abort_task_set_sync(struct iscsi_context *iscsi, uint32_t lun);

extern int
iscsi_task_mgmt_lun_reset_sync(struct iscsi_context *iscsi, uint32_t lun);

extern int
iscsi_task_mgmt_target_warm_reset_sync(struct iscsi_context *iscsi);

extern int
iscsi_task_mgmt_target_cold_reset_sync(struct iscsi_context *iscsi);

struct iscsi_data {
       size_t size;
       unsigned char *data;
};

extern int
iscsi_set_isid_oui(struct iscsi_context *iscsi, uint32_t oui, uint32_t qualifier);
extern int
iscsi_set_isid_en(struct iscsi_context *iscsi, uint32_t en, uint32_t qualifier);
extern int
iscsi_set_isid_random(struct iscsi_context *iscsi, uint32_t rnd, uint32_t qualifier);
extern int
iscsi_set_isid_reserved(struct iscsi_context *iscsi);

struct unmap_list {
       uint64_t	  lba;
       uint32_t	  num;
};

extern struct scsi_task *
iscsi_scsi_command_sync(struct iscsi_context *iscsi, int lun,
			struct scsi_task *task, struct iscsi_data *data);

extern struct scsi_task *
iscsi_reportluns_sync(struct iscsi_context *iscsi, int report_type,
		      int alloc_len);

extern struct scsi_task *
iscsi_testunitready_sync(struct iscsi_context *iscsi, int lun);

extern struct scsi_task *
iscsi_inquiry_sync(struct iscsi_context *iscsi, int lun, int evpd,
		   int page_code, int maxsize);

extern struct scsi_task *
iscsi_read6_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		  uint32_t datalen, int blocksize);

extern struct scsi_task *
iscsi_read10_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		  uint32_t datalen, int blocksize,
		  int rdprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_write10_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_writeverify10_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int bytchk, int group_number);

extern struct scsi_task *
iscsi_read12_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		  uint32_t datalen, int blocksize,
		  int rdprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_write12_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_writeverify12_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int bytchk, int group_number);

extern struct scsi_task *
iscsi_read16_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		  uint32_t datalen, int blocksize,
		  int rdprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_write16_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_orwrite_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_startstopunit_sync(struct iscsi_context *iscsi, int lun,
			 int immed, int pcm, int pc,
			 int no_flush, int loej, int start);

extern struct scsi_task *
iscsi_preventallow_sync(struct iscsi_context *iscsi, int lun,
			int prevent);

extern struct scsi_task *
iscsi_compareandwrite_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int fua, int fua_nv, int group_number);

extern struct scsi_task *
iscsi_writeverify16_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		   unsigned char *data, uint32_t datalen, int blocksize,
		   int wrprotect, int dpo, int bytchk, int group_number);

extern struct scsi_task *
iscsi_readcapacity10_sync(struct iscsi_context *iscsi, int lun, int lba,
			  int pmi);

extern struct scsi_task *
iscsi_readcapacity16_sync(struct iscsi_context *iscsi, int lun);

extern struct scsi_task *
iscsi_get_lba_status_sync(struct iscsi_context *iscsi, int lun, uint64_t starting_lba, uint32_t alloc_len);

extern struct scsi_task *
iscsi_sanitize_sync(struct iscsi_context *iscsi, int lun,
		    int immed, int ause, int sa, int param_len,
		    struct iscsi_data *data);
extern struct scsi_task *
iscsi_sanitize_block_erase_sync(struct iscsi_context *iscsi, int lun,
		    int immed, int ause);
extern struct scsi_task *
iscsi_sanitize_crypto_erase_sync(struct iscsi_context *iscsi, int lun,
		    int immed, int ause);
extern struct scsi_task *
iscsi_sanitize_exit_failure_mode_sync(struct iscsi_context *iscsi, int lun,
		    int immed, int ause);
extern struct scsi_task *
iscsi_synchronizecache10_sync(struct iscsi_context *iscsi, int lun, int lba,
			      int num_blocks, int syncnv, int immed);

extern struct scsi_task *
iscsi_synchronizecache16_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
			      uint32_t num_blocks, int syncnv, int immed);

extern struct scsi_task *
iscsi_prefetch10_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		      int num_blocks, int immed, int group);

extern struct scsi_task *
iscsi_prefetch16_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		      int num_blocks, int immed, int group);

extern struct scsi_task *
iscsi_verify10_sync(struct iscsi_context *iscsi, int lun,
		    unsigned char *data, uint32_t datalen, uint32_t lba,
		    int vprotect, int dpo, int bytchk,
		    int blocksize);

extern struct scsi_task *
iscsi_verify12_sync(struct iscsi_context *iscsi, int lun,
		    unsigned char *data, uint32_t datalen, uint32_t lba,
		    int vprotect, int dpo, int bytchk,
		    int blocksize);

extern struct scsi_task *
iscsi_verify16_sync(struct iscsi_context *iscsi, int lun,
		    unsigned char *data, uint32_t datalen, uint64_t lba,
		    int vprotect, int dpo, int bytchk,
		    int blocksize);

extern struct scsi_task *
iscsi_writesame10_sync(struct iscsi_context *iscsi, int lun, uint32_t lba,
		       unsigned char *data, uint32_t datalen,
		       uint16_t num_blocks,
		       int anchor, int unmap, int wrprotect, int group);

extern struct scsi_task *
iscsi_writesame16_sync(struct iscsi_context *iscsi, int lun, uint64_t lba,
		       unsigned char *data, uint32_t datalen,
		       uint32_t num_blocks,
		       int anchor, int unmap, int wrprotect, int group);

extern struct scsi_task *
iscsi_persistent_reserve_in_sync(struct iscsi_context *iscsi, int lun,
				 int sa, uint16_t xferlen);

extern struct scsi_task *
iscsi_persistent_reserve_out_sync(struct iscsi_context *iscsi, int lun,
				  int sa, int scope, int type, void *params);

extern struct scsi_task *
iscsi_unmap_sync(struct iscsi_context *iscsi, int lun, int anchor, int group,
		 struct unmap_list *list, int list_len);

extern struct scsi_task *
iscsi_readtoc_sync(struct iscsi_context *iscsi, int lun, int msf,
		   int format, int track_session, int maxsize);

extern struct scsi_task *
iscsi_reserve6_sync(struct iscsi_context *iscsi, int lun);

extern struct scsi_task *
iscsi_release6_sync(struct iscsi_context *iscsi, int lun);

extern struct scsi_task *
iscsi_report_supported_opcodes_sync(struct iscsi_context *iscsi, int lun,
				    int rctd, int options,
				    int opcode, int sa,
				    uint32_t alloc_len);
extern void
iscsi_set_tcp_user_timeout(struct iscsi_context *iscsi, int timeout_ms);


extern void
iscsi_set_tcp_keepidle(struct iscsi_context *iscsi, int value);

extern void
iscsi_set_tcp_keepcnt(struct iscsi_context *iscsi, int value);

extern void
iscsi_set_tcp_keepintvl(struct iscsi_context *iscsi, int value);

extern void
iscsi_set_tcp_syncnt(struct iscsi_context *iscsi, int value);

extern void
iscsi_set_bind_interfaces(struct iscsi_context *iscsi, char * interfaces);

extern void
iscsi_set_reconnect_max_retries(struct iscsi_context *iscsi, int count);



enum scsi_opcode {
	SCSI_OPCODE_TESTUNITREADY      = 0x00,
	SCSI_OPCODE_READ6              = 0x08,
	SCSI_OPCODE_INQUIRY            = 0x12,
	SCSI_OPCODE_MODESELECT6        = 0x15,
	SCSI_OPCODE_RESERVE6           = 0x16,
	SCSI_OPCODE_RELEASE6           = 0x17,
	SCSI_OPCODE_MODESENSE6         = 0x1a,
	SCSI_OPCODE_STARTSTOPUNIT      = 0x1b,
	SCSI_OPCODE_PREVENTALLOW       = 0x1e,
	SCSI_OPCODE_READCAPACITY10     = 0x25,
	SCSI_OPCODE_READ10             = 0x28,
	SCSI_OPCODE_WRITE10            = 0x2A,
	SCSI_OPCODE_WRITE_VERIFY10     = 0x2E,
	SCSI_OPCODE_VERIFY10           = 0x2F,
	SCSI_OPCODE_PREFETCH10         = 0x34,
	SCSI_OPCODE_SYNCHRONIZECACHE10 = 0x35,
	SCSI_OPCODE_WRITE_SAME10       = 0x41,
	SCSI_OPCODE_UNMAP              = 0x42,
	SCSI_OPCODE_READTOC            = 0x43,
	SCSI_OPCODE_SANITIZE           = 0x48,
	SCSI_OPCODE_MODESELECT10       = 0x55,
	SCSI_OPCODE_MODESENSE10        = 0x5A,
	SCSI_OPCODE_PERSISTENT_RESERVE_IN  = 0x5E,
	SCSI_OPCODE_PERSISTENT_RESERVE_OUT = 0x5F,
	SCSI_OPCODE_READ16             = 0x88,
	SCSI_OPCODE_COMPARE_AND_WRITE  = 0x89,
	SCSI_OPCODE_WRITE16            = 0x8A,
	SCSI_OPCODE_ORWRITE            = 0x8B,
	SCSI_OPCODE_WRITE_VERIFY16     = 0x8E,
	SCSI_OPCODE_VERIFY16           = 0x8F,
	SCSI_OPCODE_PREFETCH16         = 0x90,
	SCSI_OPCODE_SYNCHRONIZECACHE16 = 0x91,
	SCSI_OPCODE_WRITE_SAME16       = 0x93,
	SCSI_OPCODE_SERVICE_ACTION_IN  = 0x9E,
	SCSI_OPCODE_REPORTLUNS         = 0xA0,
	SCSI_OPCODE_MAINTENANCE_IN     = 0xA3,
	SCSI_OPCODE_READ12             = 0xA8,
	SCSI_OPCODE_WRITE12            = 0xAA,
	SCSI_OPCODE_WRITE_VERIFY12     = 0xAE,
	SCSI_OPCODE_VERIFY12           = 0xAF
};

enum scsi_persistent_in_sa {
	SCSI_PERSISTENT_RESERVE_READ_KEYS		= 0,
	SCSI_PERSISTENT_RESERVE_READ_RESERVATION	= 1,
	SCSI_PERSISTENT_RESERVE_REPORT_CAPABILITIES	= 2,
	SCSI_PERSISTENT_RESERVE_READ_FULL_STATUS	= 3
};

enum scsi_service_action_in {
	SCSI_READCAPACITY16            = 0x10,
	SCSI_GET_LBA_STATUS            = 0x12
};

enum scsi_persistent_out_sa {
	SCSI_PERSISTENT_RESERVE_REGISTER		= 0,
	SCSI_PERSISTENT_RESERVE_RESERVE			= 1,
	SCSI_PERSISTENT_RESERVE_RELEASE			= 2,
	SCSI_PERSISTENT_RESERVE_CLEAR			= 3,
	SCSI_PERSISTENT_RESERVE_PREEMPT			= 4,
	SCSI_PERSISTENT_RESERVE_PREEMPT_AND_ABORT	= 5,
	SCSI_PERSISTENT_RESERVE_REGISTER_AND_IGNORE_EXISTING_KEY = 6,
	SCSI_PERSISTENT_RESERVE_REGISTER_AND_MOVE	= 7
};

enum scsi_persistent_out_scope {
	SCSI_PERSISTENT_RESERVE_SCOPE_LU		= 0
};

enum scsi_persistent_out_type {
	SCSI_PERSISTENT_RESERVE_TYPE_WRITE_EXCLUSIVE			= 1,
	SCSI_PERSISTENT_RESERVE_TYPE_EXCLUSIVE_ACCESS			= 3,
	SCSI_PERSISTENT_RESERVE_TYPE_WRITE_EXCLUSIVE_REGISTRANTS_ONLY	= 5,
	SCSI_PERSISTENT_RESERVE_TYPE_EXCLUSIVE_ACCESS_REGISTRANTS_ONLY	= 6,
	SCSI_PERSISTENT_RESERVE_TYPE_WRITE_EXCLUSIVE_ALL_REGISTRANTS	= 7,
	SCSI_PERSISTENT_RESERVE_TYPE_EXCLUSIVE_ACCESS_ALL_REGISTRANTS	= 8
};

struct scsi_persistent_reserve_out_basic {
       uint64_t	reservation_key;
       uint64_t	service_action_reservation_key;
       uint8_t  spec_i_pt;
       uint8_t  all_tg_pt;
       uint8_t  aptpl;
};

enum scsi_maintenance_in {
	SCSI_REPORT_SUPPORTED_OP_CODES = 0x0c
};

enum scsi_op_code_reporting_options {
	SCSI_REPORT_SUPPORTING_OPS_ALL       = 0x00,
	SCSI_REPORT_SUPPORTING_OPCODE        = 0x01,
	SCSI_REPORT_SUPPORTING_SERVICEACTION = 0x02
};

/* sense keys */
enum scsi_sense_key {
	SCSI_SENSE_NO_SENSE            = 0x00,
	SCSI_SENSE_RECOVERED_ERROR     = 0x01,
	SCSI_SENSE_NOT_READY           = 0x02,
	SCSI_SENSE_MEDIUM_ERROR        = 0x03,
	SCSI_SENSE_HARDWARE_ERROR      = 0x04,
	SCSI_SENSE_ILLEGAL_REQUEST     = 0x05,
	SCSI_SENSE_UNIT_ATTENTION      = 0x06,
	SCSI_SENSE_DATA_PROTECTION     = 0x07,
	SCSI_SENSE_BLANK_CHECK         = 0x08,
	SCSI_SENSE_VENDOR_SPECIFIC     = 0x09,
	SCSI_SENSE_COPY_ABORTED        = 0x0a,
	SCSI_SENSE_COMMAND_ABORTED     = 0x0b,
	SCSI_SENSE_OBSOLETE_ERROR_CODE = 0x0c,
	SCSI_SENSE_OVERFLOW_COMMAND    = 0x0d,
	SCSI_SENSE_MISCOMPARE          = 0x0e
};

extern const char *scsi_sense_key_str(int key);

/* ascq */
#define SCSI_SENSE_ASCQ_SANITIZE_IN_PROGRESS               0x041b
#define SCSI_SENSE_ASCQ_WRITE_AFTER_SANITIZE_REQUIRED      0x1115
#define SCSI_SENSE_ASCQ_PARAMETER_LIST_LENGTH_ERROR        0x1a00
#define SCSI_SENSE_ASCQ_MISCOMPARE_DURING_VERIFY           0x1d00
#define SCSI_SENSE_ASCQ_MISCOMPARE_VERIFY_OF_UNMAPPED_LBA  0x1d01
#define SCSI_SENSE_ASCQ_INVALID_OPERATION_CODE             0x2000
#define SCSI_SENSE_ASCQ_LBA_OUT_OF_RANGE                   0x2100
#define SCSI_SENSE_ASCQ_INVALID_FIELD_IN_CDB               0x2400
#define SCSI_SENSE_ASCQ_LOGICAL_UNIT_NOT_SUPPORTED         0x2500
#define SCSI_SENSE_ASCQ_INVALID_FIELD_IN_PARAMETER_LIST    0x2600
#define SCSI_SENSE_ASCQ_WRITE_PROTECTED                    0x2700
#define SCSI_SENSE_ASCQ_BUS_RESET                          0x2900
#define SCSI_SENSE_ASCQ_POWER_ON_OCCURED                   0x2901
#define SCSI_SENSE_ASCQ_SCSI_BUS_RESET_OCCURED             0x2902
#define SCSI_SENSE_ASCQ_BUS_DEVICE_RESET_FUNCTION_OCCURED  0x2903
#define SCSI_SENSE_ASCQ_DEVICE_INTERNAL_RESET              0x2904
#define SCSI_SENSE_ASCQ_TRANSCEIVER_MODE_CHANGED_TO_SINGLE_ENDED 0x2905
#define SCSI_SENSE_ASCQ_TRANSCEIVER_MODE_CHANGED_TO_LVD    0x2906
#define SCSI_SENSE_ASCQ_NEXUS_LOSS                         0x2907
#define SCSI_SENSE_ASCQ_MODE_PARAMETERS_CHANGED            0x2a01
#define SCSI_SENSE_ASCQ_CAPACITY_DATA_HAS_CHANGED          0x2a09
#define SCSI_SENSE_ASCQ_THIN_PROVISION_SOFT_THRES_REACHED  0x3807
#define SCSI_SENSE_ASCQ_MEDIUM_NOT_PRESENT                 0x3a00
#define SCSI_SENSE_ASCQ_MEDIUM_NOT_PRESENT_TRAY_CLOSED     0x3a01
#define SCSI_SENSE_ASCQ_MEDIUM_NOT_PRESENT_TRAY_OPEN       0x3a02
#define SCSI_SENSE_ASCQ_INQUIRY_DATA_HAS_CHANGED           0x3f03
#define SCSI_SENSE_ASCQ_INTERNAL_TARGET_FAILURE            0x4400
#define SCSI_SENSE_ASCQ_MEDIUM_LOAD_OR_EJECT_FAILED        0x5300
#define SCSI_SENSE_ASCQ_MEDIUM_REMOVAL_PREVENTED           0x5302
#define SCSI_SENSE_ASCQ_INVALID_FIELD_IN_INFORMATION_UNIT  0x0e03

extern const char *scsi_sense_ascq_str(int ascq);

extern const char *scsi_pr_type_str(enum scsi_persistent_out_type pr_type);

enum scsi_xfer_dir {
	SCSI_XFER_NONE  = 0,
	SCSI_XFER_READ  = 1,
	SCSI_XFER_WRITE = 2
};

struct scsi_sense {
	unsigned char       error_type;
	enum scsi_sense_key key;
	int                 ascq;
};

struct scsi_data {
	int            size;
	unsigned char *data;
};

enum scsi_residual {
	SCSI_RESIDUAL_NO_RESIDUAL = 0,
	SCSI_RESIDUAL_UNDERFLOW,
	SCSI_RESIDUAL_OVERFLOW
};

extern struct scsi_task *scsi_create_task(int cdb_size, unsigned char *cdb, int xfer_dir, int expxferlen);

extern void scsi_free_scsi_task(struct scsi_task *task);

extern void scsi_set_task_private_ptr(struct scsi_task *task, void *ptr);
extern void *scsi_get_task_private_ptr(struct scsi_task *task);

/*
 * TESTUNITREADY
 */
extern struct scsi_task *scsi_cdb_testunitready(void);

/*
 * SANITIZE
 */
#define SCSI_SANITIZE_OVERWRITE		0x01
#define SCSI_SANITIZE_BLOCK_ERASE	0x02
#define SCSI_SANITIZE_CRYPTO_ERASE	0x03
#define SCSI_SANITIZE_EXIT_FAILURE_MODE	0x1f

extern struct scsi_task *scsi_cdb_sanitize(int immed, int ause, int sa,
       int param_len);


/*
 * REPORTLUNS
 */
#define SCSI_REPORTLUNS_REPORT_ALL_LUNS				0x00
#define SCSI_REPORTLUNS_REPORT_WELL_KNOWN_ONLY			0x01
#define SCSI_REPORTLUNS_REPORT_AVAILABLE_LUNS_ONLY		0x02

struct scsi_reportluns_list {
	uint32_t num;
	uint16_t luns[0];
};

extern struct scsi_task *scsi_reportluns_cdb(int report_type, int alloc_len);

/*
 * RESERVE6
 */
extern struct scsi_task *scsi_cdb_reserve6(void);
/*
 * RELEASE6
 */
extern struct scsi_task *scsi_cdb_release6(void);

/*
 * READCAPACITY10
 */
struct scsi_readcapacity10 {
	uint32_t lba;
	uint32_t block_size;
};
extern struct scsi_task *scsi_cdb_readcapacity10(int lba, int pmi);


/*
 * INQUIRY
 */
enum scsi_inquiry_peripheral_qualifier {
	SCSI_INQUIRY_PERIPHERAL_QUALIFIER_CONNECTED     = 0x00,
	SCSI_INQUIRY_PERIPHERAL_QUALIFIER_DISCONNECTED  = 0x01,
	SCSI_INQUIRY_PERIPHERAL_QUALIFIER_NOT_SUPPORTED = 0x03
};

const char *scsi_devqualifier_to_str(
			enum scsi_inquiry_peripheral_qualifier qualifier);

enum scsi_inquiry_peripheral_device_type {
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_DIRECT_ACCESS            = 0x00,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_SEQUENTIAL_ACCESS        = 0x01,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_PRINTER                  = 0x02,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_PROCESSOR                = 0x03,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_WRITE_ONCE               = 0x04,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_MMC                      = 0x05,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_SCANNER                  = 0x06,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_OPTICAL_MEMORY           = 0x07,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_MEDIA_CHANGER            = 0x08,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_COMMUNICATIONS           = 0x09,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_STORAGE_ARRAY_CONTROLLER = 0x0c,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_ENCLOSURE_SERVICES       = 0x0d,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_SIMPLIFIED_DIRECT_ACCESS = 0x0e,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_OPTICAL_CARD_READER      = 0x0f,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_BRIDGE_CONTROLLER        = 0x10,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_OSD                      = 0x11,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_AUTOMATION               = 0x12,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_SEQURITY_MANAGER         = 0x13,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_WELL_KNOWN_LUN           = 0x1e,
	SCSI_INQUIRY_PERIPHERAL_DEVICE_TYPE_UNKNOWN                  = 0x1f
};

extern const char *scsi_devtype_to_str(enum scsi_inquiry_peripheral_device_type type);

enum scsi_version {
	SCSI_VERSION_SPC  = 0x03,
	SCSI_VERSION_SPC2 = 0x04,
	SCSI_VERSION_SPC3 = 0x05
};

extern const char *scsi_version_to_str(enum scsi_version version);

enum scsi_version_descriptor {
	SCSI_VERSION_DESCRIPTOR_ISCSI				= 0x0960,
	SCSI_VERSION_DESCRIPTOR_SBC				= 0x0180,
	SCSI_VERSION_DESCRIPTOR_SBC_ANSI_INCITS_306_1998	= 0x019C,
	SCSI_VERSION_DESCRIPTOR_SBC_T10_0996_D_R08C		= 0x019B,
	SCSI_VERSION_DESCRIPTOR_SBC_2				= 0x0320,
	SCSI_VERSION_DESCRIPTOR_SBC_2_ISO_IEC_14776_322		= 0x033E,
	SCSI_VERSION_DESCRIPTOR_SBC_2_ANSI_INCITS_405_2005	= 0x033D,
	SCSI_VERSION_DESCRIPTOR_SBC_2_T10_1417_D_R16		= 0x033B,
	SCSI_VERSION_DESCRIPTOR_SBC_2_T10_1417_D_R5A		= 0x0322,
	SCSI_VERSION_DESCRIPTOR_SBC_2_T10_1417_D_R15		= 0x0324,
	SCSI_VERSION_DESCRIPTOR_SBC_3				= 0x04C0,
	SCSI_VERSION_DESCRIPTOR_SPC				= 0x0120,
	SCSI_VERSION_DESCRIPTOR_SPC_ANSI_INCITS_301_1997	= 0x013C,
	SCSI_VERSION_DESCRIPTOR_SPC_T10_0995_D_R11A		= 0x013B,
	SCSI_VERSION_DESCRIPTOR_SPC_2				= 0x0260,
	SCSI_VERSION_DESCRIPTOR_SPC_2_ISO_IEC_14776_452		= 0x0278,
	SCSI_VERSION_DESCRIPTOR_SPC_2_ANSI_INCITS_351_2001	= 0x0277,
	SCSI_VERSION_DESCRIPTOR_SPC_2_T10_1236_D_R20		= 0x0276,
	SCSI_VERSION_DESCRIPTOR_SPC_2_T10_1236_D_R12		= 0x0267,
	SCSI_VERSION_DESCRIPTOR_SPC_2_T10_1236_D_R18		= 0x0269,
	SCSI_VERSION_DESCRIPTOR_SPC_2_T10_1236_D_R19		= 0x0275,
	SCSI_VERSION_DESCRIPTOR_SPC_3				= 0x0300,
	SCSI_VERSION_DESCRIPTOR_SPC_3_ISO_IEC_14776_453		= 0x0316,
	SCSI_VERSION_DESCRIPTOR_SPC_3_ANSI_INCITS_408_2005	= 0x0314,
	SCSI_VERSION_DESCRIPTOR_SPC_3_T10_1416_D_R7		= 0x0301,
	SCSI_VERSION_DESCRIPTOR_SPC_3_T10_1416_D_R21		= 0x0307,
	SCSI_VERSION_DESCRIPTOR_SPC_3_T10_1416_D_R22		= 0x030F,
	SCSI_VERSION_DESCRIPTOR_SPC_3_T10_1416_D_R23		= 0x0312,
	SCSI_VERSION_DESCRIPTOR_SPC_4				= 0x0460,
	SCSI_VERSION_DESCRIPTOR_SPC_4_T10_1731_D_R16		= 0x0461,
	SCSI_VERSION_DESCRIPTOR_SPC_4_T10_1731_D_R18		= 0x0462,
	SCSI_VERSION_DESCRIPTOR_SPC_4_T10_1731_D_R23		= 0x0463,
	SCSI_VERSION_DESCRIPTOR_SSC				= 0x0200,
	SCSI_VERSION_DESCRIPTOR_UAS_T10_2095D_R04		= 0x1747
};

extern const char *scsi_version_descriptor_to_str(enum scsi_version_descriptor version_descriptor);

enum scsi_inquiry_tpgs {
	SCSI_INQUIRY_TPGS_NO_SUPPORT            = 0x00,
	SCSI_INQUIRY_TPGS_IMPLICIT              = 0x01,
	SCSI_INQUIRY_TPGS_EXPLICIT              = 0x02,
	SCSI_INQUIRY_TPGS_IMPLICIT_AND_EXPLICIT = 0x03
};

/* fix typos, leave old names for backward compatibility */
#define periperal_qualifier qualifier
#define periperal_device_type device_type

struct scsi_inquiry_standard {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	int rmb;
	int version;
	int normaca;
	int hisup;
	int response_data_format;

	int additional_length;

	int sccs;
	int acc;
	int tpgs;
	int threepc;
	int protect;

	int encserv;
	int multip;
	int addr16;
	int wbus16;
	int sync;
	int cmdque;

	int clocking;
	int qas;
	int ius;

	char vendor_identification[8+1];
	char product_identification[16+1];
	char product_revision_level[4+1];

	uint16_t version_descriptor[8];
};

enum scsi_inquiry_pagecode {
	SCSI_INQUIRY_PAGECODE_SUPPORTED_VPD_PAGES          = 0x00,
	SCSI_INQUIRY_PAGECODE_UNIT_SERIAL_NUMBER           = 0x80,
	SCSI_INQUIRY_PAGECODE_DEVICE_IDENTIFICATION        = 0x83,
	SCSI_INQUIRY_PAGECODE_BLOCK_LIMITS                 = 0xB0,
	SCSI_INQUIRY_PAGECODE_BLOCK_DEVICE_CHARACTERISTICS = 0xB1,
	SCSI_INQUIRY_PAGECODE_LOGICAL_BLOCK_PROVISIONING   = 0xB2
};

extern const char *scsi_inquiry_pagecode_to_str(int pagecode);

struct scsi_inquiry_supported_pages {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	enum scsi_inquiry_pagecode pagecode;

	int num_pages;
	unsigned char *pages;
};

struct scsi_inquiry_block_limits {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	enum scsi_inquiry_pagecode pagecode;

	int wsnz;		   		/* write same no zero */
	uint8_t max_cmp;			/* maximum_compare_and_write_length */
	uint16_t opt_gran;			/* optimal_transfer_length_granularity */
	uint32_t max_xfer_len;			/* maximum_transfer_length */
	uint32_t opt_xfer_len;			/* optimal_transfer_length */
	uint32_t max_prefetch;			/* maximum_prefetched_xdread_xdwrite_transfer_length */
	uint32_t max_unmap;			/* maximum_unmap_lba_count */
	uint32_t max_unmap_bdc;			/* maximum_unmap_block_descriptor_count */
	uint32_t opt_unmap_gran;		/* optimal_unmap_granularity */
	int ugavalid;
	uint32_t unmap_gran_align;		/* unmap_granularity_alignment */
	uint64_t max_ws_len;			/* maximum_write_same_length */
};

struct scsi_inquiry_block_device_characteristics {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	enum scsi_inquiry_pagecode pagecode;

	int medium_rotation_rate;
	int product_type;
	int wabereq;
	int wacereq;
	int nominal_form_factor;
	int fuab;
	int vbuls;
};

enum scsi_inquiry_provisioning_type {
	PROVISIONING_TYPE_NONE     = 0,
	PROVISIONING_TYPE_RESOURCE = 1,
	PROVISIONING_TYPE_THIN     = 2
};

struct scsi_inquiry_logical_block_provisioning {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	enum scsi_inquiry_pagecode pagecode;

       int threshold_exponent;
       int lbpu;
       int lbpws;
       int lbpws10;
       int lbprz;
       int anc_sup;
       int dp;
       enum scsi_inquiry_provisioning_type provisioning_type;
};

extern struct scsi_task *scsi_cdb_inquiry(int evpd, int page_code, int alloc_len);

struct scsi_inquiry_unit_serial_number {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	enum scsi_inquiry_pagecode pagecode;

	char *usn;
};

enum scsi_protocol_identifier {
	SCSI_PROTOCOL_IDENTIFIER_FIBRE_CHANNEL = 0x00,
	SCSI_PROTOCOL_IDENTIFIER_PARALLEL_SCSI = 0x01,
	SCSI_PROTOCOL_IDENTIFIER_SSA           = 0x02,
	SCSI_PROTOCOL_IDENTIFIER_IEEE_1394     = 0x03,
	SCSI_PROTOCOL_IDENTIFIER_RDMA          = 0x04,
	SCSI_PROTOCOL_IDENTIFIER_ISCSI         = 0x05,
	SCSI_PROTOCOL_IDENTIFIER_SAS           = 0x06,
	SCSI_PROTOCOL_IDENTIFIER_ADT           = 0x07,
	SCSI_PROTOCOL_IDENTIFIER_ATA           = 0x08
};

extern const char *scsi_protocol_identifier_to_str(int identifier);

enum scsi_codeset {
	SCSI_CODESET_BINARY = 0x01,
	SCSI_CODESET_ASCII  = 0x02,
	SCSI_CODESET_UTF8   = 0x03
};

extern const char *scsi_codeset_to_str(int codeset);

enum scsi_association {
	SCSI_ASSOCIATION_LOGICAL_UNIT  = 0x00,
	SCSI_ASSOCIATION_TARGET_PORT   = 0x01,
	SCSI_ASSOCIATION_TARGET_DEVICE = 0x02
};

extern const char *scsi_association_to_str(int association);

enum scsi_designator_type {
	SCSI_DESIGNATOR_TYPE_VENDOR_SPECIFIC             = 0x00,
	SCSI_DESIGNATOR_TYPE_T10_VENDORT_ID              = 0x01,
	SCSI_DESIGNATOR_TYPE_EUI_64                      = 0x02,
	SCSI_DESIGNATOR_TYPE_NAA                         = 0x03,
	SCSI_DESIGNATOR_TYPE_RELATIVE_TARGET_PORT        = 0x04,
	SCSI_DESIGNATOR_TYPE_TARGET_PORT_GROUP           = 0x05,
	SCSI_DESIGNATOR_TYPE_LOGICAL_UNIT_GROUP          = 0x06,
	SCSI_DESIGNATOR_TYPE_MD5_LOGICAL_UNIT_IDENTIFIER = 0x07,
	SCSI_DESIGNATOR_TYPE_SCSI_NAME_STRING            = 0x08
};

extern const char *scsi_designator_type_to_str(int association);

struct scsi_inquiry_device_designator {
	struct scsi_inquiry_device_designator *next;

	enum scsi_protocol_identifier protocol_identifier;
	enum scsi_codeset code_set;
	int piv;
	enum scsi_association association;
	enum scsi_designator_type designator_type;
	int designator_length;
	char *designator;
};

struct scsi_inquiry_device_identification {
	enum scsi_inquiry_peripheral_qualifier qualifier;
	enum scsi_inquiry_peripheral_device_type device_type;
	enum scsi_inquiry_pagecode pagecode;

	struct scsi_inquiry_device_designator *designators;
};

/*
 * MODESENSE
 */
enum scsi_modesense_page_control {
	SCSI_MODESENSE_PC_CURRENT    = 0x00,
	SCSI_MODESENSE_PC_CHANGEABLE = 0x01,
	SCSI_MODESENSE_PC_DEFAULT    = 0x02,
	SCSI_MODESENSE_PC_SAVED      = 0x03
};

enum scsi_modesense_page_code {
	SCSI_MODEPAGE_READ_WRITE_ERROR_RECOVERY = 0x01,
	SCSI_MODEPAGE_DISCONNECT_RECONNECT      = 0x02,
	SCSI_MODEPAGE_VERIFY_ERROR_RECOVERY     = 0x07,
	SCSI_MODEPAGE_CACHING                   = 0x08,
	SCSI_MODEPAGE_XOR_CONTROL               = 0x10,
	SCSI_MODEPAGE_CONTROL                   = 0x0a,
	SCSI_MODEPAGE_POWER_CONDITION           = 0x1a,
	SCSI_MODEPAGE_INFORMATIONAL_EXCEPTIONS_CONTROL        = 0x1c,
	SCSI_MODEPAGE_RETURN_ALL_PAGES          = 0x3f
};


/* Do not use in new code.
 * Backward compatibility macros
 */
#define SCSI_MODESENSE_PAGECODE_READ_WRITE_ERROR_RECOVERY SCSI_MODEPAGE_READ_WRITE_ERROR_RECOVERY
#define SCSI_MODESENSE_PAGECODE_DISCONNECT_RECONNECT SCSI_MODEPAGE_DISCONNECT_RECONNECT
#define SCSI_MODESENSE_PAGECODE_VERIFY_ERROR_RECOVERY SCSI_MODEPAGE_VERIFY_ERROR_RECOVERY
#define SCSI_MODESENSE_PAGECODE_CACHING SCSI_MODEPAGE_CACHING
#define SCSI_MODESENSE_PAGECODE_XOR_CONTROL SCSI_MODEPAGE_XOR_CONTROL
#define SCSI_MODESENSE_PAGECODE_CONTROL SCSI_MODEPAGE_CONTROL
#define SCSI_MODESENSE_PAGECODE_INFORMATIONAL_EXCEPTIONS_CONTROL SCSI_MODEPAGE_INFORMATIONAL_EXCEPTIONS_CONTROL
#define SCSI_MODESENSE_PAGECODE_RETURN_ALL_PAGES SCSI_MODEPAGE_RETURN_ALL_PAGES

struct scsi_readcapacity16 {
       uint64_t returned_lba;
       uint32_t block_length;
       uint8_t  p_type;
       uint8_t  prot_en;
       uint8_t  p_i_exp;
       uint8_t  lbppbe;
       uint8_t  lbpme;
       uint8_t  lbprz;
       uint16_t lalba;
};

enum scsi_provisioning_type {
     SCSI_PROVISIONING_TYPE_MAPPED	= 0x00,
     SCSI_PROVISIONING_TYPE_DEALLOCATED	= 0x01,
     SCSI_PROVISIONING_TYPE_ANCHORED	= 0x02
};

struct scsi_lba_status_descriptor {
       uint64_t	lba;
       uint32_t num_blocks;
       enum scsi_provisioning_type provisioning;
};

struct scsi_get_lba_status {
       uint32_t num_descriptors;
       struct scsi_lba_status_descriptor *descriptors;
};


struct scsi_op_timeout_descriptor {
	uint16_t descriptor_length;
	uint8_t command_specific;
	uint32_t nominal_processing_timeout;
	uint32_t recommended_timeout;

};
struct scsi_command_descriptor {
	uint8_t opcode;
	uint16_t sa;
	uint8_t ctdp;
	uint8_t servactv;
	uint16_t cdb_len;

	/* only present if CTDP==1 */
	struct scsi_op_timeout_descriptor to;
};

struct scsi_report_supported_op_codes {
	int num_descriptors;
	struct scsi_command_descriptor descriptors[0];
};

struct scsi_report_supported_op_codes_one_command {
	uint8_t ctdp;
	uint8_t support;
	uint8_t cdb_length;
	uint8_t cdb_usage_data[16];

	/* only present if CTDP==1 */
	struct scsi_op_timeout_descriptor to;
};

struct scsi_persistent_reserve_in_read_keys {
       uint32_t prgeneration;
       uint32_t additional_length;

       int      num_keys;
       uint64_t keys[0];
};

struct scsi_persistent_reserve_in_read_reservation {
       uint32_t prgeneration;
       uint32_t additional_length;

       int reserved;

       uint64_t reservation_key;
       unsigned char pr_scope;
       unsigned char pr_type;
};

struct scsi_persistent_reserve_in_report_capabilities {
       uint16_t length;
       uint8_t  crh;
       uint8_t  sip_c;
       uint8_t  atp_c;
       uint8_t  ptpl_c;
       uint8_t  tmv;
       uint8_t  allow_commands;
       uint8_t  ptpl_a;
       uint16_t persistent_reservation_type_mask;
};

struct scsi_read6_cdb {
	enum scsi_opcode opcode;
	uint32_t lba;
	uint16_t transfer_length;
	uint8_t  control;
};

struct scsi_read10_cdb {
	enum scsi_opcode opcode;
	uint8_t  rdprotect;
	uint8_t  dpo;
	uint8_t  fua;
	uint8_t  fua_nv;
	uint32_t lba;
	uint8_t  group;
	uint16_t transfer_length;
	uint8_t  control;
};

struct scsi_read12_cdb {
	enum scsi_opcode opcode;
	uint8_t  rdprotect;
	uint8_t  dpo;
	uint8_t  fua;
	uint8_t	 rarc;
	uint8_t  fua_nv;
	uint32_t lba;
	uint32_t transfer_length;
	uint8_t  group;
	uint8_t  control;
};

struct scsi_read16_cdb {
	enum scsi_opcode opcode;
	uint8_t  rdprotect;
	uint8_t  dpo;
	uint8_t  fua;
	uint8_t	 rarc;
	uint8_t  fua_nv;
	uint64_t lba;
	uint32_t transfer_length;
	uint8_t  group;
	uint8_t  control;
};

struct scsi_verify10_cdb {
	enum scsi_opcode opcode;
	uint8_t  vrprotect;
	uint8_t  dpo;
	uint8_t  bytchk;
	uint32_t lba;
	uint8_t  group;
	uint16_t verification_length;
	uint8_t  control;
};

struct scsi_verify12_cdb {
	enum scsi_opcode opcode;
	uint8_t  vrprotect;
	uint8_t  dpo;
	uint8_t  bytchk;
	uint32_t lba;
	uint32_t verification_length;
	uint8_t  group;
	uint8_t  control;
};

struct scsi_verify16_cdb {
	enum scsi_opcode opcode;
	uint8_t  vrprotect;
	uint8_t  dpo;
	uint8_t  bytchk;
	uint64_t lba;
	uint32_t verification_length;
	uint8_t  group;
	uint8_t  control;
};

struct scsi_write10_cdb {
	enum scsi_opcode opcode;
	uint8_t  wrprotect;
	uint8_t  dpo;
	uint8_t  fua;
	uint8_t  fua_nv;
	uint32_t lba;
	uint8_t  group;
	uint16_t transfer_length;
	uint8_t  control;
};

struct scsi_write12_cdb {
	enum scsi_opcode opcode;
	uint8_t  wrprotect;
	uint8_t  dpo;
	uint8_t  fua;
	uint8_t  fua_nv;
	uint32_t lba;
	uint32_t transfer_length;
	uint8_t  group;
	uint8_t  control;
};

struct scsi_write16_cdb {
	enum scsi_opcode opcode;
	uint8_t  wrprotect;
	uint8_t  dpo;
	uint8_t  fua;
	uint8_t  fua_nv;
	uint32_t lba;
	uint32_t transfer_length;
	uint8_t  group;
	uint8_t  control;
};

extern int scsi_datain_getfullsize(struct scsi_task *task);
extern void *scsi_datain_unmarshall(struct scsi_task *task);
extern void *scsi_cdb_unmarshall(struct scsi_task *task, enum scsi_opcode opcode);

extern struct scsi_task *scsi_cdb_compareandwrite(uint64_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_get_lba_status(uint64_t starting_lba, uint32_t alloc_len);
extern struct scsi_task *scsi_cdb_orwrite(uint64_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_persistent_reserve_in(enum scsi_persistent_in_sa sa, uint16_t xferlen);
extern struct scsi_task *scsi_cdb_persistent_reserve_out(enum scsi_persistent_out_sa sa, enum scsi_persistent_out_scope scope, enum scsi_persistent_out_type type, void *params);
extern struct scsi_task *scsi_cdb_prefetch10(uint32_t lba, int num_blocks, int immed, int group);
extern struct scsi_task *scsi_cdb_prefetch16(uint64_t lba, int num_blocks, int immed, int group);
extern struct scsi_task *scsi_cdb_preventallow(int prevent);
extern struct scsi_task *scsi_cdb_read6(uint32_t lba, uint32_t xferlen, int blocksize);
extern struct scsi_task *scsi_cdb_read10(uint32_t lba, uint32_t xferlen, int blocksize, int rdprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_read12(uint32_t lba, uint32_t xferlen, int blocksize, int rdprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_read16(uint64_t lba, uint32_t xferlen, int blocksize, int rdprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_readcapacity16(void);
extern struct scsi_task *scsi_cdb_report_supported_opcodes(int rctd, int options, enum scsi_opcode opcode, int sa, uint32_t alloc_len);
extern struct scsi_task *scsi_cdb_serviceactionin16(enum scsi_service_action_in sa, uint32_t xferlen);
extern struct scsi_task *scsi_cdb_startstopunit(int immed, int pcm, int pc, int no_flush, int loej, int start);
extern struct scsi_task *scsi_cdb_synchronizecache10(int lba, int num_blocks, int syncnv, int immed);
extern struct scsi_task *scsi_cdb_synchronizecache16(uint64_t lba, uint32_t num_blocks, int syncnv, int immed);
extern struct scsi_task *scsi_cdb_unmap(int anchor, int group, uint16_t xferlen);
extern struct scsi_task *scsi_cdb_verify10(uint32_t lba, uint32_t xferlen, int vprotect, int dpo, int bytchk, int blocksize);
extern struct scsi_task *scsi_cdb_verify12(uint32_t lba, uint32_t xferlen, int vprotect, int dpo, int bytchk, int blocksize);
extern struct scsi_task *scsi_cdb_verify16(uint64_t lba, uint32_t xferlen, int vprotect, int dpo, int bytchk, int blocksize);
extern struct scsi_task *scsi_cdb_write10(uint32_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_write12(uint32_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_write16(uint64_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int fua, int fua_nv, int group_number);
extern struct scsi_task *scsi_cdb_writesame10(int wrprotect, int anchor, int unmap, uint32_t lba, int group, uint16_t num_blocks, uint32_t datalen);
extern struct scsi_task *scsi_cdb_writesame16(int wrprotect, int anchor, int unmap, uint64_t lba, int group, uint32_t num_blocks, uint32_t datalen);
extern struct scsi_task *scsi_cdb_writeverify10(uint32_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int bytchk, int group_number);
extern struct scsi_task *scsi_cdb_writeverify12(uint32_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int bytchk, int group_number);
extern struct scsi_task *scsi_cdb_writeverify16(uint64_t lba, uint32_t xferlen, int blocksize, int wrprotect, int dpo, int bytchk, int group_number);

