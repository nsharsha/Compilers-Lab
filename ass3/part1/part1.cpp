#include <bits/stdc++.h>
#include "part1.h"
using namespace std;
#define pb push_back
extern int yylex();
extern int yylineno;
extern char* yytext;



int main(void) 
{

	int ntoken, vtoken;
	vector<string>class_names;
	int class_line=0,inh_line=0,obj_line=0,constr_line=0;
	int last_class=0,last_inh=0,last_obj=0,last_constr=0;
	ntoken = yylex();
	bool flag=false;
	while(ntoken) {
		//printf("%s%d%d\n",yytext,ntoken,yylineno);
		switch(ntoken)
		{
			case OPEN:{
							flag=true;break;
						}
			case CLOSE :{
							flag=false;break;
						}
			case CLASS:	{
						if(!flag)
						{char *token=strtok(yytext," ");
						token=strtok(NULL," ");
						string temp=token;
						//cout<<temp;
						if(temp[temp.length()-2]=='\n')
							temp=temp.substr(0,temp.length()-2);
						else if(temp[temp.length()-1]=='{' ||temp[temp.length()-1]=='\n'  )
							temp=temp.substr(0,temp.length()-1);
													
						class_names.pb(temp);
						if(last_class!=yylineno)
						{
							class_line+=1;last_class=yylineno;
						}
						}
						break;}
			case INH:   {if(!flag){ 
						char *token=strtok(yytext," ");
						token=strtok(NULL," ");
						class_names.pb(token);
						token=strtok(NULL," ");
						token=strtok(NULL," ");
						string temp=token;//cout<<temp;
						if(temp[temp.length()-2]=='\n')
							temp=temp.substr(0,temp.length()-2);
						else if(temp[temp.length()-1]=='{' ||temp[temp.length()-1]=='\n'  )
							temp=temp.substr(0,temp.length()-1);
						
						if(find(class_names.begin(),class_names.end(),temp)!=class_names.end())
						{
							if(last_class!=yylineno)
							{
								class_line+=1;last_class=yylineno;
							}
							if(last_inh!=yylineno)
							{
								inh_line+=1;last_inh=yylineno;
							}
						}}
						break;}
			case OBJ: 	{if(!flag){
							char *token=strtok(yytext," ");
							char *temp1=strtok(token,".");
							string temp=temp1;
							if(find(class_names.begin(),class_names.end(),temp)!=class_names.end())
							{
								if(last_obj!=yylineno)
								{
									obj_line+=1;last_obj=yylineno;
								}
								
							}}
							break;
						}
			case CONS:{if(!flag) {
						string temp=yytext;
						int i=0;
						for(i;i<temp.length();i++)
						{
							if(temp[i]==' ' ||temp[i]=='(' )break;
						}
						temp=temp.substr(0,i);
						if(find(class_names.begin(),class_names.end(),temp)!=class_names.end())
						{
							if(last_constr!=yylineno)
							{
								constr_line+=1;last_constr=yylineno;
							}
							
						}
					  } break;}
			

		}
		ntoken = yylex();
	}
	
	cout<<"Class Declarations:"<<class_line<<"\n"<<"Object Declarations:"<<obj_line<<"\n"<<"Inheritance Declarations:"<<inh_line<<"\nConstructor Declarations:"<<constr_line<<"\n";
	return 0;
}
