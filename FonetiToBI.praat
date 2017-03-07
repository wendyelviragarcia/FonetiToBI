# Script para crear anotaciones ToBI en ficheros textgrid con la transcripcion fonetica y las palabras en formato Cereproc

form Argumentos
	#sentence Directorio_wav D:\Usuarios\labfonub15\Desktop\ejemplos_Interface\
	sentence Directorio_wav /Users/weg/Desktop/testme/
	optionmenu Lengua 1
          option Sp_ToBI
          option Cat_ToBI
 	choice Formato_transcripcion: 1
		button SAMPA
		button IPA
	boolean Crear_figura 1
	boolean Revision 0
endform

directorio_scripts$ ="."
directorio_textgrid$= directorio_wav$

Create Strings as file list... lista_ficheros 'directorio_wav$'/*.wav
objeto_lista = selected ("Strings")

if formato_transcripcion = 1
	transcripcion$ = "SAMPA"
elsif formato_transcripcion = 2
	transcripcion$ = "IPA"
endif

numberOfFiles = Get number of strings
for ifile to numberOfFiles
	select Strings lista_ficheros
	fichero$ = Get string... ifile

	directorio_script_creacion_tiers$ = directorio_scripts$+"/"
	printline Creamos un tier con las silabas para el fichero 'fichero$'. 
	#execute 'directorio_script_creacion_tiers$'crea_tier_silabas.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 2 1
	execute 'directorio_script_creacion_tiers$'crea_tier_silabas.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 2 1 'transcripcion$'
	printline Creamos un tier con los grupos fonicos para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'crea_tier_grupos_fonicos.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 3
	printline Creamos un tier con los grupos entonativos para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'crea_tier_grupos_entonativos.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 1 2 3
	printline Creamos un tier con los ToBI break Index para el fichero 'fichero$'. 
	execute 'directorio_script_creacion_tiers$'crea_break_index_tier.praat 'fichero$' 'directorio_wav$' 'directorio_textgrid$' 1 3 4

endfor
select objeto_lista
Remove

execute eti_tobi.praat 'directorio_wav$' "T" 3 1 5 1 4 1.5 6 1 0 1 'lengua$' 0 'crear_figura' 'revision'
