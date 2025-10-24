#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug  4 13:38:12 2025

@author: speechlab
"""

import scipy.signal
import matplotlib.pyplot as plt
import numpy as np
import parselmouth
import seaborn as sns
import statistics
# from flask import *
import os
import time
import scipy.io.wavfile as wav
#from g2p_en import G2p
import pandas as pd
import itertools
import more_itertools as mit
from itertools import groupby
from statistics import mean
import requests
import json
import wave
import requests
from parselmouth.praat import call 
#from transformers import pipeline
# from jiwer import wer
import requests
import json
import os
from tabulate import tabulate
# import speech_recognition as sr
# from pydub import AudioSegment
# from pydub.silence import split_on_silence
# from ai4bharat.transliteration import XlitEngine
from itertools import zip_longest
import sys
import soundfile as sf

#from transformers import WhisperProcessor, WhisperForConditionalGeneration
import torch
import soundfile as sf

#ddd_phoneme, ddd_syllable, ddd_word, ddd_intensity, ddd_break, ddd_tobi


def full_code(language):
        # f1 =filename.split('\\')
        # file = f1[-1].split('.')[0]
        # os.system("ch_wave " + filename + " -F 16000 -otype wav -o temp.wav")
        # os.system("ch_wave temp.wav -c 1 -otype wav -o temp.wav")
        ###############################################################################
        ###############################################################################
        ##########################Speech to Text#######################################
        if language == 'English':
            # headersList = {
            #         "Authorization": f"Token {token}"
            #         }
            # files = {
            #         'file': open('temp.wav', 'rb'),
            #         'language': (None, 'english'),
            #         'vtt': (None, 'true'),
            #         }
            # response = requests.post('https://asr.iitm.ac.in/api/asr/', files=files,
            #                              headers=headersList)
            # text = response.json().get("transcript")
            # print(text)
            # outf = open("text.txt", "w")
            # for lines in text:
            #     outf.write(lines)
            #     # outf.write("\n")
            # outf.close()
            # os.system("tr -d '[:punct:]' <text.txt >temp.txt")
            text_line=sys.argv[2]
      
 # Use 'tr' command to remove punctuation and output to t.txt
            # os.system(f"tr -d '[:punct:]' < {textfile} > t.txt")
            # print(f"Wave Line: {wave_line}")
            try:
                with open("te.txt", "w", encoding="utf-8") as temp_file:
                    temp_file.write(text_line)
                    print("Successfully written to te.txt.")
            except Exception as e:
                    print(f"Error writing to te.txt: {e}")

 # Step 2: Remove punctuation from te.txt and save to t.txt using `tr`
            try:
                os.system("tr -d '[:punct:]' < te.txt > temp.txt")
                print("Successfully processed te.txt and saved to temp.txt.")
            except Exception as e:
                print(f"Error processing te.txt: {e}")

 # Step 3: Check if t.txt exists and print its contents
            if os.path.exists("temp.txt"):
                 with open("temp.txt", "r", encoding="utf-8") as processed_file:
                     processed_line = processed_file.read().strip()
                     print(f"Processed Text Line: {processed_line}")
            else:
                 print("Error: temp.txt was not created.")
            ###############################################################################
            ###############################################################################
            #####################PHONEME SEGMENTATION######################################

            os.system("rm -r data")
            os.system("mkdir data")
            # os.system("cp -r temp.wav data/")
            os.system("ch_wave temp.wav -itype wav -otype nist -o data/temp.wav")
            # os.system("cp temp.wav data/")
            os.system("mv temp.txt data")
            # os.system("mv temp.wav data")
            # os.system("rm *.wav")
            # os.system("./scripts/ortho_to_phonetic1 data/temp.txt phoneset_smp >data/temp.lab")
            # texts = ["She had your dark suit in greasy wash water all year"]
            with open("data/temp.txt") as f:
                texts = f.read()
                # print(texts)
            g2p = G2p()
            out = g2p(texts)
            # res = [ele for ele in out if ele.strip()]
            outf = open("file.txt", "w")
            for lines in out:
                outf.write(lines)
                outf.write("\n")
            outf.close()
            os.system("./scripts/map_eng file.txt english_map")
            
        elif language =='tamil':
            


           text_line=sys.argv[2]
     
# Use 'tr' command to remove punctuation and output to t.txt
           # os.system(f"tr -d '[:punct:]' < {textfile} > t.txt")
           # print(f"Wave Line: {wave_line}")
           try:
               with open("te.txt", "w", encoding="utf-8") as temp_file:
                   temp_file.write(text_line)
                   print("Successfully written to te.txt.")
           except Exception as e:
                   print(f"Error writing to te.txt: {e}")

# Step 2: Remove punctuation from te.txt and save to t.txt using `tr`
           try:
               os.system("tr -d '[:punct:]' < te.txt > t.txt")
               print("Successfully processed te.txt and saved to t.txt.")
           except Exception as e:
               print(f"Error processing te.txt: {e}")

# Step 3: Check if t.txt exists and print its contents
           if os.path.exists("t.txt"):
                with open("t.txt", "r", encoding="utf-8") as processed_file:
                    processed_line = processed_file.read().strip()
                    print(f"Processed Text Line: {processed_line}")
           else:
                print("Error: t.txt was not created.")


           ###############################################################################
           ###############################################################################
           #####################PHONEME SEGMENTATION######################################
           os.system("rm -r data")
           os.system("mkdir data")
           # os.system("cp -r temp.wav data/")
           # os.system("ch_wave temp.wav -itype wav -otype nist -o data/temp.wav")
           # os.system("mv temp.txt data")
           # os.system("mv temp.wav data")
           # os.system("rm *.wav")
           # os.system("./scripts/ortho_to_phonetic1 data/temp.txt phoneset_smp >data/temp.lab")
           # texts = ["She had your dark suit in greasy wash water all year"]
           os.system("sed -i 's/ /sil/g' t.txt")
           os.system("perl scripts/vuv.pl t.txt")
           os.system("cp -r lists/out_word temp.txt")
           os.system("sed -i 's/sil/ /g' temp.txt")
           os.system("sed -i 's/sil/SIL/g' lists/out_word")
           os.system("./scripts/ortho_to_phonetic1_phoneme_tam lists/out_word dep_list/phonelist_tamil >p")
           os.system("./scripts/startsil p")
           # os.system("mv data/*.lab try_out/")
 
#filename=sys.argv[1]
language = sys.argv[1]
full_code(language)
