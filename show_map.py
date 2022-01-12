import numpy as np
import json
import subprocess
import copy
from web3 import Web3
from ast import literal_eval


def get_planet_type(planet_hash):
    if planet_hash % 3 == 0:
        if planet_hash % 5 == 0: 
            if planet_hash % 7 == 0: 
                planet_type = 3
            else:
                planet_type = 2
        else:
            planet_type = 1

    else:
        planet_type = 0

    return planet_type

curr_x = 44
curr_y = 4

bound = 14
min_x = 44-bound
max_x = 44+bound
min_y = 0
max_y = 4+bound

with open('input_move_suc.json', 'r') as f:
    input_json = json.load(f)

matrix = np.ones((max_x-min_x, max_y-min_y))*-1
true_input = copy.copy(input_json)
print(input_json)
try:
    for i in range(min_x, max_x):
        for j in range(min_y, max_y):
            # dist = np.sqrt((max(curr_x, i)**2 - min(curr_x, i)**2) + (max(curr_y, j)**2 - min(curr_y, j)**2))
            # print(f"{curr_x} {i} {curr_y} {j} {dist}")
            # if dist >= bound:
            #     continue
            input_json = true_input
            input_json['x2'] = i
            input_json['y2'] = j
            with open('input_move_suc.json', 'w') as f:
                json.dump(input_json, f)

            calldata = subprocess.run(["bash", "move_user.sh"], capture_output=True) 

            result = calldata.stdout.decode().split(",")
            hash = result[-1]
            hash = literal_eval(hash[2:-3])

            if calldata.stderr:
                print(calldata.stderr)
                planet_type = -1
                continue
            else:
                planet_type = get_planet_type(hash)

            if i == curr_x and j == curr_y:
                matrix[i-min_x, j-min_y] = planet_type + 10 
            else:
                matrix[i-min_x, j-min_y] = planet_type
            print(f"{matrix} {i} {j} ")
            # matrix[i, j]

except KeyboardInterrupt:
    with open('input_move_suc.json', 'w') as f:
        json.dump(true_input, f)
    
