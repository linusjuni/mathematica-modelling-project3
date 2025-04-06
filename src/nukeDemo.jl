using GLPK, Cbc, JuMP, SparseArrays, CSV, DelimitedFiles, Plots

distance_height = readdlm("src/height_distance.csv", ',', Float64)
H = distance_height[:,2]

# kommentar

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

# include("Model_I.jl")
include("Model_II.jl")
# include("Model_II_v2.jl")

# x, R = solveIP(H,K)
x, R = solveIP2(H,K)
