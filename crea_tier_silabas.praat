# Creado por Juanma el 11.01.2008
# Script para crear un tier con la segmentacion en silabas de un fichero de entrada a partir de un tier con la transcripcion fonetica
# Esta preparado para ser ejecutado desde linea de comandos
# Modificado por Juanma el 24.08.2011
# Ahora el limite de palabra actua como barrera para la silabificacion

form Parameters
	word Sound_file ifm_n1001_001.wav
	sentence Directory_sound /Users/juan/Desktop/prueba_silabas/
	sentence Directory_textgrid /Users/juan/Desktop/prueba_silabas/
	positive Tier_transcription 2
	positive Tier_words 1
	word Phonetic_alphabet SAMPA
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


		#Creamos el TextGrid de silabas

		duracion = Get duration
		Create TextGrid... 0.0 duracion "Syllables"
		textgrid_silabas = selected ("TextGrid")

		# Empezamos a marcar las sílabas. Ahora mismo se intenta seguir el criterio de agrupacion en silabas del Segre.

		select textgrid

		num_palabras = Get number of intervals... tier_words

		final_silaba = 0
		hay_nucleo = 0
		contador_silabas = 0
		etiqueta_silaba$= ""

		for cont_palabras from 1 to num_palabras

			select textgrid
			tiempo_inicio_palabra = Get start point... 'tier_words' cont_palabras
			tiempo_final_palabra = Get end point... 'tier_words' cont_palabras

			etiqueta_palabra_actual$ = Get label of interval... 'tier_words' cont_palabras
			#printline Palabra actual: 'etiqueta_palabra_actual$'

			Extract part... tiempo_inicio_palabra tiempo_final_palabra  yes
			textgrid_palabra = selected ("TextGrid")
			select textgrid_palabra

			num_intervalos = Get number of intervals... tier_transcription


			for cont_intervalos from 1 to num_intervalos

				etiqueta_intervalo_actual$ = Get label of interval... 'tier_transcription' cont_intervalos
				call TipoSonido 'etiqueta_intervalo_actual$' 'phonetic_alphabet$'
				tipo_sonido_actual$ = tipo_sonido$

				#printline Numero intervalo: 'cont_intervalos'
				#printline Sonido actual: 'etiqueta_intervalo_actual$'
				#printline Tipo sonido actual: 'tipo_sonido_actual$'
				
				if tipo_sonido_actual$ = "Silencio"
					
					final_silaba = 1
					etiqueta_silaba$= "P"
					
				endif

				if  cont_intervalos <=  (num_intervalos-1)
					etiqueta_intervalo_posterior1$ = Get label of interval... 'tier_transcription' (cont_intervalos+1)
					call TipoSonido 'etiqueta_intervalo_posterior1$' 'phonetic_alphabet$'
					tipo_sonido_posterior1$	= tipo_sonido$
				else
					tipo_sonido_posterior1$ = "Silencio"
				endif

				#printline Tipo sonido posterior 1: 'tipo_sonido_posterior1$'

				if cont_intervalos <= (num_intervalos-2)
					etiqueta_intervalo_posterior2$ = Get label of interval... 'tier_transcription' (cont_intervalos+2)
					call TipoSonido 'etiqueta_intervalo_posterior2$' 'phonetic_alphabet$'
					tipo_sonido_posterior2$ = tipo_sonido$
				else

					tipo_sonido_posterior2$ = "Silencio"

				endif

				#printline Tipo sonido posterior 2: 'tipo_sonido_posterior2$'

				if tipo_sonido_actual$ = "VocalTonica" or tipo_sonido_actual$ = "VocalAtona" or tipo_sonido_actual$ = "VocalTonica2"

					hay_nucleo = 1

					if tipo_sonido_actual$ = "VocalTonica"

						etiqueta_silaba$= "T"

					endif

					if tipo_sonido_posterior1$ = "Silencio"

						final_silaba = 1

					endif

					if tipo_sonido_posterior1$ = "VocalTonica" or tipo_sonido_posterior1$ = "VocalAtona" or tipo_sonido_posterior1$ = "VocalTonica2"

						final_silaba = 1

					else

						if tipo_sonido_posterior1$ = "Consonante" or tipo_sonido_posterior1$ = "Semivocal"

							if tipo_sonido_posterior1$ = "Consonante"


								if tipo_sonido_posterior2$ = "VocalTonica" or tipo_sonido_posterior2$ = "VocalAtona" or tipo_sonido_posterior2$ = "VocalTonica2" or tipo_sonido_posterior2$ = "Semivocal"

									final_silaba = 1

								else

									if tipo_sonido_posterior2$ = "Consonante"

										if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "B" or etiqueta_intervalo_posterior1$ = "G" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f" or etiqueta_intervalo_posterior1$ = "v"

											if etiqueta_intervalo_posterior2$ = "r" or etiqueta_intervalo_posterior2$ = "l"

												final_silaba = 1

											endif

										endif


										if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "D" or etiqueta_intervalo_posterior1$ = "t" 

											if etiqueta_intervalo_posterior2$ = "r"

												final_silaba = 1

											endif

										endif

									endif

								endif

							endif

							if tipo_sonido_posterior1$ = "Semivocal"

								if tipo_sonido_posterior2$ = "VocalTonica" or tipo_sonido_posterior2$ = "VocalTonica2"

									final_silaba = 1

								endif

							endif

						endif

					endif

				endif


				if tipo_sonido_actual$ = "Consonante" or tipo_sonido_actual$ = "Semivocal"


					if tipo_sonido_posterior1$ = "Silencio"

						final_silaba = 1

					endif

					if tipo_sonido_posterior1$ = "Consonante" and hay_nucleo = 1


						if tipo_sonido_posterior2$ = "VocalTonica" or tipo_sonido_posterior2$ = "VocalAtona" or tipo_sonido_posterior2$ = "VocalTonica2" or tipo_sonido_posterior2$ = "Semivocal"

							final_silaba = 1

						endif

						if tipo_sonido_posterior2$ = "Consonante"

							if etiqueta_intervalo_posterior1$ = "b" or etiqueta_intervalo_posterior1$ = "g" or etiqueta_intervalo_posterior1$ = "B" or etiqueta_intervalo_posterior1$ = "G" or etiqueta_intervalo_posterior1$ = "p" or etiqueta_intervalo_posterior1$ = "k" or etiqueta_intervalo_posterior1$ = "f" or etiqueta_intervalo_posterior1$ = "v"

								if etiqueta_intervalo_posterior2$ = "r" or etiqueta_intervalo_posterior2$ = "l"

									final_silaba = 1

								endif

							endif


							if etiqueta_intervalo_posterior1$ = "d" or etiqueta_intervalo_posterior1$ = "D" or etiqueta_intervalo_posterior1$ = "t" 

								if etiqueta_intervalo_posterior2$ = "r"

									final_silaba = 1

								endif

							endif

						endif


					endif

					if tipo_sonido_actual$ = "Semivocal" and tipo_sonido_posterior1$ = "Semivocal" and tipo_sonido_posterior2$ = "VocalTonica" and hay_nucleo = 1

						final_silaba = 1

					endif


				endif

				if final_silaba = 1

					#printline Hay final silaba
					tiempo_final_silaba = Get end point... 'tier_transcription' cont_intervalos
					inicio_silaba = 1

					select textgrid_silabas

					if cont_palabras < num_palabras
						Insert boundary... 1 'tiempo_final_silaba'
					endif

					contador_silabas = contador_silabas+1

					Set interval text... 1 contador_silabas 'etiqueta_silaba$'
					
					select textgrid_palabra

					final_silaba = 0
					etiqueta_silaba$= ""
					hay_nucleo = 0

					
				endif


			endfor

			select textgrid_palabra
			Remove

		endfor


		# Unimos los textgrid en uno solo

		select textgrid
		name$ = selected$ ("TextGrid")

		plus 'textgrid_silabas'
		Merge
		Rename... 'name$'
		numero_tiers = Get number of tiers
		Duplicate tier... numero_tiers 3 Syllables
		Remove tier... numero_tiers+1

		textgrid_salida = selected ("TextGrid")

		select textgrid
		plus 'textgrid_silabas'
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


procedure TipoSonido etiqueta_sonido$ alphabet$

# printline Etiqueta sonido: 'etiqueta_sonido$'

if alphabet$ = "SAMPA"

	if etiqueta_sonido$ = "..." or etiqueta_sonido$ = "_" or etiqueta_sonido$ = ""

		tipo_sonido$ = "Silencio"

	else

		#if etiqueta_sonido$ = "a_&quot" or etiqueta_sonido$ = "e_&quot" or etiqueta_sonido$ = "E_&quot" or etiqueta_sonido$ = "i_&quot" or etiqueta_sonido$ = "o_&quot" or etiqueta_sonido$ = "O_&quot" or etiqueta_sonido$ = "u_&quot" or etiqueta_sonido$ = "@_&quot" or etiqueta_sonido$ = "6_&quot" or etiqueta_sonido$ = "U_&quot" or etiqueta_sonido$ = "i~_&quot" or etiqueta_sonido$ = "e~_&quot" or etiqueta_sonido$ = "6~_&quot" or etiqueta_sonido$ = "o~_&quot" or etiqueta_sonido$ = "u~_&quot" or etiqueta_sonido$ = "I_&quot"

		if etiqueta_sonido$ = "a_&quot" or etiqueta_sonido$ = "A_&quot" or etiqueta_sonido$ = "2_&quot" or etiqueta_sonido$ = "9_&quot" or etiqueta_sonido$ = "e_&quot" or etiqueta_sonido$ = "E_&quot" or etiqueta_sonido$ = "i_&quot" or etiqueta_sonido$ = "y_&quot" or etiqueta_sonido$ = "o_&quot" or etiqueta_sonido$ = "O_&quot" or etiqueta_sonido$ = "u_&quot" or etiqueta_sonido$ = "a~_&quot" or etiqueta_sonido$ = "9~_&quot" or etiqueta_sonido$ = "e~_&quot" or etiqueta_sonido$ = "o~_&quot" or etiqueta_sonido$ = "@_&quot"

			tipo_sonido$ = "VocalTonica"

		else

			#if etiqueta_sonido$ = "a_%" or etiqueta_sonido$ = "e_%" or etiqueta_sonido$ = "E_%" or etiqueta_sonido$ = "i_%" or etiqueta_sonido$ = "o_%" or etiqueta_sonido$ = "O_%" or etiqueta_sonido$ = "u_%" or etiqueta_sonido$ = "@_%" or etiqueta_sonido$ = "a_&#37" or etiqueta_sonido$ = "e_&#37" or etiqueta_sonido$ = "E_&#37" or etiqueta_sonido$ = "i_&#37" or etiqueta_sonido$ = "o_&#37" or etiqueta_sonido$ = "O_&#37" or etiqueta_sonido$ = "u_&#37" or etiqueta_sonido$ = "@_&#37" or etiqueta_sonido$ = "6_&#37" or etiqueta_sonido$ = "U_&#37" or etiqueta_sonido$ = "i~_&#37" or etiqueta_sonido$ = "e~_&#37" or etiqueta_sonido$ = "6~_&#37" or etiqueta_sonido$ = "o~_&#37" or etiqueta_sonido$ = "u~_&#37" or etiqueta_sonido$ = "I_&#37"

			if etiqueta_sonido$ = "a_%" or etiqueta_sonido$ = "A_%" or etiqueta_sonido$ = "2_%" or etiqueta_sonido$ = "9_%" or etiqueta_sonido$ = "e_%" or etiqueta_sonido$ = "E_%" or etiqueta_sonido$ = "i_%" or etiqueta_sonido$ = "y_%" or etiqueta_sonido$ = "o_%" or etiqueta_sonido$ = "O_%" or etiqueta_sonido$ = "u_%" or etiqueta_sonido$ = "a~_%" or etiqueta_sonido$ = "9~_%" or etiqueta_sonido$ = "e~_%" or etiqueta_sonido$ = "o~_%" or etiqueta_sonido$ = "@_%"

				tipo_sonido$ = "VocalTonica2"

			else

				#if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "E" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "O" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "@" or etiqueta_sonido$ = "6" or etiqueta_sonido$ = "U" or etiqueta_sonido$ = "i~" or etiqueta_sonido$ = "e~" or etiqueta_sonido$ = "6~" or etiqueta_sonido$ = "o~" or etiqueta_sonido$ = "u~" or etiqueta_sonido$ = "I"

				if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "A" or etiqueta_sonido$ = "2" or etiqueta_sonido$ = "9" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "E" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "y" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "O" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "a~" or etiqueta_sonido$ = "9~" or etiqueta_sonido$ = "e~" or etiqueta_sonido$ = "o~" or etiqueta_sonido$ = "@"

					tipo_sonido$ = "VocalAtona"

				else
			
					if etiqueta_sonido$ = "w" or etiqueta_sonido$ = "j" or etiqueta_sonido$ = "H" or etiqueta_sonido$ = "j~" or etiqueta_sonido$ = "w~"

						tipo_sonido$ = "Semivocal"

					else

						tipo_sonido$ = "Consonante"

					endif

				endif

			endif

		endif

	endif
	
else

	if alphabet$ = "IPA"
		Convert to backslash trigraphs
		if etiqueta_sonido$ = "||" or etiqueta_sonido$ = "|" or etiqueta_sonido$ = ""

			tipo_sonido$ = "Silencio"

		else


			if etiqueta_sonido$ = "\'1a" or etiqueta_sonido$ = "\'1\as" or etiqueta_sonido$ = "\'1\o/" or etiqueta_sonido$ = "\'1\oe" or etiqueta_sonido$ = "\'1e" or etiqueta_sonido$ = "\'1\ef" or etiqueta_sonido$ = "\'1i" or etiqueta_sonido$ = "\'1y" or etiqueta_sonido$ = "\'1o" or etiqueta_sonido$ = "\'1\ot" or etiqueta_sonido$ = "\'1u" or etiqueta_sonido$ = "\'1a\~^" or etiqueta_sonido$ = "\'1\oe\~^" or etiqueta_sonido$ = "\'1e\~^" or etiqueta_sonido$ = "\'1o\~^" or etiqueta_sonido$ = "\'1\sw"

				tipo_sonido$ = "VocalTonica"

			else


				if etiqueta_sonido$ = "\'2a" or etiqueta_sonido$ = "\'2\as" or etiqueta_sonido$ = "\'2\o/" or etiqueta_sonido$ = "\'2\oe" or etiqueta_sonido$ = "\'2e" or etiqueta_sonido$ = "\'2\ef" or etiqueta_sonido$ = "\'2i" or etiqueta_sonido$ = "\'2y" or etiqueta_sonido$ = "\'2o" or etiqueta_sonido$ = "\'2\ot" or etiqueta_sonido$ = "\'2u" or etiqueta_sonido$ = "\'2a\~^" or etiqueta_sonido$ = "\'2\oe\~^" or etiqueta_sonido$ = "\'2e\~^" or etiqueta_sonido$ = "\'2o\~^" or etiqueta_sonido$ = "\'2\sw"

					tipo_sonido$ = "VocalTonica2"

				else

					if etiqueta_sonido$ = "a" or etiqueta_sonido$ = "\as" or etiqueta_sonido$ = "\o/" or etiqueta_sonido$ = "\oe" or etiqueta_sonido$ = "e" or etiqueta_sonido$ = "\ef" or etiqueta_sonido$ = "i" or etiqueta_sonido$ = "y" or etiqueta_sonido$ = "o" or etiqueta_sonido$ = "\ot" or etiqueta_sonido$ = "u" or etiqueta_sonido$ = "a\~^" or etiqueta_sonido$ = "\oe\~^" or etiqueta_sonido$ = "e\~^" or etiqueta_sonido$ = "o\~^" or etiqueta_sonido$ = "\sw"

						tipo_sonido$ = "VocalAtona"

					else
				
						if etiqueta_sonido$ = "w" or etiqueta_sonido$ = "j" or etiqueta_sonido$ = "\ht" or etiqueta_sonido$ = "j\~^" or etiqueta_sonido$ = "w\~^"

							tipo_sonido$ = "Semivocal"

						else

							tipo_sonido$ = "Consonante"

						endif

					endif

				endif

			endif

		endif
		
	else
	
		printline Alfabeto no reconocido
	
	endif
endif

# printline Tipo sonido: 'tipo_sonido$'

endproc