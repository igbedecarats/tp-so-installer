# copio la tabla de variables de conf como para ir probando
CURRDIR=/home/ivan/FIUBA/7508-SistemasOperativos/TP-SO
GRUPO=/home/ivan/FIUBA/7508-SistemasOperativos/TP-SO
ARRIDIR=/home/ivan/FIUBA/7508-SistemasOperativos/TP-SO
BINDIR=/home/ivan/FIUBA/7508-SistemasOperativos/TP-SO
CONFDIR=/home/ivan/FIUBA/7508-SistemasOperativos/TP-SO
DATASIZE=200
LOGDIR=/home/ivan/FIUBA/7508-SistemasOperativos/TP-SO/logs
LOGEXT=log
MAXLOGSIZE=1
USERID=carlos
RETAIL_ENV="Loaded"

# Grupo 8 Tema D
# Comando "logging"
#
# Opciones y Parámetros
#	Parámetro 1 (obligatorio): comando
#	Parámetro 2 (obligatorio): mensaje
#	Parámetro 3 (opcional): tipo de mensaje (INFO|WAR|ERR default INFO)


# Función que maneja el tamaño de los archivos de log
# PRE: Debe existir la ruta y el archivo del log
function checkLogSize (){

cd $dirLog
cantBytes=`wc -c "$nombreArchivo."$extArchLog | cut -d' ' -f1` # Tomo la cantidad de bytes que ocupa
if [ ${cantBytes:-0} -ge $maxSizeLog ]
then
	echo `date '+%m-%d-%y %T'`"-"$nombreUsuario"-"$nombreComando"-INFO-Log excedido">>$dirLog/"$nombreArchivo."$extArchLog

	bytesAcum=0
	mitadTamanio=0

	touch -c $dirLog/"$nombreArchivo."$extArchLog  

	# Calculo el tamaño en bytes del archivo de log
	while read fileLine
	do                         
		# Acumulo los bytes que van sumando las líneas del archivo
		bytesAcum=$(($bytesAcum+`echo $fileLine | wc -c`))                            
	done < $dirLog/"$nombreArchivo."$extArchLog
	
	mitadTamanio=$(($bytesAcum/2))

	bytesDeleted=0

	touch -c $dirLog/"$nombreArchivo."$extArchLog 

	# Creo el directorio temporal
	mkdir -p "$dirLog/temp"

	# Creo el archivo de log temporal
	>"$dirLog/temp/$nombreArchivo.$extArchLog"

	# Elimino las líneas más antiguas que superen el 50% del tamaño permitido
	while read fileLine
	do
		if [ $bytesDeleted -le $mitadTamanio ]
		then	
			# Sumo bytes acumulados de las lineas que tengo que eliminar hasta llegar al 50% del total
			# Voy eliminando líneas hasta sumar el 50% del total
			bytesDeleted=$(($bytesDeleted+`echo $fileLine | wc -c`))
		else
			# Escribo la línea que persiste en un archivo temporal "temp.log"
			echo "$fileLine">>$dirLog/"temp"/"$nombreArchivo."$extArchLog
		fi # [ $bytesDeleted -le $mitadTamanio ]
	done < $dirLog/"$nombreArchivo."$extArchLog

	rm $dirLog/"$nombreArchivo."$extArchLog

	$CURRDIR/mover.sh $dirLog/"temp"/"$nombreArchivo."$extArchLog $dirLog logging
	rmdir "$dirLog/temp"
fi # [ ${cantBytes:-0} -ge $maxSizeLog]
       
} # Fin checkLogSize ()

# No pueden ser más de 3 ni menos de 2 parámetros
if [ $# -gt 3 -o $# -lt 2 ]
then
	$CURRDIR/logging.sh logging " Comando $1: Cantidad de parámetros inválida." ERR
	exit 1
fi

tipoMensaje="  "
mensaje=""

# Si hay tres parámetros tengo tipo
if [ $# -eq 3 ]
then
	tipoMensaje=$(echo $3 | tr "[:lower:]" "[:upper:]")
	mensaje=$2
fi

if [ $tipoMensaje != "INFO" -a $tipoMensaje != "WAR" -a $tipoMensaje != "ERR" ]
then
	$CURRDIR/logging.sh logging " Comando $1: Tipo de mensaje inválido, se toma el default" WAR
        tipoMensaJe="INFO"

fi

# Si hay dos parámetros no tengo tipo de mensaje
if [ $# -eq 2 ]
then
	mensaje=$2
        $CURRDIR/logging.sh logging " Comando $1: No envio tipo de mensaje, se toma el default" WAR
	tipoMensaJe="INFO"
fi

# Valido que el ambiente haya sido correctamente inicializado
if [ -z "$RETAIL_ENV" ] # Si el ambiente fue inicializado, RETAIL_ENV tiene el valor "Loaded"
then
	echo "El ambiente no ha sido correctamente inicializado."
	echo "No será posible generar el archivo de log."
	exit 2
fi # [ -z "$RETAIL_ENV" ]

# Valido que el directorio de logs sea una ruta válida (no vacía)
if [ -z "$LOGDIR" ]
then
	echo "El directorio especificado para almacenar los archivos de log es nulo."
	echo "No será posible generar el archivo de log."
	exit 2
fi

# Valido que no sea vacía la cantidad de KB que pueden ocupar los archivos de log
if [ -z "$MAXLOGSIZE" ]
then
	echo "El tamaño especificado para los archivos de log es nulo."
	echo "No será posible generar el archivo de log."
	exit 2
fi

nombreArchivo="$1"
nombreComando="$1"
nombreUsuario=$USERID

dirLog="$LOGDIR" # Obtengo el directorio en donde se almacenan los logs
extArchLog="$LOGEXT" # Obtengo la extensión del archivo de log (sin .)
maxSizeLog=$(($MAXLOGSIZE * 1024)) # Obtengo el máximo tamaño que puede ocupar un archivo de log (en bytes)

#Verifico si existe el directorio de los archivos de log
if [ ! -d "$dirLog" ]
then
	#Creo el directorio
	mkdir -p "$dirLog"

	#Creo el archivo de log
	>"$dirLog/$nombreArchivo.$extArchLog"

fi #[ ! -d $dirLog ]

#Verifico si existe el archivo de log
existeLog=`ls $dirLog | grep "$nombreArchivo.$extArchLog"`
if [ -z $existeLog ]
then
	#Creo el archivo de log
	>"$dirLog/$nombreArchivo.$extArchLog"

fi #[ -z $existeLog ]

# Guardo el MENSAJE en el log
echo `date '+%m-%d-%y %T'`"-"$nombreUsuario"-"$nombreComando"-"$tipoMensaje"-"$mensaje>>$dirLog/"$nombreArchivo."$extArchLog

checkLogSize

exit 0

