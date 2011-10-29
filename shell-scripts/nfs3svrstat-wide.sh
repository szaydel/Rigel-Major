#!/usr/bin/bash
#
# This script measures the latency of NFS server operations.
# The minimum, average, and maximum latency for a server's NFS
# operations is shown in microseconds.
#
# Copyright 2010 Richard Elling
#
# Version 0.1, first pass, please do not distribute
#
PATH=/usr/sbin:/usr/bin
operation="all"
opt_time=0
interval=1
count=-1

# todo: allow subset tracking
TRACK_commit=1
TRACK_pathconf=1
TRACK_fsinfo=1
TRACK_fsstat=1
TRACK_readdirplus=1
TRACK_readdir=1
TRACK_link=1
TRACK_rename=1
TRACK_rmdir=1
TRACK_remove=1
TRACK_mknod=1
TRACK_symlink=1
TRACK_mkdir=1
TRACK_create=1
TRACK_write=1
TRACK_read=1
TRACK_readlink=1
TRACK_access=1
TRACK_lookup=1
TRACK_setattr=1
TRACK_getattr=1
TRACK_null=1

show_usage() {
	cat << END >&2
USAGE: $0 [-ht] [interval [count]]
	-h	# print usage
	-t	# print timestamp, human readable
	-T	# print timestamp, microseconds since January 1, 1970
END
}

while getopts 34htT name
do
	case $name in
		h) show_usage; exit 0 ;;
		t) opt_time=1 ;;
		T) opt_time=2 ;;
		?) show_usage; exit 1 ;;
	esac
done
shift $(( $OPTIND - 1 ))

# process remaining parameters
if [[ "$1" > 0 ]]; then
	interval=$1; shift
fi
if [[ "$1" > 0 ]]; then
	count=$1; shift
fi
if [[ ! -z "$1" ]]; then
	show_usage; exit 1
fi

# options are known, now run dtrace
dtrace -n '
inline int INTERVAL = '$interval';
inline int COUNT = '$count';
inline int PRINT_TIME = '$opt_time';

#pragma D option quiet

dtrace:::BEGIN
{
	secs = INTERVAL;
	counts = COUNT;
	printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
		"client", "ops",
        "read ops", "bytes read", "read min", "read avg", "read max",
        "write ops", "async write ops", "sync write ops", "bytes write",
		"write min", "write avg", "write max",
		"commit ops", "commit min", "commit avg", "commit max",
        "pathconf ops", "pathconf min", "pathconf avg", "pathconf max",
        "fsinfo ops", "fsinfo min", "fsinfo avg", "fsinfo max",
        "fsstat ops", "fsstat min", "fsstat avg", "fsstat max",
        "readdirplus ops", "readdirplus min", "readdirplus avg", "readdirplus max",
        "readdir ops", "readdir min", "readdir avg", "readdir max",
        "link ops", "link min", "link avg", "link max",
        "rename ops", "rename min", "rename avg", "rename max",
        "rmdir ops", "rmdir min", "rmdir avg", "rmdir max",
        "remove ops", "remove min", "remove avg", "remove max",
        "mknod ops", "mknod min", "mknod avg", "mknod max",
        "symlink ops", "symlink min", "symlink avg", "symlink max",
        "mkdir ops", "mkdir min", "mkdir avg", "mkdir max",
        "create ops", "create min", "create avg", "create max",
        "readlink ops", "readlink min", "readlink avg", "readlink max",
        "access ops", "access min", "access avg", "access max",
        "lookup ops", "lookup min", "lookup avg", "lookup max",
        "setattr ops", "setattr min", "setattr avg", "setattr max",
        "getattr ops", "getattr min", "getattr avg", "getattr max",
        "null ops", "null min", "null avg", "null max");
}

nfsv3:nfssrv::op-commit-start
/'$TRACK_commit'/
{
	self->ts = timestamp;
	@count_commit[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-pathconf-start
/'$TRACK_pathconf'/
{
	self->ts = timestamp;
	@count_pathconf[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-fsinfo-start
/'$TRACK_fsinfo'/
{
	self->ts = timestamp;
	@count_fsinfo[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-fsstat-start
/'$TRACK_fsstat'/
{
	self->ts = timestamp;
	@count_fsstat[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-readdirplus-start
/'$TRACK_readdirplus'/
{
	self->ts = timestamp;
	@count_readdirplus[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-readdir-start
/'$TRACK_readdir'/
{
	self->ts = timestamp;
	@count_readdir[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-link-start
/'$TRACK_link'/
{
	self->ts = timestamp;
	@count_link[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-rename-start
/'$TRACK_rename'/
{
	self->ts = timestamp;
	@count_rename[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-rmdir-start
/'$TRACK_rmdir'/
{
	self->ts = timestamp;
	@count_rmdir[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-remove-start
/'$TRACK_remove'/
{
	self->ts = timestamp;
	@count_remove[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-mknod-start
/'$TRACK_mknod'/
{
	self->ts = timestamp;
	@count_mknod[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-symlink-start
/'$TRACK_symlink'/
{
	self->ts = timestamp;
	@count_symlink[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-mkdir-start
/'$TRACK_mkdir'/
{
	self->ts = timestamp;
	@count_mkdir[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-create-start
/'$TRACK_create'/
{
	self->ts = timestamp;
	@count_create[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-write-start
/'$TRACK_write'/
{
	self->ts = timestamp;
	@count_write[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
	@bytes_write[args[0]->ci_remote] = sum(args[2]->data.data_len);
}
nfsv3:nfssrv::op-write-start
/'$TRACK_write' && args[2]->stable/
{
	@count_sync_write[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-write-start
/'$TRACK_write' && !args[2]->stable/
{
	@count_async_write[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-read-start
/'$TRACK_read'/
{
	self->ts = timestamp;
	@count_read[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
	@bytes_read[args[0]->ci_remote] = sum(args[2]->count);
}
nfsv3:nfssrv::op-readlink-start
/'$TRACK_readlink'/
{
	self->ts = timestamp;
	@count_readlink[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-access-start
/'$TRACK_access'/
{
	self->ts = timestamp;
	@count_access[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-lookup-start
/'$TRACK_lookup'/
{
	self->ts = timestamp;
	@count_lookup[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-setattr-start
/'$TRACK_setattr'/
{
	self->ts = timestamp;
	@count_setattr[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-getattr-start
/'$TRACK_getattr'/
{
	self->ts = timestamp;
	@count_getattr[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}
nfsv3:nfssrv::op-null-start
/'$TRACK_null'/
{
	self->ts = timestamp;
	@count_null[args[0]->ci_remote] = count();
	@op_count[args[0]->ci_remote] = count();
}

nfsv3:nfssrv::op-commit-done
/'$TRACK_commit' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_commit[args[0]->ci_remote] = avg(t);
        @mintime_commit[args[0]->ci_remote] = min(t);
        @maxtime_commit[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-pathconf-done
/'$TRACK_pathconf' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_pathconf[args[0]->ci_remote] = avg(t);
        @mintime_pathconf[args[0]->ci_remote] = min(t);
        @maxtime_pathconf[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-fsinfo-done
/'$TRACK_fsinfo' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_fsinfo[args[0]->ci_remote] = avg(t);
        @mintime_fsinfo[args[0]->ci_remote] = min(t);
        @maxtime_fsinfo[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-fsstat-done
/'$TRACK_fsstat' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_fsstat[args[0]->ci_remote] = avg(t);
        @mintime_fsstat[args[0]->ci_remote] = min(t);
        @maxtime_fsstat[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-readdirplus-done
/'$TRACK_readdirplus' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_readdirplus[args[0]->ci_remote] = avg(t);
        @mintime_readdirplus[args[0]->ci_remote] = min(t);
        @maxtime_readdirplus[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-readdir-done
/'$TRACK_readdir' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_readdir[args[0]->ci_remote] = avg(t);
        @mintime_readdir[args[0]->ci_remote] = min(t);
        @maxtime_readdir[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-link-done
/'$TRACK_link' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_link[args[0]->ci_remote] = avg(t);
        @mintime_link[args[0]->ci_remote] = min(t);
        @maxtime_link[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-rename-done
/'$TRACK_rename' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_rename[args[0]->ci_remote] = avg(t);
        @mintime_rename[args[0]->ci_remote] = min(t);
        @maxtime_rename[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-rmdir-done
/'$TRACK_rmdir' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_rmdir[args[0]->ci_remote] = avg(t);
        @mintime_rmdir[args[0]->ci_remote] = min(t);
        @maxtime_rmdir[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-remove-done
/'$TRACK_remove' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_remove[args[0]->ci_remote] = avg(t);
        @mintime_remove[args[0]->ci_remote] = min(t);
        @maxtime_remove[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-mknod-done
/'$TRACK_mknod' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_mknod[args[0]->ci_remote] = avg(t);
        @mintime_mknod[args[0]->ci_remote] = min(t);
        @maxtime_mknod[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-symlink-done
/'$TRACK_symlink' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_symlink[args[0]->ci_remote] = avg(t);
        @mintime_symlink[args[0]->ci_remote] = min(t);
        @maxtime_symlink[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-mkdir-done
/'$TRACK_mkdir' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_mkdir[args[0]->ci_remote] = avg(t);
        @mintime_mkdir[args[0]->ci_remote] = min(t);
        @maxtime_mkdir[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-create-done
/'$TRACK_create' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_create[args[0]->ci_remote] = avg(t);
        @mintime_create[args[0]->ci_remote] = min(t);
        @maxtime_create[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-write-done
/'$TRACK_write' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_write[args[0]->ci_remote] = avg(t);
        @mintime_write[args[0]->ci_remote] = min(t);
        @maxtime_write[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-read-done
/'$TRACK_read' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_read[args[0]->ci_remote] = avg(t);
        @mintime_read[args[0]->ci_remote] = min(t);
        @maxtime_read[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-readlink-done
/'$TRACK_readlink' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_readlink[args[0]->ci_remote] = avg(t);
        @mintime_readlink[args[0]->ci_remote] = min(t);
        @maxtime_readlink[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-access-done
/'$TRACK_access' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_access[args[0]->ci_remote] = avg(t);
        @mintime_access[args[0]->ci_remote] = min(t);
        @maxtime_access[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-lookup-done
/'$TRACK_lookup' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_lookup[args[0]->ci_remote] = avg(t);
        @mintime_lookup[args[0]->ci_remote] = min(t);
        @maxtime_lookup[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-setattr-done
/'$TRACK_setattr' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_setattr[args[0]->ci_remote] = avg(t);
        @mintime_setattr[args[0]->ci_remote] = min(t);
        @maxtime_setattr[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-getattr-done
/'$TRACK_getattr' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_getattr[args[0]->ci_remote] = avg(t);
        @mintime_getattr[args[0]->ci_remote] = min(t);
        @maxtime_getattr[args[0]->ci_remote] = max(t);
}
nfsv3:nfssrv::op-null-done
/'$TRACK_null' && self->ts/
{
        t = timestamp - self->ts;
        @avgtime_null[args[0]->ci_remote] = avg(t);
        @mintime_null[args[0]->ci_remote] = min(t);
        @maxtime_null[args[0]->ci_remote] = max(t);
}

profile:::tick-1sec
{
	secs--;
}

profile:::tick-1sec
/secs == 0/
{
	normalize(@avgtime_commit, 1000); normalize(@mintime_commit, 1000); normalize(@maxtime_commit, 1000);               normalize(@avgtime_pathconf, 1000); normalize(@mintime_pathconf, 1000); normalize(@maxtime_pathconf, 1000);
	normalize(@avgtime_fsinfo, 1000); normalize(@mintime_fsinfo, 1000); normalize(@maxtime_fsinfo, 1000);
	normalize(@avgtime_fsstat, 1000); normalize(@mintime_fsstat, 1000); normalize(@maxtime_fsstat, 1000);
	normalize(@avgtime_readdirplus, 1000); normalize(@mintime_readdirplus, 1000); normalize(@maxtime_readdirplus, 1000);
	normalize(@avgtime_readdir, 1000); normalize(@mintime_readdir, 1000); normalize(@maxtime_readdir, 1000);
	normalize(@avgtime_link, 1000); normalize(@mintime_link, 1000); normalize(@maxtime_link, 1000);
	normalize(@avgtime_rename, 1000); normalize(@mintime_rename, 1000); normalize(@maxtime_rename, 1000);
	normalize(@avgtime_rmdir, 1000); normalize(@mintime_rmdir, 1000); normalize(@maxtime_rmdir, 1000);
	normalize(@avgtime_remove, 1000); normalize(@mintime_remove, 1000); normalize(@maxtime_remove, 1000);
	normalize(@avgtime_mknod, 1000); normalize(@mintime_mknod, 1000); normalize(@maxtime_mknod, 1000);
	normalize(@avgtime_symlink, 1000); normalize(@mintime_symlink, 1000); normalize(@maxtime_symlink, 1000);
	normalize(@avgtime_mkdir, 1000); normalize(@mintime_mkdir, 1000); normalize(@maxtime_mkdir, 1000);
	normalize(@avgtime_create, 1000); normalize(@mintime_create, 1000); normalize(@maxtime_create, 1000);
	normalize(@avgtime_write, 1000); normalize(@mintime_write, 1000); normalize(@maxtime_write, 1000);
	normalize(@avgtime_read, 1000); normalize(@mintime_read, 1000); normalize(@maxtime_read, 1000);
	normalize(@avgtime_readlink, 1000); normalize(@mintime_readlink, 1000); normalize(@maxtime_readlink, 1000);
	normalize(@avgtime_access, 1000); normalize(@mintime_access, 1000); normalize(@maxtime_access, 1000);
	normalize(@avgtime_lookup, 1000); normalize(@mintime_lookup, 1000); normalize(@maxtime_lookup, 1000);
	normalize(@avgtime_setattr, 1000); normalize(@mintime_setattr, 1000); normalize(@maxtime_setattr, 1000);
	normalize(@avgtime_getattr, 1000); normalize(@mintime_getattr, 1000); normalize(@maxtime_getattr, 1000);
	normalize(@avgtime_null, 1000); normalize(@mintime_null, 1000); normalize(@maxtime_null, 1000);

	PRINT_TIME == 1 ? printf("%Y\n", walltimestamp) : 1;
	PRINT_TIME == 2 ? printf("%d\n", walltimestamp/1000) : 1;
	printa("%s,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d\n",
		@op_count,
		@count_read, @bytes_read, @mintime_read, @avgtime_read, @maxtime_read,
		@count_write, @count_async_write, @count_sync_write, @bytes_write,
		@mintime_write, @avgtime_write, @maxtime_write,
		@count_commit, @mintime_commit, @avgtime_commit, @maxtime_commit,
		@count_pathconf, @mintime_pathconf, @avgtime_pathconf, @maxtime_pathconf,
		@count_fsinfo, @mintime_fsinfo, @avgtime_fsinfo, @maxtime_fsinfo,
		@count_fsstat, @mintime_fsstat, @avgtime_fsstat, @maxtime_fsstat,
		@count_readdirplus, @mintime_readdirplus, @avgtime_readdirplus, @maxtime_readdirplus,
		@count_readdir, @mintime_readdir, @avgtime_readdir, @maxtime_readdir,
		@count_link, @mintime_link, @avgtime_link, @maxtime_link,
		@count_rename, @mintime_rename, @avgtime_rename, @maxtime_rename,
		@count_rmdir, @mintime_rmdir, @avgtime_rmdir, @maxtime_rmdir,
		@count_remove, @mintime_remove, @avgtime_remove, @maxtime_remove,
		@count_mknod, @mintime_mknod, @avgtime_mknod, @maxtime_mknod,
		@count_symlink, @mintime_symlink, @avgtime_symlink, @maxtime_symlink,
		@count_mkdir, @mintime_mkdir, @avgtime_mkdir, @maxtime_mkdir,
		@count_create, @mintime_create, @avgtime_create, @maxtime_create,
		@count_readlink, @mintime_readlink, @avgtime_readlink, @maxtime_readlink,
		@count_access, @mintime_access, @avgtime_access, @maxtime_access,
		@count_lookup, @mintime_lookup, @avgtime_lookup, @maxtime_lookup,
		@count_setattr, @mintime_setattr, @avgtime_setattr, @maxtime_setattr,
		@count_getattr, @mintime_getattr, @avgtime_getattr, @maxtime_getattr,
		@count_null, @mintime_null, @avgtime_null, @maxtime_null);

	trunc(@op_count, 0);
	trunc(@count_commit, 0); trunc(@avgtime_commit, 0); trunc(@mintime_commit, 0); trunc(@maxtime_commit, 0);
	trunc(@count_pathconf, 0); trunc(@avgtime_pathconf, 0); trunc(@mintime_pathconf, 0); trunc(@maxtime_pathconf, 0);
	trunc(@count_fsinfo, 0); trunc(@avgtime_fsinfo, 0); trunc(@mintime_fsinfo, 0); trunc(@maxtime_fsinfo, 0);
	trunc(@count_fsstat, 0); trunc(@avgtime_fsstat, 0); trunc(@mintime_fsstat, 0); trunc(@maxtime_fsstat, 0);
	trunc(@count_readdirplus, 0); trunc(@avgtime_readdirplus, 0); trunc(@mintime_readdirplus, 0); trunc(@maxtime_readdirplus, 0);
	trunc(@count_readdir, 0); trunc(@avgtime_readdir, 0); trunc(@mintime_readdir, 0); trunc(@maxtime_readdir, 0);
	trunc(@count_link, 0); trunc(@avgtime_link, 0); trunc(@mintime_link, 0); trunc(@maxtime_link, 0);
	trunc(@count_rename, 0); trunc(@avgtime_rename, 0); trunc(@mintime_rename, 0); trunc(@maxtime_rename, 0);
	trunc(@count_rmdir, 0); trunc(@avgtime_rmdir, 0); trunc(@mintime_rmdir, 0); trunc(@maxtime_rmdir, 0);
	trunc(@count_remove, 0); trunc(@avgtime_remove, 0); trunc(@mintime_remove, 0); trunc(@maxtime_remove, 0);
	trunc(@count_mknod, 0); trunc(@avgtime_mknod, 0); trunc(@mintime_mknod, 0); trunc(@maxtime_mknod, 0);
	trunc(@count_symlink, 0); trunc(@avgtime_symlink, 0); trunc(@mintime_symlink, 0); trunc(@maxtime_symlink, 0);
	trunc(@count_mkdir, 0); trunc(@avgtime_mkdir, 0); trunc(@mintime_mkdir, 0); trunc(@maxtime_mkdir, 0);
	trunc(@count_create, 0); trunc(@avgtime_create, 0); trunc(@mintime_create, 0); trunc(@maxtime_create, 0);
	trunc(@count_write, 0); trunc(@avgtime_write, 0); trunc(@mintime_write, 0); trunc(@maxtime_write, 0);
	trunc(@bytes_write, 0); trunc(@count_async_write, 0); trunc(@count_sync_write, 0);
	trunc(@count_read, 0); trunc(@avgtime_read, 0); trunc(@mintime_read, 0); trunc(@maxtime_read, 0);
	trunc(@bytes_read, 0);
	trunc(@count_readlink, 0); trunc(@avgtime_readlink, 0); trunc(@mintime_readlink, 0); trunc(@maxtime_readlink, 0);
	trunc(@count_access, 0); trunc(@avgtime_access, 0); trunc(@mintime_access, 0); trunc(@maxtime_access, 0);
	trunc(@count_lookup, 0); trunc(@avgtime_lookup, 0); trunc(@mintime_lookup, 0); trunc(@maxtime_lookup, 0);
	trunc(@count_setattr, 0); trunc(@avgtime_setattr, 0); trunc(@mintime_setattr, 0); trunc(@maxtime_setattr, 0);
	trunc(@count_getattr, 0); trunc(@avgtime_getattr, 0); trunc(@mintime_getattr, 0); trunc(@maxtime_getattr, 0);
	trunc(@count_null, 0); trunc(@avgtime_null, 0); trunc(@mintime_null, 0); trunc(@maxtime_null, 0);

	secs = INTERVAL;
	counts--;
}

profile:::tick-1sec
/counts == 0/
{
	exit(0);
}
'