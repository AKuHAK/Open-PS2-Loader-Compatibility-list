#!/bin/bash
rm -rf *.md
rm -rf *.JSON
rm -rf *.MDUMMY
echo Downloading Report number "$1"
wget -q --show-progress "https://api.github.com/repos/ps2homebrew/Open-PS2-Loader-Compatibility-list/issues/$1" -O REPORT.JSON
dos2unix REPORT.JSON
echo Processing data...
jq -r '.body' REPORT.JSON > BODY.MDUMMY
awk '/^### */{ close(out); out=$2".md" } out!=""{print > out}' BODY.MDUMMY
read -p "Press any key to resume ..."
echo MDs
ls *.md
echo END MDs
read -p "Press any key to resume ..."
for a in *.md
do
sed -i '/^###/d' "$a"
sed -i '/^\s*$/d' "$a"
sed -i '/\/n$/d;' "$a"
done
read -p "Press any key to resume ..."
declare TESTERNAME=$(jq .user.login REPORT.JSON)
declare TESTERURL=$(jq .user.html_url REPORT.JSON)
declare TESTER="[${TESTERNAME}](${TESTERURL})"
declare SOURCEURL=$(jq .html_url REPORT.JSON)
declare SOURCE="[#$1](${SOURCEURL})"
declare ELF=$(head -n 1 Game.md)
declare REDUMPELF="${ELF//.}"
declare REDUMPELF="${REDUMPELF//_/-}"
declare REDUMPLINK="http://redump.org/discs/serial/${REDUMPELF}"
declare PLAYABLE=$(head -n 1 Gameplay.md)
declare TITLE=$(head -n 1 Title.md)
declare DEVICES=$(paste -s -d ' ' Devices.md)
declare OPL=$(head -n 1 OPL.md)
declare OPLBETA=$(head -n 1 BETA.md)
declare CONSOLE_MODEL=$(head -n 1 Console.md)
declare FORMAT=$(head -n 1 Image.md)
declare MEDIA=$(head -n 1 Media.md)
read -p "Press any key to resume ..."
if grep -q "_No response_" Compatibility.md
then
	echo - No compatibility modes provided
else
	declare COMPAT_MODES=$(paste -s -d ' ' Compatibility.md)
fi
read -p "Press any key to resume ..."
if grep -q "_No response_" comments.md
then
	echo - No comments provided
else
	declare COMMENTS=$(paste -s -d ' ' comments.md)
fi
read -p "Press any key to resume ..."
sed -ni '/\[X\]/p' features.md
for A in VMC PADEMU PADMACRO IGR GSM
do
	if grep -q "$A" features.md
	then
	declare $A=YES
	else
	declare $A=NO
	fi
done
echo "--------------------{ SUMMARY }--------------------"
echo TESTER  		- "$TESTER" -
echo TITLE  		- "$TITLE" -
echo ELF 			- "$ELF" -
echo DEVICES 		- "$DEVICES" -
echo FORMAT 		- "$FORMAT" -
echo MEDIA 			- "$MEDIA" -
echo OPL VERSION	- "$OPLBETA $OPL" -
echo ---
echo VMC 			- "$VMC" -
echo PADEMU 		- "$PADEMU" -
echo PADMACRO 		- "$PADMACRO" -
echo IGR 			- "$IGR" -
echo GSM 			- "$GSM" -
echo ---
echo COMPAT_MODES 	- "$COMPAT_MODES" -
echo COMMENTS 		- "$COMMENTS" -
read -p "Press any key to resume ..."
if [[ "$TITLE" =~ ^[a-z]|[A-Z].* ]]; then
FSTCHAR=${TITLE:0:1}
FSTCHAR=${FSTCHAR^^}
else
FSTCHAR=NUMBERED
fi
echo game goes into folder $FSTCHAR

FILETARGET="../List/$FSTCHAR/$ELF.md"
echo file path "$FILETARGET"
if [ -f "$FILETARGET" ]
then
	echo "$FILETARGET Exists, skipping creation"
else
	echo "$FILETARGET doesnt exist, creating new file with game title as heading"
	echo "[$ELF](${REDUMPLINK}) - $TITLE">"$FILETARGET"
	echo "=">>"$FILETARGET"
	echo "">>"$FILETARGET"
	echo appending table header liquid macro
	cat heading.TEMPLATE >> "$FILETARGET"
fi

echo "| $MEDIA | $FORMAT | $OPLBETA $OPL | $DEVICES | $COMPAT_MODES | $VMC | $IGR | $PADEMU | $PLAYABLE | $TESTER | $CONSOLE_MODEL | $COMMENTS | $SOURCE ">>"$FILETARGET"
