#!/bin/bash
##
# Generate the pk3 sources list for the Flatpak Builder manifiest.
#
# Clone git.xonotic.org/xonotic/xonotic-maps.pk3dir.git and then place
# this file within its directory and run it from the command line.
# The list should match the Xonotic checkout you are using. So if it
# is not the HEAD of master, checkout the commit you want first then
# run this script.
#
# The sources manifiest will be output in the same directory as
# `xonotic-pk3.sources.json`. Copy that file to the Flatpak builder
# with the org.xonotic.Xonotic.json and build!
#
# NOTE
# In order to generate the file checksum values the maps have to be
# downloaded. The files are downloaded to `tmp-maps-COMMITHASH`. You
# can delete that directory once the source manifiest has been
# generated.
#

bspdir="data"
url_http="http://beta.xonotic.org/autobuild-bsp/"
sourcesjsonfile="xonotic-pk3.sources.json"

make_source()
{
	url=$1
	destdir=$2
	commithash=$3
	tmpmapdir="tmp-maps-$commithash"
	pkgname="${url##*/}"

	mkdir -p "$tmpmapdir"

	if [ ! -f "$tmpmapdir/$pkgname" ]; then
		# Download the file so we can generate the checksum value.
		if ! wget -c -P "$tmpmapdir/" "$url"; then
			echo "WARNING: could not download $url., maybe not ready yet."
			return 1
		fi
	fi

	checksum=$(sha256sum "$tmpmapdir/$pkgname" | cut -d " " -f 1)

	echo "    {"
	echo "      \"type\": \"file\","
	echo "      \"dest\": \"$destdir\","
	echo "      \"url\": \"$url\"",
	echo "      \"sha256\": \"$checksum\""
	echo "    }"
}

generate_manifest_sources()
{
	echo "Generating map manifest sources..."

	# Init the file.
	echo "  [" > "$sourcesjsonfile"

	commithash=$1
	# Get the real commit hash.
	if [ "$commithash" = "HEAD" ]; then
		commithash=`git rev-parse --verify HEAD`
	fi

	url=$2
	destdir=$3

	for F in `git show "${commithash}:maps/"`; do
		case "$F" in
			*.map.options)
				;;
			*)
				continue
				;;
		esac
		M=${F%.map.options}
		blobhash=`git rev-parse --revs-only "${commithash}:maps/$M.map.options" || true`-`git rev-parse --revs-only "${commithash}:maps/$M.map" || true`
		case "$blobhash" in
			-*)
				;;
			*-)
				;;
			*)

				if ! buildersource="$(make_source "$url$M-$blobhash.pk3" "$destdir" "$commithash")"; then
					echo "An error has occured."
					echo "$buildersource"
				else
					echo "$buildersource," >> "$sourcesjsonfile"
				fi
				;;
		esac
	done

	# Remove the trailing comma.
	sed -i '$ s/.$//' "$sourcesjsonfile"

	echo "  ]" >> "$sourcesjsonfile"
}

generate_manifest_sources "HEAD" "$url_http" "$bspdir"
