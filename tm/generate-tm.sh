#!/bin/sh
# Generate TM file based on translation files
# downloaded from https://translate.rx.studio/

set -eu

# Clean download and generated files.
clean() {
  rm -rf r18r* r-project* \
    tm-rx-studio.pot pt_BR.po
}


download_and_extract() {
  for project in r18r r-project; do
    filename="${project}-pt_BR.zip"
    url="https://translate.rx.studio/download-language/pt_BR/${project}/?format=zip"
    wget -q -O $filename $url
    unzip -q $filename
  done
}


patch_remove_duplicate() {
  patch -sp0 -i remove-duplicate.patch
}


generate() {
  out=$1
  shift
  msgcat $* 2>/dev/null | \
    msgattrib \
      --no-fuzzy \
      --no-obsolete \
      --no-wrap \
      -o $out
  
  if [ -f "$out" ]; then
    echo "$out generated"
  fi
}


clean
download_and_extract
patch_remove_duplicate
generate  tm-rx-studio.pot  $(find * -type f -name '*.pot')
generate  pt_BR.po          $(find * -type f -regex ".*/\(R-\)?pt_BR.po")

