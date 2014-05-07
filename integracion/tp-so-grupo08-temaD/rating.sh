#!/bin/bash


CONFIGURACION=conf/installer.conf
GRUPO=`grep '^GRUPO' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'` 
MAEDIR=`grep '^MAEDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
NOVEDIR=`grep '^NOVEDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
RECHDIR=`grep '^RECHDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
ACEPDIR=`grep '^ACEPDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`
BINDIR=`grep '^BINDIR' $CONFIGURACION | sed 's-\(.*\)=\(.*\)=\(.*\)=\(.*\)-\2-g'`



#ACEPDIR=aceptados
#MAEDIR=maedir
#PROCESADAS=procesadas
#RECHDIR=rechazados
#INFODIR=infodir
#LISTAMAESTRA=listamaestra

#rm $ACEPDIR/logger.log

#rmdir $ACEPDIR --ignore-fail-on-non-empty
#rmdir $ACEPDIR/$PROCESADAS
#mkdir $INFODIR
#mkdir $INFODIR/listas
#mkdir $ACEPDIR
#mkdir $RECHDIR
#mkdir $ACEPDIR/$PROCESADAS

LOGFILE="$GRUPO/$ACEPDIR/logger.log"

ACEPTADOS=$GRUPO/$ACEPDIR

PROCESADAS="procesadas"

## Si no existe el log lo crea
if [ ! -f $LOGFILE ] 
then	
	touch $LOGFILE
fi
echo "Inicio de Rating" >> $LOGFILE # escribe que inicia el rating en el log
cantidad=$(ls -l "$GRUPO/$ACEPDIR" | grep -v total  | wc -l) # calculo la cantidad de archivos a leer
echo "Cantidad de Listas de compras a procesar:<$cantidad>" >> $LOGFILE # escribo la cantidad de listas a procesar
for file in $(ls -1 $GRUPO/$ACEPDIR  ) # recorro todos los files en la carpeta de aceptados
do
	if (file $GRUPO/$ACEPDIR/$file | grep 'usuario.*') #lo proceso si tiene el formato correcto
	then
		echo "Archivo a procesar: <$file>" >> $LOGFILE # escribo el nombre del archivo que estos procesando
		if [ -s $GRUPO/$ACEPDIR/$file ] # si existe y no esta vacio
		then	
			if [ -f $GRUPO/$ACEPDIR/$PROCESADAS/$file ] # si esta duplicado, se lo rechaza
			then
				rechazado=1 # se rechaza el archivo por duplicado
				echo "Se rechaza el archivo $file por estar DUPLICADO" >> $LOGFILE
			else
				echo "Procesando archivo $file"	
				lineaactual=1 # linea actual que se procesa
				while read line	# recorre todas las lineas del archivo
				do 
					#coincidenciatotal=0					
					numdepalabras=`echo -n "$line" | wc -w | sed 's/ //g' ` # cantidad de palabras de la linea
					line=`echo $line | awk '{print tolower($0)}'` # la pongo en minusculas
					uno=1
					coincidencia=1
					for word in $line; do # recorro las palabras de la linea
						if [ $coincidencia = 1 ]; then # si vienen coincidiendo todas, entra, si una ya no se encontro se sale
							coincidencia=0 
							#numerofila=1
							line2=`sed -n ''$lineaactual'p' listamaestra`; # se agarra la linea que se esta procesando en la lista maestra
							line2=`echo $line2 | awk '{print tolower($0)}'` #pasa a minuscula todo
							#echo $line2
							for word2 in $line2; do
									#echo "word2 es $word2"
									#echo "Word es $word"
									#shopt -s nocaseglob
									#echo "COMPARANDO $word con $word2 "
									ultimapalabrarenglon=`echo ${line##* }` # agarro la ultima palabra del renglon
									if [ "$word" = "$word2" ] #comparo la palabra actual del archivo procesando y me fijo si esta en el word 2
									then	
										echo "Coincidencia entre $word y $word2"
										coincidencia=1
										#ultimapalabrarenglon=`echo ${line##* }`
									fi
									if [ "$word" = "$ultimapalabrarenglon" ] && [ $coincidencia=1 ]; then
											ultimapalabra=`echo ${line##* }`
											numero_lista_unidades=0
											while read line4 # RECORRO LA LISTA DE CONVERSIONES
											do 
												numero_lista_unidades=$(($numero_lista_unidades+$uno))							
												for word4 in $line4; do # recorro las palabras de esa linea
													if [ $ultimapalabra = $word4 ]; then
															#echo "El numero de fila en la lista d unidades es $numero_lista_unidades"
															linea_donde_buscar=`sed -n ''$numero_lista_unidades'p' $MAEDIR/um.tab`;
															for word2 in $line2; do
																if [ "$word4" = "$ultimapalabra" ]; then
																	coincidencia=1
																fi
															done
													fi							
												done
												linea_actual=$(($linea_actual+$uno)) 
											done	< $GRUPO/$MAEDIR/um.tab
									#else
									#	coincidencia=0
									#	continue
									
								fi
							done 
							if [ "$coincidencia" = 0 ]; then
								echo "=================== NO COINCIDE ========================"
								
							fi
						fi
					done
					if [ $coincidencia = 1 ]; then #si llego hasta aca con coincidencia igual a 1 es porque encontro todas las palabras
						echo "----------- COINCIDEN --------------------"
						touch $GRUPO/$INFODIR/listas/$file
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
						#echo "PRECIO ES $precio"
						echo "$nroItem $line $line2 $Precio " >> $GRUPO/$INFODIR/listas/$file
					fi
					uno=1
					lineaactual=$(($lineaactual+$uno))
				done < $GRUPO/$ACEPDIR/$file
				#mv $ACEPDIR/$file --target-directory=$ACEPDIR/$PROCESADAS # MOVERLO CON MOVER
				$GRUPO/$BINDIR/mover.sh $GRUPO/$ACEPDIR/$file $GRUPO/$ACEPDIR/$PROCESADAS 		
			fi
		else
			echo "Se rechaza el archivo $file por estar VACIO" >> $LOGFILE
			$GRUPO/$BINDIR/mover.sh $GRUPO/$ACEPDIR/$file $GRUPO/$RECHDIR
			#mv $ACEPDIR/$file --target-directory=$RECHDIR

		fi
	else
		if [ ! -d $GRUPO/$ACEPDIR/$file ] # si no es un directorio lo mueve
		then
			if [ $GRUPO/$ACEPDIR/$file != $LOGFILE ] # si no es el log lo mueve
			then
				echo "ENTRA ACA CON $file"	
				echo "Se rechaza el archivo $file por formato invalido" >> $LOGFILE 
				#mv $ACEPDIR/$file --target-directory=$RECHDIR # mueve el archivo a rechazados
				$GRUPO/$BINDIR/mover.sh $GRUPO/$ACEPDIR/$file $GRUPO/$RECHDIR
			fi
		fi
	fi
done

echo "Fin del Rating" >> $LOGFILE





