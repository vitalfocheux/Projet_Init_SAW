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
def is_saw(trail) : 
    posX = 0
    posY = 0

    visited = set()
    visited.add((posX, posY))  # On part de (0,0)
    for dir in trail:
        if dir == 3:    # North
            posY += 1
        elif dir == 1:  # South
            posY -= 1
        elif dir == 0:  # East
            posX += 1
        elif dir == 2:  # West
            posX -= 1

        if (posX, posY) in visited:
            return False  

        visited.add((posX, posY))
    return True
def folding(trail, k, direction="cw"):
    if k < 0 or k >= len(trail):
        raise ValueError("Index de pivot invalide")

    res = trail[:k]  # On garde la partie avant le pivot telle quelle

    if direction == "cw":        
        rotated = [(d + 1) % 4 for d in trail[k:]]
    elif direction == "ccw":     
        rotated = [(d - 1) % 4 for d in trail[k:]]
    else:
        raise ValueError("Direction invalide : choisir 'cw' ou 'ccw'")

    return res + rotated


def is_usaw(trail):
    
    for k in range(1, len(trail) - 1):  # Évite les extrémités
        for direction in ["cw", "ccw"]:
            new_trail = folding(trail, k, direction)
            if is_saw(new_trail):
                return [False, new_trail]
    return [True, []]

def printTrail(trail):# pour recuperer dans le terminal le trail 
    for i in trail:
        print(i, end='')
    print()

# create most of the octogon  
def P1P2Raw(figure, progress, addForMod):



    # addformod = 2 on va dans le sens p2 ; addformod = 0 on va sens p1
   

    # stairs 1
    for _ in range(4): 
        figure += [2, (1 + addForMod ) % 4 ]
    #line left init 
    for _ in range(6): 
        figure += [2]
    #line left scale 
    for _ in range(progress): 
        figure += [2  , 2 ]


    # stairs 2
    for _ in range(4): 
        figure += [(3 + addForMod ) % 4 , 2]
    #line up /down init 
    for _ in range(6): 
        figure += [(3 + addForMod ) % 4]
    #line up/down scale 
    for _ in range(progress): 
        figure += [(3 + addForMod ) % 4  , (3 + addForMod ) % 4 ]


    # stairs 3
    for _ in range(4): 
        figure += [0 , (3 + addForMod ) % 4]
    #line right init 
    for _ in range(6): 
        figure += [0]
    #line right scale 
    for _ in range(progress): 
        figure += [0 , 0 ]


    #final stairs 
    for _ in range(4): 
        figure += [(1 + addForMod ) % 4 , 0]

    return figure

# 
def addP1P2ToFigureNtimes(n, figure, P1Turn = True, progress = 0):
    #progress = couche de l'octogone  plus on est vers l'exterieur plsu il sera élévé
    # n = nombre d'iterations 


    addForMod = 0
    if not P1Turn: # selon le sens où l'on est la prochaine couche sera plus ou moins avancée vers l'extérieur
        addForMod = 2
        futurProgress = progress - 1
        progressNextIter = progress + 1
    else:
        futurProgress = progress + 1
        progressNextIter = progress + 3


    if progress >= n * 2 : # cond de fin
        if P1Turn :
            figure += [3, 2]
        else: 
            figure += [0, (addForMod + 1) % 4]
        return figure

    #1 ere partie
    #les débuts et fins de P1/P2 varient bcp selon la situation où on est 

    #starts
    if P1Turn : #petit virage
        if (progress != 0):
            figure += [0]
        
        figure += [1]
        #final line down scale 
        for _ in range(progress): 
            figure += [1]
    else : # grand virage
        figure += [0,0,0,3,3,3]
         #final line up scale 
        for _ in range(progress):
            
            figure += [3]


    figure = P1P2Raw(figure, progress, addForMod)

    #finissions 
    if P1Turn : 
        figure += [1 , 1 , 1]
        #final line down scale 
        for _ in range(progress): 
            figure += [1]
    else :
        figure += [3]
         #final line up scale 
        for _ in range(progress):
            figure += [3]




    P1Turn = not P1Turn
    addForMod = (addForMod + 2 ) % 4

    figure = addP1P2ToFigureNtimes(n,figure, P1Turn, progressNextIter)# appel recursif, on reconstitue le chemin après plus de la moitié


    # 2 eme partie  , si on avait p1 on a mtn p2 vice versa

    

    #débuts 
    if P1Turn : #grand virage
        figure += [1,1]
        #final line down scale 
        for _ in range(futurProgress): 
            figure += [1]
    else : # petit virage
        figure += [3,3]
         #final line up scale 
        for _ in range(futurProgress): 
            figure += [3]

    figure = P1P2Raw(figure, futurProgress, addForMod)

    #finissions 
    if P1Turn : #petit virage
        figure += [1 , 1 ]
        #final line down scale 
        for _ in range(futurProgress): 
            figure += [1]
        
        figure += [2]
        
    else : #grand virage
        
         #final line up scale 
        for _ in range(futurProgress): 
            figure += [3]
        figure += [3,3,2,2,2]

    return figure

    


def reverse_path(trail):
    reverse_dir = {0: 2, 2: 0, 1: 3, 3: 1}
    return [reverse_dir[d] for d in reversed(trail)]

def create_usaw(n, L1, R1):

  figure = reverse_path(R1)# J'ai échangé le départ et l'arrivée jai donc du inverser les directions
  # les usaw sont concatenations de R1 + n fois (P1 , P2) + L1
  figure += [0] # en manque dans la génération


  figure = addP1P2ToFigureNtimes(n,figure)


  #ajout de L1 à la fin
  
  L1 = reverse_path(L1)
  figure += L1
  return figure


# Main function to execute the script
def main():
  # the path of the file
  input_file_path = "./L_1.txt" 

  # translate the path to a digit tab
  L1 = get_paths_from_file(input_file_path)[0]
  del L1[-1] # en trop  dans la génération

  input_file_path = "./R_1.txt" 

  R1 = get_paths_from_file(input_file_path)[0]


# test : 8 premiers usaw
  for i in range(8):# 0 marche pas c'est normal je pense
    res = create_usaw(i, L1, R1)
    printTrail(res)
    if not (is_saw(res) and is_usaw(res)[0]):
        print("n =  ", i , " ne fonctionne pas")

# Execute the main function
main()