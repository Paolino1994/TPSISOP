#!/bin/bash
nombre=${0##*/}
MAEDIR="datos"
ARRIDIR="arribados" #estos despues hay que borrarlos y usar las variables globales
OKDIR="aceptados"
NOKDIR="rechazados"
SLEEPTIME=5 #para probar, esto tiene que ser una variable global, despues borrar
function ver_maestros {
			consvalido=0
			contador=1
			consesionarios_arch=`more  "$MAEDIR/concesionarios.csv.xls"`
			cons=`echo "$consesionarios_arch"  | cut -d ";" -f 2`
			indicfin=0
			while [ $indicfin -eq 0 ]
			do
				cons2=`echo $cons | cut -d " " -f $contador`
				contador=`expr $contador + 1`
				if [ -z "$cons2" ]; then #si no esta vacio entra
					indicfin=1
				else		
					if [ $cons2 -eq $consesionario ] ; then
						#echo "consesionario $consesionario valido"
						indicfin=1
						consvalido=1 #el consesionario es valido
					fi
				fi
			done
			if [ $consvalido -ne 1 ] ; then
				#echo "consesionario $consesionario NO valido"
				consvalido=0
			fi
           }
           
function ver_adju {
				contador=1
				adjuArch=`more  "$MAEDIR/FechasAdj.csv.xls"`
				adjuTodas=`echo "$adjuArch"  | cut -d ";" -f 1`
				adjuValida=0				
				indicfin=0
				while [ $indicfin -eq 0 ]
				do
					adju=`echo $adjuTodas | cut -d " " -f $contador`
					
					contador=`expr $contador + 1`
					if [ -z "$adju" ]; then #si no esta vacio entra
						indicfin=1
						#echo $ultima
						separar=`echo $ultima | cut -d "/" -f3 ``echo $ultima | cut -d "/" -f2 ``echo $ultima | cut -d "/" -f1 `
						#echo $separar
					else		
						#if [ $cons2 -eq 3780 ] ; then
						#	echo "consesionario 3780 valido"
						#	indicfin=1
						#fi
					ultima=$adju
					fi
				done
				
				if [ $fecha -gt $separar ] ; then
						adjuValida=1 #fecha de adjudicacion valida
				fi
				#echo $fecha $separar $adjuValida
}

#echo "recibir"
archivosAceptados=0
NoTerminaRecibir=1
while [ $NoTerminaRecibir -eq 1 ]; do
a=`ls -G $ARRIDIR`
#echo $a
#echo ${#a} # longitud del array
i=1
indicvacia=0
GrabarBitacora.sh RecibirOfertas "itearacion NRO X" #aca grabo la iteracion, cuadnmo se hace preparar ambiente se deberia crear un avariable golbal llamada iteracionNRO"
#iteracionNRO=$(echo $iteracionNRO + 1 | bc) #le sumo 1 a la iteracion
while [ $indicvacia -eq 0 ]
do
	arch=`echo $a  | cut -d " " -f $i`
	i=`expr $i + 1`
	if [ -n "$arch" ]; then #si no esta vacio entra
		indicvacia=0    
		#echo "$arch"
		consesionario=`echo $arch  | cut -d "_" -f 1`
		#echo $consesionario
		case ${consesionario#[-+]} in #veo si son solo numeros
			*[!0-9]* ) malConsesionario=1 ;;
			* ) malConsesionario=0 ;;
		esac
		if [ $malConsesionario -eq 1 ] # si se tiene que comprobar la longitud le agrego  "-o ${#consesionario} -ne 4" 
		then #aca veo la parte del consesionario
			#echo "$arch no se acepta por mal consesionario"
			#MoverArchivo $ARRIDIR/$arch $NOKDIR
			GrabarBitacora.sh $nombre "$arch fue rechazado por que el conserionario no eran numeros"
		else
			
			ver_maestros #veo si el consesionario esta en maestros, si esta pone a consvalido en 1
			#me tengo que fijar si esta en el maestor de consesionarios, no se el formato del archivo!!
			fecha=`echo $arch  | cut -d "_" -f 2 | cut -d "." -f 1`
			#echo $parte
			
			if [ ${#fecha} -ne 8 -o $consvalido -ne 1 ]; then #aca veo la parte de la fecha
				if [ $consvalido -eq 0 ] ; then
					#echo "$arch no se acepta por que el consesionario no esta en la tabla"
					#MoverArchivo $ARRIDIR/$arch $NOKDIR
					GrabarBitacora.sh $nombre "$arch fue rechazado por que ell consecionario no esta en la tabla maestra"
				else
					#echo "$arch no se acepta por fecha mal formato"
					#MoverArchivo $ARRIDIR/$arch $NOKDIR
					GrabarBitacora.sh $nombre "$arch fue rechazado por mla formato"
				fi
				
			else
				#me fijo si la fecha es correcta
				date -d $fecha +%Y%m%d > /dev/null  2>&1 # aca comparo me falta ver si la fecha es correcta, todavia no anda
				#echo $validacionFecha
				resultadoEvaluacion=$? #aca veo si anduvo bien
				#echo $resultadoEvaluacion
				
				if [ $resultadoEvaluacion -eq 0 ]; then    #evalua que la fecha sea valida
					fechaHoy=`date +"%Y%m%d"`
					ver_adju # me fijo si la fecha es mayor a la adjudicacion
					
					if [ $fecha -gt $fechaHoy -o $adjuValida -ne 1 ] ; then #evaluar que la fecha sea menor a la actual y que la adjudicacion sea mayor
						if [ $fecha -gt $fechaHoy ] ; then
							#echo "$arch no se acepta por fecha mayor a actual"
							#MoverArchivo $ARRIDIR/$arch $NOKDIR
							GrabarBitacora.sh $nombre "$arch fue rechazado por fecha mayor a actual"
						else
							#echo "$arch no se acepta por fecha menor a ultima fecha de adjudicacion"
							#MoverArchivo $ARRIDIR/$arch $NOKDIR
							GrabarBitacora.sh $nombre "$arch fue rechazado por fecha menor a ultima fecha de adjudicacion"
						fi
						
						#echo $parte
						#echo $fechaHoy						
					else
						
						if [ -s "$ARRIDIR/$arch" ] ;then
							isFile=$(file $ARRIDIR/$arch | cut -d\  -f2) 
							if [ $isFile = "ASCII" ] ;then
								fileExists=0
								#echo "$arch se acepta"
								#MoverArchivo $ARRIDIR/$arch $OKDIR  # es la unica forma de que este correcto
								GrabarBitacora.sh $nombre "$arch fue movido a $OKDIR"
								archivosAceptados=`expr $archivosAceptados + 1`
								
							else
								#echo "$arch no se acepta porque no es un archivo de texto"
								#MoverArchivo $ARRIDIR/$arch $NOKDIR
								GrabarBitacora.sh $nombre "$arch fue rechazado por no ser archivo de texto"
							fi
							
						else
							# codigo si no existe o es vacio
							#echo "$arch  no se acepta por archivo vacio"
							#MoverArchivo $ARRIDIR/$arch $NOKDIR
							GrabarBitacora.sh $nombre "$arch fue rechazado por estar vacio"
						fi
					fi
				else
					#echo "$arch no se acepta por fecha no valida"
					#MoverArchivo $ARRIDIR/$arch $NOKDIR
					GrabarBitacora.sh $nombre "$arch fue rechazado por fecha no valida"
				fi
			fi
		fi
	else
	#termina el ciclo cpm indicvacia=1
    #echo "empty"
    indicvacia=1
   fi
done

if [ $archivosAceptados -ne 0 ] ; then # si paso algun archivo a aceptado llama a ProcesarOfertas
	#LanzarProceso.sh ProcesarOfertas.sh
	#GrabarBitacora.sh $nombre "ProcesarOfertas corriendo bajo el no.: `pidof ProcesarOfertas.sh`"
	echo $archivosAceptados
fi

sleep $SLEEPTIME
archivosAceptados=0
done

