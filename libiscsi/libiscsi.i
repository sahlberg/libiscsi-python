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

struct scsi_mode_page;

struct unmap_list {
       uint64_t	  lba;
       uint32_t	  num;
};

extern struct scsi_task *
iscsi_scsi_command_sync(struct iscsi_context *iscsi, int lun,
			struct scsi_task *task, struct iscsi_data *data);

extern struct scsi_task *
iscsi_modeselect6_sync(struct iscsi_context *iscsi, int lun,
		       int pf, int sp, struct scsi_mode_page *mp);

extern struct scsi_task *
iscsi_modeselect10_sync(struct iscsi_context *iscsi, int lun,
			int pf, int sp, struct scsi_mode_page *mp);

extern struct scsi_task *
iscsi_modesense6_sync(struct iscsi_context *iscsi, int lun, int dbd,
		      int pc, int page_code, int sub_page_code,
		      unsigned char alloc_len);

extern struct scsi_task *
iscsi_modesense10_sync(struct iscsi_context *iscsi, int lun, int llbaa, int dbd,
		      int pc, int page_code, int sub_page_code,
		      unsigned char alloc_len);

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
