#!/bin/bash


CONFIGURACION=../conf/installer.conf
 

GRUPO=`grep '^GRUPO' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
MAEDIR=`grep '^MAEDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
NOVEDIR=`grep '^NOVEDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
RECHDIR=`grep '^RECHDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
ACEPDIR=`grep '^ACEPDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
BINDIR=`grep '^BINDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`


PROCESADAS=procesadas
INFODIR=infodir
LISTAMAESTRA=listamaestra
LOGFILE="$GRUPO/$ACEPDIR/logger.log"
ACEPTADOS=$GRUPO/$ACEPDIR


$GRUPO/$BINDIR/logging.sh rating "Inicio de Rating" INFO

cantidad=$(ls -l "$GRUPO/$ACEPDIR" | grep -v total  | wc -l) # calculo la cantidad de archivos a leer

$GRUPO/$BINDIR/logging.sh rating "Cantidad de Listas de compras a procesar:<$cantidad>" INFO
for file in $(ls -1 $GRUPO/$ACEPDIR  ) # recorro todos los files en la carpeta de aceptados
do
	if (file $GRUPO/$ACEPDIR/$file | grep 'usuario.*') #lo proceso si tiene el formato correcto
	then
		$GRUPO/$BINDIR/logging.sh rating "Archivo a procesar: <$file>" 
		if [ -s $GRUPO/$ACEPDIR/$file ] # si existe y no esta vacio
		then	
			if [ -f $GRUPO/$ACEPDIR/$PROCESADAS/$file ] # si esta duplicado, se lo rechaza
			then
				rechazado=1 # se rechaza el archivo por duplicado
				$GRUPO/$BINDIR/logging.sh rating "Se rechaza el archivo $file por estar DUPLICADO"
			else
				echo "Procesando archivo $file"	
				lineaactual=1 # linea actual que se procesa
				while read line	# recorre todas las lineas del archivo
				do 
					numdepalabras=`echo -n "$line" | wc -w | sed 's/ //g' ` # cantidad de palabras de la linea
					line=`echo $line | awk '{print tolower($0)}'` # la pongo en minusculas
					uno=1
					coincidencia=1
					for word in $line; do # recorro las palabras de la linea
						if [ $coincidencia = 1 ]; then # si vienen coincidiendo todas, entra, si una ya no se encontro se sale
							coincidencia=0 
							line2=`sed -n ''$lineaactual'p' $GRUPO/$MAEDIR/precios.mae`; # se agarra la linea que se esta procesando en la lista maestra
							line2=`echo $line2 | awk '{print tolower($0)}'` #pasa a minuscula todo
							for word2 in $line2; do
									ultimapalabrarenglon=`echo ${line##* }` # agarro la ultima palabra del renglon
									if [ "$word" = "$word2" ] #comparo la palabra actual del archivo procesando y me fijo si esta en el word 2
									then	
										#echo "Coincidencia entre $word y $word2"
										coincidencia=1
									fi
									if [ "$word" = "$ultimapalabrarenglon" ] && [ $coincidencia=1 ]; then
											ultimapalabra=`echo ${line##* }`
											numero_lista_unidades=0
											while read line4 # RECORRO LA LISTA DE CONVERSIONES
											do
												if (echo "$line4" | grep "$ultimapalabrarenglon" ) ; then
													coincidencia=1
												fi
											done	< $GRUPO/$MAEDIR/um.tab
									fi
								done 
							if [ "$coincidencia" = 0 ]; then
								echo "=================== NO COINCIDE ========================"
								
							fi
						fi
					done
					if [ $coincidencia = 1 ]; then #si llego hasta aca con coincidencia igual a 1 es porque encontro todas las palabras
						echo "=================== COINCIDEN ========================"
						touch $INFODIR/listas/$file
						linea_actual=1					
						while read line3
						do 
							for word3 in $line3; do
								if [ $word3 = $word ]; then
									numerodelineaenprecios=$linea_actual
								fi				
							done
							linea_actual=$(($linea_actual+$uno)) 
						done	< $GRUPO/$MAEDIR/precios.mae				
						lineaenprecios=`sed -n ''$numerodelineaenprecios'p' $GRUPO/$MAEDIR/precios.mae`;
						nroItem=`echo $lineaenprecios | cut -f 1 -d " "`
						Precio=`echo ${lineaenprecios##* }`
						echo "$nroItem $line $line2 $Precio " >> $INFODIR/listas/$file
					fi
					uno=1
					lineaactual=$(($lineaactual+$uno))
				done < $GRUPO/$ACEPDIR/$file
				$GRUPO/$BINDIR/mover.sh $GRUPO/$ACEPDIR/$file $GRUPO/$ACEPDIR/$PROCESADAS 		
			fi
		else
			$GRUPO/$BINDIR/logging.sh rating "Se rechaza el archivo $file por estar VACIO" WAR
			$GRUPO/$BINDIR/mover.sh $GRUPO/$ACEPDIR/$file $GRUPO/$RECHDIR
		fi
	else
		if [ ! -d $GRUPO/$ACEPDIR/$file ] # si no es un directorio lo mueve
		then
			if [ $GRUPO/$ACEPDIR/$file != $LOGFILE ] # si no es el log lo mueve
			then
				$GRUPO/$BINDIR/logging.sh rating "Se rechaza el archivo $file por formato invalido" WAR
				$GRUPO/$BINDIR/mover.sh $GRUPO/$ACEPDIR/$file $GRUPO/$RECHDIR
			fi
		fi
	fi
done

$GRUPO/$BINDIR/logging.sh rating "Fin del Rating" INFO




