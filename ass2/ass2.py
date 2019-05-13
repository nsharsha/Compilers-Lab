import re
def class_def(class_match,count_class,class_names,class_index,index):
    name=class_match.group()
    class_name=name.split()[1].lstrip()
    count_class+=name.count("\n")
    if class_index==0:
        count_class+=1
    else:
        count_class+=(fp[class_index:index+class_match.start()].count("\n")>0)
    class_names.append(class_name)
    return count_class,class_names

def inh_def(count_inh,count_class,inh_index,inh_match,index):
    number=inh_match.group().count("\n")
    count_inh+=number
    count_class+=number
    if(inh_index==0):
        count_inh+=1
    else:
        count_inh+=(fp[inh_index:index+inh_match.start()].count("\n")>0)
    return count_inh,count_class

def constr_def(constr_match,class_names,count_constr,constr_index,index):
    constr_name=constr_match.group().split("{")[0].rstrip()
    name=constr_name.split("(")[0]
    constr_flag=0
    for p in class_names:
        if p in name:
            constr_flag=1
            break
    if constr_flag==1:
        count_constr+=constr_name.count("\n")
        if constr_index==0:
            count_constr+=1
        else:
            count_constr+=(fp[constr_index:index+constr_match.start()].count("\n")>0)
    return count_constr,constr_index
def obj_def(obj_match,class_names,count_obj,obj_index,index):
    obj_name=obj_match.group()
    name=obj_name.split()[0]
    obj_flag=0
    for p in class_names:
        if p in name:
            obj_flag=1
            break
    if obj_flag==1:
        count_obj+=obj_name.count("\n")
        if obj_index==0:
            count_obj+=1
        else:
            count_obj+=(fp[obj_index:index+obj_match.start()].count("\n")>0)
    return count_obj,obj_index


index=0
class_names=[]
class_expr="class\s*\w+"
inh_expr="^\s*extends\s*\w+"
obj_expr=r"\w+.*?=\s*?new\s*\w+(.|\n)*?;"
constr_expr="\w+\s*\((\w|,|\s|\n)*?\)\s*\{"
expr="(class\s*\w+)|(\w+.*?=\s*?new\s*\w+(.|\n)*?;)|(\w+\s*\((\w|,|\s|\n)*?\)\s*\{)"

count_class=0
count_inh=0
count_obj=0
count_constr=0

inh_index=0
class_index=0
obj_index=0
constr_index=0


print("Enter file name")
a=input()
fp=open(a,"r").read()
fp=re.sub(re.compile("/\*.*?\*/",re.DOTALL ) ,"" ,fp)
fp=re.sub(re.compile("//.*?\n" ) ,"" ,fp)


while  index<len(fp):
    match=re.search(expr,fp[index:])
    if match:

        if "class " in match.group() or "class\n" in match.group():
            count_class,class_names=class_def(match,count_class,class_names,class_index,index)
            index=index+match.end()+1
            class_index=index
            inh_match=re.search(inh_expr,fp[index:])
            if(inh_match):
                count_inh,count_class=inh_def(count_inh,count_class,inh_index,inh_match,index)
                count_inh+=match.group().count("\n")
                index=index+inh_match.end()+1
                class_index=index
                inh_index=index
        elif "new" in match.group():
            count_obj,obj_index=obj_def(match,class_names,count_obj,obj_index,index)
            index=index+match.end()+1
            obj_index=index
        else:
            count_constr,constr_index=constr_def(match,class_names,count_constr,constr_index,index)
            index=index+match.end()+1
            contr_index=index
    else:
        break

file=open("output.txt","w")
file.write("Class Definitions:"+str(count_class)+"\n")
file.write("Object Definitions:"+str(count_obj)+"\n")
file.write("Inherited Class Definitions:"+str(count_inh)+"\n")
file.write("Constructor Definitions:"+str(count_constr))
