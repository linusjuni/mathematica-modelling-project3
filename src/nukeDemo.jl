using GLPK, Cbc, JuMP, SparseArrays, CSV, DelimitedFiles, Plots



distance_height = readdlm("src/height_distance.csv", ',', Float64)
H = distance_height[:,2]

p1 = plot(distance_height[:,1]/1000, distance_height[:,2])

K = [
300 140 40
]


function constructA(H,K)
    # Convert K to a vector
    K = vec(K)
    
    # Get the size of H
    n = length(H)
    
    A = spdiagm(
        0 => fill(K[1], n),   # Main diagonal
        1 => fill(K[2], n-1),  # First upper diagonal
        -1 => fill(K[2], n-1),  # First lower diagonal
        2 => fill(K[3], n-2),  # Second upper diagonal
        -2 => fill(K[3], n-2)   # Second lower diagonal
    )
    return A
end

function solveIP(H, K)
    h = length(H)
    myModel = Model(Cbc.Optimizer)
    # If your want ot use GLPK instead use:
    #myModel = Model(GLPK.Optimizer)

    A = constructA(H,K)

    @variable(myModel, x[1:h], Bin )
    @variable(myModel, R[1:h] >= 0 )

    @objective(myModel, Min, sum(x[j] for j=1:h) )

    @constraint(myModel, [j=1:h],R[j] >= H[j] + 10 )
    @constraint(myModel, [i=1:h],R[i] == sum(A[i,j]*x[j] for j=1:h) )

    optimize!(myModel)

    if termination_status(myModel) == MOI.OPTIMAL
        println("Objective value: ", JuMP.objective_value(myModel))
        println("x = ", JuMP.value.(x))
        println("R = ", JuMP.value.(R))
    else
        println("Optimize was not succesful. Return code: ", termination_status(myModel))
    end
    x = JuMP.value.(x)
    R = JuMP.value.(R)
    return x, R
end

x, R = solveIP(H,K)

# Solve second one
function solveIP2(H, K)
    h = length(H)
    # myModel = Model(Cbc.Optimizer)
    # If your want ot use GLPK instead use:
    myModel = Model(GLPK.Optimizer)

    A = constructA(H,K)

    @variable(myModel, x[1:h], Bin )
    @variable(myModel, U[1:h], Bin )
    @variable(myModel, R[1:h] >= 0 )

    @objective(myModel, Min, sum(abs(U)) for j=1:h )


    @constraint(myModel, [j=1:h], U < R[j] - H[j] - 10 < )
    @constraint(myModel, [j=1:h], sum(R[j] - H[j] - 10) <= 0)


    @constraint(myModel, [j=1:h],R[j] >= H[j] + 10 )
    @constraint(myModel, [i=1:h],R[i] == sum(A[i,j]*x[j] for j=1:h) )

    optimize!(myModel)

    if termination_status(myModel) == MOI.OPTIMAL
        println("Objective value: ", JuMP.objective_value(myModel))
        println("x = ", JuMP.value.(x))
        println("R = ", JuMP.value.(R))
    else
        println("Optimize was not succesful. Return code: ", termination_status(myModel))
    end
    x = JuMP.value.(x)
    R = JuMP.value.(R)
    return x, R
end


x, R = solveIP2(H,K)