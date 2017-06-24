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

TODO

- package database
  - mirrored
  - installed
- does pacman call makepkg ?
- what to do with backup files ?
- install hooks
- alpm hooks


# Reference

- https://www.archlinux.org/pacman/
