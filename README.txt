#!/bin/bash
# ============================================================
# Prosody Incorporated Text-to-Speech (TTS)
# Shiv Nadar University Chennai
# Department of Computer Science and Engineering
# ============================================================

# ------------------------------------------------------------
# OVERVIEW
# ------------------------------------------------------------
# The Prosody Incorporated Text-to-Speech (TTS) system generates
# natural and expressive speech from text. It extends standard
# TTS by integrating emotion-aware prosody modeling to produce
# speech in multiple emotional tones:
#   - Neutral
#   - Happy
#   - Sad
#   - Exclamatory
#
# Built using:
#   - Streamlit (for the web interface)
#   - FastSpeech2 (for text-to-mel synthesis)
#   - HiFi-GAN (for high-quality waveform generation)
#
# Supports word-level synthesis for multiple Indian languages.
# ------------------------------------------------------------


# ------------------------------------------------------------
# KEY FEATURES
# ------------------------------------------------------------
# • Emotion Control: Neutral / Happy / Sad / Exclamatory
# • Interactive Web Interface built with Streamlit
# • Neural Models Used: FastSpeech2 + HiFi-GAN Vocoder
# ------------------------------------------------------------


# ------------------------------------------------------------
# INSTALLATION & SETUP
# ------------------------------------------------------------

# 1. Clone the repository
git clone https://github.com/<your-username>/prosody-tts.git
cd prosody-tts

# 2. Install dependencies
pip install -r requirements.txt

# 3. Activate the conda environment
conda activate tts-hs-hifigan

# 4. Run the Streamlit app
streamlit run prosody_tts_emotions.py
# ------------------------------------------------------------


# ------------------------------------------------------------
# USAGE GUIDE
# ------------------------------------------------------------
# 1. Select the language (e.g., Tamil)
# 2. Choose emotion (Neutral / Happy / Sad / Exclamatory)
# 3. Enter your text input in the chosen language
# 4. Click 'Generate Speech'
# 5. Wait for the synthesis process to complete
# 6. Listen to and download the generated audio output
# ------------------------------------------------------------


# ------------------------------------------------------------
# CORE COMPONENTS
# ------------------------------------------------------------
# Streamlit UI          : Interactive interface for emotion and language selection
# Preprocessing Pipeline: Converts text to phoneme + label format
# FastSpeech2_HS        : Base TTS model for syllable-level synthesis
# FastSpeech2_HS_proso  : Emotion-conditioned word-level synthesis
# HiFi-GAN Vocoder      : Converts mel-spectrograms to natural audio
# ------------------------------------------------------------


#----------------------------------------------------------------
#SYSTEM ARCHITECTURE
#---------------------------------------------------------------
┌──────────────────────────────────────────────┐
│                 Streamlit UI                 │
│──────────────────────────────────────────────│
│ - User selects language, emotion, and text   │
│ - Displays progress bar and synthesis result │
└──────────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│         Text & Phoneme Preprocessing          │
│──────────────────────────────────────────────│
│ - Text processing and phoneme labeling        │
│ - HTS-compatible label formatting             │
│ - Text cleanup and preparation                │
└──────────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│     Base Synthesis (Syllable-Level)          │
│──────────────────────────────────────────────│
│ - Uses fastspeech2  model for base TTS     │
│ - Generates output: `syl_base.wav`           │
└──────────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│     Word-Level Synthesis (Prosody)           │
│──────────────────────────────────────────────│
│ - Emotion-conditioned fastspeech2 prosody trained model   │
│ - Adds prosodic variation and emotion control│
│ - Generates output: `wrd_proso.wav`          │
└──────────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│           Streamlit Output Display            │
│──────────────────────────────────────────────│
│ - Base and prosody audio playback             │
│ - Download buttons and emotion info display   │
└──────────────────────────────────────────────┘

#-------------------------------------------------------------------

# ------------------------------------------------------------
# CONTRIBUTORS
# ------------------------------------------------------------
# Shiv Nadar University Chennai
# Department of Computer Science and Engineering
# ------------------------------------------------------------


# ------------------------------------------------------------
# LICENSE
# ------------------------------------------------------------
# This repository is currently available only in Tamil and is being fine-tuned. Work in progress.
#
# © 2025 Shiv Nadar University Chennai.
# All Rights Reserved.
# ------------------------------------------------------------
