#!/bin/bash
#echo "recibir"
NoTerminaRecibir=1
while [ $NoTerminaRecibir -eq 1 ]; do
a=`ls -G arribados`
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
		if [ ${#consesionario} -ne 4 ]; then #aca veo la parte del consesionario
			echo "no se acepta por mal consesionario"
			#MoverArchivo ....... #Falta agregar esto
			#me tengo que fijar si esta en el maestor de consesionarios, no se el formato del archivo!!
		else
			fecha=`echo $arch  | cut -d "_" -f 2 | cut -d "." -f 1`
			#echo $parte
			if [ ${#fecha} -ne 8 ]; then #aca veo la parte de la fecha
				echo "no se acepta por fecha mal formato"
				#MoverArchivo ....... #Falta agregar esto
			else
				#me fijo si la fecha es correcta
				validacionFecha=$(date -d "$fecha" +%y%m%d) # aca comparo me falta ver si la fecha es correcta, todavia no anda
				#echo $validacionFecha
				resultadoEvaluacion=$? #aca veo si anduvo bien
				#echo $resultadoEvaluacion
				if [ $? -eq 0 ]; then    #evalua que la fecha sea valida
					fechaHoy=`date +"%Y%m%d"`
					if [ $fecha -gt $fechaHoy ] ; then #evaluar que la fecha sea menor a la actual
						echo "$arch no se acepta por fecha mayor a actual"
						#MoverArchivo ....... #Falta agregar esto
						#echo $parte
						#echo $fechaHoy						
					else
						#echo "$arch se acepta"
						if [ -s "arribados/$arch" ] ;then
							# Codigo si existe y no es vacio
							echo "$arch se acepta"
							#MoverArchivo ....... #Falta agregar esto CORRECTO
						else
							# codigo si no existe o es vacio
							echo "$arch  no se acepta por archivo vacio"
							#MoverArchivo ....... #Falta agregar esto INCORRECTO
						fi
					fi
				else
					echo "no se acepta por fecha no valida"
					#MoverArchivo ....... #Falta agregar esto
				fi
			fi
		fi
	else
	#termina el ciclo cpm indicvacia=1
    #echo "empty"
    indicvacia=1
   fi
done
SLEEPTIME=5 #para probar, esto tiene que ser una variable global, despues borrar
sleep $SLEEPTIME
done

