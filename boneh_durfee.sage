def boneh_durfee(pol, modulus, mm, tt, XX, YY):
    """
    Boneh and Durfee revisited by Herrmann and May
    finds a solution if:
    * |x| < e^delta
    * |y| < e^0.5
    whenever delta < 1 - sqrt(2)/2 ~ 0.292
    """


    #
    # calculate bounds and display them
    #
    '''to do'''
    #
    # Algorithm
    #

    # change ring of pol and x
    #polZ = pol.change_ring(ZZ)
    #x, y = polZ.parent().gens()
    '''useless?'''

    # substitution (Herrman and May)
    PR.<x, y, u> = PolynomialRing(ZZ)
    Q = PR.quotient(x*y + 1 - u) # u = x*y + 1
    polZ = Q(pol).lift()

    UU = XX*YY + 1

    # x-shifts
    gg = []

    for kk in range(mm + 1):
        for ii in range(mm - kk + 1):
            xshift = (x * XX)^ii * modulus^(mm - kk) * polZ(x * XX, y * YY, u * UU)^kk
            gg.append(xshift)

    # y-shifts (selected by Herrman and May)
    for jj in range(1, tt + 1):
        for kk in range(floor(mm/tt) * jj, mm + 1):
            yshift = (y * YY)^jj * polZ(x * XX, y * YY, u * UU)^kk * modulus^(mm - kk)
            gg.append(Q(yshift).lift()) # substitution

    # monomials
    monomials = []
    for polynomial in gg:
        for monomial in polynomial.monomials():
            if monomial not in monomials:
                monomials.append(monomial)

    # unravelled linerization (Herrman and May)
    # monomials = []

    # # x-shift
    # for ii in range(mm + 1):
    #     for jj in range(ii + 1):
    #         monomials.append(x^ii * u^jj)

    # # y-shift
    # for jj in range(1, tt + 1):
    #     for kk in range(floor(mm/tt) * jj, mm + 1):
    #         monomials.append(u^kk * y^jj)

    # construct lattice B
    nn = len(monomials)

    BB = Matrix(ZZ, nn)

    for ii in range(nn):

        BB[ii, 0] = gg[ii](0, 0, 0)

        for jj in range(1, ii + 1):
            if monomials[jj] in gg[ii].monomials():
                BB[ii, jj] = gg[ii].monomial_coefficient(monomials[jj])

    #
    # DET
    #
    det = 1
    for ii in range(nn):
        det *= BB[ii, ii]

    bound = modulus^(mm * (nn - 1)) / (nn * 2^nn)^((nn - 1)/2)
    bound = int(bound)

    if det >= bound:
        print "we don't have det < bound"
        print "det - bound = ", det - bound

    # LLL
    BB = BB.LLL()

    # transform shortest vectors in polynomials  
    pol1 = pol2 = 0

    for ii in range(nn):
        pol1 += monomials[ii] * BB[0, ii] / monomials[ii](XX,YY,UU)
        pol2 += monomials[ii] * BB[1, ii] / monomials[ii](XX,YY,UU)

    # resultant
    polx = pol1.resultant(pol2)

    print polx

    return solx, soly


############################################
# Test 
##########################################

# RSA gen
length = 512;
p = next_prime(2^int(round(length/2)));
q = next_prime( round(pi.n()*p) );
N = p*q;
phi = (p-1)*(q-1)

d = 3
while gcd(d, phi) != 1:
    d += 2
e = d.inverse_mod((p-1)*(q-1))

print "d:", d

# Problem put in equation
P.<x,y> = PolynomialRing(Zmod(e))
pol = 1 + x * (N + 1 + y)
delta = (2 - sqrt(2)) / 2
tho = (1 - 2 * delta)
m = 10
t = int(tho * m)
"""
how to choose m and t?
"""
X = floor(e^0.292)
Y = floor(e^0.5)
"""why those values?
"""

# boneh_durfee
solx, soly = boneh_durfee(pol, e, m, t, X, Y)