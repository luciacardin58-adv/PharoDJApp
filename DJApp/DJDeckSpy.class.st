"
I test DJApp's wiring, not the application.

Starting the real thing opens a window and claims an audio device, sonothing here sends #start. My tests build DJApp with #basicNew and call theindividual methods, which is enough: everything worth checking is arithmeticor an address string, and neither needs sound.


DJDeckSpy stands in for a deck. It answers itself for #dsp and records every #setValue:parameter:, so I can assert on what the wiring would have written.

"
Class {
	#name : 'DJDeckSpy',
	#superclass : 'Object',
	#instVars : [
		'writes',
		'channelGain',
		'crossfadeGain'
	],
	#category : 'DJApp-Tests',
	#package : 'DJApp',
	#tag : 'Tests'
}

{ #category : 'accessing' }
DJDeckSpy >> channelGain: aNumber [

	channelGain := aNumber
]

{ #category : 'accessing' }
DJDeckSpy >> dsp [
	"I stand in for my own DSP; the wiring only ever sends setValue:parameter:."

	^ self
]

{ #category : 'initialization' }
DJDeckSpy >> initialize [

	super initialize.
	writes := OrderedCollection new
]

{ #category : 'tests - printing' }
DJDeckSpy >> prefix [

	^ 'DeckA'
]

{ #category : 'accessing' }
DJDeckSpy >> setValue: aFloat parameter: aString [

	writes add: aString -> aFloat
]

{ #category : 'accessing' }
DJDeckSpy >> valueAt: aParameter [

	^ (writes detect: [ :each | each key = aParameter ]) value
]

{ #category : 'accessing' }
DJDeckSpy >> writes [ 
^ writes
]
