from netCDF4 import Dataset as ds
from PIL import Image
import os
import numpy as np

Image.MAX_IMAGE_PIXELS = 1e12

def Makenc(infile, outname, sctyp, maxel, minel=0, sealev=0):
    np.seterr(divide='ignore',invalid='ignore')
    hmap = Image.open(infile)
    m = hmap.mode
    hmap = hmap.convert('F')
    data = np.asarray(hmap)
    if m=='L' or m=='P' or m=='RGB' or m=='RGBA' or m=='LA' or m=='PA' or m=='La':
        data = data*255
    if sctyp == 1:
        maxim = 65535
        minim = 0
    else:
        maxim = np.amax(data)
        minim = np.amin(data)
    data = data - sealev
    data = np.where(data >= 0, maxel * data / (maxim - sealev), -minel * data / (sealev - minim))
    h=data.shape[0]
    w=data.shape[1]

    nc = ds(outname+".nc", "w", format='NETCDF4')
    lat = nc.createDimension("lat",h)
    lon = nc.createDimension("lon",w)
    lats = nc.createVariable("lat","f4",("lat"))
    lons = nc.createVariable("lon","f4",("lon"))
    z = nc.createVariable("z","f4",("lat","lon"))
    z.units = "m"

    hst = 90/h
    wst = 180/w
    lats[:] = np.linspace(90-hst,-90+hst,h)
    lons[:] = np.linspace(-180-wst,180+wst,w)
    z[:]=data[:]
    nc.close
    return

if __name__ == "__main__":
    path = os.path.join(os.path.dirname(__file__), '')
    infile = path+input('Input greyscale image: ')
    sctyp = int(input('''Elevation input:
 1: Input elevation of 0 and 65535 greyscale
 2: Input max and min in-image elevation
 Input type: '''))
    maxel = float(input('Maximum Elevation (m): '))
    minel = float(input('Minimum Elevation (m): '))
    sealev = float(input('Sea Level (0 elevation) on image (0-65535): '))
    outname = path+input('Output name: ')
    Makenc(infile, outname, sctyp, maxel, minel, sealev)
