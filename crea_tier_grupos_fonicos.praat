# Creado por Juanma el 15.01.2008
# Script para crear un tier con la segmentacion en grupos fonicos de un fichero de entrada a partir de un tier con la segmentacion en silabas que incluya las pausas
# Esta preparado para ser ejecutado desde linea de comandos

form Parameters
	word Sound_file test.wav
	sentence Directory_sound .
	sentence Directory_textgrid .
	positive Tier_syllables 2
endform

nombre_completo_fichero_entrada$ = directory_sound$+"/"+sound_file$


# Intentamos leer el fichero de sonido, y el TextGrid asociado

if fileReadable (nombre_completo_fichero_entrada$)

	Read from file... 'nombre_completo_fichero_entrada$'
	nombre_sonido$ = selected$ ("Sound")
	sound = selected ("Sound")

	nombre_completo_fichero_textgrid$ = directory_textgrid$+"/"+nombre_sonido$+".TextGrid"

	if fileReadable (nombre_completo_fichero_textgrid$)
		Read from file... 'nombre_completo_fichero_textgrid$'
		textgrid = selected ("TextGrid")


		#Creamos el TextGrid de grupos fonicos

		duracion = Get duration
		Create TextGrid... 0.0 duracion "IntonationGroups"
		textgrid_grupos = selected ("TextGrid")

		# Rellenamos ahora el tier con los grupos fonicos

		select textgrid

		num_intervalos = Get number of intervals... tier_syllables

		grupo_inicial = 0
		contador_grupos = 1
		etiqueta_intervalo_actual$ = ""
		etiqueta_intervalo_anterior$ = ""

		for cont_intervalos from 1 to num_intervalos

			etiqueta_intervalo_anterior$ = etiqueta_intervalo_actual$
			etiqueta_intervalo_actual$ = Get label of interval... 'tier_syllables' cont_intervalos

			#printline Etiqueta intervalo actual: 'etiqueta_intervalo_actual$'

			if etiqueta_intervalo_actual$ = "P"

				grupo_inicial = 1
				tiempo_inicial_pausa = Get starting point... 'tier_syllables' cont_intervalos
				tiempo_final_pausa = Get end point... 'tier_syllables' cont_intervalos
	
				#printline Tiempo inicial pausa: 'tiempo_inicial_pausa'
				#printline Tiempo final pausa: 'tiempo_final_pausa'
	
				select textgrid_grupos
		
				if cont_intervalos > 1 and etiqueta_intervalo_anterior$ <> "P"
					Insert boundary... 1 'tiempo_inicial_pausa'
					contador_grupos = contador_grupos+1					
				endif


				Set interval text... 1 contador_grupos P

				if cont_intervalos < num_intervalos
					Insert boundary... 1 'tiempo_final_pausa'
					contador_grupos = contador_grupos+1
				endif

				select textgrid


			endif


		endfor
		

		# Unimos los textgrid en uno solo

		select textgrid
		name$ = selected$ ("TextGrid")

		plus 'textgrid_grupos'
		Merge
		Rename... 'name$'
		textgrid_salida = selected ("TextGrid")

		select textgrid
		plus 'textgrid_grupos'
		plus sound
		Remove

		# Guardamos la salida en un fichero

		select textgrid_salida
		nombre_completo_fichero_salida$ = directory_textgrid$+"/"+nombre_sonido$+".TextGrid"
		Write to text file... 'nombre_completo_fichero_salida$'
		Remove
		
	else
		printline No se ha encontrado un fichero con el TextGrid.
		select sound
		Remove
	endif


	
else

	printline Error al abrir el fichero.

endif

