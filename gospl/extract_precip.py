from netCDF4 import Dataset as ds
import numpy as np
import os

def extract(infiles, outfile):
    data = ds(infiles[0])
    pre = data['pr'][:]
    if len(infiles) > 1:
        for f in range(len(infiles)):
            if f == 0:
                continue
            data = ds(infiles[f])
            pre1 = data['pr'][:]
            if f == 1:
                pre = np.stack((pre, pre1))
            else:
                pre = np.concatenate((pre, pre1))
        pre = np.mean(pre, 0)   #Average over arrays
    pre = np.mean(pre, 0, keepdims=True)   #Average over time

    h = pre.shape[1]
    w = pre.shape[2]
    new = ds(outfile, 'w', format='NETCDF4')
    lat = new.createDimension('lat', h)
    lon = new.createDimension('lon', w)
    time = new.createDimension('time', 1)
    lats = new.createVariable('lat','f4',('lat'))
    lons = new.createVariable('lon','f4',('lon'))
    times = new.createVariable('time','u1', ('time'))
    pr = new.createVariable('pr','f4',('lat','lon'))
    pr.units = 'm/s'

    #Leaving this in here for personal use
    #pre = pre*1000*(60*60*24)

    hst = 90/h
    wst = 180/w
    lats[:] = np.linspace(90-hst,-90+hst,h)
    lons[:] = np.linspace(-180-wst,180+wst,w)
    times[:] = [1]
    pr[:,:] = pre
    new.close
    return
    
                
            
        

if __name__ == "__main__":
    path = os.path.join(os.path.dirname(__file__), '')
    infiles = []
    while True:
        infile = input('Input file or folder of files (STOP for no more files):')
        if infile == 'stop' or infile == 'STOP' or infile == 'Stop':
            break
        infile = path+infile
        if os.path.exists(infile):
            if os.path.isdir(infile):
                found = False
                for f in os.listdir(infile):
                    if f.endswith(".nc"):
                        infiles.append(infile+"/"+f)
                        found = True
                        print(" Found "+str(f))
                if found:
                    print("Found all files")
                else:
                    print("No files found in "+str(infile))
            else:
                infiles.append(infile)
                print('File found')
        print('No file found at '+str(infile))
    outfile = path+input('Output name: ')+'.nc'
    print('running...')
    extract(infiles, outfile)
    print('Complete')
                
    
