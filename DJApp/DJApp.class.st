"
I am the entry point of the **Pharo DJ application**.

I own the three things that have to exist together and know about each other only through me: 
- a DJMixingConsole (the Phausto DSP graph), 
- a DJConsoleElement (the Bloc user interface),
- the BlSpace they are shown in.

Neither the DSP layer nor the UI layer references the other directly; I wire them in #connectUI and tear them down in #stop.

Usage:
```language=Pharo
	DJApp open.
```
Instance creation and shutdown:
```language=Pharo
	| app |
	app := DJApp new start.
	app stop.
```
"
Class {
	#name : 'DJApp',
	#superclass : 'Object',
	#instVars : [
		'consoleElement',
		'space',
		'console',
		'decks'
	],
	#category : 'DJApp',
	#package : 'DJApp'
}

{ #category : 'examples' }
DJApp class >> example [
	<sampleInstance>
	^ self open
]

{ #category : 'instance creation' }
DJApp class >> open [
	^ self new start
]

{ #category : 'api - converting' }
DJApp >> applyFilter: aKnobValue to: aDeckDsp [
	"One bipolar knob, two filters. Left sweeps the lowpass down from open,
	 right sweeps the highpass up from open. The idle side parks wide open."

	| lp hp |
	lp := aKnobValue < 0
		      ifTrue: [ self sweep: aKnobValue abs from: 22040 to: 200 ]
		      ifFalse: [ 22040 ].
	hp := aKnobValue > 0
		      ifTrue: [ self sweep: aKnobValue from: 25 to: 4000 ]
		      ifFalse: [ 25 ].
	aDeckDsp dsp setValue: lp parameter: aDeckDsp prefix , 'LowPassFrequency'.
	aDeckDsp dsp setValue: hp parameter: aDeckDsp prefix , 'HiPassFrequency'
]

{ #category : 'building' }
DJApp >> buildAudio [

	self deckAt: #A put: (DJDeck onDeck: #A fromFilePath: self defaultTrackPath).
	self deckAt: #B put: (DJDeck onDeck: #B fromFilePath: self defaultTrackPath)
]

{ #category : 'building' }
DJApp >> buildUI [

	consoleElement := DJConsoleElement new
]

{ #category : 'host space - displaying' }
DJApp >> closeSpace [

	space ifNil: [ ^ self ].
	space close.
	space := nil
]

{ #category : 'connecting' }
DJApp >> connectCrossfader [
"Left is full A, right is full B. Linear, so the centre sums two tracks at half each; a cut fader, not constant power."

	| fader |
	fader := consoleElement mixer crossfader.
	fader callBack: [ :each |
		| t |
		t := fader value + 100 / 200.
		self deckAt: #A ifPresent: [ :deck | deck crossfadeGain: 1 - t ].
		self deckAt: #B ifPresent: [ :deck | deck crossfadeGain: t ] ]
]

{ #category : 'building' }
DJApp >> connectDeck: aSymbol element: anElement strip: aStrip [

	self connectTempo: anElement toDeck: aSymbol.
	self connectStrip: aStrip toDeck: aSymbol.
	self connectTransport: anElement toDeck: aSymbol.
	self deckAt: aSymbol ifPresent: [ :deck |
		self setShelfCornersFor: deck.
		self pushWidgetsFrom: aStrip to: deck ]
]

{ #category : 'connecting' }
DJApp >> connectStrip: aStrip toDeck: aSymbol [
"The channel fader goes through the deck, not straight at 'ULevel' — the crossfader writes the same address and the two have to multiply."

	| eq |
	eq := aStrip eqCOntrols.
	aStrip channelFader callBack: [ :each |
		self deckAt: aSymbol ifPresent: [ :deck |
			deck channelGain: aStrip channelFader gain ] ].
	eq lowKnob callBack: [ :each |
		self deckAt: aSymbol ifPresent: [ :deck |
			deck dsp
				setValue: (self decibelsFrom: eq lowKnob currentValue)
				parameter: deck prefix , 'LowLevel' ] ].
	eq midKnob callBack: [ :each |
		self deckAt: aSymbol ifPresent: [ :deck |
			deck dsp
				setValue: (self decibelsFrom: eq midKnob currentValue)
				parameter: deck prefix , 'MidLfx' ] ].
	eq highKnob callBack: [ :each |
		self deckAt: aSymbol ifPresent: [ :deck |
			deck dsp
				setValue: (self decibelsFrom: eq highKnob currentValue)
				parameter: deck prefix , 'HighLevel' ] ].
	aStrip filterKnob callBack: [ :each |
		self deckAt: aSymbol ifPresent: [ :deck |
			self applyFilter: aStrip filterKnob currentValue to: deck ] ]
]

{ #category : 'connecting' }
DJApp >> connectTempo: aDeckElement toDeck: aSymbol [
"snappedValue, not value: the fader travel quantises to pixels and the centre detent has to read exactly 0."

	aDeckElement tempoFader callBack: [ :each |
		self deckAt: aSymbol ifPresent: [ :deck |
			deck dsp
				setValue: aDeckElement tempoFader snappedValue
				parameter: deck prefix , 'Speed' ] ]
]

{ #category : 'connecting' }
DJApp >> connectTrackLoading [

	consoleElement trackLoadedAction: [ :element :path |
		self
			loadTrack: path
			onDeck: (element == consoleElement leftDeck
					 ifTrue: [ #A ]
					 ifFalse: [ #B ]) ]
]

{ #category : 'connecting' }
DJApp >> connectTransport: anElement toDeck: aSymbol [

	anElement playAction: [ :playing |
		self deckAt: aSymbol ifPresent: [ :deck |
			playing
				ifTrue: [ deck play ]
				ifFalse: [ deck pause ] ] ]
]

{ #category : 'connecting' }
DJApp >> connectUI [

	self
		connectDeck: #A
		element: consoleElement leftDeck
		strip: consoleElement mixer leftStrip.
	self
		connectDeck: #B
		element: consoleElement rightDeck
		strip: consoleElement mixer rightStrip.
	self connectCrossfader.
	self connectTrackLoading
]

{ #category : 'accessing' }
DJApp >> consoleElement [
	^ consoleElement
]

{ #category : 'accessing' }
DJApp >> consoleElement: anObject [
	consoleElement := anObject
]

{ #category : 'api - converting' }
DJApp >> decibelsFrom: aKnobValue [
	"EQ knobs travel -100 to 100; the shelves take -6 to 6 dB."

	^ aKnobValue * 6 / 100
]

{ #category : 'accessing' }
DJApp >> deckAt: aSymbol [

	^ decks at: aSymbol ifAbsent: [ nil ]
]

{ #category : 'accessing' }
DJApp >> deckAt: aSymbol ifPresent: aBlock [
"A deck does not exist until a track is loaded onto it, so every callback fires against nil until then."

	^ (self deckAt: aSymbol) ifNotNil: aBlock
]

{ #category : 'accessing' }
DJApp >> deckAt: aSymbol put: aDeck [

	^ decks at: aSymbol put: aDeck
]

{ #category : 'accessing' }
DJApp >> decks [ 
^ decks
]

{ #category : 'accessing' }
DJApp >> defaultTrackPath [

	^ FileLocator imageDirectory asAbsolute pathString
	  , '/TurboSamples/blip/LAZ_R900.wav'
]

{ #category : 'initialization' }
DJApp >> initialize [

	super initialize.
	decks := Dictionary new
]

{ #category : 'loading' }
DJApp >> loadTrack: aPath onDeck: aSymbol [
	"New first, then destroy — a failed construction leaves the previous
	 track playing rather than silence."

	| old new |
	old := self deckAt: aSymbol.
	new := DJDeck onDeck: aSymbol fromFilePath: aPath.
	self deckAt: aSymbol put: new.
	old ifNotNil: [ :each | each destroy ].
	self pushStateTo: aSymbol
]

{ #category : 'host space - displaying' }
DJApp >> openSpace [

	space ifNotNil: [ ^ self ].
	space := consoleElement inSpace.
	space extent: DJConsoleElement defaultExtent.
	space title: 'Pharo DJ'.
	space show
]

{ #category : 'loading' }
DJApp >> pushStateTo: aSymbol [
"A new deck boots at Phausto's defaults — shelves at +3 dB, uLevel 0.5, filters open: while the widgets stay where the DJ left them. Every control has to be restated or the load silently resets the sound."

	| deck strip |
	deck := self deckAt: aSymbol.
	strip := self stripAt: aSymbol.
	self setShelfCornersFor: deck.
	self pushWidgetsFrom: strip to: deck.
	self pushCrossfadeTo: deck forDeck: aSymbol
]

{ #category : 'initialization' }
DJApp >> pushWidgetsFrom: aStrip to: aDeckDsp [
	"The DSP boots with boosted shelves and uLevel 0.5, the widgets boot flat
	 and open. Push once so the two agree before the first turn."

	| eq |
	eq := aStrip eqCOntrols.
	aDeckDsp channelGain: aStrip channelFader gain.
	aDeckDsp dsp
		setValue: (self decibelsFrom: eq lowKnob currentValue)
		parameter: aDeckDsp prefix , 'LowLevel'.
	aDeckDsp dsp
		setValue: (self decibelsFrom: eq midKnob currentValue)
		parameter: aDeckDsp prefix , 'MidLfx'.
	aDeckDsp dsp
		setValue: (self decibelsFrom: eq highKnob currentValue)
		parameter: aDeckDsp prefix , 'HighLevel'.
	self applyFilter: aStrip filterKnob currentValue to: aDeckDsp
]

{ #category : 'releasing' }
DJApp >> releaseAudio [

	decks valuesDo: [ :each | each destroy ].
	decks removeAll
]

{ #category : 'initialization' }
DJApp >> setShelfCornersFor: aDeckDsp [
	"No widget owns these. Standard three-band crossover, set once."

	aDeckDsp dsp setValue: 200 parameter: aDeckDsp prefix , 'LowFreq'.
	aDeckDsp dsp setValue: 3000 parameter: aDeckDsp prefix , 'HighFreq'.
	aDeckDsp dsp setValue: 1000 parameter: aDeckDsp prefix , 'MidFx'.
	aDeckDsp dsp setValue: 1200 parameter: aDeckDsp prefix , 'MidB'
]

{ #category : 'accessing' }
DJApp >> space [ 
^ space 
]

{ #category : 'accessing' }
DJApp >> start [

	self buildAudio.
	self buildUI.
	self connectUI.
	self openSpace.
	consoleElement browser rootFolder: FileLocator home asFileReference
]

{ #category : 'running' }
DJApp >> stop [
	self closeSpace.
	self releaseAudio
]

{ #category : 'api - converting' }
DJApp >> sweep: aPercent from: aStart to: anEnd [
	"Exponential, so equal knob travel sounds like equal pitch travel."

	^ aStart * ((anEnd / aStart) raisedTo: aPercent / 100)
]
