input_file = "data/temp.lab"
output_file = "data/phn.lab"

start_time = 125
end_time = 100

with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        phoneme = line.strip()
        new_line = f"{start_time} {end_time} {phoneme}\n"
        outfile.write(new_line)
