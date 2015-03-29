#! /bin/bash

ruta="-- path completo hasta script --"
path_p="-- path completo hasta directorio de salida p --"
path_m="-- path completo hasta directorio de salida m "

## access point level1 edifP
for octeto in {115..141}
	do
		# se verifica status del access point
		# IP -> los primeros 3 octetos de la direccion ip, de forma estatica
		status=$(nmap -sP IP."$octeto" | grep "Nmap done:" | awk '{print $6}')
		if [[ "$status" = "(1" ]]; then
			python2.7 "$ruta"lvl1_mon.py IP.$octeto  | grep -A 55 'vap_name\[1\]\[0\]' > "$path_p"out_statics_ap
	
			estudiantes=$(cat "$path_p"/out_statics_ap | grep -A 4 Estudiantes_USM | grep sta_num | awk -F "'" '{print $2}')
			if [[ $estudiantes = "" ]]; then estudiantes=0; fi
			profesores=$(cat "$path_p"out_statics_ap | grep -A 4 Profesores_USM | grep sta_num | awk -F "'" '{print $2}')
			if [[ $profesores = "" ]]; then profesores=0; fi
			visitas=$(cat "$path_p"out_statics_ap | grep -A 4 Visitas_USM | grep sta_num | awk -F "'" '{print $2}')
			if [[ $visitas = "" ]]; then visitas=0; fi
			eduroam=$(cat "$path_p"out_statics_ap | grep -A 4 eduroam | grep sta_num | awk -F "'" '{print $2}')
			if [[ $eduroam = "" ]]; then eduroam=0; fi

			echo "$(date | awk '{print $1 , $4}');$estudiantes;$profesores;$visitas;$eduroam;$(($estudiantes+$profesores+$visitas+$eduroam));" >> "$path_p"IP.$octeto.csv

			rm "$path_p"out_statics_ap;
		fi
done

## access point level1 edifm
for octeto in {11..23}
	do
		status=$(nmap -sP IP."$octeto" | grep "Nmap done:" | awk '{print $6}')
		if [[ "$status" = "(1" ]]; then
			python2.7 "$ruta"lvl1_mon.py IP.$octeto  | grep -A 55 'vap_name\[1\]\[0\]' > "$path_m"out_statics_ap
	
			estudiantes=$(cat "$path_m"/out_statics_ap | grep -A 4 Estudiantes_USM | grep sta_num | awk -F "'" '{print $2}')
			if [[ $estudiantes = "" ]]; then estudiantes=0; fi
			profesores=$(cat "$path_m"out_statics_ap | grep -A 4 Profesores_USM | grep sta_num | awk -F "'" '{print $2}')
			if [[ $profesores = "" ]]; then profesores=0; fi
			visitas=$(cat "$path_m"out_statics_ap | grep -A 4 Visitas_USM | grep sta_num | awk -F "'" '{print $2}')
			if [[ $visitas = "" ]]; then visitas=0; fi
			eduroam=$(cat "$path_m"out_statics_ap | grep -A 4 eduroam | grep sta_num | awk -F "'" '{print $2}')
			if [[ $eduroam = "" ]]; then eduroam=0; fi


		echo "$(date | awk '{print $1 , $4}');$estudiantes;$profesores;$visitas;$eduroam;$(($estudiantes+$profesores+$visitas+$eduroam))" >> "$path_m"IP.$octeto.csv

		rm "$path_m"out_statics_ap;
	fi
done

