%{
#pragma GCC diagnostic ignored "-Wwrite-strings"
#include "part5.h"
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <fstream>
#include <sstream> 


using namespace std;
bool error=false;
void yyerror (string s);
int yylex();
int loop=0;
int level=0;
int func_index=-1;
int m_return;
int num_param=0;
int next_quad=0;
int call_return;
vector<string>names;

void writefile(char opp[],char arg1[],int a1,char arg2[],int a2,char res[],int a3);

int switch_flag=0;
map<int,vector<int> >break_list;
map<int,vector<int> >cont_list;
map<int,vector<int> >switch_list;

vector<variables*>variablelist;

vector<variables*>allvariables;
vector<string> tempvariable;
vector<variables>vars;
int global_var(string name);
vector <function*> allfunctions;
vector<string>intermediate;
vector<param*> funcparams;
char* convertfloat(char* s);
char* convertint(char* s);
bool search_func(string name);

int quadnum=0;
FILE *fnew;
int compatible_type(int a,int b);
int var_lev(string name);
bool search_par(string name);
bool search_var(string name);
void patch(int type);
bool check_break();
void check_continue();
int check_function(string name);
int var_index(string name,int l,int k);
int par_index(string name,int l,int k);
bool remove_vars();
struct attl func(char sym[],struct attl a1,struct attl a2);
void back_patch(list<int> a,int next_quad);
int while_start=-1;

list<int> nextandor;
list<int> fandor;
void cont_patch(int n);
void break_patch(int n);
void  mid_patch(list<int> a,string value);
bool check_switch();
void switch_patch(int n);
vector<string> parampass;
void into_function();
string check_arr(string name,vector<string>arr);
int variabletype=0;
int array_assign;
bool arr_false=false;
%}



       /* Yacc definitions */
%union
{
	struct attl att;
	
	char s[40];
	int ty;
	node *nextlist;
}


%start start
%token LIBRARY DEFAULT INT FLOAT VOID ELSEIF ELSE IF WHILE FOR SWITCH CASE BREAK ASSIGN MOD NEWLINE CONTINUE OPEN LESS GREAT EQUAL COLON NOTEQUAL AND OR COMMA CLOSE LESSEQUAL CURLYCLOSE CURLYOPEN SQCLOSE SQOPEN GREATEQUAL MINUS PLUS INTO SEMI MAIN RETURN



%token <s> NUMBER
%token <s> FLOATNUM
%token <s> ID
%type <ty> types
%type <ty> r_type
%type <att> num1
%type <att> expr
%type <att> condition1
%type <att> andcondition
%type <att> expression11
%type <att> expression1
%type <nextlist> ifexpr
%type <nextlist>body
%type <nextlist>whileexpr 
%type<nextlist>forloopexpr
%type <nextlist> case
%type <nextlist> caselist
%type <nextlist>subcase
%type <nextlist>con
%type <nextlist>operation
%type <att> func_call
%type <nextlist> dim_list2;
%type <s>id

%left OR
%left AND
%left PLUS MINUS
%left INTO DIV



%define parse.error verbose
%%

/* descriptions of expected inputs corresponding actions (in C) */
start:lib_list decl_list  main | lib_list r_type main

decl_list: var_decl SEMI decl_list | func_decl decl_list |var_decl SEMI r_type{} |func_decl r_type{}

var_decl : types var_list {patch($1);variablelist.clear();variabletype=0;}

var_list : id_arr COMMA var_list|id_arr 



id_arr:	ID{if(search_var($1)){variables *temp;if(func_index!=-1) {temp=new variables($1,variabletype,level,0,allfunctions[func_index]->func_name);}else{temp=new variables($1,variabletype,level,0,"");}variablelist.push_back(temp);vars.push_back(*temp);string j;string s4($1);if(func_index!=-1){j=allfunctions[func_index]->func_name;ostringstream str1; str1<<level;string geek=str1.str();s4=s4+"_"+geek+"_";}if(variabletype==1){j=j+"_1";}else{j=j+"_2";} s4="=,0,,"+s4+j;intermediate.push_back(s4);next_quad++;}} 
		|ID ASSIGN expr{if(search_var($1)){variables *temp;if(func_index!=-1) {temp=new variables($1,variabletype,level,0,allfunctions[func_index]->func_name);}else{temp=new variables($1,variabletype,level,0,"");}variablelist.push_back(temp);vars.push_back(*temp);string j;string s4($1);if(func_index!=-1){j=allfunctions[func_index]->func_name;ostringstream str1; str1<<level;string geek=str1.str();s4=s4+"_"+geek;}if(variabletype==1){j=j+"_1";}else{j=j+"_2";} string te($3.value);s4="=,"+te+",,"+s4+"_"+j;if($3.type==4){sprintf($1,"%s_%d_%s",$1,level,j.c_str());writefile("refparam","",1,"",1,"_return",1);writefile("call",$3.value,1,"",1,$3.name,1);writefile("=","_return",1,"",1,$1,1);}else{intermediate.push_back(s4);next_quad++;}}}
		|ID {if(search_var($1)){variables *temp;if(func_index!=-1) {temp=new variables($1,variabletype,level,1,allfunctions[func_index]->func_name);}else{temp=new variables($1,0,level,1,"");}variablelist.push_back(temp);}} dim_list {vars.push_back(*(variablelist[variablelist.size()-1]));}

dim_list:SQOPEN NUMBER SQCLOSE{string k($2);stringstream ss(k);int x=0;ss>>x;variablelist[variablelist.size()-1]->dim.push_back(x);} dim_list|SQOPEN NUMBER SQCLOSE {string k($2);stringstream ss(k);int x=0;ss>>x;variablelist[variablelist.size()-1]->dim.push_back(x);}

types:INT {$$=1;variabletype=1;}|FLOAT{$$=2;variabletype=2;}

func_decl: types ID{level=1;} OPEN p_decl CLOSE {if(!search_func($2)){function *temp=new function($2,$1,funcparams.size(),funcparams);allfunctions.push_back(temp);}level=2;func_index=allfunctions.size()-1;into_function();ostringstream str1;str1 << $2; string geek = str1.str();intermediate.push_back("func_begin,,,"+geek);next_quad++;} CURLYOPEN  stmt_list CURLYCLOSE {writefile("func_end","",1,"",1,"",1);remove_vars();level=0;func_index=-1;funcparams.clear();names.clear();}
			| VOID ID{level=1;} OPEN p_decl CLOSE {if(!search_func($2)){function *temp=new function($2,0,funcparams.size(),funcparams);allfunctions.push_back(temp);}level=2;func_index=allfunctions.size()-1;into_function();ostringstream str1;str1 << $2; string geek = str1.str();intermediate.push_back("func_begin,,,"+geek);next_quad++;} CURLYOPEN  stmt_list CURLYCLOSE{writefile("func_end","",1,"",1,"",1);remove_vars();level=0;func_index=-1;funcparams.clear();names.clear();}

r_type:types{$$=$1;}|VOID{$$=0;}

p_decl:p_list|%empty

p_list :  p_list COMMA par_decl|par_decl

par_decl:types ID{if(!search_par($2)){param *temp=new param($2,$1,0);funcparams.push_back(temp);}}
		|types ID{if(!search_par($2)){param *temp=new param($2,$1,1);funcparams.push_back(temp);}} dim_list1
		|error {yyerrok;}
dim_list1:SQOPEN NUMBER SQCLOSE dim_list1 | SQOPEN NUMBER SQCLOSE


main:  MAIN OPEN CLOSE {function *temp=new function("main",m_return,0,funcparams);allfunctions.push_back(temp);level=2;func_index=allfunctions.size()-1;level=2;ostringstream str1;str1 << "main"; string geek = str1.str();intermediate.push_back(",,,"+geek);next_quad++;} CURLYOPEN  stmt_list CURLYCLOSE{level=0;writefile("main_end","",1,"",1,"",1);}
	



stmt_list:stmt stmt_list|%empty


stmt:body|forloop|whileloop|ifelse|{switch_flag++;}switchcase|rbc

rbc:assign SEMI|func_call SEMI {writefile("refparam","",1,"",1,"_return0",1);writefile("call",$1.value,1,"",1,$1.name,1);}|BREAK SEMI{if(check_break()){string temp="goto,,,";intermediate.push_back(temp);break_list[loop].push_back(next_quad);next_quad++;}else if (check_switch()){string temp="goto,,,";intermediate.push_back(temp);switch_list[switch_flag].push_back(next_quad);next_quad++;}}|CONTINUE SEMI{check_continue();string temp="goto,,,";intermediate.push_back(temp);cont_list[loop].push_back(next_quad);next_quad++;}|RETURN SEMI{intermediate.push_back("return,,,");next_quad++;}|RETURN ID SEMI{string k($2);writefile("return","",1,"",1,$2,3);}|RETURN NUMBER SEMI{string k($2);intermediate.push_back("return,,,"+k);next_quad++;}|RETURN FLOATNUM SEMI{string k($2);intermediate.push_back("return,,,"+k);next_quad++;}|var_decl SEMI|error SEMI{yyerrok;}
body:{level++;}CURLYOPEN stmt_list CURLYCLOSE{remove_vars();level--;}

assign:operation 

func_call:ID  OPEN  par_list CLOSE  {call_return=check_function($1);$$.returntype=call_return;sprintf($$.name,"%d",num_param+1);num_param=0;strcpy($$.value,$1);} |error CLOSE{yyerrok;}
par_list:param1  
		|%empty

param1: expr{writefile("param","",1,"",1,$1.value,$1.type);num_param++;} COMMA param1
		|expr{writefile("param","",1,"",1,$1.value,$1.type);num_param++;}


ifelse:ifexpr body{string temp="goto,,,";intermediate.push_back(temp);$2=new node();$2->next.push_back(next_quad);next_quad++;back_patch($1->next,next_quad);	ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;} else_list{back_patch($2->next,next_quad);	ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;}

ifexpr:IF OPEN expr CLOSE{string k($3.value);string temp="if,"+k+",,";intermediate.push_back(temp);$$=new node();$$->next.push_back(next_quad);back_patch($$->next,next_quad+2);$$->next.clear();next_quad++;string temp1="goto,,,";intermediate.push_back(temp1);$$->next.push_back(next_quad);next_quad++;	ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;}
else_list: ELSE body |%empty

switchcase:SWITCH OPEN num1{if($3.returntype==0 || $3.returntype==2){error=true;cout<<"Error:Line No : "<<yylineno<<" Switch needs Int Argument\n";}} CLOSE CURLYOPEN caselist{mid_patch($7->f,$3.value);} default CURLYCLOSE{	ostringstream str1;str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);switch_patch(next_quad);next_quad++;switch_flag--;if(switch_flag==0){switch_list.clear();}}
default:DEFAULT COLON stmt_list |%empty
caselist:case caselist{$$=new node();$$->begin=$1->begin;back_patch($1->next,$2->begin);$1->f.insert($1->f.end(),$2->f.begin(),$2->f.end());$$->f=$1->f;}|%empty{$$=new node();$$->begin=next_quad;}
case:subcase{ostringstream str1;str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;} stmt_list{$$=new node();$$->begin=$1->begin;$$->f=$1->f;$$->next=$1->next;}
subcase: CASE NUMBER COLON {$$=new node();ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);$$->begin=next_quad;next_quad++;string l($2);string temp=","+l+",";char a[20];sprintf(a,"_t%d_1",quadnum++);string k(a);tempvariable.push_back(k);temp=temp+k;intermediate.push_back(temp);$$->f.push_back(next_quad);next_quad++;string temp1="if,"+k+",,";intermediate.push_back(temp1);$$->next.push_back(next_quad);back_patch($$->next,next_quad+2);next_quad++; string temp2="goto,,,";$$->next.clear();$$->next.push_back(next_quad);intermediate.push_back(temp2);next_quad++;}


whileloop: whileexpr body{$2=new node();$2->next.push_back(next_quad);string temp="goto,,,";intermediate.push_back(temp);next_quad++;back_patch($2->next,$1->begin);back_patch($1->next,next_quad);break_patch(next_quad);cont_patch($1->begin);ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;loop--;if(loop==0){break_list.clear();cont_list.clear();}}
whileexpr:{loop++;}WHILE OPEN{while_start=next_quad;ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;} expr CLOSE{$$=new node();string k($5.value);$$->begin=while_start;string temp="if,"+k+",,";intermediate.push_back(temp);$$->next.push_back(next_quad);back_patch($$->next,next_quad+2);$$->next.clear();next_quad++;string temp1="goto,,,";intermediate.push_back(temp1);$$->next.push_back(next_quad);next_quad++;ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;}|error CLOSE{yyerrok;}

forloop:forloopexpr body{$2=new node();$2->next.push_back(next_quad);string temp="goto,,,";intermediate.push_back(temp);back_patch($2->next,$1->begin);next_quad++;back_patch($1->f,next_quad);break_patch(next_quad);cont_patch($1->begin);ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;loop--;if(loop==0){break_list.clear();cont_list.clear();}}

init: types ID ASSIGN expr{variables*temp; if(func_index!=-1) {temp=new variables($2,$1,level,0,allfunctions[func_index]->func_name);}else{temp=new variables($2,$1,level,0,"");}allvariables.push_back(temp);vars.push_back(*temp);writefile("=",$4.value,$4.type,"",1,$2,3);}
|ID{int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1 && find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Error:Line No : "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}}
|ID {int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1 && find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Error:Line No : "<<yylineno<<" "<<$1<<" undeclared\n"; names.push_back($1);}}  ASSIGN expr {writefile("=",$4.value,$4.type,"",1,$1,3);}
|%empty

forloopexpr:{loop++;level++;}FOR OPEN init SEMI con{$6->next.push_back(next_quad);string k($6->value);string temp="if,"+k+",,";intermediate.push_back(temp);next_quad++;$6->f.push_back(next_quad);string temp1="goto,,,";intermediate.push_back(temp1);next_quad++;ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;} SEMI {while_start=next_quad;ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;}operation{$10=new node();$10->begin=while_start;$10->next.push_back(next_quad);string temp="goto,,,";intermediate.push_back(temp);back_patch($10->next,$6->begin);next_quad++;} CLOSE {back_patch($6->next,next_quad);ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;level--;$$=new node;$$->begin=$10->begin;$$->f=$6->f;}

operation:id PLUS PLUS {int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else writefile("+",$1,3,"1",1,$1,3);} 
		|id  MINUS MINUS {int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else writefile("-",$1,3,"1",1,$1,3);}
		|MINUS MINUS id{int t=var_index($3,0,1);if(t==-1) t=par_index($3,0,1);if(t==-1&& find(names.begin(),names.end(),$3)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$3<<" undeclared\n";names.push_back($3);}else writefile("-",$3,3,"1",1,$3,3);}
		|PLUS PLUS ID{int t=var_index($3,0,1);if(t==-1) t=par_index($3,0,1);if(t==-1&& find(names.begin(),names.end(),$3)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$3<<" undeclared\n";names.push_back($3);}else writefile("+",$3,3,"1",1,$3,3);}
		|id ASSIGN expr {int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;names.push_back($1);}else if($3.type==4){int t=var_index($1,0,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$3.value,1,"",1,$3.name,1);writefile("=",a,1,"",1,$1,3);}else writefile("=",$3.value,$3.type,"",1,$1,3);}
		|id PLUS ASSIGN expr {int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else if($4.type==4){int t=var_index($1,0,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$4.value,1,"",1,$4.name,1);writefile("+",a,1,$1,3,$1,3);}else writefile("+",$4.value,$4.type,$1,3,$1,3);} 
		|id  MINUS ASSIGN expr{int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else if($4.type==4){int t=var_index($1,0,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$4.value,1,"",1,$4.name,1);writefile("-",a,1,$1,3,$1,3);}else writefile("-",$4.value,$4.type,$1,3,$1,3);} 
		|id INTO ASSIGN expr{int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else if($4.type==4){int t=var_index($1,0,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$4.value,1,"",1,$4.name,1);writefile("*",a,1,$1,3,$1,3);} else writefile("*",$4.value,$4.type,$1,3,$1,3);} 
		|id DIV ASSIGN expr{int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else if($4.type==4){int t=var_index($1,0,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$4.value,1,"",1,$4.name,1);writefile("/",a,1,$1,3,$1,3);}else writefile("/",$4.value,$4.type,$1,3,$1,3);} 
		|id MOD ASSIGN expr{int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else if($4.type==4){int t=var_index($1,0,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$4.value,1,"",1,$4.name,1);writefile("%",a,1,$1,3,$1,3);}else writefile("%",$4.value,$4.type,$1,3,$1,3);} 
		|id dim_list2 PLUS PLUS {int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else{ string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());}writefile("+",$1,5,"1",1,$1,5);} }
		|id dim_list2 MINUS MINUS {int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else { string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());}writefile("-",$1,5,"1",1,$1,5);}}
		|MINUS MINUS id dim_list2{int t=var_index($3,1,1);if(t==-1) t=par_index($3,1,1);if(t==-1&& find(names.begin(),names.end(),$3)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$3<<" undeclared\n";names.push_back($3);}else { string z=check_arr($3,$4->arr);if(z!="-1"){strcpy($3,z.c_str());}writefile("-",$3,5,"1",1,$3,5);}}
		|PLUS PLUS id dim_list2{ int t=var_index($3,1,1);if(t==-1) t=par_index($3,1,1);if(t==-1&& find(names.begin(),names.end(),$3)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$3<<" undeclared\n";names.push_back($3);}else { string z=check_arr($3,$4->arr);if(z!="-1"){strcpy($3,z.c_str());}writefile("+",$3,5,"1",1,$3,5);}}
		|id dim_list2 ASSIGN expr {int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else {string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());} if($4.type==4){int t=var_index($1,1,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$4.value,1,"",1,$4.name,1);writefile("=",a,1,"",1,$1,5);}else writefile("=",$4.value,$4.type,"",1,$1,5);}}
		|id dim_list2 PLUS ASSIGN expr {int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else {string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());} if($5.type==4){int t=var_index($1,1,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$5.value,1,"",1,$5.name,1);writefile("+",a,1,$1,5,$1,5);}else writefile("+",$5.value,$5.type,$1,5,$1,5);}} 
		|id dim_list2 MINUS ASSIGN expr{int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else{string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());}  if($5.type==4){int t=var_index($1,1,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$5.value,1,"",1,$5.name,1);writefile("-",a,1,$1,5,$1,5);}else writefile("-",$5.value,$5.type,$1,5,$1,5);}} 
		|id dim_list2 INTO ASSIGN expr{int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else {string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());} if($5.type==4){int t=var_index($1,1,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$5.value,1,"",1,$5.name,1);writefile("*",a,1,$1,5,$1,5);} else writefile("*",$5.value,$5.type,$1,5,$1,5);} }
		|id dim_list2 DIV ASSIGN expr{int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else {string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());} if($5.type==4){int t=var_index($1,1,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$5.value,1,"",1,$5.name,1);writefile("/",a,1,$1,5,$1,5);}else writefile("/",$5.value,$5.type,$1,5,$1,5);} }
		|id dim_list2 MOD ASSIGN expr{int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else { string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($1,z.c_str());}if($5.type==4){int t=var_index($1,1,1);char a[20];sprintf(a,"_return%d",t);writefile("refparam","",1,"",1,a,1);writefile("call",$5.value,1,"",1,$5.name,1);writefile("%",a,1,$1,5,$1,5);}else writefile("%",$5.value,$5.type,$1,5,$1,5);} }
		|%empty {$$=new node();}

lib_list:LIBRARY lib_list
		|LIBRARY 


con:	{while_start=next_quad;ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);next_quad++;}expr {$$=new node();$$->begin=while_start;strcpy($$->value,$2.value);}
		|%empty {ostringstream str1; str1 << next_quad; string geek = str1.str();intermediate.push_back(",,,L"+geek);$$=new node();$$->begin=next_quad;next_quad++;strcpy($$->value,"1");}

expr: 			andcondition{ostringstream str2; str2 << next_quad; string geek1 = str2.str();intermediate.push_back(",,,L"+geek1);back_patch(nextandor,next_quad);next_quad++;ostringstream str1; str1 << quadnum; string geek = str1.str();intermediate.push_back("=,1,,_t"+geek+"_1");geek="_t"+geek+"_1";/*tempvariable.push_back(geek);*/next_quad++;sprintf($$.value,"_t%d_1",quadnum);string k($$.value);tempvariable.push_back(k);quadnum++;ostringstream str3;int n=next_quad+3; str3 << n; string geek3 = str3.str();intermediate.push_back("goto,,,L"+geek3);next_quad++;ostringstream str4;n=next_quad; str4 << n; string geek4 = str4.str();intermediate.push_back(",,,L"+geek4);back_patch(fandor,next_quad);next_quad++;intermediate.push_back("=,0,,"+geek);next_quad++;intermediate.push_back(",,,L"+geek3);next_quad++;fandor.clear();nextandor.clear();}
				| andcondition OR{back_patch(fandor,next_quad);ostringstream str2; str2 << next_quad; string geek1 = str2.str();intermediate.push_back(",,,L"+geek1);next_quad++;fandor.clear();} expr{strcpy($$.value,$4.value);}
				|expression1 {strcpy($$.value,$1.value);$$.type=$1.type;strcpy($$.name,$1.name);$$.returntype=$1.returntype;}


andcondition:	 condition1 {string k($1.value);string temp="if,"+k+",,";intermediate.push_back(temp);nextandor.push_back(next_quad);next_quad++;string temp1="goto,,,";intermediate.push_back(temp1);fandor.push_back(next_quad);next_quad++;}
				|condition1{string k($1.value);int n=next_quad+2;ostringstream str1;  str1 << n;string geek = str1.str();string temp="if,"+k+",,"+"L"+geek;intermediate.push_back(temp);next_quad++;string temp1="goto,,,";intermediate.push_back(temp1);fandor.push_back(next_quad);next_quad++;ostringstream str2; str2 << next_quad; string geek1 = str2.str();intermediate.push_back(",,,L"+geek1);next_quad++;}  AND andcondition 


condition1 :	 expression1 LESSEQUAL expression1{$$=func("<=",$1,$3);}
				|expression1 GREATEQUAL expression1  {$$=func(">=",$1,$3);}
				|expression1 GREAT expression1 {$$=func(">",$1,$3);}
				|expression1 LESS expression1 		{$$=func("<",$1,$3);}
				|expression1 NOTEQUAL expression1  {$$=func("!=",$1,$3);}
				|expression1 EQUAL expression1 {$$=func("==",$1,$3);} 
				
			
expression1	:	expression1 PLUS expression11 {$$=func("+",$1,$3);} 		
				|expression1 MINUS expression11 {$$=func("-",$1,$3);}
				|expression11 {strcpy($$.value,$1.value);$$.type=$1.type;strcpy($$.name,$1.name);$$.returntype=$1.returntype;}

expression11:	num1 INTO expression11 {$$=func("*",$1,$3);}
				|num1 DIV expression11 {$$=func("/",$1,$3);}
				|num1 MOD expression11 {if($1.returntype==2||$3.returntype==2){error=true;cout<<"Error:Line No : "<<yylineno<<" "<<"operand cannot be float\n";}$$=func("%",$1,$3);}
				|num1 {strcpy($$.value,$1.value);$$.type=$1.type;strcpy($$.name,$1.name);$$.returntype=$1.returntype;}


num1 		:	FLOATNUM {strcpy($$.value,$1);$$.type=2;$$.returntype=2;}
				|NUMBER {strcpy($$.value,$1);$$.type=1;$$.returntype=1;} 
				|ID {int t=var_index($1,0,1);if(t==-1) t=par_index($1,0,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Error:Line No : "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}else{$$.returntype=t;}strcpy($$.value,$1);$$.type=3;}
				|func_call {cout<<1;if(call_return==0){error=true;cout<<"Error:Line No : "<<yylineno<<" void value not ignored as it ought to be\n";}char a[20];sprintf(a,"_return%d",call_return);writefile("refparam","",1,"",1,a,1);writefile("call",$1.value,1,"",1,$1.name,1);char b[20];sprintf(b,"=,_return%d,,_t%d_%d",call_return,quadnum++,call_return);string k1(b);intermediate.push_back(k1);next_quad++;$$.returntype=call_return;cout<<$$.returntype;char j[20];sprintf(j,"_t%d_%d",quadnum-1,call_return);strcpy($$.value,j);string z(j);tempvariable.push_back(z);$$.type=6;strcpy($$.name,$1.name);call_return=-1;}   
				|ID dim_list2 {int t=var_index($1,1,1);if(t==-1) t=par_index($1,1,1);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Line No: "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);strcpy($$.value,$1);}else{$$.returntype=t;if(!arr_false){string z=check_arr($1,$2->arr);if(z!="-1"){strcpy($$.value,z.c_str());}else{strcpy($$.value,$1);}}else{strcpy($$.value,$1);}}$$.type=5;arr_false=false;}

dim_list2:  SQOPEN expr SQCLOSE dim_list2{$$=new node();string k($2.value);if($2.returntype==2){error=true;arr_false=true;cout<<"Line No: "<<yylineno<<" No float in arrays\n";}$$->arr.push_back(k);$$->arr.insert($$->arr.end(),$4->arr.begin(),$4->arr.end());}| SQOPEN expr SQCLOSE{$$=new node();string k($2.value);if($2.returntype==2){error=true;arr_false=true;cout<<"Line No: "<<yylineno<<" No float in arrays\n";}$$->arr.push_back(k);}
id      :	ID{int t=var_index($1,0,0);if(t==-1) t=par_index($1,0,0);if(t==-1&& find(names.begin(),names.end(),$1)==names.end()){error=true;cout<<"Error:Line No : "<<yylineno<<" "<<$1<<" undeclared\n";names.push_back($1);}strcpy($$,$1);}
//ID:ID {string l($1);if(func_index!=-1){string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<level;string geek=str1.str();j=l+"_"+geek+"_"+j;strcpy($$,j.c_str());}}

%%                     /*  code */


int main (void) {
	
	
	int k= yyparse(); //call the function so as to cause parsing to occur, returns 0 if eof is reached, 1 if failed due to syntax error
	if(!error)
	{
		ofstream out("Intermediate.txt");
		for(int i=0;i<intermediate.size();i++)
		{
			out<<intermediate[i]<<endl;
		}
		out.close();
		ofstream out2("variables.txt");
		for(int i=0;i<vars.size();i++)
		{
			int l=1;
			if(vars[i].ele_type==1)
			{
				for(int j=0;j<vars[i].dim.size();j++)
				{
					l=l*vars[i].dim[j];
				}
			}
			out2<<vars[i].var_name;
			if(vars[i].var_level!=0)
				out2<<"_"<<vars[i].var_level;
			if(vars[i].func_name.size()!=0)
				out2<<"_"<<vars[i].func_name;
			out2<<"_"<<vars[i].var_type<<","<<l<<","<<vars[i].var_type<<endl;
		}
		for(int i=0;i<tempvariable.size();i++)
		{
			out2<<tempvariable[i]<<endl;
		}

		out2.close();
		ofstream out3("parameters.txt");
		for(int i=0;i<parampass.size();i++)
		{
			out3<<parampass[i]<<endl;
		}
		out3.close();
	}
	
	
	return 0;
}


void into_function()
{
	parampass.push_back(allfunctions[func_index]->func_name);
	ostringstream str1;str1 << allfunctions[func_index]->return_type;
    string geek = str1.str();
	parampass.push_back(geek);
	for(int i=0;i<allfunctions[func_index]->param_list.size();i++)
	{
		int n=allfunctions[func_index]->param_list[i]->par_type;

		ostringstream str2;str2 << n;
    	string geek1 = str2.str();
		parampass.push_back(allfunctions[func_index]->param_list[i]->par_name+"_1_"+allfunctions[func_index]->func_name+"_"+geek1);
	}
	parampass.push_back("-1");
}

bool search_func(string name)
{
    for(int i=0;i<allfunctions.size();i++)
    {
        if(name==allfunctions[i]->func_name)
        {
            //cout<<"as\n";
            error=true;
            return true;
        }
    }
    return false;
}

int compatible_type(int a,int b)
{
	if(a==2||b==2)
	{
		return 2;
	}
	else
	{
		return 1;
	}
}

void yyerror (string s) {cerr<<yylineno<<": "<< s<<endl;error=true;}	//in case of error, i.e. some unmatched syntax of the grammar defined print Invalid Syntax

void writefile(char* opp,char* arg1,int a1,char* arg2,int a2,char* res,int a3)
{
	//fprintf(fnew,"%s,%s,%s,%s\n",opp,arg1,arg2,res);
	string s1(opp);
	string s2(arg1);
	if(a1==3)
	{
		string l(arg1);
		if(func_index!=-1)
		{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s2=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(arg1);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s2=j;}}
		
			//cout<<"\nbai\n";
	}
	if(a1==5)
	{
		string l(arg1);
		s2=l;
	}
	string s3(arg2);
	if(a2==3)
	{
		string l(arg2);
		if(func_index!=-1)
		{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s3=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(arg2);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s3=j;}}
		
			//cout<<"\nbai\n";
	}
	if(a2==5)
	{
		string l(arg2);
		s3=l;
	}
	string s4(res);
	if(a3==3)
	{
		string l(res);
		if(func_index!=-1)
		{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s4=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(res);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s4=j;}}
		
			//cout<<"\n %^%$\n";
	}
	if(a3==5)
	{
		string l(res);s4=l;
	}
	s1=s1+","+s2+","+s3+","+s4;

	//cout<<s1<<endl;
	next_quad++;
	intermediate.push_back(s1);
}

char* convertfloat(char* s)
{
	strcat(s,".000000\0");
	return s;
}
char* convertint(char* s)
{
	char *temp=strtok(s,".");
	return temp;
}
bool remove_vars()
{
	int i=0;
	for( i=0;i<allvariables.size();i++)
	{
		if(allvariables[i]->var_level==level)break;

	}
	allvariables.resize(i);
}

bool search_par(string name)
{
    for(int i=0;i<funcparams.size();i++)
    {
        if(name==funcparams[i]->par_name)
        {
            cout<<"Error:Line No :"<<yylineno<<"Parameter redeclaration of "<<name<<"\n";  return false;
            error=true;
            return true;
		
        }
    }
    return false;
}

int global_var(string name)
{
	for(int i=allvariables.size()-1;i>=0;i--)
	{
		if(allvariables[i]->var_name==name)
		{
			
				//cout<<name<<" "<<allvariables[i]->var_type<<endl;
				if(allvariables[i]->var_level==0)
				{
					return allvariables[i]->var_type;
				}
			
		}

	}
	return -1;
}

int check_function(string name)
{
	for(int i=0;i<allfunctions.size();i++)
	{
		 if(name==allfunctions[i]->func_name)
		 {
			 if(allfunctions[i]->num_param==num_param)
			 {
				 return allfunctions[i]->return_type;
			 }
			 else if(allfunctions[i]->num_param>num_param)
			 {
				 error=true;
				 cout<<"too few arguments in "<<name<<"\n";return -1;
			 }
			 else
			 {
				error=true;
				 cout<<"too many arguments in "<<name<<"\n";return -1;
			 }

		 }
	}
	cout<<name<<" function not declared\n";error=true;
	return -1;
}


bool search_var(string name)
{
	vector<variables*>::iterator ptr; 
	for(ptr=variablelist.begin();ptr!=variablelist.end();ptr++)
	{
		if((*ptr)->var_name==name) {error=true;cout<<"Error:Line No :"<<yylineno<<"Redeclaration of "<<name<<"\n";  return false;}
	}
	for(ptr=allvariables.begin();ptr!=allvariables.end();ptr++)
	{
		if((*ptr)->var_name==name && (*ptr)->var_level==level) {error=true;cout<<"Error:Line No :"<<yylineno<<"Redeclaration of "<<name<<"\n";  return false;}
	}
	if(level==2)
	{
		vector<param*> :: iterator i;
		for(i=funcparams.begin();i!=funcparams.end();i++)
		{
					if((*i)->par_name==name) {error=true;cout<<"Error:Line No :"<<yylineno<<"Variable and Parameter name matching "<<name<<"\n";  return false;}
	
		}
	}
	return true;

}


int par_index(string name,int t,int l)
{
if(l==1){
	for(int i=0;i<allfunctions[func_index]->num_param;i++)
	{
		if(allfunctions[func_index]->param_list[i]->par_name==name)
		{
			if(allfunctions[func_index]->param_list[i]->par_ele_type==t)
				return allfunctions[func_index]->param_list[i]->par_type;
			else
			{error=true;cout<<"Incompatible type\n";return -2;}
		}
	}
	return -1;
	}
	else
	{
		for(int i=0;i<allfunctions[func_index]->num_param;i++)
	{
		if(allfunctions[func_index]->param_list[i]->par_name==name)
		{
		
				return allfunctions[func_index]->param_list[i]->par_type;
			
		}
	}
	return -1;
	}
}


int var_index(string name,int t,int l)
{
	int j=-1;
	if(l==1)
	{
	for(int i=allvariables.size()-1;i>=0;i--)
	{
		if(allvariables[i]->var_name==name)
		{
			if(allvariables[i]->ele_type==t)
			{
				//cout<<name<<" "<<allvariables[i]->var_type<<endl;
				if(allvariables[i]->var_level==0)
				{
					j=0;break;
				}
				else
					return allvariables[i]->var_type;
			}
			else 
			{
				error=true;cout<<"Incompatible type\n";return -2;
			}
			
		}
	}
	for(int i=funcparams.size()-1;i>=0;i--)
	{
		if(funcparams[i]->par_name==name)
		{
			if(funcparams[i]->par_ele_type==t)
			{
				//cout<<name<<" "<<funcparams[i]->par_type<<endl;
				return funcparams[i]->par_type;
			}
			else
			{
				error=true;cout<<"Incompatible type\n";return -2;
			}
			
		}
	}
	return j;
	}
	else
	{
		for(int i=allvariables.size()-1;i>=0;i--)
	{
		if(allvariables[i]->var_name==name)
		{
			
				//cout<<name<<" "<<allvariables[i]->var_type<<endl;
				if(allvariables[i]->var_level==0)
				{
					j=0;break;
				}
				else
					return allvariables[i]->var_type;

		
			
		}
	}
	for(int i=funcparams.size()-1;i>=0;i--)
	{
		if(funcparams[i]->par_name==name)
		{
				//cout<<name<<" "<<funcparams[i]->par_type<<endl;
				return funcparams[i]->par_type;

			
		}
	}
	return j;
	}
}

int var_lev(string name)
{
	int j1=-1;
	int j2=-1;
	for(int i=funcparams.size()-1;i>=0;i--)
	{
		if(funcparams[i]->par_name==name)
		{
			//cout<<name<<" "<<funcparams[i]->par_type<<endl;
			j1=1;
			break;
		}
	}
	for(int i=allvariables.size()-1;i>=0;i--)
	{
		if(allvariables[i]->var_name==name)
		{
			//cout<<name<<" "<<allvariables[i]->var_level<<endl;
			
			j2=allvariables[i]->var_level;
			break;
		}
	}
	
	return max(j1,j2);

	
}

void patch(int type)
{
	vector<variables*>::iterator ptr; 
	for(ptr=variablelist.begin();ptr!=variablelist.end();ptr++)
	{
		(*ptr)->var_type=type;
		allvariables.push_back(*ptr);
	}
}


struct attl func(char sym[],struct attl a1,struct attl a2)
{
	struct attl a3;
	char*t;
	char temp[20];char temp2[20];int t1=a1.type;int t2=a2.type;
	if(a1.type==3||a1.type==5||a1.type==6)
	{t1=a1.returntype;}
	if(a2.type==3||a2.type==5||a2.type==6)
	{t2=a2.returntype;}
	int restype=compatible_type(t1,t2);
	if(t1==restype)
	{sprintf(temp,"_t%d_%d",quadnum++,restype);string k(temp);tempvariable.push_back(k);writefile("=",a1.value,a1.type,"",1,temp,1);}
	else{sprintf(temp,"_t%d_%d",quadnum++,restype);string k(temp);tempvariable.push_back(k);
		writefile("cnvrt_float",a1.value,a1.type,"",1,temp,1);}
	if(t2==restype)
	{sprintf(temp2,"_t%d_%d",quadnum++,restype);string k(temp2);tempvariable.push_back(k);writefile("=",a2.value,a2.type,"",1,temp2,1);}
	else{sprintf(temp2,"_t%d_%d",quadnum++,restype);string k(temp2);tempvariable.push_back(k);
		writefile("cnvrt_float",a2.value,a2.type,"",1,temp2,1);}
	sprintf(a3.value,"_t%d_%d",quadnum++,restype);string k(a3.value);tempvariable.push_back(k);writefile(sym,temp,1,temp2,1,a3.value,1);
	a3.type=restype;
	a3.returntype=restype;
	return a3;
}


void back_patch(list<int> a,int next_quad)
{
	ostringstream str1; 
  
    // Sending a number as a stream into output 
    // string 
    str1 << next_quad; 
  	
    // the str() coverts number into string 
    string geek = str1.str();
	for(list<int>::iterator it=a.begin();it!=a.end();it++)
	{
		
		intermediate[*it]=intermediate[*it]+"L"+geek;
	}
}

void switch_patch(int n)
{
	ostringstream str1;  
  
    // Sending a number as a stream into output 
    // string 
    str1 << n; 
  
    // the str() coverts number into string 
    string geek = str1.str();
	for(int i=0;i<switch_list[switch_flag].size();i++)
	{
		intermediate[switch_list[switch_flag][i]]=intermediate[switch_list[switch_flag][i]]+"L"+geek;
	}
	switch_list[switch_flag].clear();
}

void break_patch(int n)
{
	ostringstream str1; 
  
    // Sending a number as a stream into output 
    // string 
    str1 << n; 
  
    // the str() coverts number into string 
    string geek = str1.str();
	for(int i=0;i<break_list[loop].size();i++)
	{
		intermediate[break_list[loop][i]]=intermediate[break_list[loop][i]]+"L"+geek;
	}
	break_list[loop].clear();
}

void cont_patch(int n)
{
	ostringstream str1; 
  
    // Sending a number as a stream into output 
    // string 
    str1 << n; 
  
    // the str() coverts number into string 
    string geek = str1.str();
	for(int i=0;i<cont_list[loop].size();i++)
	{
		intermediate[cont_list[loop][i]]=intermediate[cont_list[loop][i]]+"L"+geek;
	}
	cont_list[loop].clear();
}

void  mid_patch(list<int> a,string value)
{
	if(func_index!=-1)
	{
		string j=allfunctions[func_index]->func_name;
		ostringstream str1; 
		str1<<var_lev(value);
		string geek=str1.str();
		value=value+"_"+geek+"_"+j;
		for(list<int>::iterator it=a.begin();it!=a.end();it++)
		{
			intermediate[*it]="==,"+value+intermediate[*it];
			//cout<<intermediate[*it]<<endl;
		}
	}
}


bool check_switch()
{
	if(switch_flag==0){cout<<"Error:Line No : "<<yylineno<<" break statement not within loop or switch\n";error=true;return false;}return true;
}

bool check_break()
{
	if(loop==0){return false;}return true; 
}

void check_continue()
{
	if(loop==0){cout<<"Error:Line No : "<<yylineno<<" continue statement not within loop\n";error=true;} 
}

string check_arr(string name,vector<string>arr)
{
	vector<int> index;
	int ele_size;int level=1;int type;
	for(int i=allvariables.size()-1;i>=0;i--)
	{
		if(allvariables[i]->var_name==name)
		{
			index=allvariables[i]->dim;	level=allvariables[i]->var_level;type=allvariables[i]->var_type;
			if(allvariables[i]->var_type==1)ele_size=4;
			else ele_size=8;		
		}
	}
	for(int i=funcparams.size()-1;i>=0;i--)
	{
		if(funcparams[i]->par_name==name)
		{
			if(level>1)
			{
				break;
			}
			index=funcparams[i]->par_dim;level=1;type=funcparams[i]->par_type;
			if(funcparams[i]->par_type==1)ele_size=4;
			else ele_size=8;
		}
	}
	if(arr.size()!=index.size())
	{
		error=true;cout<<"Not an array or int\n";arr.clear();return "-1";
	}
	ostringstream str1; 
  
    // Sending a number as a stream into output 
    // string 
    str1 << quadnum;
	array_assign=quadnum;
	quadnum++; 
  
    // the str() coverts number into string 
    string geek = str1.str();
	for(int i=0;i<arr.size();i++)
	{
		
		if(i==0 && i==arr.size()-1)
		{
			if(arr[i][0]!='_' && !isdigit(arr[i][0]))
			{
				string l(arr[i]);string s2;
			if(func_index!=-1)
			{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s2=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(arr[i]);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s2=j;}}
				intermediate.push_back("=,"+s2+",,_t"+geek+"_1");
		
			}
				
			else
				intermediate.push_back("=,"+arr[i]+",,_t"+geek+"_1");
			next_quad++;continue;
		}
		if(i==0)
		{string l="*,"+arr[i];
			if(arr[i][0]!='_' && !isdigit(arr[i][0]))
			{
				 l=arr[i];string s2;
			if(func_index!=-1)
			{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s2=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(arr[i]);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s2=j;}}
				l="*,"+s2;
		
			}
			
			char a[20];sprintf(a,",%d,_t",index[i+1]);string k(a);l=l+k+geek+"_1";
			intermediate.push_back(l);next_quad++;
		} 
		else if(i!=arr.size()-1)
		{
			if(arr[i][0]!='_' && !isdigit(arr[i][0]))
			{
				string l(arr[i]);string s2;
			if(func_index!=-1)
			{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s2=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(arr[i]);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s2=j;}}
				intermediate.push_back("+,"+s2+",_t"+geek+"_1"+",_t"+geek+"_1");
		
			}
			else intermediate.push_back("+,"+arr[i]+",_t"+geek+"_1"+",_t"+geek+"_1");
			next_quad++;
			string l="*,_t"+ geek;
				char a[20];sprintf(a,",%d,_t",index[i+1]);string k(a);l=l+k+geek+"_1";
				intermediate.push_back(l);next_quad++;
		}
		else 
		{
			if(arr[i][0]!='_' && !isdigit(arr[i][0]))
			{
				string l(arr[i]);string s2;
			if(func_index!=-1)
			{int h=var_index(l,0,1);string p;if(h==0){h=global_var(l);if(h!=-1){if(h==1){p="1";}else{p="2";}s2=l+"_"+p;}}else{if(h==1){p="1";}else{p="2";}string j=allfunctions[func_index]->func_name;ostringstream str1; str1<<var_lev(arr[i]);string geek=str1.str();j=l+"_"+geek+"_"+j+"_"+p;s2=j;}}
				intermediate.push_back("+,"+s2+",_t"+geek+"_1"+",_t"+geek+"_1");
		
			}
			else
				intermediate.push_back("+,"+arr[i]+",_t"+geek+"_1"+",_t"+geek+"_1");
				next_quad++;
		}
	}
	string f;
	f="_t"+geek+"_1";
	tempvariable.push_back(f);
	string l="*,_t"+geek+"_1";
	char a[20];sprintf(a,",%d,_t",ele_size);string k(a);l=l+k+geek+"_1";
				intermediate.push_back(l);next_quad++;
	char b[50];sprintf(b,"_%d_",level);
	string k1(b);	
	ostringstream str2; 
  
    // Sending a number as a stream into output 
    // string 
    str2 << type;string geek1 = str2.str();
	string l1=name+k1+allfunctions[func_index]->func_name+"_"+geek1;
	char c[20];sprintf(c,"_t%d_1",quadnum-1);string k2(c);
	string ans=l1+"["+k2+"]"+"_"+geek1;
	arr.clear();
	cout<<ans;
	return ans;
}
