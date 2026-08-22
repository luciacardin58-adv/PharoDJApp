"
I load the full Pharo DJ application: audio format parsing, the Phausto-based
deck and mixing engine, and the Bloc/Toplo user interface, plus the DJApp
package which wires them together.
"
Class {
	#name : 'BaselineOfDJApp',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDjApp',
	#package : 'BaselineOfDjApp'
}

{ #category : 'baselines' }
BaselineOfDJApp >> baseline: spec [
	<baseline>
	spec for: #common do: [ :s |
		s
			baseline: 'CoypuIDE'
			with: [ s repository: 'github://luciacardin58-adv/CoypuIDE:main' ].
		s
			baseline: 'Phausto'
			with: [ s repository: 'github://luciacardin58-adv/phausto:main' ].
		s
			baseline: 'DJAudioFormats'
			with: [ s repository: 'github://luciacardin58-adv/DJAudio-Formats:main' ].
		s
			baseline: 'DJDeck'
			with: [ s repository: 'github://luciacardin58-adv/DJDeck:main' ].
		s
			baseline: 'DjBlocUI'
			with: [ s repository: 'github://<user>/DjBlocUI:main' ].
		s
			package: 'DJApp'
			with: [ s requires: #( 'DJDeck' 'DjBlocUI' ) ].
		s
			group: 'core' with: #( 'DJApp' );
			group: 'default' with: #( 'core' ) ]
]
