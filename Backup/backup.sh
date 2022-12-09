#!/bin/bash

# Kommentare

function hauptmenu(){
	clear
	kdialog
choice=$(kdialog --separate-output --checklist "Hauptmenü" 1 "Backup erstellen      (b)" off 2  "Backup zurückspielen   (r)" off 3 "Backupinhalt anzeigen  (s)" off 4 "Backupinhalt anzeigen (s)" off 5 "Backup löschen     (d)" off 6 "Exit   (x)");

#!if [ "$?" = 0 ]; //then
#	kdialog --msgbox "$choice";
#if [ "$?" = 1 ]; then
#	kdialog --sorry "YOU CHOSE CANCEL";
#else
#	kdialog --error "ERROR";
#fi;
	#read -p "      Eingabe: " EINGABE
}

function backup(){
    //kdialog --yesno "HELLO WORLD"

	//YN=$(echo $?)
	until [ "$YN" = "0" ]; do
		compress
		echo "         Sie wählten $METHODE"
		read -p "         Sind Sie sicher (y|n): " YN
	done 
	YN=N
	until [ "$YN" = "y" -o "$YN" = "Y" ]; do
		where2Backup		
		echo "      Sie wählten $WHERE2BACKUP"
		read -p "      Sind Sie sicher (y|n): " YN
	done 
	YN=N
	until [ "$YN" = "y" -o "$YN" = "Y" ]; do
		what2Backup		
		echo "      Sie wählten $WHAT2BACKUP"
		read -p "      Sind Sie sicher (y|n): " YN
	done

	if [ -e /usr/bin/pv ]
	then
		cd  $WHAT2BACKUP
		tar ${OPTION} - * | (pv -p --timer --rate --bytes > ${BACKUPFILE})
	else
		cd  $WHAT2BACKUP
		tar ${OPTION} ${BACKUPFILE} *
	fi
	sleep 1
}
function backuprestore(){
	clear
	echo "BACKUPRESTORE"
	sleep 1
}
function backupdelete(){
	echo "BACKUPDELETE"
	sleep 1
}

# Kompressionsalgo
function compress(){
	YESNO=N
	clear
	echo "   Backup erstellen"
	echo
	until [ "$YESNO" = "y" ]
       	do
		echo "      Kompressionsalgo wählen:"
		echo
		echo "         GZIP  (z)"
		echo "         BZIP2 (b)"
		echo "         XZ    (x)"
		echo 
		read -p "         Eingabe: " COMPRESS
		echo
		YESNO=y
		case $COMPRESS in
			z|Z)
				METHODE="GZIP"
				SUFFIX=".tgz"
				OPTION="czf"
				;;
			b|B)
				METHODE="BZIP2"
				SUFFIX=".tgbzip2"
				OPTION="cjf"
				;;
			x|X)
				METHODE="XZ"
				SUFFIX=".tgxz"
				OPTION="cJf"
				;;
			*)
				YESNO=n
		esac
	done
}

function where2Backup(){
	clear
	echo "   Backup erstellen"
	echo
	echo "      Wohin soll das Backup erstellt werden"
	echo "      (Dateipfad wie z.B. /root/backup)"
	echo
	read -p "      Eingabe: " WHERE2BACKUP
	# kompletter PFAD des Backups mit Dateiname und Suffix
	BACKUPFILE="${WHERE2BACKUP}/$(date +%Y%m%d-%H%M%S)-backup${SUFFIX}"
}	

function what2Backup(){
	clear
	echo "   Backup erstellen"
	echo
	echo "      Von was soll ein Backup erstellt werden"
	echo "      (Dateipfad wie z.B. /home/<username>)"
	echo
	read -p "      Eingabe: " WHAT2BACKUP
}

function backuplist(){
	backup2Show
	backupContent
}

function backup2Show(){
	clear
	echo "   Backups auflisten"
	echo
	echo "      Von welchem Verzeichnis soll ein Backup angezeigt werden"
	echo "      (Dateipfad wie z.B. /tmp)"
	echo
	read -p "      Eingabe: " BACKUPLIST
	echo 
	echo "      Ergebnis des find-Befehls:"
	for I in $(find ${BACKUPLIST} -maxdepth 1 \( -name "*tgz" -o -name "*xz" -o -name "*bzip2" \))
	do 
		echo "      "$I
	done	
	echo
	sleep 1
}

function backupContent(){
	echo "      Von welchem Backup soll der Inhalt angezeigt werden"
        echo "      (Dateipfad wie z.B. $I)"
        echo
        read -p "      Eingabe: " BACKUPC
        echo
	tar tf ${BACKUPC} | more
	echo
	read "      Beliebige Eingabe zum Menü"
}

while :
do
	hauptmenu
	case $choice in
		1)
			backup
			;;
		2)
			backuprestore
			;;
		3)
			backuplist
			;;
		4)
			backupdelete
			;;
		5)
			backupdelete
			;;
		6)
			backupdelete
			;;
		*)
			kdialog --continue-label "Auf Wiedersehen"
			exit
	esac
done

exit 0
