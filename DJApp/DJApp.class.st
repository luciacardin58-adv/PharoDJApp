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
		'mixingConsole',
		'consoleElement',
		'space'
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

{ #category : 'building' }
DJApp >> buildAudio [
	mixingConsole := DJMixingConsole new
]

{ #category : 'building' }
DJApp >> buildUI [
	consoleElement := DJConsoleElement new
]

{ #category : 'building' }
DJApp >> closeSpace [
	space ifNil: [ ^ self ].
	space close.
	space := nil
]

{ #category : 'building' }
DJApp >> connectUI [
	"Hand the DSP layer to the UI. Filled in once we agree on the selectors."
	self flag: #todo
]

{ #category : 'accessing' }
DJApp >> consoleElement [
	^ consoleElement
]

{ #category : 'accessing' }
DJApp >> consoleElement: anObject [
	consoleElement := anObject
]

{ #category : 'initialization' }
DJApp >> initialize [
	super initialize.
	
]

{ #category : 'accessing' }
DJApp >> mixingConsole [
	^ mixingConsole
]

{ #category : 'accessing' }
DJApp >> mixingConsole: anObject [
	mixingConsole := anObject
]

{ #category : 'building' }
DJApp >> openSpace [
	space := consoleElement inSpace.
	space extent: DJConsoleElement defaultExtent.
	space title: 'Pharo DJ'.
	space show
]

{ #category : 'building' }
DJApp >> releaseAudio [
	mixingConsole ifNil: [ ^ self ].
	mixingConsole destroy.
	mixingConsole := nil
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
