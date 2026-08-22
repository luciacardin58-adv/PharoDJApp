# PharoDJApp

A DJ application written in Pharo: a two-deck console with mixer, waveform
displays, transport controls and a crate browser, built on Bloc/Toplo for the
user interface and Faust DSP through Phausto for audio.

Google Summer of Code 2026 project with the Pharo Association.
Google Summer of Code 2026 project with the Pharo Association.

📄 **[GSoC 2026 final submission report](GSOC-2026.md)** — what was built, whatworks, what is still missing, with links to every repository and commit range.


## Installation

Requires **Pharo 13**.

```smalltalk
Metacello new
	baseline: 'DJApp';
	repository: 'github://<user>/PharoDJApp:main/src';
	load
```

The baseline pulls in Phausto and CoypuIDE (which brings Bloc and Toplo) along
with the project's own packages, so a fresh Pharo 13 image is all you need.

## Usage

```smalltalk
DJApp open
```

This builds the DSP graph, opens the console window and wires the two together.
To shut down cleanly and release the native audio resources:

```smalltalk
| app |
app := DJApp new start.
app stop
```

Playlists are read from `~/Documents/PharoDJCrate/Playlists/` in M3U format with
`#EXTINF` metadata.

## Architecture

The project is split across four repositories, loaded together by
`BaselineOfDJApp`:

| Package | Role |
| --- | --- |
| `DJAudio-Formats` | Audio file parsing (WAV, AIFF/AIFC) and peak extraction |
| `DJMixingConsole` | DSP graph and playback, built on Phausto |
| `DjBlocUI` | Bloc/Toplo user interface — decks, mixer, waveforms, browser |
| `DJApp` | Composition root that connects the interface to the DSP layer |

`DjBlocUI` and `DJMixingConsole` do not reference each other. `DJApp` is the only
class that knows about both, which keeps the interface testable without an audio
device and the DSP usable without a window.

## Status

Working: crate browser, track loading, waveform rendering, transport and mixer
controls, deck playback.

In progress: drag-and-drop from the browser to the decks, BPM detection and
display, highpass cutoff wiring.

## Credits

Developed by <name> as part of Google Summer of Code 2026, mentored through the
Pharo Association. The audio and DSP layer is developed in collaboration with
Lucia.

Built on [Phausto](https://github.com/lucretiomsp/Phausto),
[CoypuIDE](https://github.com/lucretiomsp/CoypuIDE),
[Bloc](https://github.com/pharo-graphics/Bloc) and
[Toplo](https://github.com/pharo-graphics/Toplo).

## License

MIT
