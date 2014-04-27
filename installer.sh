#!/bin/bash

BASEDIR='puto'
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
	BASEDIR=$PWD
	CONFDIR='$BASEDIR/CONFDIR'
}

read -p "Ingrese un numero: "
echo "El numero ingresado es:" $REPLY
get_base_dir
echo $BASEDIR
echo $CONFDIR


