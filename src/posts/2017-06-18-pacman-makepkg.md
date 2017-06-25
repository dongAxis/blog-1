<!--
{
  "title": "Pacman and Makepkg",
  "date": "2017-06-18T12:28:03+09:00",
  "updated_date": "2017-06-24T10:30:55+09:00",
  "category": "",
  "tags": ["arch-linux"],
  "draft": false
}
-->

I read through `pacman` and `makepkg` before going for my first `pacman -Syu`.

# makepkg overview

```
load files under /usr/share/makepkg/*.sh ..

parsing options ..

source_safe makepkg.conf

exit if !INFAKEROOT and EUID == 0

source_buildfile PKGBUILD

(makepkg will be recursively run with -F after run_build, so go for below first)
if INFAKEROOT
  pkgdir="$pkgdirbase/$pkgname"
  run_package  => .. call package()
  tidy_install =>
    - call tidy_remove and tidy_modify e.g.
      - tidy_libtool => find . ! -type d -name "*.la" -exec rm -f -- '{}' +
      - tidy_strip => strip ..
  lint_package =>
    - call lint_package_functions e.g.
      - warn_build_references =>
        - find "${pkgdir}" -type f -print0 | xargs -0 grep -q -I "${srcdir}"
  create_package =>
    - cd $pkgdir
    - write_pkginfo > .PKGINFO =>
      - log build time and some other information
    - write_buildinfo > .BUILDINFO => ..
      - log current installed packages by $(run_pacman -Q | sed "s# #-#") and some other information
    - bsdtar -czf .MTREE --format=mtree ..
    - bsdtar -cf - .PKGINFO .BUILDINFO .MTREE * | xz ..
    - create_signature =>
      - gpg --detach-sign --use-agent ${SIGNWITHKEY} --no-armor "$filename"

resolve_deps ${depends[@]} =>
  - handle_deps => run_pacman -S --asdeps $deplist (run_pacman adds 'sudo' depending on arguments)

cd src

download_sources =>
  - get_all_sources_for_arch (go through $source)
  - download_file =>
    - get_downloadclient (check for $DLAGENTS)
    - command .. (execute download command)

check_source_integrity =>
  - check_checksums =>
    - verify_integrity_sums =>
      - verify_integrity_one =>
        - openssl dgst -md5 .. and compare with value from $md5sums
  - check_pgpsigs =>
    - gzip -c -d -f < $sourcefile | gpg --quiet --batch --status-file "$statusfile" --verify "$file" - 2> /dev/null

extract_sources =>
  - extract_file =>
    - file -bizL "$file" then run appropriate extractor

run_prepare => .. call prepare()

cd $startdir

run_build => .. call build()
run_check => .. call check()

enter_fakeroot => fakeroot -- makepkg -F "${ARGLIST[@]}"

install_package =>
  - pkglist+=("$PKGDEST/${pkg}-${fullver}-${pkgarch}${PKGEXT}") ..
  - run_pacman -U "${pkglist[@]}"
```


# pacman overview

```
[ Data file structure ]
/var/cache/pacman
└── pkg
    ├── aalib-1.4rc5-12-x86_64.pkg.tar.xz
    ├── abs-2.4.4-2-x86_64.pkg.tar.xz
    ...
    ├── zlib-1:1.2.11-1-x86_64.pkg.tar.xz
    └── zvbi-0.2.35-1-x86_64.pkg.tar.xz

/var/lib/pacman
├── local
│   ├── aalib-1.4rc5-12
│   │   ├── desc
│   │   ├── files
│   │   └── mtree
...
│   └── zvbi-0.2.35-1
│       ├── desc
│       ├── files
│       └── mtree
└── sync
    ├── community.db
    ├── community.files
    ├── core.db
    ├── core.files
    ├── extra.db
    └── extra.files


[ Data structure ]
config_t
'-* config_repo_t (this part is used to setup dbs_sync field)
'-' alpm_handle_t
  '-' alpm_db_t (db_local)
    '-' alpm_pkghash_t (pkgcache)
  '-* alpm_db_t (dbs_sync)
    '-' (treename e.g. core, extra)
    '-* (servers)
  '-' alpm_trans_t
    '-* alpm_pkg_t (packages to add)
    '-* alpm_pkg_t (packages to remove)


(examples "pacman -Sv gnujump" or "pacman -Syu")
- main =>
  - config_t *config = config_new
  - parseargs =>
    - parsearg_op => config->op = PM_OP_SYNC (for "-S")
    - parsearg_sync =>
      - (config->op_s_upgrade)++             (for "-u")
      - (config->op_s_sync)++                (for "-y")
    - parsearg_global => (config->verbose)++ (for "-v")
    - pm_targets = alpm_list_add(..)         (for "gnujump")
    - checkargs_sync => ..
  - parseconfig =>
    - parse_ini => ..
    - setup_libalpm =>
      - config->handle = alpm_initialize
      - register_repo (for each repository section e.g. [core], [extra], ..) =>
        - alpm_db_t *db = alpm_register_syncdb => _alpm_db_register_sync =>
          - db = _alpm_db_new
          - handle->dbs_sync = alpm_list_add ..
        - _add_mirror => alpm_db_add_server => db->servers = alpm_list_add
  - pacman_sync =>
	  - sync_dbs = alpm_get_syncdbs
    - (if config->op_s_sync) sync_syncdbs(.. sync_dbs) =>
      - for each sync_dbs, alpm_db_update =>
        - for each db->servers until success
          - _alpm_download (e.g. download https://archlinux.surlyjake.com/archlinux/core/os/x86_64/core.db to /var/pacman/sync/core.db)
      - _alpm_db_free_pkgcache
    - sync_trans(targets) =>
      - trans_init(config->flags, 1)
      - process_target => .. => process_pkg =>
        - alpm_add_pkg => trans->add = alpm_list_add ..
        - config->explicit_adds = alpm_list_add ..
      - (if config->op_s_upgrade) alpm_sync_sysupgrade =>
        - for each alpm_pkg_t *lpkg from _alpm_db_get_pkgcache(handle->db_local),
          - for each handle->dbs_sync until until finds replacement,
            - alpm_list_t *replacers = check_replacers =>
              - find spkg from _alpm_db_get_pkgcache(sdb) to replace lpkg ..
            - trans->add = alpm_list_join(.. replacers)
      - sync_prepare_execute =>
        - alpm_trans_prepare =>
          - _alpm_sync_prepare =>
            - for each alpm_pkg_t *pkg in trans->add, _alpm_resolvedeps => ...
            - check _alpm_innerconflicts(handle, trans->add)
            - check _alpm_outerconflicts(handle->db_local, trans->add)
            - alpm_checkdeps
          - trans->add = _alpm_sortbydeps
        - alpm_trans_commit =>
          - _alpm_sync_load =>
            - download_files =>
              - find_dl_candidates from each handle->dbs_sync
              - download_single_file => _alpm_download
            - load_packages =>
              - for each handle->trans->add
                - alpm_pkg_t *pkgfile = _alpm_pkg_load_internal =>
                  - _alpm_open_archive
                  - _alpm_pkg_new
                  - ... (TODO: follow more here)
                - i->data = pkgfile  
          - _alpm_hook_run(.. ALPM_HOOK_PRE_TRANSACTION) ..
          - _alpm_sync_commit =>
            - _alpm_remove_packages (if any) =>
              - for each trans->remove, _alpm_remove_single_package =>
                - _alpm_runscriptlet(.. "pre_remove" ..)
                - remove_package_files =>
                  - alpm_filelist_t *filelist = alpm_pkg_get_files(oldpkg)
                  - for each alpm_file_t *file, unlink_file => unlink
                - _alpm_runscriptlet(.. "post_remove" ..)
                - _alpm_local_db_remove(handle->db_local, oldpkg) => simply unlink and rmdir
                - _alpm_db_remove_pkgfromcache(handle->db_local, oldpkg) => ..
            - _alpm_upgrade_packages =>
              - for each trans->add, commit_single_pkg =>
                - _alpm_runscriptlet "pre_upgrade" or  "pre_install"
                - _alpm_remove_single_package(oldpkg) => ..
                - _alpm_local_db_prepare => mkdir pkg file directory
                - _alpm_open_archive and interate archive_read_next_header
                  - extract_single_file =>
                    - (for dot files e.g. ".MTREE", ".INSTALL") extract_db_file =>
                      - perform_extraction (as "mtree" and "install") => archive_read_extract
                    - (otherwise after checking directory/file conflict) perform_extraction =>
                - newpkg->installdate = time(NULL)
                - _alpm_local_db_write(.. newpkg ..) => create "desc" and "files" files
                - _alpm_db_add_pkgincache
                - _alpm_runscriptlet "post_upgrade" or "post_install"
              - _alpm_ldconfig => ..
          - _alpm_hook_run(.. ALPM_HOOK_POST_TRANSACTION) ..
```


# Reference

- https://www.archlinux.org/pacman/
- https://git.archlinux.org/pacman.git/tree/README
