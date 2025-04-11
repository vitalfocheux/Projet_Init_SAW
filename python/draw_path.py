# -*- coding: utf-8 -*-


# Downloads and Imports


import random
import matplotlib.pyplot as plt
import numpy as np
import os


# get the path from a text file


# take a file path consisting of digit paths separated by newlines
# and return a list of lists of digits
# the digits must be between 0 and 3
def get_paths_from_file(file_path):
    with open(file_path, 'r') as file:
        content = file.readlines()

    # Process each line to extract digits and ensure they are between 0 and 3
    result = []
    for line in content:
        line = line.strip()  # Remove any leading/trailing whitespace or newline characters
        digits = [int(digit) for digit in line if digit.isdigit() and 0 <= int(digit) <= 3]
        result.append(digits)

    return result

"""
* Example well formed file:
* If the input file contains:
* 0123
* 3210
* The function will return: [[0, 1, 2, 3], [3, 2, 1, 0]]
"""


# integer between 0 and 3 to coordinates

def int_to_coordinates(digits):
    x, y = 0, 0
    x_coords, y_coords = [x], [y]

    for digit in digits:
        if digit == 3:    # North
            y += 1
        elif digit == 1:  # South
            y -= 1
        elif digit == 0:  # East
            x += 1
        elif digit == 2:  # West
            x -= 1

        x_coords.append(x)
        y_coords.append(y)

    return (x_coords, y_coords)

# print a self avoiding path

# Function for drawing the path and generating PNG images of these paths
def draw_path_and_export(digits, directory_path):
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
    # Initialise coordinates
    x_coords, y_coords = int_to_coordinates(digits)

    # Draw the path with matplotlib
    plt.figure(figsize=(8, 8))
    plt.plot(x_coords, y_coords, 'b-')
    plt.scatter(x_coords[0], y_coords[0], color='green', label='Départ')
    plt.scatter(x_coords[-1], y_coords[-1], color='red', label='Arrivée')
    plt.legend()
    plt.axis('equal')  # to avoid distortion

    # Generate a unique filename to avoid overwriting existing files
    base_filename = "drawing"
    file_extension = ".png"
    output_path = os.path.join(directory_path, base_filename + file_extension)
    counter = 1

    while os.path.exists(output_path):
        output_path = os.path.join(directory_path, f"{base_filename}_{counter}{file_extension}")
        counter += 1

    # Save the drawing as PNG in the specified directory
    plt.savefig(output_path)
    plt.close()  # Closed the figure to avoid memory issues

    print(f"Image sauvegardée dans : {output_path}")





# Main function to execute the script
def main():
  # the path of the file
  input_file_path = "./L_1.txt" # Modify the relative path to the file
  output_directory_path = "./drawing" # Modify the relative path to the output directory (may not exist)

  # translate the path to a digit tab
  digits = get_paths_from_file(input_file_path)

  for digit in digits:

    draw_path_and_export(digit, output_directory_path)

# Execute the main function
main()