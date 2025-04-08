# -*- coding: utf-8 -*-
"""draw_path.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/github/vitalfocheux/Projet_Init_SAW/blob/main/python/draw_path.ipynb

# Downloads and Imports
"""

import random
import matplotlib.pyplot as plt
import numpy as np

"""# get the path from a text file

like this :
1232312320000232020210
"""

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

# Example usage:
# If the input file contains:
# 0123
# 3210
# The function will return: [[0, 1, 2, 3], [3, 2, 1, 0]]

"""# Random creation of a self avoiding_path"""

def generate_self_avoiding_path(length):
    directions = []
    visited = set()
    x, y = 0, 0
    visited.add((x, y))

    for _ in range(length):
        possible_moves = []
        if (x, y + 1) not in visited:  # North
            possible_moves.append('n')
        if (x, y - 1) not in visited:  # South
            possible_moves.append('s')
        if (x + 1, y) not in visited:  # East
            possible_moves.append('e')
        if (x - 1, y) not in visited:  # West
            possible_moves.append('w')

        if not possible_moves:
            break  # No more moves available

        move = random.choice(possible_moves)
        directions.append(move)

        if move == 'n':
            y += 1
        elif move == 's':
            y -= 1
        elif move == 'e':
            x += 1
        elif move == 'w':
            x -= 1

        visited.add((x, y))

    return directions

# Générer un chemin auto-évitant de longueur 20
path = generate_self_avoiding_path(2000)
print(path)

"""# print a self avoiding path"""

# Fonction pour dessiner le chemin
def draw_path(digits):
    x, y = 0, 0
    x_coords, y_coords = [x], [y]

    for digit in digits:
        if digit == 3:  # Nord
            y += 1
        elif digit == 1:  # Sud
            y -= 1
        elif digit == 0:  # Est
            x += 1
        elif digit == 2:  # Ouest
            x -= 1

        x_coords.append(x)
        y_coords.append(y)

    plt.figure(figsize=(8, 8))
    plt.plot(x_coords, y_coords, 'b-')
    plt.scatter(x_coords[0], y_coords[0], color='green', label='Départ')
    plt.scatter(x_coords[-1], y_coords[-1], color='red', label='Arrivée')
    plt.legend()
    plt.axis('equal')  # Pour que les axes soient égaux
    plt.show()


import matplotlib.pyplot as plt
import os

def draw_path_and_export(digits, directory_path):
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
    # Initialiser les coordonnées
    x, y = 0, 0
    x_coords, y_coords = [x], [y]

    # Calculer les coordonnées en fonction des directions
    for digit in digits:
        if digit == 3:  # Nord
            y += 1
        elif digit == 1:  # Sud
            y -= 1
        elif digit == 0:  # Est
            x += 1
        elif digit == 2:  # Ouest
            x -= 1

        x_coords.append(x)
        y_coords.append(y)

    # Dessiner le chemin avec matplotlib
    plt.figure(figsize=(8, 8))
    plt.plot(x_coords, y_coords, 'b-')
    plt.scatter(x_coords[0], y_coords[0], color='green', label='Départ')
    plt.scatter(x_coords[-1], y_coords[-1], color='red', label='Arrivée')
    plt.legend()
    plt.axis('equal')  # Pour que les axes soient égaux

    # Générer un nom de fichier unique pour éviter d'écraser un fichier existant
    base_filename = "drawing"
    file_extension = ".png"
    output_path = os.path.join(directory_path, base_filename + file_extension)
    counter = 1

    while os.path.exists(output_path):
        output_path = os.path.join(directory_path, f"{base_filename}_{counter}{file_extension}")
        counter += 1

    # Sauvegarder le dessin en PNG dans le répertoire spécifié
    plt.savefig(output_path)
    plt.close()  # Fermer la figure pour éviter d'occuper la mémoire

    print(f"Image sauvegardée dans : {output_path}")

# Fonction principale
def main():
  # the path of the file
  input_file_path = "./R_1.txt" #modifier le chemin relatif vers le fichier des saw
  output_directory_path = "./drawing" # modifier le chemin relatif vers le dossier de sortie (peut ne pas exister)

  # translate the path to a digit tab
  digits = get_paths_from_file(input_file_path)

  for digit in digits:

    draw_path_and_export(digit, output_directory_path)

# Exécuter la fonction principale
main()