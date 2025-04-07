# Solve second one
function solveIP4(H, K)
    h = length(H)
    myModel = Model(Cbc.Optimizer)
    # If your want ot use GLPK instead use:
    # myModel = Model(GLPK.Optimizer)

    A = constructA(H,K)

    @variable(myModel, x[1:h], Bin)
    @variable(myModel, k[1:h] >= 0 )
    @variable(myModel, U[1:h] >= 0 )
    @variable(myModel, R[1:h] >= 0 )

    @objective(myModel, Min, sum(U[j] for j=1:h) )


    @constraint(myModel, [j=1:h], 10 + H[j] - R[j] <= U[j])
    @constraint(myModel, [j=1:h], 10 + H[j] - R[j] >= -U[j])

    # Force z[j] to be nonzero only if x[j] == 1
@constraint(myModel, [j=1:h], k[j] <= 3 * x[j])

# Mutual exclusion: no two adjacent x's can be 1
@constraint(myModel, [j=1:h-1], x[j] + x[j+1] <= 1)


    @constraint(myModel, [j=1:h],R[j] >= H[j] + 10 )
    @constraint(myModel, [i=1:h],R[i] == sum(A[i,j]*(k[j]) for j=1:h) )

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


