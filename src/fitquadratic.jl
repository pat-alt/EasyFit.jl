#
# Quadratic fit
# 

struct Quadratic
  a::Float64
  b::Float64
  c::Float64
  R::Float64
  x::Vector{Float64}
  y::Vector{Float64}
  ypred::Vector{Float64}
  residues::Vector{Float64}
end

"""
`fitquad(x,y)` or `fitquadratic(x,y)`

Obtains the quadratic fit: ``y = a*x^2 + b*x + c``

Optional lower and upper bounds for a and b can be provided using, for example:

```
fitquad(x,y, lower(b=0.), upper(a=5.,b=7.) )
```
and the intercept `c` can be fixed with

```
fitquad(x,y, c=3.)
```

# Examples
```jldoctest
julia>  x = sort(rand(10)); y = x.^2 .+ rand(10);

julia> fit = fitquad(x,y)

 ------------------- Quadratic Fit ------------- 

 Equation: y = ax^2 + bx + c 

 With: a = 1.9829681649993036
       b = -1.24215737650827
       c = 0.9410816080128867

 Pearson correlation coefficient, R = 0.8452759310204063
 Average square residue = 0.039620067833833005

 Predicted Y: ypred = [0.778952191090992, 0.7759243614999851...
 residues = [0.0550252612868799, -0.15207394277809727...

 ----------------------------------------------- 

```
"""
function fitquadratic(X::AbstractArray{<:Real}, Y::AbstractArray{<:Real};
  l::lower=lower(), u::upper=upper(), c=nothing,
  options::Options=Options())
  # Check data
  X, Y = checkdata(X, Y, options)
  # Set bounds
  vars = [VarType(:a, Number, 1),
    VarType(:b, Number, 1),
    VarType(:c, Nothing, 1)]
  lower, upper = setbounds(vars, l, u)
  if c == nothing
    # Set model
    @. model(x, p) = p[1] * x^2 + p[2] * x + p[3]
    # Fit
    fit = find_best_fit(model, X, Y, length(vars), options, lower, upper)
    # Analyze results and return
    R = pearson(X, Y, model, fit)
    x, y, ypred = finexy(X, options.fine, model, fit)
    return Quadratic(fit.param..., R, x, y, ypred, fit.resid)
  else
    lower = lower[1:length(vars)-1]
    upper = upper[1:length(vars)-1]
    # Set model
    @. model_const(x, p) = p[1] * x^2 + p[2] * x + c
    # Fit
    fit = find_best_fit(model_const, X, Y, length(vars) - 1, options, lower, upper)
    # Analyze results and return
    R = pearson(X, Y, model_const, fit)
    x, y, ypred = finexy(X, options.fine, model_const, fit)
    return Quadratic(fit.param..., c, R, x, y, ypred, fit.resid)
  end
end
fitquad = fitquadratic

"""
    (fit::Quadratic)(x::Real)

Calling the the fitted estimator on a new sample generates point predictions. To compute predictions for multiple new data points, use broadcasting.

# Examples

```jldoctest
julia> x = sort(rand(10)); y = x.^2 .+ rand(10);

julia> f = fitquad(x,y)

 ------------------- Quadratic Fit ------------- 

 Equation: y = ax^2 + bx + c 

 With: a = 3.0661527272135043
       b = -1.2832262361743607
       c = 0.3650565332863989

 Pearson correlation coefficient, R = 0.8641384358642901
 Average square residue = 0.06365720683818799

 Predicted Y: ypred = [0.2860912283436672, 0.2607175680542409...
 residues = [0.11956927540814413, -0.26398094542690925...

 ----------------------------------------------- 


julia> f.(rand(10))
10-element Vector{Float64}:
 1.7769193832294496
 0.2489307162532048
 0.33127545070267345
 0.4422093927705098
 0.2974933484569105
 0.6299254836558978
 0.24575582331233475
 0.9185494116516484
 1.4615291776107249
 1.600204246377446
```
"""
function (fit::Quadratic)(x::Real)
  a = fit.a
  b = fit.b
  c = fit.c
  return a * x^2 + b * x + c
end

function Base.show(io::IO, fit::Quadratic)
  println("")
  println(" ------------------- Quadratic Fit ------------- ")
  println("")
  println(" Equation: y = ax^2 + bx + c ")
  println("")
  println(" With: a = ", fit.a)
  println("       b = ", fit.b)
  println("       c = ", fit.c)
  println("")
  println(" Pearson correlation coefficient, R = ", fit.R)
  println(" Average square residue = ", mean(fit.residues .^ 2))
  println("")
  println(" Predicted Y: ypred = [", fit.ypred[1], ", ", fit.ypred[2], "...")
  println(" residues = [", fit.residues[1], ", ", fit.residues[2], "...")
  println("")
  println(" ----------------------------------------------- ")
end

export fitquad, fitquadratic
