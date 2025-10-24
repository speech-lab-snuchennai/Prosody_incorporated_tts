import sys
import os
import torch
import librosa
import numpy as np
import soundfile as sf
from espnet2.bin.tts_inference import Text2Speech
import matplotlib.pyplot as plt

# Constants
SAMPLING_RATE = 48000  # Use the rate your model was trained with
N_FFT = 8192
HOP_LENGTH = 1024
WIN_LENGTH = 4096

if len(sys.argv) != 3:
    print("Usage: python3 synthesize_without_vocoder.py '<text>' <reference_audio_path>")
    sys.exit(1)

text = sys.argv[1]
reference_audio_path = sys.argv[2]

# Load reference audio
try:
    ref_audio, ref_sr = librosa.load(reference_audio_path, sr=SAMPLING_RATE)
    print(f"Reference audio loaded from {reference_audio_path}")
except Exception as e:
    print(f"Error loading reference audio: {e}")
    sys.exit(1)

# Select device
device = "cuda" if torch.cuda.is_available() else "cpu"

# Load FastSpeech2 model (no vocoder)
try:
    text2speech = Text2Speech(
        train_config="exp/tts_train_fastspeech2_raw_char_None/config.yaml",
        model_file="exp/tts_train_fastspeech2_raw_char_None/1000epoch.pth",
        device=device
    )
    print("TTS model loaded.")
except Exception as e:
    print(f"Error loading TTS model: {e}")
    sys.exit(1)

# Generate mel-spectrogram
try:
    with torch.no_grad():
        output = text2speech(text, speech=ref_audio)
        mel = output["feat_gen_denorm"].cpu().T.numpy()  # (n_mels, T)
        print(f"Generated mel-spectrogram shape: {mel.shape}")
except Exception as e:
    print(f"Error during synthesis: {e}")
    sys.exit(1)

# Griffin-Lim vocoding
try:
    # Mel-to-linear spectrogram (approximate)
    mel_basis = librosa.filters.mel(sr=SAMPLING_RATE, n_fft=N_FFT, n_mels=mel.shape[0])
    inv_mel_basis = np.linalg.pinv(mel_basis)
    linear_spec = np.maximum(1e-10, np.dot(inv_mel_basis, mel))

    # Griffin-Lim waveform reconstruction
    audio = librosa.feature.inverse.griffinlim(
        S=linear_spec,
        n_iter=60,
        hop_length=HOP_LENGTH,
        win_length=WIN_LENGTH,
        n_fft=N_FFT,
    )
except Exception as e:
    print(f"Error during Griffin-Lim reconstruction: {e}")
    sys.exit(1)

# Save audio
output_path = "/home/speechlab/Desktop/fastspeech2_no_vocoder.wav"
sf.write(output_path, audio, SAMPLING_RATE)
print(f"Audio saved to: {output_path}")
