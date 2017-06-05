Shadowcast
==========

Lua non recursive implementation of *shadowcasting* techinque for fast calculation of field of view. Original recursive algorithm by [Björn Bergström](bjorn.bergstrom@roguelikedevelopment.org) description at [Rogue Basin](http://www.roguebasin.com/index.php?title=FOV_using_recursive_shadowcasting). 

Current implementation allows simple luminance evaluation (not just FOV) and with some effort even light blending, see test example for instance (you will need [luabox](https://github.com/iskolbin/luabox) installed).

Shadowcast.new( absorption, [topology, [directions]] )
----------------------------
Create new luminance object. You must pass `absorption` 2d array where essentialy `0` means free space and `1` means wall. You can choose `topology` from the predefined set: `Shadowcast.MANHATTAN`, `Shadowcast.EUCLIDEAN` (which is the default) or `Shadowcast.CHEBYSHEV`. For now `directions` is limited to `Shadowcast.DIRECTIONS_8`. 

Shadowcast.get( x, y )
----------------------
Get luminance at the selected location. If x or/and y is/are out of bounds then function returns `0`.

Shadowcast.insert( x, y, radius )
---------------------------------
Insert new light source. Function returns newly created table, which could be used for the `remove` method. _Note that if you alter the table fields, you must `update` the whole simulation_. 

Shadowcast.remove( source )
---------------------------
Remove the `source` from the simulation. If it's not present then nothing happens.

Shadowcast.update()
-------------------
Fully update the whole light simulation. Note that when you insert/remove light sources luminance updated automatically and quite efficient, because only connected to the light source computations are made. Unfortunatly, because of the nature of compuataions with floating point after some iterations you will get rounding error. Using `update` sometimes while somehow expensive negates this error.
