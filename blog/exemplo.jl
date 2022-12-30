# Este é um arquivo de exemplo

"""
    y = aprox_log(x)

Retorna um valor aproximado para `log(x)`, utilizando
a expansão

ln(x) = 2(z + z^3/3 + z^5/5 + ...)

onde z = (x-1)/(x+1).
"""
function aprox_log(x)
    y = (x-1)/(x+1)
    return 2*(y + y^3/3 + y^5/5)
end
