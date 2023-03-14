from netCDF4 import Dataset as ds
from PIL import Image
import os
import numpy as np
import math as ma
import random

def convert(infile, outname, var, typ=1, ext=0):
    filenum = len(infile)
    datar1 = []
    for i in range(filenum):
        data = ds(infile[i])
        datar1.append(data[var][:])
        datar1[i] = np.flip(datar1[i], 0)   #flip from netcdf's bottom-top order to PIL's top-bottom order
    if filenum == 1:
        datar = datar1[i]
    elif filenum == 4:
        datarn = np.concatenate((datar1[0], datar1[1]), 1)
        datars = np.concatenate((datar1[2], datar1[3]), 1)
        datar = np.concatenate((datarn, datars), 0)
    else:
        datarnn = np.concatenate((datar1[0], datar1[1], datar1[2], datar1[3]), 1)
        datarn = np.concatenate((datar1[4], datar1[5], datar1[6], datar1[7]), 1)
        datars = np.concatenate((datar1[8], datar1[9], datar1[10], datar1[11]), 1)
        datarss = np.concatenate((datar1[12], datar1[13], datar1[14], datar1[15]), 1)
        datar = np.concatenate((datarnn, datarn, datars, datarss), 0)
    if typ == 4:
        print('Working, may take some time...')
        random.seed()
        colors = {0:(0,0,0)}    #Create list of rgb colors with the first corresponding to black
        used = [(0,0,0)]    #List of colors that have already been used
        norep = True
        if np.amax(datar) > 16777215:
            norep = False
            print('  Warning: too many ids for unique colors; there will be repeats')
        print(' Assigning random colors to ids...')
        if norep:
            for n in range(np.amax(datar)):
                while True:
                    newcolor = (random.randint(0,255),random.randint(0,255),random.randint(0,255))  #Assign each id a random rgb color
                    if newcolor not in used:    #Ensure each new color is unique
                        used.append(newcolor)
                        colors[n+1] = newcolor
                        break
        else:
            for n in range(np.amax(datar)):
                newcolor = (random.randint(0,255),random.randint(0,255),random.randint(0,255))  #If too many ids for each to be unique, don't bother checking
                colors[n+1] = newcolor
        print(' Coloring pixels by id...')
        datar2 = np.empty([datar.shape[0],datar.shape[1],3], np.uint8)  #Create new array to hold color for each id
        xax = np.arange(0,datar.shape[0])
        yax = np.arange(0,datar.shape[1])
        xax,yax = np.meshgrid(xax,yax)  #Create grid with index of each datapoint in data array
        with np.nditer([xax,yax]) as co:
            for x, y in co:
                datar2[x,y,:] = np.asarray(colors[datar[x,y]])  #Assign each pixel the appropriate color
        outmap = Image.fromarray(datar2)
    elif typ == 3:
        datar = np.where(datar > ext, 65535, 0) #Binarize data by threshold
        outmap = Image.fromarray(datar.astype('uint16'))
    else:
        dmax = np.amax(datar)
        dmin = np.amin(datar)
        print(f'Maximum value: {dmax}')
        print(f'Minimum value: {dmin}')
        if typ == 2:
            datar = np.log10(datar)
            dmax = np.amax(datar)
            datar = datar*65535/dmax
        else:
            if typ == 0:
                ran = dmax - dmin
            elif typ == 1:
                datar = datar**ext
                dmax = np.amax(datar)
                dmin = np.amin(datar)
                dmin = min(dmin,0)
                ran = dmax - dmin
            datar = (datar-dmin) * 65535/ran
            print(f'Greyscale value of 0: {(ran-dmax)*65535/ran}')
        outmap = Image.fromarray(datar.astype('uint16'))
    outmap.save(outname)
    return

if __name__ == "__main__":
    path = os.path.join(os.path.dirname(__file__), '')
    print('''NetCDF to .png file converter
For 2-dimensional scalar data
Outputs as 16-bit greyscale or 3x8-bit colors
Made 2022 by Nikolai Hersfeldt
''')
    while True:
        filenum = int(input('Number of files (1, 4, 16): '))
        if filenum == 1 or filenum == 4 or filenum == 16:
            break
        print(' Can only use 1, 4, or 16 files')
    infile = []
    if filenum == 1:
        infile.append(path+input('Input file: '))
    elif filenum == 4:
        infile.append(path+input('NW input file: '))
        infile.append(path+input('NE input file: '))
        infile.append(path+input('SW input file: '))
        infile.append(path+input('SE input file: '))
    elif filenum == 16:
        infile.append(path+input('NNWW input file: '))
        infile.append(path+input('NNW  input file: '))
        infile.append(path+input('NNE  input file: '))
        infile.append(path+input('NNEE input file: '))
        infile.append(path+input('NWW  input file: '))
        infile.append(path+input('NW   input file: '))
        infile.append(path+input('NE   input file: '))
        infile.append(path+input('NEE  input file: '))
        infile.append(path+input('SWW  input file: '))
        infile.append(path+input('SW   input file: '))
        infile.append(path+input('SE   input file: '))
        infile.append(path+input('SEE  input file: '))
        infile.append(path+input('SSWW input file: '))
        infile.append(path+input('SSW  input file: '))
        infile.append(path+input('SSE  input file: '))
        infile.append(path+input('SSEE input file: '))
    data = ds(infile[0])
    print('Found variables:')
    for i in data.variables:
        print(' '+i)
    ext = 0
    while True:
        var = input('Choose variable: ')
        typ = int(input('''Map type
 0: Linear greyscale
 1: Greyscale on exponential scale
 2: Greyscale on logarithmic scale
 3: Binary by threshold
 4: Random color by integer id
 Choose type: '''))
        if typ == 3:
            ext = float(input('''Threshold
 All values above will be shown white, all below shown black
 Input: '''))
        elif typ == 1:
            ext = float(input('Exponent: '))
        outname = path+input('Output name: ')
        convert(infile, outname, var, typ, ext)
        print('')
        print('Map saved to '+outname)
        if 'y' not in input('Another?: '):
            break
