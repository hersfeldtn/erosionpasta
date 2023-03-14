from PIL import Image
import numpy as np
import os

Image.MAX_IMAGE_PIXELS = 1e12

def rescale(infile, outfile, resctype, xval, zpoint=0):
    im = Image.open(infile)
    m = im.mode
    im = im.convert('F')
    data = np.asarray(im)
    if m=='L' or m=='P' or m=='RGB' or m=='RGBA' or m=='LA' or m=='PA' or m=='La':
        data = data*255
    data = data - zpoint
    if resctyp < 3:
        if resctyp == 1:
            data += xval
        elif resctyp == 2:
            data *= xval
            data =+ zpoint
        if np.amin(data) < 0:
            print(f' Values outside range (down to {np.amin(data)}), trimming to 0')
            data = np.maximum(data,0)
        if np.amax(data) > 65535:
            print(f' Values outside range (up to {np.amax(data)}), trimming to 65535')
            data = np.minimum(data,65535)
    else:
        sign = np.where(data > 0, True,False)
        data = np.abs(data)
        if resctyp == 3:
            data = np.power(data, xval)
            data *= np.where(sign, 1, -1)
            data += zpoint**xval
            sc = ((65535-zpoint)**xval + zpoint**xval)/65535
            print(f' Greyscale of new zero point: {zpoint**xval/sc}')
            data /= sc
        elif resctype == 4:
            data = np.log10(data)
            data /= np.log10(xval)
            data += np.log10(zpoint)/np.log10(xval)
            sc = (np.log10(65535-zpoint) + np.log10(zpoint))/(np.log10(xval)*65535)
            print(f' Greyscale of new zero point: {np.log10(zpoint)/np.log10(xval)/sc}')
            data /= sc
    outim = Image.fromarray(data.astype('uint16'))
    outim.save(outfile)
    return
        
def blend(infile1, infile2, outfile, bltyp, off=0, sc=1, min2=0, max2=1):
    im1 = Image.open(infile1)
    m = im1.mode
    im1 = im1.convert('F')
    data1 = np.asarray(im1)
    if m=='L' or m=='P' or m=='RGB' or m=='RGBA' or m=='LA' or m=='PA' or m=='La':
        data1 = data1*255
    im2 = Image.open(infile2)
    m = im2.mode
    im2 = im2.convert('F')
    data2 = np.asarray(im2)
    if m=='L' or m=='P' or m=='RGB' or m=='RGBA' or m=='LA' or m=='PA' or m=='La':
        data2 = data2*255
    if bltyp == 1:
        data2 = data2 - off
        data2 *= sc
        dataout = data1 + data2
    else:
        data1 = data1 - off
        data2 = data2 * sc
        data2 *= (max2-min2)/65535
        data2 += min2
        if bltyp == 2:
            dataout = data1 * data2
        elif bltyp == 3:
            sign = np.where(data1 > 0, True,False)
            data1 = np.abs(data1)
            dataout = np.power(data1, data2)
            dataout *= np.where(sign, 1, -1)
    if np.amin(data) < 0:
        print(f' Values outside range (down to {np.amin(data)}), trimming to 0')
        data = np.maximum(data,0)
    if np.amax(data) > 65535:
        print(f' Values outside range (up to {np.amax(data)}), trimming to 65535')
        data = np.minimum(data,65535)
    outim = Image.fromarray(dataout.astype('uint16'))
    outim.save(outfile)
    return          

if __name__ == "__main__":
    print('''Greyscale Utilities
for use with 16-bit greyscale images
(so all greyscale values are on 0-65535 scale;
 any values outside this range will be clipped at the end)
Was a bit of a quick write so may have weird behavior if you use invalid inputs
''')
    path = os.path.join(os.path.dirname(__file__), '')
    typ = int(input('''
Functions:
 1: Rescale image
 2: Blend 2 images (of same resolution)
Choose function: '''))
    print('')
    if typ == 1:
        infile = path + input('Input file: ')
        resctyp = int(input('''Rescale function
 1: Offset (add x to all values)
 2: Linear (multiply all values by x)
 3: Exponent (raise all values to power of x)
 4: Logarithm (return logarithm of all values with base of x)
 (Notes:
  For 1 and 2, values outside 0-65535 will be clipped
  For 3 and 4, values will be rescaled to same 0-65535 output range
   and negative values will be converted to positive before applying function
   then converted back to negative)
Choose function: '''))
        print('')
        zpoint = 0
        if resctyp == 1:
            xval = int(input('Offset value: '))
        elif resctyp == 2:
            xval = float(input('Scale to muliply by: '))
        elif resctyp == 3:
            xval = float(input('Exponent: '))
        elif resctyp == 4:
            xval = float(input('Logarithm base: '))
        if resctyp > 1:
            zpoint = int(input('Greyscale value of zero point (e.g. sea level): '))
        outfile = path + input('Output filename: ')
        print('running...')
        rescale(infile, outfile, resctyp, xval, zpoint)
        input(f'''
Image saved to {outfile}
press enter to close''')
    elif typ == 2:
        infile1 = path+input('Input first file: ')
        infile2 = path+input('Input second file: ')
        bltyp = int(input('''Blend type:
 1: Sum (add file 2 values to file 1 values)
 2: Product (multiply file 1 values by file 2 values)
 3: Power (raise file 1 values to power of file 2)
 (Notes:
  Any resulting values outside 0-65535 will be clipped
  For 3, negative values from File 1
   will be converted to positive before applying function
   then converted back to negative)
Choose function: '''))
        print('')
        if bltyp == 1:
            off = int(input('Greyscale of File 2 zero point (e.g. sea level): '))
            sc = float(input('File 2 scale: '))
        else:
            off = int(input('Greyscale of File 1 zero point (e.g. sea level): '))
            sc = float(input('File 1 scale: '))
            min2 = float(input('File 2 min value (at 0 greyscale): '))
            max2 = float(input('File 2 max value (at 65535 greyscale): '))
        outfile = path + input('Output filename: ')
        print('running...')
        blend(infile1, infile2, outfile, bltyp, off, sc, min2, max2)
        input(f'''
Image saved to {outfile}
press enter to close''')
        


            
    
