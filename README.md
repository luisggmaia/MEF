# MEF

This is a set of classes containing attributes and methods for calculations of quantities related to a structure, separeted as a set of Finite Elements.

### `Co.py`

Implementation of coordinate type. To facilitate the use of the program by user.

### `Node.py`

Represents a node in the beam finite element model. It stores the node index, its global coordinates (`co`), and the mechanical conditions associated with the node, including displacement constraints (`cst`), externally applied forces and moments (`F_star`), reaction forces (`R`), and optional additional stiffness contributions (`k`), such as those produced by springs. The class also stores the nodal displacement vector (`d`) obtained from the analysis and provides a dependent property `F` representing the total nodal force (applied plus reaction). Utility methods allow forces to be added or removed and provide simple plotting functionality to visualize nodes in the structure.

### `Elem.py`

Represents a two-node Euler–Bernoulli beam finite element used in the structural finite element formulation. The class stores the element index, its initial and final `Node` objects, and the mechanical properties (Young’s modulus `E`, cross-sectional area `S`, and second moment of area `I`). Distributed axial (`q`) and transverse (`p`) loads are defined as function handles along the element. Several dependent properties compute geometric quantities such as element length and orientation, as well as the rotation matrix, the global stiffness matrix, and the equivalent nodal load vector. The class also provides access to global and local displacement vectors, interpolation functions for axial and transverse displacements and rotations, and functions to evaluate axial force, shear force, and bending moment along the element. Additional methods allow distributed loads to be modified and provide basic visualization of the element in a MATLAB plot.

### `Est.py`

Represents the structural model composed of a set of beam `Node` and `Elem` objects. The class manages the creation, storage, and access of nodes and elements, ensuring index consistency and connectivity within the structure. It assembles the global stiffness matrix and load vectors from the contributions of individual elements and nodes, while accounting for displacement constraints and additional nodal stiffness. Dependent properties provide the global stiffness matrix (`K`), total and applied load vectors (`F` and `F_star`), the constraint vector (`cst`), nodal displacements (`d`), and reaction forces (`R`). The `analyze` method performs the structural analysis by solving the reduced linear system for the unknown displacements and updating the corresponding nodal displacements and reactions. Optional plotting utilities allow the structural model to be visualized as nodes and elements are created.
