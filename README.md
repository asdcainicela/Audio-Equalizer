# Audio Equalizer

A real-time audio equalizer implementation using MATLAB App Designer. This application allows users to modify audio signals through frequency band adjustments using wavelet transforms.

## Features

- Real-time audio signal processing
- Wavelet transform based equalization
- Interactive user interface built with MATLAB App Designer
- Support for multiple frequency bands
- Audio file input/output capabilities

## Requirements

- MATLAB R2019b or newer
- MATLAB Signal Processing Toolbox
- MATLAB Wavelet Toolbox

## Installation

1. Clone this repository:
```bash
git clone https://github.com/asdcainicela/Audio-Equalizer.git
```

2. Open MATLAB and navigate to the project folder
3. Open `App.mlapp` in App Designer

## Project Structure

```
Audio-Equalizer/
├── App.mlapp          # Main application file
├── function/          # Core processing functions
│   ├── dwwt.m        # Discrete wavelet transform
│   ├── fourier.m     # Fourier transform utilities
│   └── rwwt.m        # Reverse wavelet transform
├── img/              # Application icons
│   ├── check.png
│   ├── record.png
│   └── warning.png
└── README.md
```

## Usage

1. Launch the application by running `App.mlapp`
2. Load an audio file or select real-time input
3. Adjust the frequency bands using the equalizer sliders
4. Apply the changes and play the modified audio

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms of the included LICENSE file.