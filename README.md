# FonetiToBI 1.0
## User manual

FonetiToBI is a Praat-based tool for prosodic annotation in ToBI format (Break Indices, Pitch Accents, Boundary Tones) of Spanish and Catalan utterances. It has been developed by Wendy Elvira-García and Juan María Garrido at the Phonetics Lab of the University of Barcelona.

It is made of a set of Praat scripts, which should be kept together (always in the same directory) to ensure the correct processing of the input data. To run FonetiToBI, Praat must be installed in your computer.

To execute FonetiToBI, run ‘FonetiToBI.praat’ in the usual way.  It will ask you for following arguments:

*	'Directorio_wav': path to the directory with the input files
*	'Lengua': ToBI convention to be used 
  ... o	Sp_ToBI
  ... o	Cat-ToBI
*	‘Formato_transcripcion’: Phonetic transcription alphabet used in the input TextGrid
  ... o	SAMPA
  ... o	IPA
*	'Crear_figura': Check this box if  you want to get a png file with an image of the annotation
*	'Revision': Check this box if you want to revise the output. The output TextGrid will be opened in Praat.

FonetiToBI needs two input files for each utterance to be annotated, containing:

*	The speech wave (wav file)
*	The orthographic and phonetic transcription, time-aligned with the signal (TextGrid file)

Both files should be in the directory specified in the script arguments.

Phonetic transcription in the TextGrid can be provided either using IPA or SAMPA symbols. All segments, including pauses, should be transcribed using the corresponding conventions. Blanks are also allowed for pause transcription.

FonetiToBI generates as output a set of tiers, wich are appended to the input TextGrid file:

*	The syllable segmentation, with indication of stressed syllables
*	The BreakTier
*	A narrow ToBI annotation
*	A wide (standard) ToBI annotation
*	A png file containing a graphical representation of the waveform, the corresponding spectrogram, pitch contour and all the annotation tiers (optional).

The obtained ToBI annotation follows the Sp_ToBI and Cat_ToBI conventions. 
