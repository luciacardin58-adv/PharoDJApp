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
		'deckA',
		'console',
		'deckB'
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

	deckA := DJDeck onDeck: #A fromFilePath: self defaultTrackPath.
	deckB := DJDeck onDeck: #B fromFilePath: self defaultTrackPath
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
"Left is full A, right is full B. Linear, so the centre sums two tracks at half each;  a cut fader, not constant power."

	| fader |
	fader := consoleElement mixer crossfader.
	fader callBack: [ :each |
		| t |
		t := fader value + 100 / 200.
		deckA crossfadeGain: 1 - t.
		deckB crossfadeGain: t ]
]

{ #category : 'connecting' }
DJApp >> connectDeck: aDeck element: anElement strip: aStrip [

	self connectTempo: anElement to: aDeck.
	self connectStrip: aStrip to: aDeck.
	self setShelfCornersFor: aDeck.
	self pushWidgetsFrom: aStrip to: aDeck
]

{ #category : 'connecting' }
DJApp >> connectStrip: aStrip to: aDeckDsp [

	| eq |
	eq := aStrip eqCOntrols.
	aStrip channelFader callBack: [ :each |
		aDeckDsp dsp
			setValue: aStrip channelFader gain
			parameter: aDeckDsp prefix , 'ULevel' ].
	eq lowKnob callBack: [ :each |
		aDeckDsp dsp
			setValue: (self decibelsFrom: eq lowKnob value)
			parameter: aDeckDsp prefix , 'LowLevel' ].
	eq midKnob callBack: [ :each |
		aDeckDsp dsp
			setValue: (self decibelsFrom: eq midKnob value)
			parameter: aDeckDsp prefix , 'MidLfx' ].
	eq highKnob callBack: [ :each |
		aDeckDsp dsp
			setValue: (self decibelsFrom: eq highKnob value)
			parameter: aDeckDsp prefix , 'HighLevel' ].
	aStrip filterKnob callBack: [ :each |
		self applyFilter: aStrip filterKnob value to: aDeckDsp ]
]

{ #category : 'connecting' }
DJApp >> connectTempo: aDeckElement to: aDeckDsp [
"snappedValue, not value: the fader travel quantises to pixels and centre detent has to read exactly 0."

	aDeckElement tempoFader callBack: [ :each |
			aDeckDsp dsp
				setValue: aDeckElement tempoFader snappedValue
				parameter: aDeckDsp prefix , 'Speed' ]
]

{ #category : 'connecting' }
DJApp >> connectUI [

	self
		connectDeck: deckA
		element: consoleElement leftDeck
		strip: consoleElement mixer leftStrip.
	self
		connectDeck: deckB
		element: consoleElement rightDeck
		strip: consoleElement mixer rightStrip.
	self connectCrossfader
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
DJApp >> deckA [ 
^ deckA 
]

{ #category : 'accessing' }
DJApp >> deckB [

	^ deckB
]

{ #category : 'initialization' }
DJApp >> initialize [
	super initialize.
	
]

{ #category : 'host space - displaying' }
DJApp >> openSpace [

	space := consoleElement inSpace.
	space extent: DJConsoleElement defaultExtent.
	space title: 'Pharo DJ'.
	space show
]

{ #category : 'initialization' }
DJApp >> pushWidgetsFrom: aStrip to: aDeckDsp [
	"The DSP boots with boosted shelves and uLevel 0.5, the widgets boot flat
	 and open. Push once so the two agree before the first turn."

	| eq |
	eq := aStrip eqCOntrols.
	aDeckDsp dsp
		setValue: aStrip channelFader gain
		parameter: aDeckDsp prefix , 'ULevel'.
	aDeckDsp dsp
		setValue: (self decibelsFrom: eq lowKnob value)
		parameter: aDeckDsp prefix , 'LowLevel'.
	aDeckDsp dsp
		setValue: (self decibelsFrom: eq midKnob value)
		parameter: aDeckDsp prefix , 'MidLfx'.
	aDeckDsp dsp
		setValue: (self decibelsFrom: eq highKnob value)
		parameter: aDeckDsp prefix , 'HighLevel'.
	self applyFilter: aStrip filterKnob value to: aDeckDsp
]

{ #category : 'releasing' }
DJApp >> releaseAudio [

	deckA ifNotNil: [ deckA destroy ].
	deckB ifNotNil: [ deckB destroy ].
	deckA := nil.
	deckB := nil
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

{ #category : 'running' }
DJApp >> start [
	self buildAudio.
	self buildUI.
	self connectUI.
	self openSpace
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
