#!/bin/bash

BASEDIR_GRUPO=''
CONFDIR=''
BINDIR=''
MAEDIR=''
NOVEDIR=''
ACEPDIR=''
INFODIR=''
RECHDIR=''
LOGDIR=''
CANT_COMP_FALTANTES=''
ESTADO_INSTALACION=''
ACEPTO_TERMINOS_Y_CONDICIONES='no'

get_base_dir() {
	BASEDIR_GRUPO=$PWD
	CONFDIR=$BASEDIR_GRUPO/conf
}

make_confdir_folder() {
	if [ -d "$CONFDIR" ]
	then
		echo "$CONFDIR found."
	else
		echo "$CONFDIR not found. Creating it!"
		mkdir $CONFDIR
	fi
}

init_installer_log_file() {
	if [ -d "$CONFDIR" ]
	then
		touch $CONFDIR/Installer.log
		#echo 'date "+%m-%d-%y %T" - Archivo $CONFDIR/Installer.log creado.' >> $CONFDIR/Installer.log
		echo "date '+%m-%d-%y %T' - Archivo $CONFDIR/Installer.log creado." >> $CONFDIR/Installer.log
	fi
}

#read -p "Ingrese un numero: "
#echo "El numero ingresado es:" $REPLY
get_base_dir
echo $BASEDIR_GRUPO
echo $CONFDIR
make_confdir_folder
init_installer_log_file


