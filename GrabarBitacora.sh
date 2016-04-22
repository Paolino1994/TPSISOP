#!/bin/bash
#grabar bitacora
LOGDIR="informes" # esto desùes borrar por variables globales"
tamaniomax=50 # 5 a modo de ejemplo despues poner LOGSIZE
excedido=0 # en 0 significa que no se exedio, en 1 se exedio
if [ $# != 3 -a $# != 2 ] ; #veo si los parametros estan correctos
	then
	echo "Se ingresaron mal los parametros"
	exit 1
fi
#cambiar informes por variable global LOGDIR
log="$LOGDIR/$1.log"
#echo "se guardo en $1" # a modo de guia
if [ $# = 3 ] ;
	then
	# usuario ; Fecha y Hora ; Comando que lo llama ; Tipo de Mensaje ; Mensaje    al final del log 
	echo "`logname`; `date +"%T %e/%m/%y" ` ; $1 ; $3 ; $2" >> $log
	else
	# usuario ; Fecha y Hora ; Comando que lo llama ; Mensaje       al final del log 
	echo "`logname`; `date +"%T %e/%m/%y" ` ; $1 ; $2" >> $log
fi
#wc -l me da la longitud del archivo
lincrud=`wc -l $log`  
#el sed es para eliminar el nombre del archivo
cantlin=` echo "$lincrud" | sed 's/\ .*log//'`
while [ $cantlin -gt $tamaniomax ]; do #borra lineas de mas
	sed -i '1d' $log #borra la primera linea
	lincrud=`wc -l $log`  
	cantlin=` echo "$lincrud" | sed 's/\ .*log//'`
	#echo $cantlin $tamaniomax #control del whie
	excedido=1 #se excedio
done
if [ $excedido -eq 1 ] ; # veo si esta exedido
	then
	sed -i "1i\Log Excedido" $log
fi
#more $log # para ver que anda
exit 0



