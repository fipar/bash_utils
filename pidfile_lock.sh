#!/bin/bash

# pidfile lock lets you use a pid file that also works as a lock file to prevent concurrent execution of processes. 
# I wrote it to make sure potentially long running cron jobs never have more than one instance, but it can be used in other cases like init scripts. 

# this is the name of the lock file to use for control
[ -z "$_pidfile_lock_LOCKFILE" ] && _pidfile_lock_LOCKFILE=/tmp/pidfile_lock_default.pid
# this controls verbosity. by default we only output on errors 
[ -z "$_pidfile_lock_VERBOSE" ] && _pidfile_lock_VERBOSE=0

_pidfile_lock_lock()
{
    test -f $_pidfile_lock_LOCKFILE && kill -0 $(cat $_pidfile_lock_LOCKFILE) 2>/dev/null && {
	echo "Already locked. Pid: $(cat $_pidfile_lock_LOCKFILE)">&2
	return 1
    }
    echo $$ > $_pidfile_lock_LOCKFILE
}

_pidfile_lock_unlock()
{
    [ -f $_pidfile_lock_LOCKFILE ] || { 
	echo "Already unlocked">&2
	return 1 
    }
    [ -f $_pidfile_lock_LOCKFILE -a "$(cat $_pidfile_lock_LOCKFILE)" -eq "$$" ] || {
	echo "Attempt to unlock a pid we don't own (we're $$, lock file is $(cat $_pidfile_lock_LOCKFILE))">&2
	return 1
    }
    rm -f $_pidfile_lock_LOCKFILE
}

_pidfile_lock_test()
{
    [ -f $_pidfile_lock_LOCKFILE ] && {
	[ $_pidfile_lock_VERBOSE -gt 0 ] && echo "Locked. Pid: $(cat $_pidfile_lock_LOCKFILE)"
	return 1
    }
    return 0
}
