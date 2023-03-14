; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; All functions work assuming Wilbur is the open as the main window and the mouse is hovering over "select"


;Functions
	;scripting utilities
		;waits for window x to close, unless it already is
		winclose(x)
		{
			If WinExist(x)
				WinWaitClose
			Sleep speed*10
			return
		}
		;checks if wilbur is done working by trying to open an info window
		checkact(x)
		{
			Sleep speed*10
			inactive:=1
			While inactive=1
			{
				If WinExist("Operation Progress")
					WinWaitClose
				WinWait("Map Information", , x*speed)
				If WinExist("Map Information")
				{
					Sleep speed*10
					Send "{Enter}"
					Break
				}				
				Else
					Send "{Click}{Left}{Left}{Enter}"
			}
			Sleep speed*10
			return
		}
		;clears a weird bug the fist time wilbur tries to load a selection after opening
		;x should be some preexisting mask in your working directory, doesn't matter which
		checksel(x)
		{
			Send "{Click}{Up}{Up}{Enter}"
			WinWait("Load Selection from Image File")
			Sleep speed*10
			Loop 5
			{
				Send "{Tab}"
			}
			Send x . "{Enter}"
			If WinExist("Load Selection from Image File")
			{
				WinWaitClose , , speed*2
				If WinExist("Load Selection from Image File")
					Send x
					Sleep speed*100
					Send "{Enter}"
			}
			checkact(1)
			return
		}
	;File
		;opens new file of size (x,y)
		new(x,y)
		{
			Send "{Click}{Left}{Left}{Left}{Left}{Enter}"
			WinWait(, , "Save changes to", speed*5)
			If Winexist(, , "Save changes to")
				Send "{Tab}{Enter}"
			WinWait("Surface Size")
			Sleep speed*10
			Send x . "{Tab}" . y . "{Enter}"
			Sleep speed*10
			Send Ceil(y/2) . "{Tab}" . Ceil(-1*x/2) . "{Tab}" . Ceil(x/2) . "{Tab}" . Ceil(-1*y/2) . "{Enter}"
			winclose("Surface Size")
			checkact(1)
			return
		}
		;opens a greyscale surface (.bmp, .jpg, .png) with name x
		opengrey(x)
		{
			Send "^o"
			WinWait("Open File")
			Sleep speed*10
			Send x . "{Tab}"
			Send "{Down}"
			Loop 25
			{
				Send "{Up}"
			}
			Sleep speed*10
			Send "{Enter}{Enter}"
			winclose("Open File")
			checkact(5)
			return
		}
		;opens an mdr surface with name x
		openmdr(x)
		{
			Send "^o"
			WinWait("Open File")
			Sleep speed*10
			Send x . "{Tab}"
			Send "{Down}"
			Loop 25
			{
				Send "{Up}"
			}
			Send "{Down}{Down}{Down}"
			Sleep speed*10
			Send "{Enter}{Enter}"
			winclose("Open File")
			checkact(5)
			return
		}
		;Save surface as a 16-bit .png file with name x
		savepng(x)
		{
			Send "^s"
			WinWait("Select File As")
			Sleep speed*10
			Send x . "{Tab}{Down}"
			Loop 35
			{
				Send "{Up}"
			}
			Send "{Enter}{Enter}"
			WinWait("Confirm Save As", , speed*5)
			If WinExist("Confirm Save As")
			{
					Sleep speed*10
					Send "{Tab}{Enter}"
					WinWait("Wilbur")
			}
			If WinExist("Wilbur")
			{
					Sleep speed*10
					Send "{Enter}"
					winclose("Wilbur")
			}
			checkact(1)
			return
		}
		;Save surface as an mdr file with name x
		savemdr(x)
		{
			Send "^s"
			WinWait("Select File As")
			Sleep speed*10
			Send x . "{Tab}{Down}"
			Loop 35
			{
				Send "{Up}"
			}
			Send "{Down}{Enter}{Enter}"
			WinWait("Confirm Save As", , speed*5)
			If WinExist("Confirm Save As")
			{
					Sleep speed*10
					Send "{Tab}{Enter}"
					winclose("Confirm Save As")
			}
			If WinExist("Enter MDR File Save Parameters")
				Sleep speed*10
			else
			{
				WinWait("Enter MDR File Save Parameters")
				Sleep speed*10
			}
			Send "{Up}{Up}{Enter}"
			winclose("Enter MDR File Save Parameters")
			checkact(1)
			return
		}
	;Edit
		;Note for all of these that the "checkact" step at the end of every other function counts as an action for counting undo/redo steps
		;undo x actions (1 by default)
		undo(x:=1)
		{
			Loop x
			{
				Send "^z"
				Sleep speed*100
			}
			return
		}
		;redo x actions (1 by default)
		redo(x:=1)
		{
			Loop x
			{
				Send "^y"
				Sleep speed*100
			}
			return
		}
		;Fade to Prior
		fade(x)
		{
			Send "{Click}{Left}{Left}{Left}{Down}{Down}{Enter}"
			WinWait("Fade to Prior (Fade to Prior)")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Fade to Prior (Fade to Prior)")
			checkact(1)
			return
		}
		;Set number of undo levels to x
		undolev(x)
		{
			Send "{Click}{Left}{Left}{Left}{Down}{Down}{Down}{Enter}"
			WinWait("Preferences")
			Sleep speed*10
			Send "{Tab}{Tab}{Tab}{Tab}{Tab}" . x . "{Enter}"
			winclose("Preferences")
			checkact(1)
			return
		}
	;Surface
		;set the map size:
		;(w = top, x = left, y = right, z = bottom)
		resize(w,x,y,z)
		{
			Send "{Click}{Left}{Left}{Down}{Enter}"
			WinWait("Map Information")
			Sleep speed*10
			Send w . "{Tab}" . x . "{Tab}" . y . "{Tab}" . z . "{Enter}"
			checkact(1)
			return
		}
		;simple resample of map to (x,y)
		resample(x,y)
		{
			Send "{Click}{Left}{Left}{Down}{Down}{Down}{Right}{Down}{Enter}"
			WinWait("Simple Resample")
			Sleep speed*10
			Send x . "{Tab}" . y . "{Tab}" . Ceil(y/2) . "{Tab}" . Ceil(-1*x/2) . "{Tab}" . Ceil(x/2) . "{Tab}" . Ceil(-1*y/2) . "{Enter}"
			winclose("Simple Resample")
			checkact(5)
			return
		}
		;rotates 90 degrees clockwise x times (once by default)
		rotate(x:=1)
		{
			Loop x
			{
				Send "{Click}{Left}{Left}{Down}{Down}{Down}{Down}{Right}{Down}{Enter}"
				checkact(1)
			}
			return
		}
		;flip map, x=0 for vertical, x=1 for horizontal
		flip(x)
		{
			Send "{Click}{Left}{Left}{Down}{Down}{Down}{Down}{Right}{Up}"
			Loop x
			{
				Send "{Up}"
			}
			Send "{Enter}"
			checkact(1)
			return
		}
	;Texture
		;recompute lighting
		light()
		{
			Send "{Click}{Left}{Enter}"
			checkact(1)
			return
		}
		;set to one of the main shaders in the texture list, selected by x from top to bottom (wilbur shader by default
		;(0 = wilbur shader, 1 = greyscale phase shader ... 8 = v2 shader)
		shader(x:=0)
		{
			Send "{Click}{Left}{Down}"
			Loop x
			{
				Send "{Down}"
			}
			Send "{Enter}"
			WinWait("Operation Progress", , speed*5)
			winclose("Operation Progress")
			checkact(1)
			return
		}
		;Draw the river flow map
		rivermap()
		{
			Send "{Click}{Left}{Up}{Up}{Up}{Up}{Up}{Up}{Right}{Up}{Up}{Enter}"
			WinWait("River Setup Dialog")
			Sleep speed*10
			Send "{Enter}"
			winclose("River Setup Dialog")
			checkact(1)
			return
		}
		;Saves texture as a .png file with name x
		savetext(x)
		{
			Send "{Click}{Left}{Up}{Enter}"
			WinWait("Select File As")
			Sleep speed*10
			Send x . "{Tab}{Down}{Down}{Down}{Down}{Up}{Enter}{Enter}"
			WinWait("Confirm Save As", , speed*5)
			If WinExist("Confirm Save As")
			{
					Sleep speed*10
					Send "{Tab}{Enter}"
					winclose("Confirm Save As")
			}
			winclose("Select File As")
			checkact(1)
			return
		}
	;Select
		;selects entire map
		selall()
		{
			Send "^a"
			checkact(1)
			return
		}
		;clears selection
		desel()
		{
			Send "^d"
			checkact(1)
			return
		}
		;inverts selection
		selinv()
		{
			Send "^I"
			checkact(1)
			return
		}
		;feathers selection by x
		feather(x)
		{
			Send "^!d"
			WinWait("Feather Selection")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Feather Selection")
			checkact(1)
			return
		}
		;selects height range from x to y, (0 to 1e20 by default) with options:
			;z=0 for between (default), z=1 for not between
			;a=0 for replace (default), a=1 for add, a=2 for subtract
		selheight(x:=0,y:=100000000000000000000,z:=0,a:=0)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Up}{Right}{Enter}"
			WinWait("Select Height Range")
			Sleep speed*10
			Send "{Up}"
			Loop z
			{
				Send "{Down}"
			}
			Send "{Tab}{Up}{Up}"
			Loop a
			{
				Send "{Down}"
			}
			Send "{Tab}" . x . "{Tab}" . y . "{Enter}"
			winclose("Height Range")
			checkact(1)
			return
		}
		;select flat areas under x degrees
		selflat(x)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Up}{Right}{Up}{Up}{Enter}"
			WinWait("Select Flat Areas")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Select Flat Areas")
			checkact(1)
			return
		}
		;select basins
		selbasin()
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Up}{Right}{Up}{Enter}"
			WinWait("Operation Progress", , speed*5)
			winclose("Operation Progress")
			checkact(1)
			return
		}
		;binarize selection with threshold x
		selbin(x)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Right}{Enter}"
			WinWait("Binarize Selection")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Binarize Selection")
			checkact(1)
			return
		}
		;create selection border of size x
		selborder(x)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Right}{Down}{Enter}"
			WinWait("Selection Border Size")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Selection Border Size")
			checkact(1)
			return
		}
		;expands selection by x pixels
		expand(x)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Right}{Down}{Down}{Enter}"
			WinWait("Expand Selection")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Expand Selection")
			checkact(1)
			return
		}
		;contracts selection by x pixels
		contract(x)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Right}{Down}{Down}{Down}{Enter}"
			WinWait("Contract Selection")
			Sleep speed*10
			Send x . "{Enter}"
			winclose("Contract Selection")
			checkact(1)
			return
		}
		;apply distance modifier to selection
		distance()
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Right}{Up}{Up}{Up}{Enter}"
			Sleep speed*10
			checkact(1)
			return
		}
		;flip selection, x=0 for horizontal, x=1 for vertical
		selflip(x)
		{
			Send "{Click}{Up}{Up}{Up}{Up}{Right}"
			Loop x
			{
				Send "{Up}"
			}
			Send "{Enter}"
			Sleep speed*10
			checkact(1)
			return
		}
		;render selextion noise of cell size x and intensity y
		selnoise(x, y)
		{
			Send "{Click}{Up}{Up}{Up}{Right}{Up}{Enter}"
			WinWait("Render Selection Noise")
			Sleep speed*10
			Send x . "{Tab}" . y . "{Enter}"
			winclose("Render Selection Noise")
			checkact(1)
			return
		}
		;load a selection mask of name x
		loadsel(x)
		{
			Send "{Click}{Up}{Up}{Enter}"
			WinWait("Load Selection from Image File")
			Sleep speed*10
			Loop 5
			{
				Send "{Tab}"
			}
			Send x . "{Enter}"
			Sleep speed*10
			winclose("Load Selection from Image File")
			checkact(1)
			return
		}
		;save a selection mask as a png with name x
		savesel(x)
		{
			Send "{Click}{Up}{Enter}"
			WinWait("Save Selection to File")
			Sleep speed*10
			Send x . "{Tab}{Down}{Up}{Up}{Down}{Enter}{Enter}"
			WinWait("Confirm Save As", , speed*5)
			If WinExist("Confirm Save As")
			{
					Send "{Tab}{Enter}"
					winclose("Confirm Save As")
			}
			winclose("Save Selection to File")
			checkact(1)
			return
		}
	;Filter
		;Blur
			;applies Gaussian blur with sigma x (1 by default)
			blur(x:=1)
			{
				Send "{Click}{Right}{Right}{Enter}"
				WinWait("Gaussian Blur")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Gaussian Blur")
				checkact(2)
				return
			}
			;box filter blur some(x=0), more(x=1), or lots(x=2)
			boxblur(x)
			{
				Send "{Click}{Right}{Right}{Down}"
				Loop x
				{
					Send "{Down}"
				}
				Send "{Enter}"
				Sleep speed*10
				checkact(1)
				return
			}
		;Erosion
			;Incise flow with amount a, exponent b, blend c, pre blur d, variable blur e, post blur f (c 1 by default and d, e, f all 0 by default)
			incise(a,b,c:=1,d:=0,e:=0,f:=0)
			{
				Send "{Click}{Right}{Down}{Down}{Right}{Down}{Enter}"
				WinWait("Incise Flow Process")
				Sleep speed*10
				Send a . "{Tab}" . b . "{Tab}" . c . "{Tab}" . d . "{Tab}" . e . "{Tab}" . f . "{Enter}"
				winclose("Incise Flow Process")
				checkact(5)
				return
			}
			;Precipiton with x passes and options:
			;a delta (0.25 by default)
			;b max length (-1 by default)
			;c blend (100 by default)
			;d noise type: 0 none (default), 1 overall, 2 per sample
			;e noise (0 by default)
			precip(x,a:=0.25,b:=-1,c:=100,d:=0,e:=0)
			{
				Send "^e"
				WinWait("Erosion (Precipiton) Setup")
				Sleep speed*10
				Send a . "{Tab}" . b . "{Tab}{Down}{Tab}{Tab}{Tab}" . x . "{Tab}{Up}"
				If c < 100
				{
					Send "{Down}"
				}
				Send "{Tab}" . c . "{Tab}{Up}{Up}"
				Loop d
				{
					Send "{Down}"
				}
				Send "{Tab}" . e . "{Enter}"
				WinWait("Operation Progress", , speed*10)
				winclose("Operation Progres")
				checkact(5)
				return
			}
		;Fill
			;Compute basin deltas with slope x (-1 by default)
			basindelta(x:=-1)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Right}{Enter}"
				WinWait("Find Basin Deltas")
				Sleep speed*10
				Send x . "{Enter}"
				WinWait("Operation Progress", , speed*10)
				winclose("Operation Progress")
				checkact(2)
				return
			}
			;Deterrace
			deterr()
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Right}{Down}{Enter}"
				WinWait("Operation Progress", , speed*10)
				winclose("Operation Progress")
				checkact(5)
				return
			}
			;fill basins with slope x (-1 by default)
			fill(x:=-1)
			{
				Send "^b"
				WinWait("Fill Basins")
				Sleep speed*10
				Send x . "{Enter}"
				WinWait("Operation Progress", , speed*10)
				winclose("Operation Progress")
				checkact(2)
				return
			}
			;Flatten block with options:
			;a=0 for world units, a=1 for samples
			;b is top
			;c for bottom
			;d for left
			;e for right
			;f for level
			flat(a,b,c,d,e,f)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Right}{Down}{Down}{Down}{Enter}"
				WinWait("Flatten Rectangular Block")
				Sleep speed*10
				Send "{Up}"
				Loop a
				{
					Send "{Down}"
				}
				Send "{Tab}" . b . "{Tab}" . d . "{Tab}" . e . "{Tab}" . c . "{Tab}" . f . "{Enter}"
				winclose("Flatten Rectangular Block")
				checkact(1)
				return
			}
			;create mound with options:
			;x min height
			;y max height
			;z noise
			;a=0 for replace, 1 for add, 2 for subtract, 3 for multiply, 4 for divide, 5 for min, 6 for max
			mound(x,y,z,a)
			{
				Send "^m"
				WinWait("Mound")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Tab}" . z . "{Tab}{Tab}{Up}{Up}{Up}{Up}{Up}{Up}"
				Loop a
				{
					Send "{Down}"
				}
				Send "{Enter}"
				winclose("Mound")
				checkact(1)
				return
			}
			;replace sample range with base value x, variance y, new value z
			replace(x,y,z)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Right}{Up}{Up}{Enter}"
				WinWait("Replace Sample Range")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Tab}" . z . "{Tab}{Enter}"
				winclose("Replace Sample Range")
				checkact(1)
				return
			}
			;sets height value to x, with
			;y=0 for replace (default), 1 for add, 2 for subtract, 3 for multiply, 4 for divide, 5 for min, 6 for max
			setval(x,y:=0)
			{	
				Send "{Click}{Right}{Down}{Down}{Down}{Right}{Up}{Enter}"
				WinWait("Set Value")
				Sleep speed*10
				Send x . "{Tab}{Up}{Up}{Up}{Up}{Up}{Up}"
				Loop y
				{
					Send "{Down}"
				}
				Send "{Enter}"
				winclose("Set Value")
				checkact(1)
				return
			}
		;height clip to (x,y) (0,1e20 by default)
			clip(x:=0,y:=100000000000000000000)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Down}{Enter}"
				WinWait("Clip Surface")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Enter}"
				winclose("Clip Surface")
				checkact(1)
				return
			}
		;Mathematical
			;exponential curve to height with:
			;x for land
			;y for sea
			;z for sea level (0 by default)
			;a for preserve height (0 for none, 1 for in-image by default, 2 for absolute)
			;b for absolute low (0 by default)
			;c for absolute high (0 by default)
			exponent(x,y,z:=0,a:=1,b:=0,c:=0)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Down}{Down}{Right}{Enter}"
				WinWait("Exponent Entry")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Tab}" . z . "{Tab}{Up}{Up}"
				Loop a
				{
					Send "{Down}"
				}
				if (a > 1)
					Send "{Tab}" . b . "{Tab}" . c
				Send "{Enter}"
				winclose("Exponent Entry")
				checkact(1)
				return
			}
			;offsets by x
			offset(x)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Down}{Down}{Right}{Down}{Enter}"
				WinWait("Surface Offset")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Surface Offset")
				checkact(1)
				return
			}
			;spans to (x.y)
			span(x,y)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Down}{Down}{Right}{Down}{Down}{Down}{Down}{Enter}"
				WinWait("Span Height Range")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Enter}"
				winclose("Span Height Range")
				checkact(1)
				return
			}
			;scales
			;w for type (0 for Single Value, 1 for Broken Value, 2 for To Range)
			;x for first value (Scale Factor if w=0, High if w=1, Highest if w=2)
			;y for second value (Break if w=1, Lowest if w=2)
			;z for Low (if w=1)
			scale(w,x,y:=0,z:=0)
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Down}{Down}{Right}{Up}{Up}{Enter}"
				WinWait("Surface Scaling")
				Sleep speed*10
				Send "{Up}{Up}"
				Loop w
				{
					Send "{Down}"
				}
				Send "{Tab}" . x
				if (w > 0)
				{
					Send "{Tab}" . y
					if (w = 1)
					{
						Send "{Tab}" . z
					}
				}
				Send "{Enter}"
				winclose("Span Height Range")
				checkact(1)
				return
			}
			;invert height map
			inverse()
			{
				Send "{Click}{Right}{Down}{Down}{Down}{Down}{Down}{Right}{Up}{Enter}"
				checkact(1)
				return
			}
		;Morphological
			;morphological dilate with x samples (1 by default)
			dilate(x:=1)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Up}{Right}{Enter}"
				WinWait("Morphological Dilate")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Morphological Dilate")
				checkact(1)
			}
			;morphological erode with x samples (1 by default)
			erode(x:=1)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Up}{Right}{Down}{Enter}"
				WinWait("Morphological Erode")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Morphological Erode")
				checkact(1)
			}
			;median with x window size (1 by default), y to replace NaN (0 by default)
			median(x:=1,y:=0)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Up}{Right}{Up}{Enter}"
				WinWait("Median")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Enter}"
				winclose("Median")
				checkact(1)
			}
		;Noise
			;Wilbur noise with options:
			;x=0 for uniform, 1 for gaussian, 2 for exponential
			;y mean
			;z variance
			noisewilb(x,y,z)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Right}{Enter}"
				WinWait("Add Noise")
				Sleep speed*10
				Send "{Up}{Up}"
				Loop x
				{
					Send "{Down}"
				}
				Send "{Tab}" . y . "{Tab}" . z . "{Enter}"
				winclose("Add Noise")
				checkact(1)
				return
			}
			;Absolute magnitude noise of magnitude x and random seed
			noiseabs(x)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Right}{Down}{Enter}"
				WinWait("Absolute Magnitude Noise")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Absolute Magnitude Noise")
				checkact(1)
				return
			}
			;Percentage noise of percent x and random seed
			noiseperc(x)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Right}{Down}{Down}{Enter}"
				WinWait("Percentage Noise")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Percentage Noise")
				checkact(1)
				return
			}
			;adds fractal noise with options:
			;a=0 for fBm (default), 1 for multi, 2 for hetero, 3 for hybrid, 4 for ridged
			;b=0 for replace (default), 1 for add, 2 for subtract, 3 for multiply, 4 for divide, 5 for min, 6 for max
			;x,y for XY scale (10 each by default)
			;z for amplitude(1 by default)
			;d for displacement(-10 by default)
			;h for H (1 by default)
			;l for lacunarity (1.9 for lacunarity)
			;v for octaves (7 by default)
			;o for offset (1 by default)
			;f for fgain (2 be default)
			;random origin and seed
			noisefract(a:=0,b:=0,x:=10,y:=10,z:=1,d:=-10,h:=1,l:=1.9,v:=7,o:=1,f:=2)
			{

				Send "{Click}{Right}{Up}{Up}{Up}{Up}{Right}{Up}{Up}{Up}{Enter}"
				WinWait("Fractal Noise")
				Sleep speed*10
				Send "{Up}{Up}{Up}{Up}"
				Loop a
				{
					Send "{Down}"
				}
				Send "{Tab}" . h . "{Tab}" . l . "{Tab}" . v . "{Tab}" . o . "{Tab}" . f . "{Tab}{Up}{Up}{Up}{Up}{Up}{Up}"
				Loop b
				{
					Send "{Down}"
				}
				Send "{Tab}" . z . "{Tab}" . d . "{Tab}" . x . "{Tab}" . y . "{Tab}{Tab}{Tab}{Enter}{Tab}{Tab}{Enter}{Tab}{Enter}"
				winclose("Fractal Noise")
				checkact(2)
				return
			}
		;Other
			;Apply an image with options:
			;x name
			;y scale (1 by default)
			;z offset (0 by default)
			;a=0 for replace (default), 1 for add, 2 for subtract, 3 for multiply, 4 for divide, 5 for min, 6 for max
			;b=0 for type greyscale (default), 1 for RG16, 2 for RGB24, 3 for BGR24
			;c=0 for fit stretch (default), 1 for tile
			apply(x,y:=1,z:=0,a:=0,b:=0,c:=0)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Right}{Enter}"
				WinWait("Emboss Image Onto Surface")
				Sleep speed*10
				Send "{Enter}"
				WinWait("Select image to apply")
				Send x . "{Enter}"
				winclose("Select image to apply")
				Send "{Tab}{Up}{Up}{Up}"
				Loop b
				{
					Send "{Down}"
				}
				Send "{Tab}{Up}"
				Loop c
				{
					Send "{Down}"
				}
				Send "{Tab}" . y . "{Tab}" . z . "{Tab}{Up}{Up}{Up}{Up}{Up}{Up}"
				Loop a
				{
					Send "{Down}"
				}
				Send "{Enter}"
				winclose("Emboss Image Onto Surface")
				checkact(1)
				return
			}
			;cosine distortion
			cosine()
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Right}{Down}{Enter}"
				checkact(1)
				return
			}
			;toroidal rotation with (x,y) samples
			toroidal(x,y)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Right}{Up}{Up}{Up}{Enter}"
				WinWait("Enter Surface Rotation Factors")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Enter}"
				winclose("Enter Surface Rotation Factors")
				checkact(1)
				return
			}
			;texture shading with detail x
			textshad(x)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Right}{Up}{Up}{Enter}"
				WinWait("Surface Texture Shading")
				Sleep speed*10
				Send x . "{Enter}"
				winclose("Surface Texture Shading")
				checkact(1)
				return
			}
			;Kill outliers with x percent and y to replace NaN (0 by default)
			killout(x,y:=0)
			{
				Send "{Click}{Right}{Up}{Up}{Up}{Right}{Up}{Enter}"
				WinWait("Kill Outliers")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Enter}"
				winclose("Kill Outliers")
				checkact(1)
				return
			}
		;Sharpen
			;box sharpen with x=0 for some, 1 for more, 2 for lots
			sharpen(x)
			{
				Send "{Click}{Right}{Up}{Up}{Right}"
				Loop x
				{
					Send "{Down}"
				}
				Send "Enter"
				Sleep speed*10
				checkact(1)
				return
			}
			;unsharp mask with stdev x and weight y (100 by default)
			unsharp(x,y:=100)
			{
				Send "{Click}{Right}{Up}{Up}{Right}{Up}{Enter}"
				WinWait("Unsharp Mask")
				Sleep speed*10
				Send x . "{Tab}" . y . "{Enter}"
				winclose("Unsharp Mask")
				checkact(1)
				return
			}
		;threshold with x of y=0 for levels (default) or y=1 for meters per interval
			threshold(x,y:=0)
			{
				Send "{Click}{Right}{Up}{Enter}"
				WinWait("Threshold (Posterization)")
				Sleep speed*10
				Send x . "{Tab}{Up}"
				Loop y
				{
					Send "{Down}"
				}
				Send "{Enter}"
				winclose("Threshold (Posterization)")
				checkact(1)
				return
			}
	;Get Info
		;Get map resolution
		;x=0 for x, x=1 for y
		getres(x)
		{
			A_Clipboard := ""
			Send "{Click}{Left}{Left}{Down}{Down}{Enter}"
			WinWait("Calculation Size")
			Sleep speed*10
			Loop x
			{
				Send "{Tab}"
			}
			Send "^c"
			Sleep speed*100
			Send "{Esc}"
			winclose("Calculation Size")
			checkact(1)
			return A_Clipboard
		}
		return
		;Get map extrema
		;x=0 for lowest elevation, x=1 for highest
		getext(x)
		{
			A_Clipboard := ""
			Send "{Click}{Right}{Right}{Right}{Right}{Right}{Enter}"
			WinWait("Histogram")
			Sleep speed*10
			Loop x
			{
				Send "{Tab}"
			}
			Send "^c"
			Sleep speed*100
			Send "{Esc}"
			winclose("Threshold (Posterization)")
			checkact(1)
			return A_Clipboard
		}


;Basic Functions
	;pause function
	^p::Pause

	;exit function
	^x::ExitApp

	;startup function
	startup()
	{
		;These steps are critical to ensure proper function of any script and should always be included:
			speed := 1
			global speed
			checksel("noise.png")
			desel()
		return
	}
	
