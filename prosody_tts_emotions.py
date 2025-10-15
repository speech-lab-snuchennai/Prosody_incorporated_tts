#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import streamlit as st
import subprocess
import os
import shutil
from pathlib import Path
import base64
import time

# Set page configuration
st.set_page_config(
    page_title="Prosody TTS - Shivnadar University",
    page_icon="🎵",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        color: #2E86AB;
        text-align: center;
        margin-bottom: 1rem;
        font-weight: bold;
    }
    .sub-header {
        font-size: 1.5rem;
        color: #A23B72;
        text-align: center;
        margin-bottom: 2rem;
    }
    .university-name {
        font-size: 1.2rem;
        color: #F18F01;
        text-align: center;
        margin-bottom: 2rem;
        font-weight: bold;
    }
    .success-box {
        background-color: #d4edda;
        border: 1px solid #c3e6cb;
        border-radius: 5px;
        padding: 15px;
        margin: 10px 0;
    }
    .audio-container {
        background-color: #f8f9fa;
        border-radius: 10px;
        padding: 20px;
        margin: 15px 0;
        border-left: 5px solid #2E86AB;
    }
    .stButton button {
        background-color: #2E86AB;
        color: white;
        font-weight: bold;
        border: none;
        padding: 10px 20px;
        border-radius: 5px;
        width: 100%;
    }
    .stButton button:hover {
        background-color: #1B5E7B;
    }
    .processing-spinner {
        text-align: center;
        padding: 20px;
    }
    .emotion-option {
        padding: 10px;
        border-radius: 5px;
        margin: 5px 0;
    }
    .emotion-neutral { background-color: #e8f4fd; border-left: 4px solid #2E86AB; }
    .emotion-happy { background-color: #f0f8e8; border-left: 4px solid #4CAF50; }
    .emotion-sad { background-color: #fde8e8; border-left: 4px solid #F44336; }
    .emotion-exclamatory { background-color: #fef7e0; border-left: 4px solid #FF9800; }
</style>
""", unsafe_allow_html=True)

# Header section
st.markdown('<div class="main-header">ShivNadar University Chennai</div>', unsafe_allow_html=True)
st.markdown('<div class="university-name">Prosody Incorporated TTS</div>', unsafe_allow_html=True)

# Initialize session state for audio files
if 'base_audio' not in st.session_state:
    st.session_state.base_audio = None
if 'proso_audio' not in st.session_state:
    st.session_state.proso_audio = None
if 'processing' not in st.session_state:
    st.session_state.processing = False
if 'process_complete' not in st.session_state:
    st.session_state.process_complete = False
if 'process_started' not in st.session_state:
    st.session_state.process_started = False
if 'selected_emotion' not in st.session_state:
    st.session_state.selected_emotion = "neutral"

# Constants
UPLOAD_FOLDER = "uploads"
STATIC_AUDIO = Path("static/audio")
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
STATIC_AUDIO.mkdir(parents=True, exist_ok=True)

def run_tts_pipeline(language, text_line, emotion):
    """Run the TTS pipeline with emotion selection"""
    try:
        st.info("🔄 Starting TTS pipeline...")
        
        # Clean previous outputs
        shutil.rmtree("try_out", ignore_errors=True)
        os.makedirs("try_out", exist_ok=True)
        if os.path.exists("lablist"):
            os.remove("lablist")

        # Run preprocessing
        st.info("📝 Running preprocessing...")
        subprocess.run(["python3", "gui_demo_tts.py", language, text_line], check=True)
        subprocess.run(["python3", "phn_to_lab.py"], check=True)
        subprocess.run("ls -v data/phn.lab >> lablist", shell=True, check=True)
        subprocess.run(["./lab_hts_format", "lablist", "try_out"], check=True)
        subprocess.run(["perl", "obtain_only_text.pl"], check=True)

        # Prepare syllable-level text
        sample_base = subprocess.getoutput("head -n 1 text_HS_without_space").strip().split(" ", 1)[1].strip(".")
        sample_base = f"${sample_base}."

        # Base synthesis
        st.info("🔊 Running base synthesis...")
        cmd_syllable = f"""
        cd Fastspeech2_HS && \
        conda run -n tts-hs-hifigan python3 inference_test_base.py \
        --sample_text "{sample_base}" \
        --language {language} \
        --gender male \
        --alpha 1 \
        --output_file syl_base.wav
        """
        result = subprocess.run(cmd_syllable, shell=True, executable="/bin/bash", capture_output=True, text=True)
        if result.returncode != 0:
            st.error(f"Syllable synthesis failed:\n{result.stderr}")
            return False

        # Emotion-based label generation
        st.info(f"🎭 Generating {emotion} emotion labels...")
        
        # Write emotion to a temporary file for rand_lab.py to read
        with open("selected_emotion.txt", "w") as f:
            f.write(emotion)
        
        # Run the modified rand_lab.py with emotion parameter - FIXED: use 'emotion' instead of 'selected_emotion'
        subprocess.run(["python3", "rand_lab.py", emotion], check=True)

        # Prepare word-level text with emotion prefix for processing
        emotion_prefix = f"{emotion}_"  # Add emotion prefix for the text processing
        sample_text = subprocess.getoutput("head -n 1 out_text_hs").strip().split(" ", 1)[1].strip(".")
        sample_text = f"${sample_text}."  # Add emotion prefix to the text

        # Word-level synthesis
        st.info("🔊 Running word-level synthesis with prosody...")
        cmd_word = f"""
        cd Fastspeech2_HS_proso && \
        conda run -n tts-hs-hifigan python3 inference_test_wrd.py \
        --sample_text "{sample_text}" \
        --language {language} \
        --gender male \
        --alpha 1 \
        --output_file wrd_proso.wav
        """
        result = subprocess.run(cmd_word, shell=True, executable="/bin/bash", capture_output=True, text=True)
        if result.returncode != 0:
            st.error(f"Word synthesis failed:\n{result.stderr}")
            return False

        # Original output file paths
        syl_path = Path("Fastspeech2_HS/syl_base.wav")
        wrd_path = Path("Fastspeech2_HS_proso/wrd_proso.wav")

        if not syl_path.exists() or not wrd_path.exists():
            st.error("Audio generation failed - output files not found.")
            return False

        # Copy to static/audio for playback
        syl_static = STATIC_AUDIO / "syl_base.wav"
        wrd_static = STATIC_AUDIO / "wrd_proso.wav"
        shutil.copyfile(syl_path, syl_static)
        shutil.copyfile(wrd_path, wrd_static)

        # Store in session state
        st.session_state.base_audio = syl_static
        st.session_state.proso_audio = wrd_static
        
        st.success("✅ TTS pipeline completed successfully!")
        return True

    except subprocess.CalledProcessError as e:
        st.error(f"A command failed: {e}")
        return False
    except Exception as e:
        st.error(f"An error occurred: {str(e)}")
        return False

def show_processing_ui():
    """Show processing UI with progress"""
    st.warning("🔄 Processing... Please wait")
    
    # Create a progress bar
    progress_bar = st.progress(0)
    status_text = st.empty()
    
    # Simulate progress updates while processing
    for i in range(100):
        # Update progress bar
        progress_bar.progress(i + 1)
        
        # Update status text based on emotion
        emotion = st.session_state.selected_emotion
        if i < 25:
            status_text.text("📝 Preprocessing text...")
        elif i < 50:
            status_text.text("🔊 Running synthesis...")
        elif i < 75:
            status_text.text(f"🎭 Generating {emotion} emotion labels...")
        else:
            status_text.text("🔊 Running word-level synthesis...")
        
        # Small delay for visual effect
        time.sleep(0.1)
        
        # Break if processing is complete
        if st.session_state.process_complete:
            break

def show_results():
    """Display the generated audio results"""
    st.success("✅ Synthesis Complete!")
    
    # Display emotion info
    emotion = st.session_state.selected_emotion
    emotion_display = {
        "neutral": "🎭 Neutral Emotion",
        "happy": "😊 Happy Emotion", 
        "sad": "😢 Sad Emotion",
        "exclamatory": "❗ Exclamatory Emotion"
    }
    
    st.info(f"**Generated with:** {emotion_display.get(emotion, emotion)}")
    
    # Display audio players
    st.markdown("### Generated Audio Outputs")
    
    # Syllable-level audio
    with st.container():
        st.markdown('<div class="audio-container">', unsafe_allow_html=True)
        st.markdown("#### Base Synthesizer")
        if st.session_state.base_audio and st.session_state.base_audio.exists():
            audio_file = open(st.session_state.base_audio, 'rb')
            audio_bytes = audio_file.read()
            st.audio(audio_bytes, format='audio/wav')
            
            # Download button for syllable audio
            st.download_button(
                label="📥 Download Base Audio",
                data=audio_bytes,
                file_name="Base.wav",
                mime="audio/wav"
            )
        st.markdown('</div>', unsafe_allow_html=True)
    
    # Word-level audio with prosody
    with st.container():
        st.markdown('<div class="audio-container">', unsafe_allow_html=True)
        st.markdown("#### Word-Level Synthesizer with Prosody")
        if st.session_state.proso_audio and st.session_state.proso_audio.exists():
            audio_file = open(st.session_state.proso_audio, 'rb')
            audio_bytes = audio_file.read()
            st.audio(audio_bytes, format='audio/wav')
            
            # Download button for word audio
            st.download_button(
                label="📥 Download Word Audio",
                data=audio_bytes,
                file_name=f"word_prosody_{emotion}.wav",
                mime="audio/wav"
            )
        st.markdown('</div>', unsafe_allow_html=True)

def get_emotion_description(emotion):
    """Get description for each emotion type"""
    descriptions = {
        "neutral": "Normal speaking style without strong emotional emphasis",
        "happy": "Joyful, upbeat tone with positive emotional expression", 
        "sad": "Melancholic, subdued tone with emotional depth",
        "exclamatory": "Emphatic, expressive tone with strong emphasis"
    }
    return descriptions.get(emotion, "")

# Main application
def main():
    # Sidebar for additional information
    with st.sidebar:
        st.markdown("### About Prosody TTS")
        st.info("""
        This Prosody Text-to-Speech system generates natural-sounding speech with:
        
        - **Syllable-level synthesis** for basic pronunciation
        - **Word-level synthesis** with enhanced prosody
        - **Emotion selection** for expressive speech
        - Support for multiple languages
        - Advanced neural network models
        """)
        
        st.markdown("### Instructions")
        st.warning("""
        1. Select your preferred language
        2. Choose emotion type
        3. Enter the text you want to synthesize
        4. Click 'Generate Speech' 
        5. Wait for processing to complete
        6. Listen to both audio outputs
        """)
        
        st.markdown("### Technical Details")
        st.code("""
        Models Used:
        - FastSpeech2
        - HiFi-GAN Vocoder
        - Emotion-aware Prosody
        """)

    # Main content area
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.markdown("### Input Parameters")
        
        # Language selection
        language = st.selectbox(
            "Select Language",
            options=["tamil", "hindi", "telugu", "malayalam", "kannada"],
            index=0,
            help="Choose the language for speech synthesis"
        )
        
        # Emotion selection
        st.markdown("### 🎭 Select Emotion Type")
        
        # Emotion options with styling
        emotion_options = {
            "neutral": {"label": "🎭 Neutral", "class": "emotion-neutral"},
            "happy": {"label": "😊 Happy", "class": "emotion-happy"}, 
            "sad": {"label": "😢 Sad", "class": "emotion-sad"},
            "exclamatory": {"label": "❗ Exclamatory", "class": "emotion-exclamatory"}
        }
        
        selected_emotion = st.radio(
            "Choose emotional style:",
            options=list(emotion_options.keys()),
            format_func=lambda x: emotion_options[x]["label"],
            index=0,
            help=get_emotion_description(selected_emotion if 'selected_emotion' in locals() else "neutral")
        )
        
        # Store selected emotion in session state
        st.session_state.selected_emotion = selected_emotion
        
        # Show emotion description
        st.markdown(f'<div class="{emotion_options[selected_emotion]["class"]} emotion-option">'
                   f'<strong>{emotion_options[selected_emotion]["label"]}</strong><br>'
                   f'<small>{get_emotion_description(selected_emotion)}</small>'
                   f'</div>', unsafe_allow_html=True)
        
        # Text input
        text_line = st.text_area(
            "Enter Text to Synthesize",
            height=100,
            placeholder="Type the text you want to convert to speech here...",
            help="Enter the text in the selected language"
        )
        
        # Generate button
        generate_btn = st.button(
            "🎵 Generate Speech",
            type="primary",
            disabled=st.session_state.processing
        )

    with col2:
        st.markdown("### System Status")
        
        if st.session_state.process_started and not st.session_state.process_complete:
            show_processing_ui()
        
        elif st.session_state.process_complete:
            show_results()

    # Handle generation process
    if generate_btn:
        if not language or not text_line:
            st.error("❌ Please provide both language and text.")
        else:
            # Reset states
            st.session_state.process_started = True
            st.session_state.process_complete = False
            st.session_state.processing = True
            
            # Use a placeholder to run the processing
            with st.spinner("Starting TTS pipeline..."):
                # Run the TTS pipeline with emotion
                success = run_tts_pipeline(language, text_line, selected_emotion)
                
                # Update states
                st.session_state.processing = False
                st.session_state.process_complete = success
                
            # Rerun to update the UI
            st.rerun()

    # Footer
    st.markdown("---")
    st.markdown(
        "<div style='text-align: center; color: #666;'>"
        "Prosody Text-to-Speech System • Shivnadar University Chennai • Research Lab"
        "</div>", 
        unsafe_allow_html=True
    )

if __name__ == "__main__":
    main()
