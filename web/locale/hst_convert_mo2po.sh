#!/usr/bin/bash
if [ ! -e /usr/bin/xgettext ]; then
	echo " **********************************************************"
	echo " * Unable to find xgettext please install gettext package *"
	echo " **********************************************************"
	exit 3
fi

lang=${1-all}

if [ "$lang" == "all" ]; then
	languages=$(ls -d ./*/ | awk -F'/' '{print $(NF-1)}')
	for lang in $languages; do
		echo "[ * ] Update $lang "
		msgunfmt "$lang/LC_MESSAGES/hestiacp.mo" -o "$lang/LC_MESSAGES/hestiacp.po"
	done
else
	echo "[ * ] Update $lang "
	msgunfmt "$lang/LC_MESSAGES/hestiacp.mo" -o "$lang/LC_MESSAGES/hestiacp.po"
fi
