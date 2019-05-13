#include<bits/stdc++.h>
#include<fstream>
#include <sstream>
#include <cstdlib> 

using namespace std;

int z=1;
void vars(ofstream &fp)
{
  string line;
  ifstream myfile("variables.txt");
  fp<<".data"<<endl;
  if(myfile.is_open())
  {
    while(getline(myfile,line))
    {
      string s1,s2;
      size_t pos = 0;
      pos = line.find(",");
      s1= line.substr(0, pos);
      if(s1[0]!='_')
      {
        line.erase(0, pos + 1);
        pos = line.find(",");
        s2= line.substr(0, pos);
        fp<<s1<<":"<<"   ";
        if(s1[s1.length()-1]=='1')
        {
          fp<<".word";
          if(s2=="1")
        {
          fp<<"    0"<<endl;
          
        }
        else
        {
            fp<<"   0:"<<s2<<endl;
        }
        }
        else
        {
          fp<<".float";
          if(s2=="1")
          {
            fp<<"  0.0"<<endl;
          }
          else
              {
                  int p=stoi(s2);
                  fp<<"   0.0";
                  for(int i=1;i<p;i++)
                  {
                        fp<<", 0.0";
                  }
                  fp<<endl;
              }
        }
        
      }
      else
      {
        fp<<s1<<":"<<"   ";
        if(s1[s1.length()-1]=='1')
        {
          fp<<".word    0"<<endl;
        }
        else
        {
          fp<<".float    0.0"<<endl;
        }
      }
      
    }
  }
  
  return;
}



bool isNumber(string s) 
{ 
   
        if(isdigit(s[0]) == false) 
            return false; 
  
    return true; 
} 

int strtoint(string s)
{

}

bool isfloat(string s)
{
    if (s.find(".")!=string::npos)return true;
    else return false; 
}

void func1(ofstream & fp,string s1)
{
	if(s1=="+"){fp<<"add $t0,$t2,$t4"<<endl;}
      			if(s1=="-"){fp<<"sub $t0,$t2,$t4"<<endl;}
      			if(s1=="*"){fp<<"mul $t0,$t2,$t4"<<endl;}
      			if(s1=="/"){fp<<"div $t0,$t2,$t4"<<endl;}
      			if(s1=="%"){fp<<"rem $t0,$t2,$t4"<<endl;}
}

void func2(ofstream & fp,string s1)
{
	if(s1=="+"){fp<<"add.s $f0,$f2,$f4"<<endl;}
      			if(s1=="-"){fp<<"sub.s $f0,$f2,$f4"<<endl;}
      			if(s1=="*"){fp<<"mul.s $f0,$f2,$f4"<<endl;}
      			if(s1=="/"){fp<<"div.s $f0,$f2,$f4"<<endl;}
      			
}

void func4(ofstream & fp,string s1)
{
	if(s1=="=="){fp<<"c.eq.s ";}
	if(s1=="<"){fp<<"c.lt.s ";}
	if(s1=="<="){fp<<"c.le.s ";}
	if(s1==">"){fp<<"c.gt.s ";}
	if(s1==">="){fp<<"c.ge.s ";}
	if(s1=="!="){fp<<"c.ne.s ";}
	

}

void func5(ofstream & fp,string s1)
{
	if(s1=="=="){fp<<"seq ";}
	if(s1=="<"){fp<<"slt ";}
	if(s1=="<="){fp<<"sle ";}
	if(s1==">"){fp<<"sgt ";}
	if(s1==">="){fp<<"sge ";}
	if(s1=="!="){fp<<"sne ";}
}


void func(ofstream & fp,string s1,string s2,string s3,string s4)
{
	
	if((!isNumber(s2)&&s2[s2.length()-1]=='2')||(isNumber(s2)&&isfloat(s2))){
			
      		if(s2[s2.length()-1]=='2'&&!isNumber(s2)){
      			string a1,a2;
      			size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"l.s $f2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"l.s $f2,"<<"$t6"<<"($t8)"<<endl;
      					
      				}	
      		}
      		else
      		{
      			string a1,a2;
      			size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"li.s $f2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li.s $f2,"<<"$t6"<<"($t8)"<<endl;
      					
      				}
      			
      		}
      		if(!isNumber(s3)){
      			string a1,a2;
      			size_t pos = 0;
      				pos = s3.find("[");
      				if(pos==string::npos){fp<<"l.s $f4,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"l.s $f4,"<<"$t6"<<"($t8)"<<endl;
      					
      				}
      			
      		}
      		else{
      				string a1,a2;
      				size_t pos = 0;
      				pos = s3.find("[");
      				if(pos==string::npos){fp<<"li.s $f4,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li.s $f4,"<<"$t6"<<"($t8)"<<endl;
      					
      				}
      				
      		}
      			func2(fp,s1);
      			if(s4[s4.length()-1]=='1'){
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"cvt.w.s $f0, $f0"<<endl<<"mfc1 $t0,$f0"<<endl<<"sw $t0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"cvt.w.s $f0, $f0"<<endl<<"mfc1 $t0,$f0"<<endl<<"sw $t0,"<<"$t6"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      			else{
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"s.s $f0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"s.s $f0,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      	}
      	else {
      		if((!isNumber(s2)&&s2[s2.length()-1]=='1')){
      			string a1,a2;
      			size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"lw $t2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"lw $t2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      			
      		}
      		else{
      			string a1,a2;
      			size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"li $t2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					fp<<"add $t8,$t6,$t8"<<endl; 
      					fp<<"li $t2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      			
      		}
      		if(!isNumber(s3)){
      			string a1,a2;
      			size_t pos = 0;
      			pos = s3.find("[");
      				if(pos==string::npos){fp<<"lw $t4,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"lw $t4,"<<"0"<<"($t8)"<<endl;
      					
      				}
      			
      		}
      			else{
      				string a1,a2;
      				size_t pos = 0;
      			pos = s3.find("[");
      				if(pos==string::npos){fp<<"li $t4,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li $t4,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      			func1(fp,s1);
      			if(s4[s4.length()-1]=='1'){
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"sw $t0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"sw $t0,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      			else{
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      	}
}



void func3(ofstream & fp,string s1,string s2,string s3,string s4){

	if((!isNumber(s2)&&s2[s2.length()-1]=='2')||(isNumber(s2)&&isfloat(s2))){

		if((!isNumber(s2)&&s2[s2.length()-1]=='2'))
		{
			string a1,a2;
      				size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"l.s $f2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"l.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
		}

		else
		{
			string a1,a2;
      				size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"li.s $f2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
		}
	}

	if((!isNumber(s2)&&s2[s2.length()-1]=='1')||(isNumber(s2)&&!isfloat(s2))){
		if((!isNumber(s2)&&s2[s2.length()-1]=='1'))
		{
			string a1,a2;
      				size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"lw $t0,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"lw $t0,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
			
		}

		else{
			string a1,a2;
      				size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"li $t0,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li $t0,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
			
		}
		fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl;
		

	}


	if((!isNumber(s3)&&s3[s3.length()-1]=='2')||(isNumber(s3)&&isfloat(s3))){

		if((!isNumber(s3)&&s3[s3.length()-1]=='2'))
		{
			string a1,a2;
      				size_t pos = 0;
      				pos = s3.find("[");
      				if(pos==string::npos){fp<<"l.s $f4,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"l.s $f4,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
		}

		else
		{
			string a1,a2;
      				size_t pos = 0;
      				pos = s3.find("[");
      				if(pos==string::npos){fp<<"li.s $f4,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li.s $f4,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
		}
	}

	if((!isNumber(s3)&&s3[s3.length()-1]=='1')||(isNumber(s3)&&!isfloat(s3))){
		if((!isNumber(s3)&&s3[s3.length()-1]=='1'))
		{
			string a1,a2;
      				size_t pos = 0;
      				pos = s3.find("[");
      				if(pos==string::npos){fp<<"lw $t2,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"lw $t2,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
			
		}

		else{
			string a1,a2;
      				size_t pos = 0;
      				pos = s3.find("[");
      				if(pos==string::npos){fp<<"li $t2,"+s3<<endl;}
      				else{
      					a1= s3.substr(0, pos);
      					s3.erase(0, pos + 1);
      					pos=s3.find("]");
      					a2=s3.substr(0, pos);
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"li $t2,"<<"0"<<"($t8)"<<endl;
      					
      				}
			
			
		}
		fp<<"mtc1 $t2,$f4"<<endl<<"cvt.s.w $f4, $f4"<<endl;
	}

		    
      if(s1=="=="){fp<<"c.eq.s ";fp<< "$f2, $f4"<<endl;fp<<"bc1f P"<<z<<endl;}
      if(s1=="<"){fp<<"c.lt.s ";fp<< "$f2, $f4"<<endl;fp<<"bc1f P"<<z<<endl;}
      if(s1=="<="){fp<<"c.le.s ";fp<< "$f2, $f4"<<endl;fp<<"bc1f P"<<z<<endl;}
      if(s1==">"){fp<<"c.le.s ";fp<< "$f2, $f4"<<endl;fp<<"bc1t P"<<z<<endl;}
      if(s1==">="){fp<<"c.lt.s ";fp<< "$f2, $f4"<<endl;fp<<"bc1t P"<<z<<endl;}
      if(s1=="!="){fp<<"c.eq.s ";fp<< "$f2, $f4"<<endl;fp<<"bc1t P"<<z<<endl;}
        fp<<"li $t8,1"<<endl<<"sw $t8,"+s4<<endl<<"j P"<<z+1<<endl;z=z+2;
        fp<<"P"<<z-2<<":"<<endl<<"li $t8,0"<<endl<<"sw $t8,"+s4<<endl<<"P"<<z-1<<":\n";
      	
	
}





int main()
{

   string line;
  ifstream myfile ("Intermediate.txt");
  ofstream fp("example.txt");
  vars(fp);

    ifstream params("parameters.txt");
    map<string,vector<string> >function;
    map<string,int>return_type;
    map<string,int>stack_num;
    vector<string>parameters;
    string func_name="main";
    int r_type;
    while(getline(params,line))
    {
      string f=line;
      getline(params,line);
      return_type[f]=(line[0]-'0');
      while(getline(params,line))
      {
        if(line=="-1") break;
        function[f].push_back(line);
      }
    }
    params.close();
   
    for(auto it=function.begin();it!=function.end();it++)
    {
      for(int j=0;j<it->second.size();j++)
      {
        int c=it->second[j][it->second[j].size()-1]-'0';
        if(c==1)
          fp<<it->second[j]<<" : .word 0"<<endl;
        else if(c==2)
          fp<<it->second[j]<<" : .float 0.0"<<endl;
      }
    }
  fp<<"\n\n.text"<<endl;
  if (myfile.is_open())
  {
    while ( getline (myfile,line) )
    {
      string s1,s2,s3,s4;
        size_t pos = 0;
      pos = line.find(",");
      s1= line.substr(0, pos);
    
      line.erase(0, pos + 1);
      pos = line.find(",");
      s2= line.substr(0, pos);
     
      line.erase(0, pos + 1);
      pos = line.find(",");
      s3= line.substr(0, pos);
      
      line.erase(0, pos + 1);
      s4=line;

      if (s1=="")fp<<s4+":"<<endl;
      if(s1=="goto")fp<<"j "<<s4<<endl;
      if(s1=="="){
      	if(!isNumber(s2)){
      		if(s2[s2.length()-1]=='2')
      		{
      			cout<<3<<endl;
      			string a1,a2;
      				size_t pos = 0;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"l.s $f2,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"l.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      			if(s4[s4.length()-1]=='1'){
      				cout<<4<<endl;
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"cvt.w.s $f2, $f2"<<endl<<"mfc1 $t0,$f2"<<endl<<"sw $t0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"cvt.w.s $f2, $f2"<<endl<<"mfc1 $t0,$f2"<<endl<<"sw $t0,"<<"0"<<"($t8)"<<endl;
      				}
      			}
      			
      			
      			else{
      				cout<<5<<endl;
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"s.s $f2,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"s.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      			
      		}
      		else
      		{
      			string a1,a2;

      				size_t pos = 0;
      				cout<<2<<endl;
      				pos = s2.find("[");
      				if(pos==string::npos){fp<<"lw $t0,"+s2<<endl;}
      				else{
      					a1= s2.substr(0, pos);
      					s2.erase(0, pos + 1);
      					pos=s2.find("]");
      					a2=s2.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"lw $t0,"<<"0"<<"($t8)"<<endl;
      					
      				}

      			if(s4[s4.length()-1]=='1'){
      				cout<<6<<endl;
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"sw $t0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"sw $t0,"<<"0"<<"($t8)"<<endl;
      				}
      			}
      			
      			
      			else{
      				cout<<7<<endl;
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      			
      		}
      	}
      	else {
      		if(isfloat(s2)){
      			cout<<8<<endl;
      			fp<<"li.s $f2,"+s2<<endl;
      			if(s4[s4.length()-1]=='1'){
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"cvt.w.s $f2, $f2"<<endl<<"mfc1 $t0,$f2"<<endl<<"sw $t0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"cvt.w.s $f2, $f2"<<endl<<"mfc1 $t0,$f2"<<endl<<"sw $t0,"<<"0"<<"($t8)"<<endl;
      				}
      			}
      			else{
      				cout<<9<<endl;
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"s.s $f2,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"s.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      		}
      		else{
      			cout<<10<<endl;
      			fp<<"li $t0,"+s2<<endl;
      			if(s4[s4.length()-1]=='1'){
      				string a1,a2;
      				size_t pos = 0;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"sw $t0,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"sw $t0,"<<"0"<<"($t8)"<<endl;
      				}
      			}
      			else{
      				cout<<11<<endl;
      				string a1,a2;
      				size_t pos = 0;cout<<s4;
      				pos = s4.find("[");
      				if(pos==string::npos){fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"+s4<<endl;}
      				else{
      					a1= s4.substr(0, pos);
      					s4.erase(0, pos + 1);
      					pos=s4.find("]");
      					a2=s4.substr(0, pos);
      					cout<<a1<<endl;
      					cout<<a2<<endl;
      					fp<<"la $t8,"+a1<<endl;
      					fp<<"lw $t6,"+a2<<endl;
      					 fp<<"add $t8,$t6,$t8"<<endl;
      					fp<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"<<"0"<<"($t8)"<<endl;
      					
      				}
      				
      			}
      			
      		}
      	}


      	
      }

     
      if(s1=="+"||s1=="-"||s1=="*"||s1=="/"||s1=="%"){func(fp,s1,s2,s3,s4);}
       if(s1==">"||s1==">="||s1=="<"||s1=="<="||s1=="=="||s1=="!="){func3(fp,s1,s2,s3,s4);}
       if(s1=="if"){fp<<"lw $t0,"+s2<<endl<<"li $t2,1"<<endl<<"bge $t0,$t2,"+s4<<endl;}
       if(s1=="cnvrt_float"){
            string a1,a2;
                              size_t pos = 0;
                              pos = s2.find("[");
                              if(pos==string::npos){fp<<"lw $t0,"+s2<<endl<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"+s4<<endl;}
                              else{
                                    a1= s2.substr(0, pos);
                                    s2.erase(0, pos + 1);
                                    pos=s2.find("]");
                                    a2=s2.substr(0, pos);
                                    cout<<a1<<endl;
                                    cout<<a2<<endl;
                                    fp<<"la $t8,"+a1<<endl;
                                    fp<<"lw $t6,"+a2<<endl;
                                     fp<<"add $t8,$t6,$t8"<<endl;
                                   fp<<"lw $t0,"<<"0"<<"($t8)"<<endl<<"mtc1 $t0,$f2"<<endl<<"cvt.s.w $f2, $f2"<<endl<<"s.s $f2,"+s4<<endl;;
                                    
                              }
           
      }
        if(s1=="func_begin")
        {
          int start=0;func_name=s4;
          fp<<func_name<<":"<<endl;
          for(int i=0;i<function[s4].size();i++)
          {
            int c=function[s4][i][function[s4][i].size()-1]-'0';
            if(c==1)
            {
              fp<<"lw $t0, "+to_string(start)+"($sp)"<<endl;
              fp<<"sw $t0, "+function[s4][i]<<endl;
              start+=4;
            }
            else
            {
              fp<<"l.s $f0, "+to_string(start)+"($sp)"<<endl;
              fp<<"s.s $f0, "+function[s4][i]<<endl;
              start+=4;
            }
          }
          stack_num[func_name]=start;
          fp<<"addi $sp, $sp, "+ to_string(start)<<endl;
          if(return_type[s4]==2)
          {
            fp<<"li.s $f0, 0.0"<<endl;
            fp<<"mfc1 $v0,$f0"<<endl;
          }
          else if (return_type[s4]==1)
          {
            fp<<"li $v0, 0"<<endl;
          }
        }
        if(s1=="return")
        {
					if(func_name=="main")
					{

						fp<<"li $v0,10"<<endl;
						fp<<"syscall"<<endl;
						continue;
					}
          if(isdigit(s4[0]))
          {
            size_t found = s4.find("."); 
            if (found != string::npos)//float
            {
              if(return_type[func_name]==2)
              {
                fp<<"li.s $f0, "+s4<<endl;
                fp<<"mfc1 $v0,$f0"<<endl;
              }
              else if(return_type[func_name]==1)
              {
                fp<<"li.s $f0, "+s4<<endl;
                fp<<"cvt.w.s $f0, $f0"<<endl;
                fp<<"mfc1 $v0, $f0"<<endl;
              }
            }
            else// int 
            {
              if(return_type[func_name]==2)// float
              {
                fp<<"li.s $f0, "+s4+".0"<<endl;
                fp<<"mfc1 $v0, $f0"<<endl;
              }
              else if(return_type[func_name]==1)//int
              {
                fp<<"li $v0, "+s4<<endl;
                
              }
            }
          }
          else
          {
            int c=s4[s4.size()-1]-'0';
            if(c==1)//int
            {
              if(return_type[func_name]==2)// float
              {
                fp<<"lw $t0, "+s4<<endl;
                fp<<"mtc1 $t0, $f0"<<endl;
                fp<<"cvt.s.w $f0, $f0"<<endl;
                fp<<"mfc1 $v0, $f0"<<endl;
              }
              else if(return_type[func_name]==1)//int
              {
                fp<<"lw $v0, "+s4<<endl;
                
              }
            }
            else if(c==2)//float
            {
              if(return_type[func_name]==2)// float
              {
                fp<<"l.s $f0, "+s4<<endl;
                fp<<"mfc1 $v0, %f0"<<endl;
              }
              else if(return_type[func_name]==1)//int
              {
                fp<<"l.s $f0, "+s4<<endl;
                fp<<"cvt.w.s $f0, $f0"<<endl;
                fp<<"mfc1 $v0, $f0"<<endl;
                
              }
            }
          }
          fp<<"jr $ra"<<endl;
        }
        if(s1=="func_end")
        {
					if(func_name=="main")
					{break;}
					func_name="main";
          fp<<"jr $ra"<<endl;
        }
        if(s1=="param")
        {
          if(parameters.size()==0)
          {
            fp<<"addiu $sp,$sp,-4"<<endl;
						fp<<"sw $ra,0($sp)"<<endl;
          }
          parameters.push_back(s4);
        }
        if(s1=="refparam")
        {
          r_type=s4[s4.size()-1]-'0';
        }
        if(s1=="call")
        {
					
					int r_start=stack_num[func_name];
					fp<<"addiu $sp,$sp,-"+to_string(r_start)<<endl;
					for(int i=0;i<function[func_name].size();i++)
          {
            int c=function[func_name][i][function[func_name][i].size()-1]-'0';
            if(c==1)
            {
							fp<<"lw $t0, "+function[func_name][i]<<endl;
              fp<<"sw $t0, "+to_string(i*4)+"($sp)"<<endl; 
            }
            else
            {
							fp<<"l.s $f0, "+function[func_name][i]<<endl;
              fp<<"s.s $f0, "+to_string(i*4)+"($sp)"<<endl;
            }
          }
					string func_name1=s2;
          int ret=return_type[s2];
					int start=stack_num[func_name1];
          fp<<"addiu $sp, $sp, -"+to_string(start)<<endl;
          for(int i=0;i<parameters.size();i++)
          {
            if(isdigit(parameters[i][0]))
            {
              size_t found = parameters[i].find("."); 
              int d=function[func_name1][i][function[func_name1][i].size()-1]-'0';
              if (found != string::npos)//float
              {cout<<s4;
                if(d==1)
                {
                  fp<<"li.s $f0, "<<parameters[i]<<endl;
                  fp<<"cvt.w.s $f0, $f0"<<endl;
                  fp<<"mfc1 $t0, $f0"<<endl;
                  fp<<"sw $t0, "+to_string(i*4)+"($sp)"<<endl;  
                }
                else if(d==2)
                {
                  fp<<"li.s $f0, "+s4<<endl;
                  fp<<"s.s $f0,"+to_string(i*4)+"($sp)"<<endl;
                }
              }
              else
              {
                if(d==1)
                {
                  fp<<"li $t0, "<<parameters[i]<<endl;
                  fp<<"sw $t0, "+to_string(i*4)+"($sp)"<<endl;
                }
                else if(d==2)
                {
                  fp<<"li $t0, "<<parameters[i]<<endl;
                  fp<<"mtc1 $t0, $f0"<<endl;
                  fp<<"cvt.s.w $f0, $f0"<<endl;
                  fp<<"s.s $f0, "+to_string(i*4)+"($sp)"<<endl;
                }
              }
              continue;
            }
            int c=parameters[i][parameters[i].size()-1]-'0';// we have
            int d=function[func_name1][i][function[func_name1][i].size()-1]-'0';// to change
            if(c==1)
            {
              if(d==1)
              {
                fp<<"lw $t0, "<<parameters[i]<<endl;
                fp<<"sw $t0, "+to_string(i*4)+"($sp)"<<endl;
              }
              else if(d==2)
              {
                fp<<"lw $t0, "<<parameters[i]<<endl;
                fp<<"mtc1 $t0, $f0"<<endl;
                fp<<"cvt.s.w $f0, $f0"<<endl;
                fp<<"s.s $f0, "+to_string(i*4)+"($sp)"<<endl;
              }
            }
            else if(c==2)
            {
              if(d==1)
              {
                fp<<"l.s $f0, "<<parameters[i]<<endl;
                fp<<"cvt.w.s $f0, $f0"<<endl;
                fp<<"mfc1 $t0, $f0"<<endl;
                fp<<"sw $t0, "+to_string(i*4)+"($sp)"<<endl;  
              }
              else if (d==2)
              {
                fp<<"l.s $f0, "<<parameters[i]<<endl;
                fp<<"s.s $f0, "+to_string(i*4)+"($sp)"<<endl;
              }
            }

          }
          parameters.clear();
          fp<<"jal "+func_name1<<endl;
					r_start=0;
					for(int i=0;i<function[func_name].size();i++)
          {
            int c=function[func_name][i][function[func_name][i].size()-1]-'0';
            if(c==1)
            {
              fp<<"lw $t0, "+to_string(r_start)+"($sp)"<<endl;
              fp<<"sw $t0, "+function[func_name][i]<<endl;
              r_start+=4;
            }
            else
            {
              fp<<"l.s $f0, "+to_string(r_start)+"($sp)"<<endl;
              fp<<"s.s $f0, "+function[func_name][i]<<endl;
              r_start+=4;
            }
          }
					fp<<"addi $sp,$sp,"+to_string(r_start)<<endl;
					fp<<"lw $ra,0($sp)"<<endl;
					fp<<"addi $sp,$sp,4"<<endl;
          if(r_type==0) continue;
          getline(myfile,line);
          string s1,s2,s3,s4;
          size_t pos = 0;
          pos = line.find(",");
          s1= line.substr(0, pos);
        
          line.erase(0, pos + 1);
          pos = line.find(",");
          s2= line.substr(0, pos);
          
          line.erase(0, pos + 1);
          pos = line.find(",");
          s3= line.substr(0, pos);
          
          line.erase(0, pos + 1);
          s4=line; 
          if(r_type==1)// we want integer
          {
            if(ret==1)
            {
              fp<<"sw $v0, "+s4<<endl;
            }
            else if(ret==2)
            {
              
              fp<<"mtc1 $v0, $f0"<<endl;
              fp<<"cvt.w.s $f0, $f0"<<endl;
              fp<<"mfc1 $t0, $f0"<<endl;
              fp<<"sw $t0, "+s4<<endl;  
            }
          }
          else if(r_type==2)//we want float
          {
            if(ret==1)
            {
              fp<<"lw $t0, $v0"<<endl;
              fp<<"mtc1 $t0, $f0"<<endl;
              fp<<"cvt.s.w $f0, $f0"<<endl;
              fp<<"s.s $f0, "+s4<<endl;
            }
            else if(ret==2)
            {
              
              fp<<"mtc1 $v0, $f0"<<endl;
              fp<<"s.s $f0, "+s4<<endl; 
            }
          }
        }
      
     
    }
    myfile.close();
    fp.close();
  }

  else cout << "Unable to open file"; 
    
 }


