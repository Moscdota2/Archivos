import numpy as np

p = np.array([[5/4, 5], [6, 8/3], [9/5, 1]])
q = np.array([[9, 6], [8, 7], [6, 8]])

pq = p + q

r = np.array([[5, 6, 1], [7, 5, 2]])
print(r)

respuesta = np.matmul(pq, r)
print(respuesta)