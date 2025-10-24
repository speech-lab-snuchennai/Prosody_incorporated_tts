import sys
import os
import torch
import librosa
import soundfile as sf
#replace the path with your hifigan path to import Generator from models.py 
sys.path.append("hifigan")
import numpy as np
import json
from espnet2.bin.tts_inference import Text2Speech
from models import Generator
from meldataset import MAX_WAV_VALUE
from env import AttrDict

# Constants
SAMPLING_RATE = 48000
NORM_SCALE = 2.3262  # adjust based on training

# Load HiFi-GAN vocoder
def load_hifigan(device):
    config_path = "/home/speechlab/Documents/cp-24k/config.json"
    model_path = "/home/speechlab/Documents/cp-24k/cp_hifigan_00145000"

    with open(config_path, 'r') as f:
        h = AttrDict(json.load(f))

    generator = Generator(h).to(device)
    state_dict = torch.load(model_path, map_location=device)
    generator.load_state_dict(state_dict['generator'])
    generator.eval()
    generator.remove_weight_norm()

    return generator

# Load TTS model
def load_tts_model(device):
    tts_config = "exp/tts_train_fastspeech2_raw_char_None/config.yaml"
    tts_model = "exp/tts_train_fastspeech2_raw_char_None/1000epoch.pth"

    return Text2Speech(
        train_config=tts_config,
        model_file=tts_model,
        device=device
    )

# Synthesize speech
def synthesize(text, ref_audio, tts, vocoder, device):
    with torch.no_grad():
        output = tts(text, speech=ref_audio)

        # Get mel-spectrogram and denormalize
        mel = output["feat_gen_denorm"].T.unsqueeze(0).to(device) * NORM_SCALE

        # HiFi-GAN inference
        y_hat = vocoder(mel)
        audio = y_hat.squeeze() * MAX_WAV_VALUE
        audio = audio.cpu().numpy().astype("int16")
        return audio

# Main
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 inference_with_ref_and_hifigan.py \"<text>\" <reference_audio.wav>")
        sys.exit(1)

    text = sys.argv[1]
    ref_audio_path = sys.argv[2]

    # Load reference audio
    try:
        ref_audio, _ = librosa.load(ref_audio_path, sr=SAMPLING_RATE)
    except Exception as e:
        print(f"Error loading reference audio: {e}")
        sys.exit(1)

    device = "cuda" if torch.cuda.is_available() else "cpu"

    print("Loading models...")
    tts = load_tts_model(device)
    vocoder = load_hifigan(device)

    print("Synthesizing speech...")
    try:
        audio = synthesize(text, ref_audio, tts, vocoder, device)
        output_path = "generated_speech.wav"
        sf.write(output_path, audio, SAMPLING_RATE, subtype="PCM_16")
        print(f"Speech saved at: {output_path}")
        os.system(f"play {output_path}")  # optional playback
    except Exception as e:
        print(f"Error during synthesis: {e}")
