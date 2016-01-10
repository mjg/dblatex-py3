import sys
import os
import re
import glob
import tempfile
import shutil
import subprocess
from subprocess import Popen, PIPE

dry_run = False

def exec_command(cmd):
    global dry_run
    cmd = " ".join(cmd)
    print cmd
    if not(dry_run):
        rc = subprocess.call(cmd, shell=True)
        if rc != 0:
            raise Exception("'%s' failed (%d)" % (cmd, rc))

def hg_export_patches(repo_src, repo_sas, patch_dir, add_source=False):
    cmd = ["hg", "-R", repo_sas, "incoming"]
    if add_source: cmd.append(repo_src)
    print " ".join(cmd)
    p = Popen(cmd, stdout=PIPE)
    data = p.communicate()[0]

    patch_revs = []
    for line in data.split("\n"):
        m = re.search("changeset: *(\d+):", line)
        if m: patch_revs.append(m.group(1))

    if not(patch_revs):
        return

    cmd = ["hg", "-R", repo_src, "export", "-o", \
           os.path.join(patch_dir, "%R-inc.diff")]
    cmd += ["-r%s" % (r) for r in patch_revs]
    exec_command(cmd)

def hg_tag_command(repo_proxy, patch, user=""):
    cmd = ["grep", "-c", "^diff.*\.hgtags", patch]
    print " ".join(cmd)
    p = Popen(cmd, stdout=PIPE)
    data = p.communicate()[0]

    if int(data) == 0:
        return []

    tag1, tag2, tag_date = "", "", ""
    for line in open(patch).readlines():
        m = re.search("Added tag ([^\s]+) for changeset", line)
        if m:
            tag1 = m.group(1)
            continue
        m = re.search("^\+\+\+ .*\s+(\w+ \w+ \d+ \d+:\d+:\d+ \d+)", line)
        if m:
            tag_date = m.group(1)
            continue
        m = re.search("^\+.* (.*)", line)
        if m:
            tag2 = m.group(1)
            continue

    if not(tag1 and tag1 == tag2):
        print "Something wrong: '%s' vs '%s'" % (tag1, tag2)
        return []

    cmd = ["hg", "-R", repo_proxy, "tag", "-d", '"'+tag_date+'"']
    if user: cmd += ["-u", user]
    cmd += [tag1]
    return cmd

def hg_import_patches(repo_proxy, patch_dir, user="", exclude_patches=None):
    excluded = exclude_patches or []
    patches = glob.glob(os.path.join(patch_dir, "*.diff"))
    patches.sort()
    cmdbase = ["hg", "-R", repo_proxy, "import"]
    if user: cmdbase += ["-u", user]

    if exclude_patches:
        excluded = [ os.path.join(patch_dir, "%s-inc.diff" % (p)) for p in
                     exclude_patches ]
    else:
        excluded = []

    for patch in patches:
        if patch in excluded: continue
        cmd = hg_tag_command(repo_proxy, patch, user)
        if not(cmd):
            cmd = cmdbase + [patch]
        exec_command(cmd)

def hg_command(repo_sas, what):
    cmd = ["hg", "-R", repo_sas, what]
    exec_command(cmd)


def push_to_proxy(repo_src, repo_sas, repo_proxy, user="", debug=False,
                  push_remote=False, exclude_patches=None):
    """
    The update principle is as follow:

    Source Repo |---------->| Intermediate/SAS Repo |
        |         incoming? 
        |            |
        | export <---"
        v       
     Patches -------------->| Proxy/Dest Repo   |----------->| Remote Repo | 
             import -u user                          push 

    The role of the intermediate repository (clone of the local one) is to 
    detect the changes to push in the Proxy repo (clone of the remote repo)
    When some changes are detected, the related patches are exported and
    applied to the Proxy repo. Once done the intermediate repo is updated
    as a mirror of the proxy repo state.

    Note: the final push from proxy to remote is on request because
    it must be done only explicitely.
    """

    curdir = os.getcwd()

    # Go into a temporary dir that will also contain the patches
    tmpdir = tempfile.mkdtemp()
    patch_dir = tmpdir
    os.chdir(tmpdir)

    # We don't use the bundle mechanism, because the commit user maybe need to
    # be changed. So, use raw patch export/import method.
    try:
        hg_export_patches(repo_src, repo_sas, patch_dir)
        hg_import_patches(repo_proxy, patch_dir, user=user,
                          exclude_patches=exclude_patches)
        hg_command(repo_sas, "pull")
        if push_remote:
            hg_command(repo_proxy, "push")
        rc = 0
    except Exception, e:
        rc = -1
        print >>sys.stderr, e

    os.chdir(curdir)
    if not(debug):
        shutil.rmtree(tmpdir)
    else:
        print "%s not removed" % (tmpdir)
    return rc


def main():
    from optparse import OptionParser
    parser = OptionParser(usage="%s [options]" % sys.argv[0])
    parser.add_option("-s", "--source",
                      help="Source repository")
    parser.add_option("-i", "--intermediate",
                      help="Intermediate clone repository to update")
    parser.add_option("-x", "--destination",
                      help="Destination repository to update (proxy)")
    parser.add_option("-R", "--push-remote", action="store_true", 
                      help="Push changes to the Remote repository")
    parser.add_option("-u", "--user",
                      help="Username of the destination commits")
    parser.add_option("-d", "--debug", action="store_true",
                      help="Debug mode. Temporary dir nor removed")
    parser.add_option("-n", "--dry-run", action="store_true",
                      help="Print the command but do nothing")
    parser.add_option("-z", "--exclude-patch", action="append",
                      help="Username of the destination commits")

    (options, args) = parser.parse_args()

    repo_src = os.getcwd()
    debug = False
    push_remote = False
    user = ""
    exclude_patches = None
    global dry_run

    errors = 0
    if options.source:
        repo_src = os.path.realpath(options.source)
    if options.dry_run:
        dry_run = True
    if options.user:
        user = options.user
    if options.debug:
        debug = options.debug
    if options.push_remote:
        push_remote = options.push_remote
    if options.exclude_patch:
        exclude_patches = []
        for patch in options.exclude_patch:
            patches = [ p.strip() for p in patch.split(",") ]
            for p in patches:
                try: d = int(p)
                except:
                    print "Invalid revision identifier: %s" % p
                    errors = errors + 1
            exclude_patches += patches

    if not(options.intermediate):
        print >> sys.stderr, "Option -i required"
        errors = errors + 1
    if not(options.destination):
        print >> sys.stderr, "Option -d required"
        errors = errors + 1

    if errors > 0:
        sys.exit(errors)

    repo_sas = options.intermediate
    repo_proxy = options.destination

    # Local synchronization between repositories
    rc = push_to_proxy(repo_src, repo_sas, repo_proxy,
                       user=user, debug=debug, push_remote=push_remote,
                       exclude_patches=exclude_patches)

    sys.exit(rc)


if __name__ == "__main__":
    main()
