#include <bits/stdc++.h>

extern int yylineno;
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

using namespace std;
class variables
{
    public:
    string var_name;
    int var_type;
    int var_level;
    int ele_type;
    vector<int>dim;
    string func_name;
    variables(string name,int type,int levell,int e_type,string func1)
    {
        var_name=name;
        var_type=type;
        var_level=levell;
        ele_type=e_type;
        func_name=func1;
    }
    
} ;
class node
{
public:
    char value[20];
    int begin;
	list<int> next;
    list<int> f;
    vector<string>arr;
};
struct attl
{
    char name[20];
    char value[20];
    int type;
    int returntype;	
}  ;


class param
{
    public:
    string par_name;
    int par_type;
    int par_ele_type;
    vector<int>par_dim;
    param(string name,int type,int t)
    {
        par_name=name;
        par_type=type;
        par_ele_type=t;
        
    }
};

class function
{
    public:
    string func_name;
    int return_type;// int float or void
    int num_param;
    vector<param*> param_list;
    function(string name,int type,int num,vector<param*> list)
    {
        func_name=name;
        return_type=type;
        num_param=num;
        param_list=list;
    }
};
