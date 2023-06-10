# from utils import plot_network, plot_matrix

import networkx as nx
# import metis
# import pandas as pd
from scipy.sparse import csc_matrix
import scipy.sparse.csgraph as csgraph
# import nxmetis
import scipy
import numpy as np
# from numpy import linalg as LA
# from bbd_matrix_container import bbd_matrix, block_vector
from mpi_bbd_matrix import bbd_matrix, block_vector

import time

# def bbd_schur_lu(Abbd):
#     n = int(Abbd.block_dim) # number of diagonal blocks
#     m = n - 1

#     # np.random.seed(1000)

#     #  size of blocks -- NN x NN where NN is the dimension of the block. 
#     Nblock = {}
#     for i in range(n):
#         Nblock[i] = Abbd.get_diag_block(i).shape[0]
    
   

#     Lbbd = bbd_matrix(n)
#     Ubbd = bbd_matrix(n)

#     for i in range(n-1):
#         lu = la.splu(Abbd[i,i].tocsc(), permc_spec="NATURAL")
#         P = sp.csc_matrix((np.ones(Nblock[i]), (lu.perm_r, np.arange(Nblock[i])))).transpose().tocsc()
#         Lbbd[i,i] = P @ lu.L
#         Ubbd[i,i] = lu.U
#         Lbbd[n-1,i] = la.spsolve(Ubbd[i,i].transpose().tocsc(),
#                                 Abbd[n-1,i].transpose().tocsc()
#                                ).transpose()
#         Ubbd[i,n-1] = la.spsolve(Lbbd[i,i], Abbd[i,n-1].tocsc())

#     B = Abbd[n-1,n-1].copy().tocsc()
#     for i in range(m):
#         B -= Lbbd[n-1,i] @ Ubbd[i,n-1]

#     lu = la.splu(B, permc_spec="NATURAL")
#     Pnn = sp.csc_matrix((np.ones(Nblock[n-1]), (lu.perm_r, np.arange(Nblock[n-1])))).transpose().tocsc()
#     Lbbd[n-1,n-1] = Pnn @ lu.L
#     Ubbd[n-1,n-1] = lu.U

#     return (Lbbd, Ubbd)

# def bbd_schur_solve(L, U, b):

#     n = int(L.block_dim)
#     y = {}
#     c = b[n-1].copy()

#     for i in range(n-1):
#         y[i] = la.spsolve(L[i,i], b[i])
#         c -= L[n-1,i] @ y[i]

#     y[n-1] = la.spsolve(L[n-1,n-1], c)
#     x = block_vector(L.block_sizes)
#     x[n-1] = la.spsolve(U[n-1,n-1], y[n-1])

#     for i in range(n-1):
#         x[i] = la.spsolve(U[i,i], y[i] - U[i,n-1] @ x[n-1])

#     return x


def admittance_to_BBD(A, num_parts=4):

    t0 = time.time()

    G2 = nx.Graph(A)
    G = nx.Graph()
    nodess = [x+1 for x in G2.nodes]
    edgess = [(x+1, y+1) for (x,y) in G2.edges]
    G.add_nodes_from(nodess)
    G.add_edges_from(edgess)

    t1 = time.time()

    edgecuts, partitions  = nxmetis.partition(G,num_parts,recursive=True, options=nxmetis.MetisOptions(rpart=0,niter=1))

    t2 = time.time()

    org_matrix = A

    nodes_part =  {}
    outside_node = {}
    for x in range(len(partitions)):
        nodes_part[x] = partitions[x]
        outside_node[x] = []

    t3 = time.time()

    common_edges = []
    partition_edges = {}
    all_partition_edges = []
    for part in nodes_part.keys():
        partition_edges[part] = []
        for e in G.edges():
            if e[0] in nodes_part[part] and e[1] in nodes_part[part]:
                partition_edges[part].append(e)
                all_partition_edges.append(e)
            else:
                if e[0] not in nodes_part[part] and e[1] not in nodes_part[part]:
                    continue
                elif e[0] not in nodes_part[part]:
                    outside_node[part].append(e[0])
                else:
                    outside_node[part].append(e[1])

    t4 = time.time()

    for e in G.edges():
        if e not in all_partition_edges:
            common_edges.append(e)

    t5 = time.time()

    common_nodes = set([e[0] for e in common_edges] +  [e[1] for e in common_edges])

    t6 = time.time()

    part_nodes_nocommon = {}
    part_nodes_common = {}
    for x in nodes_part.keys():
        part_nodes_nocommon[x] = [y for y in nodes_part[x] if y not in common_nodes]
        part_nodes_common[x] = [y for y in nodes_part[x] if y in common_nodes]

    t7 = time.time()

    all_graphs = {}
    all_graphs_edges = {}
    dmatrix = {}
    for x in part_nodes_nocommon.keys():
        all_graphs[x] = G.subgraph(part_nodes_nocommon[x])
        all_graphs_edges[x] = all_graphs[x].edges()
        dmatrix[x] = csc_matrix( all_graphs[x])

    t8 = time.time()

    index_order = []
    for x in all_graphs.keys():
        perm = nxmetis.node_nested_dissection(all_graphs[x], options=nxmetis.MetisOptions(niter=1))
#         perm = all_graphs[x].nodes()
        perm = nxmetis.node_nested_dissection(all_graphs[x], options=nxmetis.MetisOptions(niter=1))
        index_order += perm

    t9 = time.time()

    Gcorner = nx.Graph()
    Gcorner.add_edges_from(common_edges)
    permg = nxmetis.node_nested_dissection(Gcorner)
#     permg = Gcorner.nodes()

    index_order += permg

    t10 = time.time()

    index_order = np.array(index_order) - 1
    final_matrix = org_matrix[index_order[:,None],index_order]

    t11 = time.time()

    corner_begin = np.sum([len(all_graphs[x].nodes) for x in all_graphs.keys()])
    begin = 0
    blocks = {}
    for x in all_graphs.keys():
        blocks['diagonal_{}'.format(x)] = final_matrix[begin: begin+len(all_graphs[x].nodes()):1, begin: begin+len(all_graphs[x].nodes()):1]
        blocks['lower_{}'.format(x)] = final_matrix[corner_begin::1,begin: begin+len(all_graphs[x].nodes()):1]
        blocks['upper_{}'.format(x)] = final_matrix[begin: begin+len(all_graphs[x].nodes()):1, corner_begin::1]
        begin += len(all_graphs[x].nodes())
    blocks['corner'] = final_matrix[begin: begin+len(Gcorner.nodes()):1, begin: begin+len(Gcorner.nodes()):1]

    t12 = time.time()

    N = np.max(list(nodes_part.keys()))+2

    BBD = bbd_matrix(N)
    for x in blocks.keys():
        if "diagonal" in x: 
            idx = int(x.split("_")[-1])
            BBD.add_diag_block(csc_matrix(blocks[x]),idx)
        elif "upper" in x: 
            idx = int(x.split("_")[-1])
            BBD.add_right_block(csc_matrix(blocks[x]),idx)
        elif "lower" in x: 
            idx = int(x.split("_")[-1])
            BBD.add_lower_block(csc_matrix(blocks[x]),idx)
        elif "corner"  in x: 
            idx = int(N-1)
            BBD.add_diag_block(csc_matrix(blocks[x]),idx)
        else: 
            print("WARNING unknown block!! --> ",x )

    t13 = time.time()

    elapsed = t13 - t0
    time_str = """
    Graph:        {:10.2e} {:8.2%}
    NxMetis:      {:10.2e} {:8.2%}
    OutN:         {:10.2e} {:8.2%}
    PartE:        {:10.2e} {:8.2%}
    ComE:         {:10.2e} {:8.2%}
    ComN:         {:10.2e} {:8.2%}
    PartN:        {:10.2e} {:8.2%}
    AllGr:        {:10.2e} {:8.2%}
    IdxOrd:       {:10.2e} {:8.2%}
    CrnOrd:       {:10.2e} {:8.2%}
    Final:        {:10.2e} {:8.2%}
    BlkSort:      {:10.2e} {:8.2%}
    BBD:          {:10.2e} {:8.2%}
    Total:        {:10.2e}
    """.format(
        t1 - t0, (t1 - t0)/elapsed,
        t2 - t1, (t2 - t1)/elapsed,
        t3 - t2, (t3 - t2)/elapsed,
        t4 - t3, (t4 - t3)/elapsed,
        t5 - t4, (t5 - t4)/elapsed,
        t6 - t5, (t6 - t5)/elapsed,
        t7 - t6, (t7 - t6)/elapsed,
        t8 - t7, (t8 - t7)/elapsed,
        t9 - t8, (t9 - t8)/elapsed,
        t10 - t9, (t10 - t9)/elapsed,
        t11 - t10, (t11 - t10)/elapsed,
        t12 - t11, (t12 - t11)/elapsed,
        t13 - t12, (t13 - t12)/elapsed,
        elapsed,
    )

    print(time_str)

    BBD.print_summary()
        
    return (BBD,index_order)
