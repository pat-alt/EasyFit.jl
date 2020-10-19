#
# Function to set bounds with optional user input 
#

function setbounds(vars,l,u) 
  # Throw error if the user set a bound to a variable which is not in list for this function
  for field in fieldnames(typeof(l))
    if (getfield(l,field) != nothing) || (getfield(u,field) !=nothing)
      found = false
      for var in vars
        if field == var.field
          found = true
          if var.type == Nothing
            error(" Bounds to intercept $(var.field) are not supported. For a constant use $(var.field) = const.")
          end
        end
      end
      if ! found
        error(" A bound was set to variable '$field', but '$field' is not a variable of the current fit function.") 
      end
    end
  end
  # Total number variables
  n = 0
  for var in vars
    n += var.dim
  end
  lower = Vector{Float64}(undef,n)
  upper = Vector{Float64}(undef,n)
  idim = 1
  for var in vars
    ltmp = check_lower_bound_input(var,getfield(l,var.field))  
    utmp = check_upper_bound_input(var,getfield(u,var.field)) 
    @. lower[idim:idim+var.dim-1] = ltmp
    @. upper[idim:idim+var.dim-1] = utmp
    idim += var.dim
  end
  i = 0
  for var in vars
    i += 1
    if lower[i] > upper[i]
      error(" Error in bounds. Lower bound of '$(var.field)' greater than upper bound. ")
    end
  end
  return lower, upper
end

function check_lower_bound_input(var,value) 
  if value == nothing
    return [ -Inf for _ in 1:var.dim ]
  end
  if ! (value isa var.type )
    error("Lower bound of $(var.field) must be of type $(var.type), got $(typeof(value))")
  end
  if (value isa Vector) && (length(value) != var.dim)
    error("Lower bound of $(var.field) must be of dimension $(var.dim), got $(length(value))")
  end
  return value
end

function check_upper_bound_input(var,value) 
  if value == nothing
    return [ +Inf for _ in 1:var.dim ]
  end
  if ! (value isa var.type) 
    error("Upper bound of $(var.field) must be of type $(var.type), got $(typeof(value))")
  end
  if (value isa Vector) && (length(value) != var.dim)
    error("Upper bound of $(var.field) must be of dimension $(var.dim), got $(length(value))")
  end
  return value
end






