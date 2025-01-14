#
# Spline
#

struct Spline
  x :: Vector{Float64}
  y :: Vector{Float64}
end

"""

`fitspline(x,y)`

Computes a spline. 

Use `fit = fitspline(x,y)`. `fit.x` and `fit.y` will contain
the data points of the spline.  

# Example

```jldoctest
julia> x = sort(rand(10)); y = rand(10);

julia> fit = fitspline(x,y)

 -------- Spline fit --------------------------- 

 x spline: x = [0.05986115284955605, 0.0755869317846746...
 y spline: y = [0.6749928175217872, 0.5711266179726132...

 ----------------------------------------------- 
```
"""
function fitspline(X :: AbstractArray{<:Real}, Y :: AbstractArray{<:Real}, options :: Options)
  X, Y = checkdata(X,Y,options)
  t = 1:length(X)
  A = hcat(X,Y)
  itp = Interpolations.scale(interpolate(A, 
            (BSpline(Interpolations.Cubic(Natural(OnGrid()))), NoInterp())), t, 1:2)
  tfine = 1:length(X)/options.fine:length(X)
  x, y = [itp(t,1) for t in tfine], [itp(t,2) for t in tfine]
  return Spline(x,y)
end
fitspline(X :: AbstractArray{<:Real}, Y :: AbstractArray{<:Real}) = fitspline(X,Y,Options())

function (fit::Spline)(x::Real)
  throw(NotImplementedError())
end

function Base.show( io :: IO, fit :: Spline )
  println("")
  println(" -------- Spline fit --------------------------- ")
  println("")
  println(" x spline: x = [",fit.x[1],", ",fit.x[2],"...")
  println(" y spline: y = [",fit.y[1],", ",fit.y[2],"...")
  println("")
  println(" ----------------------------------------------- ")
end

export fitspline

