Class {
	#name : 'DJAppTests',
	#superclass : 'TestCase',
	#instVars : [
		'writes',
		'channelGain',
		'crossfadeGain',
		'app',
		'deck'
	],
	#category : 'DJApp-Tests',
	#package : 'DJApp',
	#tag : 'Tests'
}

{ #category : 'running' }
DJAppTests >> setUp [

	super setUp.
	app := DJApp basicNew.
	deck := DJDeckSpy new
]

{ #category : 'tests' }
DJAppTests >> testDecibelsAreLinear [

	self assert: (app decibelsFrom: 50) equals: 3
]

{ #category : 'tests' }
DJAppTests >> testDecibelsAtCentreIsFlat [

	self assert: (app decibelsFrom: 0) equals: 0
]

{ #category : 'tests' }
DJAppTests >> testDecibelsAtExtremes [

	self assert: (app decibelsFrom: 100) equals: 6.
	self assert: (app decibelsFrom: -100) equals: -6
]

{ #category : 'tests' }
DJAppTests >> testFilterCentredLeavesBothOpen [

	app applyFilter: 0 to: deck.
	self assert: (deck valueAt: 'DeckALowPassFrequency') equals: 22040.
	self assert: (deck valueAt: 'DeckAHiPassFrequency') equals: 25
]

{ #category : 'tests' }
DJAppTests >> testFilterLeftClosesTheLowpassOnly [

	app applyFilter: -100 to: deck.
	self assert: (deck valueAt: 'DeckALowPassFrequency') closeTo: 200.
	self assert: (deck valueAt: 'DeckAHiPassFrequency') equals: 25
]

{ #category : 'tests' }
DJAppTests >> testFilterWritesBothSidesEveryTime [
	"The idle filter has to be pushed back open, or it stays where the last
	 turn left it."

	app applyFilter: -50 to: deck.
	self assert: deck writes size equals: 2
]

{ #category : 'tests' }
DJAppTests >> testShelfCornersAreInRange [
	"Every one of these has a min and max in Phausto; a value outside is
	 silently clamped, so it fails as a wrong sound rather than an error."

	app setShelfCornersFor: deck.
	self assert: ((deck valueAt: 'DeckALowFreq') between: 20 and: 3000).
	self assert: ((deck valueAt: 'DeckAHighFreq') between: 20 and: 3000).
	self assert: ((deck valueAt: 'DeckAMidFx') between: 20 and: 8000).
	self assert: ((deck valueAt: 'DeckAMidB') between: 20 and: 2000)
]

{ #category : 'tests' }
DJAppTests >> testShelfCornersUseDeckPrefix [

	app setShelfCornersFor: deck.
	self
		assert: (deck writes collect: [ :each | each key ]) asSet
		equals: #( 'DeckALowFreq' 'DeckAHighFreq' 'DeckAMidFx' 'DeckAMidB' ) asSet
]

{ #category : 'tests' }
DJAppTests >> testSweepAtFullAnswersEnd [

	self assert: (app sweep: 100 from: 22040 to: 200) closeTo: 200
]

{ #category : 'tests' }
DJAppTests >> testSweepAtZeroAnswersStart [

	self assert: (app sweep: 0 from: 22040 to: 200) closeTo: 22040
]

{ #category : 'tests' }
DJAppTests >> testSweepMidpointIsGeometricMean [
	"Exponential, not linear: half the travel lands on the geometric mean,
	 which is what makes equal knob movement sound equal."

	self
		assert: (app sweep: 50 from: 22040 to: 200)
		closeTo: (22040 * 200) sqrt
]
