!#/bin/sh
# Generate TM file based on translation files
# downloaded from https://translate.rx.studio/

set -e

project_list="r18r r-project"

for project in $project_list; do
    # Download collection of PO files
    filename="${project}-pt_BR.zip"
    url="https://translate.rx.studio/download-language/pt_BR/${project}/?format=zip"
    wget -O $filename $url
    # Extract to obtain the po files
    unzip $filename
done

all_po_files = $(find * -name '(R-)?pt_BR.po')

pocompendium rx-studio-compendium.po ${all_po_files}

poterminology -i ${all_po_files} -o rx-studio-terms.po
