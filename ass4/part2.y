%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
extern int yylineno;
char column_list[100];
void project_print(char s[]);
void cartesian_prod(char f[],char s[]);
void select_table(char expr[],char s[]);
int isNumber(char s[]) ;
void equiz(char tab1[],char c[],char tab2[]);

FILE *fnew;
%}
         /* Yacc definitions */
%union
{
	char s[100];
	struct {
     char s[100];
     int  type;
  } id;
	int num;
}
%start start
%token SELECT PROJECT CARTESIAN_PRODUCT EQUI_JOIN NEWLINE OPEN LESS GREAT EQUAL NOTEQUAL AND OR COMMA CLOSE LESSEQUAL GREATEQUAL DOT MINUS PLUS INTO DIV
/*declaring all the tokens*/
%type <id> expression1
%type <id> condition1
%type <id> conditionlist1
%type <s> conditionlist2
%type <id> expression11
%type <s> num1
%type <s> id1
%token <s> NAME
%token <s> NUMBER
%token <s> STR  
%left INTO DIV
%left PLUS MINUS

%define parse.error verbose
%%

/* descriptions of expected inputs corresponding actions (in C) */

start: stmtlist
stmtlist:	stmt		
			|stmt stmtlist /*stmtlist gives one or more number of stmts*/
			
			
/*stmt can be either of the following*/
stmt:		SELECT LESS conditionlist1 GREAT OPEN NAME CLOSE  NEWLINE  {select_table($3.s,$6);printf("Valid syntax\n");}	/*SELECT <condn> (NAME) \n*/
			| PROJECT LESS attributelist GREAT OPEN NAME CLOSE  NEWLINE {project_print($6);printf("Valid syntax\n");}	/*PROJECT <attr list> (NAME) \n*/
			| OPEN NAME CLOSE CARTESIAN_PRODUCT OPEN NAME CLOSE NEWLINE {cartesian_prod($2,$6);printf("Valid syntax\n");}	/*(NAME) join \n*/
			| OPEN NAME CLOSE EQUI_JOIN LESS conditionlist2 GREAT OPEN NAME CLOSE NEWLINE {equiz($2,$6,$9);printf("Valid syntax\n");}
			| error NEWLINE {fprintf(fnew,"cout<<\"Invalid Syntax\"<<endl;");yyerrok;}	/*all the above are the only valid syntax for stmt, every else is just an error*/


conditionlist1:	NAME condition1 {sprintf($$.s,"%s,1,%s",$1,$2.s);}//attribute condn
				|NAME condition1 AND conditionlist1{sprintf($$.s,"%s,1,%s,AND,%s",$1,$2.s,$4.s);}
				|NAME condition1 OR conditionlist1{sprintf($$.s,"%s,1,%s,OR,%s",$1,$2.s,$4.s);}
				|NAME NOTEQUAL STR AND conditionlist1{sprintf($$.s,"%s,2,!=,%s,AND,%s",$1,$3,$5.s);}
				|NAME NOTEQUAL STR OR conditionlist1{sprintf($$.s,"%s,2,!=,%s,OR,%s",$1,$3,$5.s);}
				|NAME EQUAL STR AND conditionlist1{sprintf($$.s,"%s,2,==,%s,AND,%s",$1,$3,$5.s);}
				|NAME EQUAL STR OR conditionlist1{sprintf($$.s,"%s,2,==,%s,OR,%s",$1,$3,$5.s);}
				|NAME NOTEQUAL STR  	{sprintf($$.s,"%s,2,!=,%s",$1,$3);}
				|NAME EQUAL STR  	{sprintf($$.s,"%s,2,==,%s",$1,$3);}

condition1 :	 LESSEQUAL expression1	 {sprintf($$.s,"<=,%s",$2.s);}
				| GREATEQUAL expression1   {sprintf($$.s,">=,%s",$2.s);}
				| GREAT expression1	{sprintf($$.s,">,%s",$2.s);}
				| LESS expression1 		{sprintf($$.s,"<,%s",$2.s);}
				| NOTEQUAL expression1    {sprintf($$.s,"!=,%s",$2.s);}
				| EQUAL expression1   {sprintf($$.s,"==,%s",$2.s);}
			
expression1	:	expression1 PLUS expression11  {if($1.type==0 && $3.type==0){int i=0;i=atoi($1.s); int j=0;j=atoi($3.s); i=i+j; sprintf($$.s,"%d",i);$$.type=0;} else {sprintf($$.s,"%s,+,%s",$1.s,$3.s);$$.type=1;} }		
				|expression1 MINUS expression11 {if($1.type==0 && $3.type==0){int i=0;i=atoi($1.s); int j=0;j=atoi($3.s); i=i-j; sprintf($$.s,"%d",i);$$.type=0;} else {sprintf($$.s,"%s,+,%s",$1.s,$3.s);$$.type=1;} }		
				|expression11 {if($1.type!=1){int i=0;i=atoi($1.s); sprintf($$.s,"%d",i);$$.type=0;} else {sprintf($$.s,"%s",$1.s);$$.type=1;}}	

expression11:	num1 INTO expression11 {if($3.type!=1){int i=0;i=atoi($3.s); int j=0;j=atoi($1); i=i*j; sprintf($$.s,"%d",i);$$.type=0;}
										else {sprintf($$.s,"%s,*,%s",$1,$3.s);$$.type=1;}}	
				|num1 DIV expression11 {if($3.type!=1){int i=0;i=atoi($3.s); int j=0;j=atoi($1); i=i/j; sprintf($$.s,"%d",i);$$.type=0;}
										else {sprintf($$.s,"%s,*,%s",$1,$3.s);$$.type=1;}}
				|num1 {int i=0;i=atoi($1); sprintf($$.s,"%d",i);$$.type=0;}	
				|id1 INTO expression11 {sprintf($$.s,"%s,1,*,%s",$1,$3.s);$$.type=1;}	
				|id1 DIV expression11 {sprintf($$.s,"%s,1,/,%s",$1,$3.s);$$.type=1;}
				|id1 {sprintf($$.s,"%s,1",$1);$$.type=1;}
				|OPEN expression1 CLOSE {sprintf($$.s,"%s",$2.s);$$.type=$2.type;}
				|OPEN expression1 CLOSE INTO expression11 
					{if($2.type==0 && $5.type==0){int i=0;i=atoi($2.s); int j=0;j=atoi($5.s); i=i*j; sprintf($$.s,"%d",i);$$.type=0;} 
					else {sprintf($$.s,"%s,*,%s",$2.s,$5.s);$$.type=1;} }		
				|OPEN expression1 CLOSE DIV expression11 
					{if($2.type==0 && $5.type==0){int i=0;i=atoi($2.s); int j=0;j=atoi($5.s); i=i/j; sprintf($$.s,"%d",i);$$.type=0;} 
					else {sprintf($$.s,"%s,/,%s",$2.s,$5.s);$$.type=1;}  }	

id1:				NAME	{sprintf($$,"%s",$1); }//idnum1 of the type some name or number or +, -, *, / number
num1:			NUMBER   {sprintf($$,"%s",$1); }
				|MINUS NUMBER {sprintf($$,"-%s",$2); }
/*all the grammar rules below include those of the condition syntax in joins*/

conditionlist2:	NAME DOT NAME EQUAL NAME DOT NAME {sprintf($$,"%s.%s,==,%s.%s",$1,$3,$5,$7);}
				|NAME DOT NAME EQUAL NAME DOT NAME AND conditionlist2 {sprintf($$,"%s.%s,==,%s.%s,AND,%s",$1,$3,$5,$7,$9);}
				|NAME DOT NAME EQUAL NAME DOT NAME OR conditionlist2 {sprintf($$,"%s.%s,==,%s.%s,OR,%s",$1,$3,$5,$7,$9);}

attributelist :	NAME 					{ bzero(column_list,100); strcat(column_list,$1);  }	
				|attributelist COMMA NAME  {  strcat(column_list,","); strcat(column_list,$3);  }



%%                     /* C code */


int main (void) {
	fnew=fopen("ans.cpp","w");
	fprintf(fnew,"#include<bits/stdc++.h>\nusing namespace std;\nint main(){int ans;\n");
	int k= yyparse(); //call the function so as to cause parsing to occur, returns 0 if eof is reached, 1 if failed due to syntax error
	fprintf(fnew,"return 0;}");
	fclose(fnew);
	return k;
}

void yyerror (char *s) {fprintf (stderr, "%d %s\n",yylineno,s);}	//in case of error, i.e. some unmatched syntax of the grammar defined print Invalid Syntax

void project_print (char s[])
{
	
	strcat(column_list,"\0");
	
	strcat(s,".csv");
	FILE *f1=fopen(s,"r");
	if(f1==NULL)
	{

		fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",s);
		
		return;
	}
	char buffer[1000];
	fgets(buffer,1000,f1);
	char h[15][20];
	bzero(h,300); 
	char*t=strtok(buffer,"\n");
	char*temp1=strtok(t,",");
	int j=0;
	while(temp1!=NULL)
	{
		strcat(h[j],temp1);
		temp1=strtok(NULL,",");
		j++;

	}
	for(int i=0;i<j;i++)
	{
		strtok(h[i],"(");
	}
	int p[20];
	for(int i=0;i<20;i++)
	{
		p[i]=-1;
	}

	char*temp2=strtok(column_list,",");
	int k=0;
	
	while(temp2!=NULL)
	{
		for(int i=0;i<j;i++)
		{
			if(strcmp(temp2,h[i])==0)
			{
				
				p[k]=i;
				break;
			}
			

		}
		if(p[k]==-1)
		{
			fprintf(fnew,"cout<<\"%s column not present in table\"<<endl;",temp2);
	 return;
		}
		k++;
		temp2=strtok(NULL,",");
	}
	for(int i=0;i<k;i++)
	{
		fprintf(fnew,"cout<<\"%s,\";",h[p[i]]);
	}
	fprintf(fnew,"cout<<endl;");

	bzero(buffer,1000);
	char r[j][20];
	while(fgets(buffer,1000,f1) )
	{
	
		bzero(r,20*j);
		int g=0;
		char*y=strtok(buffer,"\n");
		char*w=strtok(y,",");
		while(w!=NULL)
		{
			strcat(r[g],w);
			g++;
			w=strtok(NULL,",");
		}
		for(int i=0;i<k;i++)
		{
			fprintf(fnew,"cout<<\"%s,\";",r[p[i]]);
			
		}
		fprintf(fnew,"cout<<endl;");

		bzero(buffer,1000);
	}


	fclose(f1);
	return;
}

void cartesian_prod(char f[],char s[])
{
	strcat(f,".csv");
	strcat(s,".csv");
	//FILE *fnew=fopen("ans.cpp","w");
	//fprintf(fnew,"#include<bits/stdc++.h>\nusing namespace std;\nint main(){\n");
	FILE *f1=fopen(f,"r");
	FILE *f2=fopen(s,"r");
	if(f1==NULL || f2==NULL)
	{
		if(f1==NULL)
			fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",f);
		if(f2==NULL)
		{
			fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",s);
		}
		//fprintf(fnew,"return 0;}");
		//fclose(fnew);
		return;
	}
	
	char buffer[1000],buffer1[1000];
	fgets(buffer,1000,f1);
	strtok(buffer,"\n");
	fgets(buffer1,1000,f2);strtok(buffer1,"\n");
	fprintf(fnew,"cout<<\"%s,%s\"<<endl;",buffer,buffer1);
	bzero(buffer,1000);bzero(buffer1,1000);
	fclose(f2);
	while(fgets(buffer,1000,f1)!=NULL)
	{
		strtok(buffer,"\n");
		FILE *f2=fopen(s,"r");
		fgets(buffer1,1000,f2);
		bzero(buffer1,1000);
		while(fgets(buffer1,1000,f2)!=NULL)
		{strtok(buffer1,"\n");
			fprintf(fnew,"cout<<\"%s,%s\"<<endl;",buffer,buffer1);
			bzero(buffer1,1000);
		}
		fclose(f2);
		bzero(buffer,1000);
	}
	//fprintf(fnew,"return 0;}");
	//fclose(fnew);
	fclose(f1);

}
int isNumber(char s[]) 
{ 
    for (int i = 0; i < strlen(s); i++) 
        if (isdigit(s[i]) == 0) 
            return 0; 
  
    return 1; 
}

void select_table(char expr[],char s[])
{
	//printf("%s ",expr);
	strcat(s,".csv");
	FILE *f1=fopen(s,"r");
	if(f1==NULL)
	{
		//printf("%s Table doesnt exist\n",s);
		fprintf(fnew,"string s=\"%s\";cout<<s<<\" Table doesnt exist\";",s);
		return;
	}
	char buffer[1000];char temp[1000];
	fgets(buffer,1000,f1);
	char h[15][20];
	bzero(h,300); 
	char*t=strtok(buffer,"\n");strcpy(temp,buffer);
	char*temp1=strtok(t,",");
	int j=0;
	while(temp1!=NULL)
	{
		strcat(h[j],temp1);
		temp1=strtok(NULL,",");
		j++;
	}
	int type[j];

	for(int i=0;i<j;i++)
	{
		t=strtok(h[i],"(");
		t=strtok(NULL,")");
		
		if(strcmp(t,"int")==0)
			{type[i]=1;}
		else
			{type[i]=2;}
	}
	bzero(buffer,1000);
	char express[100][100];
	bzero(express,10000);
	temp1=strtok(expr,",");
	int k=0;
	while(temp1!=NULL)
	{
		strcat(express[k],temp1);
		temp1=strtok(NULL,",");

		k++;
	}
	int point[k];
	for(int i=0;i<k;i++)
		point[i]=-1;
	for(int i=0;i<k;i++)
	{
		if(isalpha(express[i][0]))
		{
			if(strcmp(express[i],"AND")==0)
			{
				continue;
			}
			if(strcmp(express[i],"OR")==0)
			{
				continue;
			}
			int x;
			for( x=0;x<j;x++)
			{
				if(strcmp(express[i],h[x])==0)
				{
					break;
				}
			}
			if(x==j)
			{
				fprintf(fnew,"cout<<\"%s column doesnt exist\"<<endl;",express[i]);
				return;
			}
			if(type[x]!=express[i+1][0]-'0')
			{
				//printf("%d %d",type[x],express[i+1][0]-'0');
				fprintf(fnew,"cout<<\"Type Mismatch\"<<endl;");
				return;
			}
			point[i]=x;
		}
	}
	fprintf(fnew,"cout<<\"%s,\";",temp);
	fprintf(fnew,"cout<<endl;");
	char r[j][20];char a[1000];
	int g,i;

	while(fgets(buffer,1000,f1) )
	{
		bzero(a,1000);
		strcpy(a,buffer);
		strtok(a,"\n");
		bzero(r,20*j);
		char *w=strtok(buffer,"\n");
		char *t1=strtok(w,",");
		g=0;
		i=0;

		while(t1!=NULL)
		{
			strcat(r[g],t1);
			g++;
			t1=strtok(NULL,",");
		}
		fprintf(fnew,"ans=");
	    while(i<k)
		{

			if(strcmp(express[i],"AND")==0)
			{
				fprintf(fnew,"&&");i++;continue;
			}
			if(strcmp(express[i],"OR")==0)
			{
				fprintf(fnew,"||");i++;continue;
			}
			if(point[i]!=-1)
			{
				if(type[point[i]]==2)
				{
					
					fprintf(fnew,"\"%s\"",r[point[i]]);
					i++;
				}
				else
				{
					if(r[point[i]][0]!='\0')
					{
						fprintf(fnew,"%s",r[point[i]]);
						i++;
					}
					else
					{
						fprintf(fnew,"-1");
						i++;
					}
				}
			}
			else
			{
				
				fprintf(fnew,"%s",express[i]);
			}
			i++;
		}
		fprintf(fnew,";\nif(ans==1) cout<<\"%s\"<<endl;",a);
	   bzero(buffer,1000);
	}
	
}

void equiz(char f[],char expr[],char s[])
{
	
	strcat(f,".csv");
	strcat(s,".csv");
	FILE *f1=fopen(f,"r");
	FILE *f2=fopen(s,"r");
	if(f1==NULL || f2==NULL)
	{
		if(f1==NULL)
			fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",f);
		if(f2==NULL)
		{
			fprintf(fnew,"cout<<\"%s Table doesnt exist\"<<endl;",s);
		}
		return;
	}
	strtok(f,".");strtok(s,".");
	char buffer[1000];bzero(buffer,1000);
	fgets(buffer,1000,f1);
	char h[15][100];// 1st attributes
	bzero(h,1500); 
	char*t=strtok(buffer,"\n");
	char*temp1=strtok(t,",");
	int no_attr1=0;
	while(temp1!=NULL)
	{
		strcat(h[no_attr1],f);strcat(h[no_attr1],".");
		strcat(h[no_attr1],temp1);
		//printf("%s ",h[no_attr1]);
		temp1=strtok(NULL,",");
		no_attr1++;
	}
	bzero(buffer,1000);fgets(buffer,1000,f2);
	char g[15][100];
	bzero(g,1500); 
	t=strtok(buffer,"\n");
	temp1=strtok(t,",");
	int no_attr2=0;
	while(temp1!=NULL)
	{
		strcat(g[no_attr2],s);strcat(g[no_attr2],".");
		strcat(g[no_attr2],temp1);
		temp1=strtok(NULL,",");
		no_attr2++;
	}
	//printf("%d %d",no_attr1,no_attr2);
	int type1[no_attr1];
	for(int i=0;i<no_attr1;i++)
	{
		t=strtok(h[i],"(");
		t=strtok(NULL,")");
		//printf("%s",t);
		if(strcmp(t,"int")==0)
			{type1[i]=1;}
		else
			{type1[i]=2;}
	}
	int type2[no_attr2];
		for(int i=0;i<no_attr2;i++)
		{
			t=strtok(g[i],"(");
			t=strtok(NULL,")");
			
			if(strcmp(t,"int")==0)
				{type2[i]=1;}
			else
				{type2[i]=2;}
		}
		
	char express[100][100];
	bzero(express,10000);
	temp1=strtok(expr,",");
	int k=0;
	while(temp1!=NULL)
	{
		strcat(express[k],temp1);
		temp1=strtok(NULL,",");

		k++;
	}

	int point[k];
	for(int i=0;i<k;i++)
		point[i]=-1;
	for(int i=0;i<k;i++)
	{
		if(isalpha(express[i][0]))
		{
			if(strcmp(express[i],"AND")==0)
			{
				continue;
			}
			if(strcmp(express[i],"OR")==0)
			{
				continue;
			}
			int x;
			// searching in frst table
			for( x=0;x<no_attr1;x++)
			{
				if(strcmp(express[i],h[x])==0)
				{
					break;
				}
			}
			if(x==no_attr1)
			{
				// search 2nd table
				for( x=0;x<no_attr2;x++)
				{
					if(strcmp(express[i],g[x])==0)
					{
						break;
					}
				}
				if(x==no_attr2)
				{
					fprintf(fnew,"cout<<\"%s column doesnt exist\"<<endl;",express[i]);
					return;
				}
				point[i]=no_attr1+x;
			}
			else
			{
				point[i]=x;
			}
			
		}
	}
	for(int i=0;i<k;i++)
	{
		if(strcmp(express[i],"==")==0)
		{
			if(point[i-1]>=no_attr1)
			{
				if(type2[point[i-1]-no_attr1]!=type1[point[i+1]])
				{
					fprintf(fnew,"cout<<\"Type Mismatch\"<<endl;");
					return;
				}
			}
			else
			{
				if(type2[point[i+1]-no_attr1]!=type1[point[i-1]])
				{
					fprintf(fnew,"cout<<\"Type Mismatch\"<<endl;");
					return;
				}
			}
		}
	}
	fclose(f1);fclose(f2);
	strcat(f,".csv");strcat(s,".csv");
	f1=fopen(f,"r");
	f2=fopen(s,"r");
	char buffer1[1000];
	fgets(buffer,1000,f1);//1st attributes
	strtok(buffer,"\n");
	fgets(buffer1,1000,f2);strtok(buffer1,"\n");//2nd attributes
	fprintf(fnew,"cout<<\"%s,%s\"<<endl;",buffer,buffer1);
	bzero(buffer,1000);bzero(buffer1,1000);
	fclose(f2);
	char r[no_attr1+no_attr2][20];char a[1000];char temp[1000];
	int y,i;
	while(fgets(buffer,1000,f1)!=NULL)
	{
		strtok(buffer,"\n");
		FILE *f2=fopen(s,"r");
		fgets(buffer1,1000,f2);
		bzero(buffer1,1000);
		while(fgets(buffer1,1000,f2)!=NULL)
		{
			bzero(a,1000);
			strcpy(a,buffer);strcat(a,",");
			strcat(a,buffer1);
			strtok(a,"\n");
			bzero(temp,1000);strcpy(temp,a);
			bzero(r,20*(no_attr1+no_attr2));
			char *w=strtok(temp,"\n");
			char *t1=strtok(w,",");
			y=0;
			i=0;

			while(t1!=NULL)
			{
				strcat(r[y],t1);
				y++;
				t1=strtok(NULL,",");
			}
			fprintf(fnew,"ans=");
			while(i<k)
			{

				if(strcmp(express[i],"AND")==0)
				{
					fprintf(fnew,"&&");i++;continue;
				}
				if(strcmp(express[i],"OR")==0)
				{
					fprintf(fnew,"||");i++;continue;
				}
				if(point[i]!=-1)
				{
					if(point[i]>=no_attr1)
					{
						if(type2[point[i]-no_attr1]==2)
						{
							fprintf(fnew,"\"%s\"",r[point[i]]);
						}
						else
							fprintf(fnew,"%s",r[point[i]]);
					}
					else
					{
							if(type1[point[i]]==2)
						{
							fprintf(fnew,"\"%s\"",r[point[i]]);
						}
						else
							fprintf(fnew,"%s",r[point[i]]);
					}
					
				}
				else
				{
					fprintf(fnew,"%s",express[i]);
				}
				i++;
			}
			fprintf(fnew,";\nif(ans==1) cout<<\"%s\"<<endl;",a);
			bzero(buffer1,1000);
		}
		fclose(f2);
		bzero(buffer,1000);
	}
	fclose(f1);//fclose(f2);
	return;
}
