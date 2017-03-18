#!/bin/bash

SECRET="secret/bar"
SECRET_VALUE="baz"
SNAPSHOT="newBack.snap"

_logmsg() {
    if [ "$1" == "error" ]; then
        echo >&2  "[e] $2";
    else
        echo "[+] $2";
    fi
}

_delete() {
  if vault delete "${SECRET}" > /dev/null 2>&1 ; then
      retval=0
  else
    retval=1
    return "$retval"
  fi
}

_read() {
  if vault read "${SECRET}" > /dev/null 2>&1 ; then
      retval=0
  else
      retval=1
  fi
  return "$retval"
}

_snapshot_restore() {
  if consul snapshot restore "$1" > /dev/null 2>&1; then
    retval=0
  else
    retval=1
  fi
  return "$retval"
}

_snapshot_save() {
  if consul snapshot save "$1" > /dev/null 2>&1; then
    retval=0
  else
    retval=1
  fi
  return "$retval"
}

_write() {
  if vault write "${SECRET}" value="${SECRET_VALUE}" > /dev/null 2>&1; then
    retval=0
  else
    retval=1
  fi
  return "$retval"
}

if _write; then
  _logmsg info "Write 1 OK";
else
  _logmsg error "Write 1 Failed";

fi

if _read; then
  _logmsg info "Read 1 OK";
else
  _logmsg error "Read 1 Failed";

fi

if _snapshot_save "$SNAPSHOT"; then
  _logmsg info "Snapshot save 1 OK";
else
  _logmsg error "Snapshot save 1 Failed";

fi

if _read; then
  _logmsg info "Read 2 OK";
else
  _logmsg error "Read 2 Failed";

fi

if _delete; then
  _logmsg info "Delete 1 OK";
else
  _logmsg error "Delete 1 Failed";

fi

if _read; then
  _logmsg info "Read 3 (immediately after delete 1) OK";
else
  _logmsg error "Read 3 (immediately after delete 1) Failed";

fi

if _snapshot_restore "${SNAPSHOT}"; then
  _logmsg info "Snapshot restore 1 OK";
else
  _logmsg error "Snapshot restore 1 Failed";

fi

if _read; then
  _logmsg info "Read 4 OK";
else
  _logmsg error "Read 4 Failed";

fi

if _delete; then
  _logmsg info "Delete 2 OK";
else
  _logmsg error "Delete 2 Failed";

fi

if _read; then
  _logmsg info "Read 5 (immediately after delete 2) OK";
else
  _logmsg error "Read 5 (immediately after delete 2) Failed";

fi

if _snapshot_restore "${SNAPSHOT}"; then
  _logmsg info "Snapshot restore 2 OK";
else
  _logmsg error "Snapshot restore 2 Failed";

fi

if _read; then
  _logmsg info "Read 6 OK";
else
  _logmsg error "Read 6 Failed";

fi
