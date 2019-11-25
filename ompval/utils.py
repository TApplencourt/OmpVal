#  _        _    ___          
# / \ |\/| |_)    | ._ _   _  
# \_/ |  | |      | | (/_ (/_ 
#                             

from typing import List
def omp_walk(path: List,omp_tree) -> List[List[str]]:

    paths = [path]
    for children in omp_tree[path[-1]]:
        paths += omp_walk( path + [children], omp_tree)

    return paths


#  _                                                   
# /   _   _|  _     _   _  ._   _  ._ _. _|_ o  _  ._  
# \_ (_) (_| (/_   (_| (/_ | | (/_ | (_|  |_ | (_) | | 
#                   _|                                 
#
import os, jinja2

#~=~=~=~
#~ Utils
#~=~=~=~

def path2name(path):
    # Some node in the path have space in their name. We will replace them with
    # one underscore. Level will be replaced with two.

    l_node_serialized = ("_".join(node.split()) for node in path)
    return "__".join(l_node_serialized)

def path2loopcount(path,omp_typing):
    # Compute how many for loop will be needed.
    # The last pragma of the node will tell us, via a omp_typing lockup, 
    # if it will be followed by a for loop
    return sum(omp_typing[ node.split().pop() ] == 'for-loops' for node in path)

def array_mapping(l_name,borned=False):

    if not borned:
        return "".join(f"[0:{i}]" for i in l_name)
    else:
        return "".join(f"[{i}]" for i in l_name)

def array_init_value(l_size):
    from functools import reduce
    import operator
    total_size = reduce(operator.mul, l_size, 1)
    return ','.join(map(str,range(total_size)))

def is_target(pragma):
    return pragma.split()[0] == "target"


#~=~=~=~
#~ Template
#~=~=~=~

# Setup jinja enviroement
dirname = os.path.dirname(__file__)
templateLoader = jinja2.FileSystemLoader(searchpath=os.path.join(dirname,"template"))
templateEnv = jinja2.Environment(loader=templateLoader)


# Need to check that for each "contruct" programa we have a "distribute" one.
def memcopy_ub(path):
    # Merge everything
    l = []
    for pragma in path:
        l.extend(pragma.split())

    #No check is teanm is followed by distribute
    # And parrallel  by for
    while l:
        pragma = l.pop(0)
        if pragma == 'teams':
            if not l:
                return True
            else:
                pragma = l.pop(0)
                if pragma != 'distribute':
                    return True
        elif pragma == 'parallel':
            if not l:
                return True
            else:
                pragma = l.pop(0)
                if pragma != 'for':
                    return True


def gen_makefile(l_name, folder='tmp'):
    import os
    l_name_run = [ f"run_{name}" for name in l_name]
    t = templateEnv.get_template("Makefile.jinja2")
    makefile = t.render(l_name=l_name, l_name_run=l_name_run)

    os.makedirs(folder, exist_ok=True)
    for t_ in ("ub","sound"):
        with open(os.path.join(folder,t_,'Makefile'), 'w') as f:
            f.write(makefile)

def gen_test(path, omp_typing, ref_l_array_size,test, folder='tmp'):  
    import os

    template = templateEnv.get_template(test)

    ref_l_var_array_size = "LMN"
    ref_l_var_loop_idx = "ijk"

    name = path2name(path)
    loop_count = path2loopcount(path,omp_typing)

    l_var_array_size = ref_l_var_array_size[:loop_count]
    l_array_size = ref_l_array_size[:loop_count]
    l_var_loop_idx = ref_l_var_loop_idx[:loop_count]

    l_pragma_type= [omp_typing[ node.split().pop() ] == 'for-loops' for node in path]

    i = 0
    new_l = []
    tmp_l = []
    for pragma in path:
    
        *heads, tails = pragma.split()
        if omp_typing[tails] == 'structured-block':
          tmp_l.append(pragma)
        else:

            new_l.append( (tmp_l,(pragma, ref_l_var_loop_idx[i], ref_l_var_array_size[i]) ) )  
            tmp_l = []
            i+=1

    if folder.endswith('atomic') and name.endswith('simd'):
        folder = os.path.join(folder,'ub')
    elif folder.endswith('memcopy') and memcopy_ub(path):
        folder = os.path.join(folder,'ub')
    else:
        folder = os.path.join(folder,'sound')

    test = template.render(name=name,zip=zip,
                    array_mapping=array_mapping,
                    is_target=is_target,
                    array_init_value=array_init_value,
                    l_var_array_size=l_var_array_size,
                    l_var_loop_idx=l_var_loop_idx,
                    l_array_size=l_array_size,
                    l_pragma=path,
                    l_pragma2=new_l,
                    l_pragma_type=l_pragma_type)

    import os
    os.makedirs(folder, exist_ok=True)
    with open(os.path.join(folder,f'{name}.cpp'),'w') as f:
      f.write(test) 
    return name