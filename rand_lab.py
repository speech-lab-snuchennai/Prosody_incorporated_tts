import sys

input_file = "text_HS_without_space"
output_file = "out_text_hs"

# Unicode numerals: first is ௧, last is ௨, others in between
special_numerals = ['௦', '௦', '௦', '௦', '௦', '௦', '௦', '௦', '௦']

# Get emotion from command line argument
emotion = sys.argv[1] if len(sys.argv) > 1 else "neutral"

with open(input_file, "r") as infile:
    line = infile.read().strip()

# Separate prefix and rest
parts = line.split(' ', 1)
prefix = parts[0]
rest = parts[1] if len(parts) > 1 else ""

# Check for trailing dot
has_trailing_dot = rest.endswith('.')

# Extract tokens after each dot
tokens = rest.split('.')[1:]  # remove the empty part before first dot

# If trailing dot left an empty token
if has_trailing_dot and tokens[-1] == '':
    tokens = tokens[:-1]
    trailing_dot = True
else:
    trailing_dot = False

# Use the emotion from user input instead of detecting from prefix
case_type = emotion

print(f"Debug: emotion={emotion}, case_type={case_type}")

# Prepare suffix numerals based on case type
num_tokens = len(tokens)
suffixes = []

if case_type == "happy":
    # Happy case: special characters ௧ for everything, numbers 5
    suffixes = ['௧'] * num_tokens
        
elif case_type == "sad":
    # Sad case: special characters ௨ for everything, numbers 2
    suffixes = ['௨'] * num_tokens
        
elif case_type == "exclamatory":
    # Exclamatory case: special characters ௭,௮,೧ repeatedly, numbers 4 and 5
    if num_tokens == 1:
        suffixes = ['௯']
    elif num_tokens == 2:
        suffixes = ['௯', '௫']
    elif num_tokens == 3:
        suffixes = ['௯', '௫', '೧']
    else:
        middle_count = num_tokens - 2
        middle_numerals = []
        for i in range(middle_count):
            middle_numerals.append(['௭', '௫', '௮'][i % 3])
        suffixes = ['௯'] + middle_numerals + ['೧']
        
else:
    # Default/Neutral case: original logic
    if num_tokens == 1:
        suffixes = ['௧']
    elif num_tokens == 2:
        suffixes = ['௧', '௨']
    else:
        middle_count = num_tokens - 2
        middle_numerals = []
        for i in range(middle_count):
            middle_numerals.append(special_numerals[i % len(special_numerals)])
        suffixes = ['௧'] + middle_numerals + ['௨']

print(f"Debug: num_tokens={num_tokens}, suffixes={suffixes}, tokens={tokens}")

# Construct new tokens with appropriate numbers based on case type
numbered = []
for i, token in enumerate(tokens):
    if case_type == "happy":
        # Happy case: number 5 for everything
        number = 5
    elif case_type == "sad":
        # Sad case: number 2 for everything
        number = 2
    elif case_type == "exclamatory":
        # Exclamatory case: numbers 4 and 5 alternately
        number = 4 if i % 2 == 0 else 5
    else:
        # Default/Neutral case: numbers 3,4,5
        number = (i % 3) + 3
    
    numbered.append(f".{number}{token}{suffixes[i]}")

# Combine all
final_line = prefix + ' ' + ''.join(numbered)
if trailing_dot:
    final_line += '.'

with open(output_file, "w") as outfile:
    outfile.write(final_line + "\n")

print(f"Final output: {final_line}")
