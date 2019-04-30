#!/bin/bash
#

LINT=$(which swiftlint)

EXITSTATUS=0

if [[ -e "${LINT}" ]]; then
	echo "SwiftLint Start..."
else
	echo "🚨 SwiftLint does not exist, download from https://github.com/realm/SwiftLint"
	exit 1
fi

RESULT=$($LINT lint --quiet)

if [ "$RESULT" == '' ]; then
	printf "✅ SwiftLint Finished.\n"
else
	echo ""
	printf "❌❌❌ SwiftLint Failed. Please check below:\n"

	while read -r line; do

		FILEPATH=$(echo $line | cut -d : -f 1)
		L=$(echo $line | cut -d : -f 2)
		C=$(echo $line | cut -d : -f 3)
		TYPE=$(echo $line | cut -d : -f 4 | cut -c 2-)
		MESSAGE=$(echo $line | cut -d : -f 5 | cut -c 2-)
		DESCRIPTION=$(echo $line | cut -d : -f 6 | cut -c 2-)
		if [ "$TYPE" == 'error' ]; then
			printf "\n☠️ $TYPE \n"
			EXITSTATUS=1
		elif [ "$TYPE" == 'warning' ]; then
			printf "\n⚠️ $TYPE \n"
			EXITSTATUS=1
		else
			printf "\nℹ️ $TYPE \n"
		fi
		printf "➡️ $FILEPATH:$L:$C: \n"
		printf "🗒 $MESSAGE - $DESCRIPTION\n"
	done <<< "$RESULT"

	printf "\nCOMMIT ABORTED. Please fix them before commiting.\n"

	exit $EXITSTATUS
fi