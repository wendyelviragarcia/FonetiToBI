# Creado por Juanma el 30.09.2016
# Script para crear un break index tier en formato ToBI a partir de un tier con la segmentacion en grupos fonicos generada por SegProso
# Esta preparado para ser ejecutado desde linea de comandos

form Parameters
	word Sound_file ifm_n1001_001.wav
	sentence Directory_sound /Users/juan/Desktop/prueba_silabas/
	sentence Directory_textgrid /Users/juan/Desktop/prueba_silabas/
	positive Tier_words 3
	positive Tier_syllables 3
	positive Tier_intonation_units 5
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


		#Creamos el TextGrid para los Break Index

		duracion = Get duration
		Create TextGrid: 0, 'duracion', "BreakIndex", "BreakIndex"
		#Create TextGrid... 0 duracion "BreakIndex" "BreakIndex"
		textgrid_grupos = selected ("TextGrid")

		# Rellenamos ahora el tier

		select textgrid

		num_intervalos = Get number of intervals... tier_intonation_units

		grupo_inicial = 0
		contador_grupos = 1
		etiqueta_intervalo_actual$ = ""
		etiqueta_intervalo_anterior$ = ""
		etiqueta_intervalo_siguiente$ = ""

		for cont_intervalos from 1 to num_intervalos

			etiqueta_intervalo_anterior$ = etiqueta_intervalo_actual$
			etiqueta_intervalo_actual$ = Get label of interval... 'tier_intonation_units' cont_intervalos
			#printline Etiqueta intervalo actual: 'etiqueta_intervalo_actual$'
	
			if cont_intervalos < num_intervalos
				etiqueta_intervalo_siguiente$ = Get label of interval... 'tier_intonation_units' (cont_intervalos+1)
			else
				etiqueta_intervalo_siguiente$ = ""
			endif

			if etiqueta_intervalo_actual$ <> "P"
			
				#printline Etiqueta intervalo anterior: 'etiqueta_intervalo_anterior$'
				tiempo_inicio_intervalo = Get start point... 'tier_intonation_units' cont_intervalos
				tiempo_final_intervalo = Get end point... 'tier_intonation_units' cont_intervalos

				#printline Tiempo inicial intervalo: 'tiempo_inicio_intervalo'
				#printline Tiempo final intervalo: 'tiempo_final_intervalo'

				#printline Tiempo inicio unidad entonativa: 'tiempo_inicio_unidad_entonativa'

				if etiqueta_intervalo_siguiente$ = "P"

					etiqueta_break_index$ = "4"
				else
					etiqueta_break_index$ = "3"
				endif
			
				select textgrid_grupos
				
				Insert point... 1  'tiempo_final_intervalo' 'etiqueta_break_index$'
						
				select textgrid
				
				Extract part... tiempo_inicio_intervalo tiempo_final_intervalo 1 yes
				
				textgrid_grupo = selected ("TextGrid")
		
				num_palabras = Get number of intervals... tier_words

				grupo_inicial = 0
				contador_grupos = 1
				etiqueta_palabra_actual$ = ""
				etiqueta_palabra_anterior$ = ""
				etiqueta_palabra_siguiente$ = ""

				for cont_palabras from 1 to num_palabras

					etiqueta_palabra_anterior$ = etiqueta_palabra_actual$
					etiqueta_palabra_actual$ = Get label of interval... 'tier_words' cont_palabras
					
					tiempo_final_palabra = Get end point... 'tier_words' cont_palabras

					#printline Tiempo inicial silaba: 'tiempo_inicial_silaba'
					#printline Tiempo final silaba: 'tiempo_final_silaba'

					#printline Tiempo inicio unidad entonativa: 'tiempo_inicio_unidad_entonativa'
					
					call EsPalabraTonica (cont_palabras)
					
					if es_palabra_tonica = 1
						etiqueta_break_index$ = "1"					
					else				
						etiqueta_break_index$ = "0"
						
					endif
				
					select textgrid_grupos
					
					if 'tiempo_final_palabra' <> 'tiempo_final_intervalo'

						Insert point... 1  'tiempo_final_palabra' 'etiqueta_break_index$'

					endif
			
					select textgrid_grupo							

				endfor
		
				Remove
				select textgrid
			
			endif

		endfor
		

		
		# Unimos los textgrid en uno solo

		select textgrid
		name$ = selected$ ("TextGrid")

		plus 'textgrid_grupos'
		Merge
		Rename... 'name$'
		numero_tiers = Get number of tiers
		#Duplicate tier... numero_tiers 4 BreakIndex
		Remove tier... (numero_tiers-1)
		Remove tier... (numero_tiers-2)

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

procedure EsPalabraTonica num_intervalo_tier

	#printline Entro en EsPalabraTonica
	#printline 'etiqueta_intervalo_actual$'

	es_palabra_tonica = 0

	tiempo_inicio_palabra = Get starting point... 'tier_words' num_intervalo_tier
	tiempo_final_palabra = Get end point... 'tier_words' num_intervalo_tier

	Extract part... tiempo_inicio_palabra tiempo_final_palabra 1 yes

	textGrid_palabra = selected ("TextGrid")

	num_silabas_palabra = Get number of intervals... tier_syllables

	for cont_silabas from 1 to num_silabas_palabra

		etiqueta_silaba$ = ""
		etiqueta_silaba$ = Get label of interval... 'tier_syllables' cont_silabas
		if etiqueta_silaba$ = "T"
			es_palabra_tonica = 1		
		endif
		
	endfor

	Remove
	select textgrid
	
	#printline Etiqueta silaba: 'etiqueta_silaba$'
	#printline Es palabra tonica: 'es_palabra_tonica'

endproc
