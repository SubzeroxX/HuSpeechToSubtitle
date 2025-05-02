# Universal Speech-to-Text Transcriber

A fork of marklechner/spch2txt tool. Modified to generate valid srt files for videos.

### Setup
Setup on windows: Run setup.bat (it will install python and the packages into a venv)

### Usage
Drop an mp3 or mp4 file on to the start.bat file.

# Parts from the origin project

## Prerequisites

- Python 3.12.3
- FFmpeg
- Sufficient disk space for Whisper model

## Configuration

Adjust these parameters in the script for different use cases:

- `model_size`: Choose from "tiny", "base", "small", "medium", "large-v2"
- `chunk_duration`: Duration in minutes for splitting large files
- `use_chunks`: Boolean to enable/disable chunked processing

## Performance Notes

- Recommended to use "medium" model for balance of speed and accuracy
- M1 Mac users can utilize MPS acceleration
- Large files can be processed either directly or in chunks based on available memory
