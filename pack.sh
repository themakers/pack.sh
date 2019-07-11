#!/usr/bin/env bash -e

# TODO: Should we add compression support?

genfilename="pack.gen.go"

genfile="$(pwd)/${genfilename}"

# assetsdir="$(pwd)/assets"

pkgname="main"


showHelp()
{
   echo ""
   echo "Usage: $0 -a assets_dir -o output -p package_name"
   echo -e "\t-a Assets directory"
   echo -e "\t-o Output file/dir (default: \$PWD/${genfilename})"
   echo -e "\t-p Generated file package name (default: main)"
   exit 1
}

while getopts "a:o:p:" opt
do
   case "$opt" in
      a ) assetsdir="$OPTARG" ;;
      o ) genfile="$OPTARG" ;;
      p ) pkgname="$OPTARG" ;;
      ? ) showHelp ;; #> Print help in case parameter is non-existent
   esac
done

#> Check required parameters
if [ -z "$assetsdir" ]
then
   echo "Some or all of the parameters are empty";
   showHelp
fi

#> Fix/prepare args

if [[ -d $genfile ]]; then
    genfile="${genfile}/${genfilename}"
fi

#> Get the party started

echo "pack.sh: Assets dir: ${assetsdir}"
echo "pack.sh: Package name: ${pkgname}"
echo "pack.sh: Generating ${genfile}"

cat > $genfile <<EOL
package ${pkgname}

var avfs = map[string][]byte{
EOL

for filepath in $(find ${assetsdir} -type f); do

prefix="${assetsdir}/"
filename=${filepath#"$prefix"}

cat >> $genfile <<EOL
"$filename": []byte{
EOL

echo "pack.sh: Adding ${filepath} as ${filename}"

hexdump -ve '12/1 "0x%02x, " "\n"' $filepath | sed 's/0x  ,//g' >> $genfile

#> gzip version
# cat $filename | gzip -9 -k -c | hexdump -ve '12/1 "0x%02x, " "\n"' | sed 's/0x  ,//g' >> $genfile

# hexdump -ve '12/1 "0x%02x, " "\n"' $filename | sed 's/0x  ,//g' >> $genfile
# hexdump -ve '12/1 "0x%.02x, " "\n"' $filename >> $genfile

cat >> $genfile <<EOL

},
EOL
done

cat >> $genfile <<EOL
}
EOL

echo "pack.sh: Formatting ${genfile}"

gofmt -s -w $genfile || echo "pack.sh: warning: gofmt error"


echo "pack.sh: done"

