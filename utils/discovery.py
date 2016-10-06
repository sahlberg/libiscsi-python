#!/usr/bin/env python
# coding: utf-8
#
# Example program to perform iscsi discovery on a host

import sys
import libiscsi

def usage():
    print 'Usage: discovery <ISCSI-USL>'
    print ''
    print 'Example: discovery iscsi://120.0.0.1'
    sys.exit()
    
def discovery():
    _iscsi = libiscsi.iscsi_create_context('iqn.2007-10.com.github:python-scsi')
    _iscsi_url = libiscsi.iscsi_parse_full_url(_iscsi, 'iscsi://127.0.0.1/iqn.ronnie.test/1')
    libiscsi.iscsi_set_targetname(_iscsi, _iscsi_url.target)
    libiscsi.iscsi_set_session_type(_iscsi, libiscsi.ISCSI_SESSION_DISCOVERY)
    libiscsi.iscsi_set_header_digest(_iscsi, libiscsi.ISCSI_HEADER_DIGEST_NONE_CRC32C)
    libiscsi.iscsi_full_connect_sync(_iscsi, _iscsi_url.portal, _iscsi_url.lun)

    _da = libiscsi.iscsi_discovery_sync(_iscsi)
    da = _da
    while da:
        print 'Target', da.target_name
        dp = da.portals
        while dp:
            print '  Portal', dp.portal
            dp = dp.next
        da = da.next
    libiscsi.iscsi_free_discovery_data(_iscsi, _da)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()
    discovery()
