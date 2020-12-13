#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <set>
#include <bitset>
#include <iterator>
#include <iomanip> 
#include <cassert>
#include <algorithm>
#include <time.h>

using namespace std;
int random_32(){
  int x = rand() & 0xff;
  x |= (rand() & 0xff) << 8;
  x |= (rand() & 0xff) << 16;
  x |= (rand() & 0xff) << 24;
  return x;
}
template< typename T >
std::string int_to_hex( T i)
{
  std::stringstream stream;
  stream << "0x" 
         << std::setfill ('0') << std::setw(sizeof(T)*2) 
         << std::hex << i;
  return stream.str();
}

string get_filename(string const& s)
{
    string::size_type pos = s.find('.');
    if (pos != string::npos)
    {
        return s.substr(0, pos);
    }
    else
    {
        return s;
    }
}

void create_addiu(string afile){
    ofstream infile; 
    int min = -32768;
    int max = 32767;
    srand(time(NULL));
    int num1 = rand()%(max-min + 1) + min;;
    int num2 = rand()%(max-min + 1) + min;;
    int ans = num1+num2;
    infile.open(afile); 
    infile<<"desc random addiu"<<endl;
    infile<<"addiu $2, $2, "+to_string(num1)<<endl;
    infile<<"addiu $2, $2, "+to_string(num2)<<endl;
    infile<<"jr $0"<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_addu(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = num1+num2;
    infile.open(afile); 
    infile<<"desc random addu"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"addu $2, $2, $16"<<endl;
    infile<<"addu $2, $2, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_and(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = num1&num2;
    infile.open(afile); 
    infile<<"desc random "<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"and $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_andi(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = 0;
    int max = 0xffff;
    int num2 = rand()%(max-min + 1) + min;;
    int ans = num1&num2;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"andi $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_div(string afile){
    string div_q = get_filename(afile)+"a.txt";
    string div_r = get_filename(afile)+"b.txt";
    ofstream infileq; 
    ofstream infiler;
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int q = num1/num2;
    int r = num1%num2;
    infileq.open(div_q); 
    infiler.open(div_r); 
    infileq<<"desc random quotient"<<endl;
    infileq<<"lw $16, 4($zero)"<<endl;
    infileq<<"lw $17, 8($zero)"<<endl;
    infileq<<"sll $0, $0, 0"<<endl;
    infileq<<"div $16, $17"<<endl;
    infileq<<"mflo $2"<<endl;
    infileq<<"jr $0"<<endl;
    infileq<<"sll $0, $0, 0"<<endl;
    infileq<<"data "<<int_to_hex(num1)<<endl;
    infileq<<"data "<<int_to_hex(num2)<<endl;
    infileq<<"#"<<int_to_hex(q);
    infileq.close();
    infiler<<"desc random remainder"<<endl;
    infiler<<"lw $16, 4($zero)"<<endl;
    infiler<<"lw $17, 8($zero)"<<endl;
    infiler<<"sll $0, $0, 0"<<endl;
    infiler<<"div $16, $17"<<endl;
    infiler<<"mfhi $2"<<endl;
    infiler<<"jr $0"<<endl;
    infiler<<"sll $0, $0, 0"<<endl;
    infiler<<"data "<<int_to_hex(num1)<<endl;
    infiler<<"data "<<int_to_hex(num2)<<endl;
    infiler<<"#"<<int_to_hex(r);
    infiler.close();
}

void create_divu(string afile){
    string div_q = get_filename(afile)+"a.txt";
    string div_r = get_filename(afile)+"b.txt";
    ofstream infileq; 
    ofstream infiler;
    srand (time(NULL));
    unsigned int num1 = random_32();
    unsigned int num2 = random_32();
    unsigned int q = num1/num2;
    unsigned int r = num1%num2;
    infileq.open(div_q); 
    infiler.open(div_r); 
    infileq<<"desc random quotient"<<endl;
    infileq<<"lw $16, 4($zero)"<<endl;
    infileq<<"lw $17, 8($zero)"<<endl;
    infileq<<"sll $0, $0, 0"<<endl;
    infileq<<"divu $16, $17"<<endl;
    infileq<<"mflo $2"<<endl;
    infileq<<"jr $0"<<endl;
    infileq<<"sll $0, $0, 0"<<endl;
    infileq<<"data "<<int_to_hex(num1)<<endl;
    infileq<<"data "<<int_to_hex(num2)<<endl;
    infileq<<"#"<<int_to_hex(q);
    infileq.close();
    infiler<<"desc random remainder"<<endl;
    infiler<<"lw $16, 4($zero)"<<endl;
    infiler<<"lw $17, 8($zero)"<<endl;
    infiler<<"sll $0, $0, 0"<<endl;
    infiler<<"divu $16, $17"<<endl;
    infiler<<"mfhi $2"<<endl;
    infiler<<"jr $0"<<endl;
    infiler<<"sll $0, $0, 0"<<endl;
    infiler<<"data "<<int_to_hex(num1)<<endl;
    infiler<<"data "<<int_to_hex(num2)<<endl;
    infiler<<"#"<<int_to_hex(r);
    infiler.close();
}

void create_mult(string afile){
    string mult_l = get_filename(afile)+"a.txt";
    string mult_h = get_filename(afile)+"b.txt";
    ofstream infileh; 
    ofstream infilel;
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    long int x = num1;
    long int y = num2;
    long int ans = x*y;
    int l = 0xffffffff&ans;
    int h = ans>>32;
    infileh.open(mult_l); 
    infilel.open(mult_h); 
    infileh<<"desc random lo"<<endl;
    infileh<<"lw $16, 4($zero)"<<endl;
    infileh<<"lw $17, 8($zero)"<<endl;
    infileh<<"sll $0, $0, 0"<<endl;
    infileh<<"mult $16, $17"<<endl;
    infileh<<"mflo $2"<<endl;
    infileh<<"jr $0"<<endl;
    infileh<<"sll $0, $0, 0"<<endl;
    infileh<<"data "<<int_to_hex(num1)<<endl;
    infileh<<"data "<<int_to_hex(num2)<<endl;
    infileh<<"#"<<int_to_hex(l);
    infileh.close();
    infilel<<"desc random hi"<<endl;
    infilel<<"lw $16, 4($zero)"<<endl;
    infilel<<"lw $17, 8($zero)"<<endl;
    infilel<<"sll $0, $0, 0"<<endl;
    infilel<<"mult $16, $17"<<endl;
    infilel<<"mfhi $2"<<endl;
    infilel<<"jr $0"<<endl;
    infilel<<"sll $0, $0, 0"<<endl;
    infilel<<"data "<<int_to_hex(num1)<<endl;
    infilel<<"data "<<int_to_hex(num2)<<endl;
    infilel<<"#"<<int_to_hex(h);
    infilel.close();
}

void create_multu(string afile){
    string mult_l = get_filename(afile)+"a.txt";
    string mult_h = get_filename(afile)+"b.txt";
    ofstream infileh; 
    ofstream infilel;
    srand (time(NULL));
    unsigned int num1 = random_32();
    unsigned int num2 = random_32();
    long int x = num1;
    long int y = num2;
    unsigned long int ans = x*y;
    int l = 0xffffffff&ans;
    int h = ans>>32;
    infileh.open(mult_l); 
    infilel.open(mult_h); 
    infileh<<"desc random lo"<<endl;
    infileh<<"lw $16, 4($zero)"<<endl;
    infileh<<"lw $17, 8($zero)"<<endl;
    infileh<<"sll $0, $0, 0"<<endl;
    infileh<<"multu $16, $17"<<endl;
    infileh<<"mflo $2"<<endl;
    infileh<<"jr $0"<<endl;
    infileh<<"sll $0, $0, 0"<<endl;
    infileh<<"data "<<int_to_hex(num1)<<endl;
    infileh<<"data "<<int_to_hex(num2)<<endl;
    infileh<<"#"<<int_to_hex(l);
    infileh.close();
    infilel<<"desc random hi"<<endl;
    infilel<<"lw $16, 4($zero)"<<endl;
    infilel<<"lw $17, 8($zero)"<<endl;
    infilel<<"sll $0, $0, 0"<<endl;
    infilel<<"multu $16, $17"<<endl;
    infilel<<"mfhi $2"<<endl;
    infilel<<"jr $0"<<endl;
    infilel<<"sll $0, $0, 0"<<endl;
    infilel<<"data "<<int_to_hex(num1)<<endl;
    infilel<<"data "<<int_to_hex(num2)<<endl;
    infilel<<"#"<<int_to_hex(h);
    infilel.close();
}

void create_lui(string afile){
    ofstream infile; 
    srand (time(NULL));
    int min = 0;
    int max = 0xffff;
    int num1 = rand()%(max-min + 1) + min;
    int num2 = rand()%(max-min + 1) + min;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lui $2, "<<num1<<endl;
    infile<<"lui $2, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"#"<<int_to_hex(num2<<16);
    infile.close();
}

void create_ori(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = 0;
    int max = 0xffff;
    int num2 = rand()%(max-min + 1) + min;
    int ans = num1|num2;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"ori $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_or(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = num1|num2;
    infile.open(afile); 
    infile<<"desc random "<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"or $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_subu(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = 0-num1-num2;
    infile.open(afile); 
    infile<<"desc random two sub"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"subu $2, $2, $16"<<endl;
    infile<<"subu $2, $2, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_xor(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = num1^num2;
    infile.open(afile); 
    infile<<"desc random "<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"xor $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_xori(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = 0;
    int max = 0xffff;
    int num2 = rand()%(max-min + 1) + min;;
    int ans = num1^num2;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"xori $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_sll(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = 0;
    int max = 31;
    int num2 = rand()%(max-min + 1) + min;;
    int ans = num1<<num2;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"sll $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_sllv(string afile){
    ofstream infile; 
    srand (time(NULL));
    unsigned int num1 = random_32();
    unsigned int num2 = random_32();
    int ans = num1<<num2;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"sllv $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_srl(string afile){
    ofstream infile; 
    srand (time(NULL));
    unsigned int num1 = random_32();
    unsigned int min = 0;
    unsigned int max = 31;
    unsigned int num2 = rand()%(max-min + 1) + min;;
    unsigned int ans = num1>>num2;
    infile.open(afile); 
    infile<<"desc random immediate"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"srl $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_srlv(string afile){
    ofstream infile; 
    srand (time(NULL));
    unsigned int num1 = random_32();
    unsigned int num2 = random_32();
    unsigned int ans = num1>>num2;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"srlv $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_sra(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = 0;
    int max = 31;
    int num2 = rand()%(max-min + 1) + min;;
    int ans = num1>>num2;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"sra $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_srav(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = num1>>num2;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"srav $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_slt(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int num2 = random_32();
    int ans = num1<num2;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"slt $2, $17, $16"<<endl;
    infile<<"slt $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_slti(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = -32768;
    int max = 32767;
    int num2 = rand()%(max-min + 1) + min;
    int ans = num1<num2;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"slti $2, $16, 3"<<endl;
    infile<<"slti $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_sltu(string afile){
    ofstream infile; 
    srand (time(NULL));
    unsigned int num1 = random_32();
    unsigned int num2 = random_32();
    int ans = num1<num2;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"lw $17, 8($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"sltu $2, $17, $16"<<endl;
    infile<<"sltu $2, $16, $17"<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"data "<<int_to_hex(num2)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}

void create_sltiu(string afile){
    ofstream infile; 
    srand (time(NULL));
    int num1 = random_32();
    int min = -32768;
    int max = 32767;
    int num2 = rand()%(max-min + 1) + min;
    unsigned int num = num2;
    int ans = num1<num;
    infile.open(afile); 
    infile<<"desc random vals"<<endl;
    infile<<"lw $16, 4($zero)"<<endl;
    infile<<"sll $0, $0, 0"<<endl;
    infile<<"sltiu $2, $16, 4"<<endl;
    infile<<"sltiu $2, $16, "<<num2<<endl;
    infile<<"jr $0"<<endl;
    infile<<"data "<<int_to_hex(num1)<<endl;
    infile<<"#"<<int_to_hex(ans);
    infile.close();
}


int main(int argc, char *argv[]){
    string test_case = argv[1];
    if (size_t pos = test_case.find("addiu")!= string::npos){
        create_addiu(test_case);
    }
    else if (size_t pos = test_case.find("addu")!= string::npos){
        create_addu(test_case);
    }
    else if (size_t pos = test_case.find("andi")!= string::npos){
        create_andi(test_case);
    }
    else if (size_t pos = test_case.find("and_")!= string::npos){
        create_and(test_case);
    }
    else if (size_t pos = test_case.find("subu")!= string::npos){
        create_subu(test_case);
    }
    else if (size_t pos = test_case.find("or_")!= string::npos){
        create_or(test_case);
    }
    else if (size_t pos = test_case.find("ori")!= string::npos){
        create_ori(test_case);
    }
    else if (size_t pos = test_case.find("xori")!= string::npos){
        create_xori(test_case);
    }
    else if (size_t pos = test_case.find("xor_")!= string::npos){
        create_xor(test_case);
    }
    else if (size_t pos = test_case.find("div_")!= string::npos){
        create_div(test_case);
    }
    else if (size_t pos = test_case.find("divu")!= string::npos){
        create_divu(test_case);
    }
    else if (size_t pos = test_case.find("lui")!= string::npos){
        create_lui(test_case);
    }
    else if (size_t pos = test_case.find("mult_")!= string::npos){
        create_mult(test_case);
    }
    else if (size_t pos = test_case.find("multu")!= string::npos){
        create_multu(test_case);
    }
    else if (size_t pos = test_case.find("sra")!= string::npos){
        create_sra(test_case);
    }
    else if (size_t pos = test_case.find("srav")!= string::npos){
        create_srav(test_case);
    }
    else if (size_t pos = test_case.find("srl")!= string::npos){
        create_srl(test_case);
    }
    else if (size_t pos = test_case.find("srlv")!= string::npos){
        create_srlv(test_case);
    }
    else if (size_t pos = test_case.find("sll")!= string::npos){
        create_sll(test_case);
    }
    else if (size_t pos = test_case.find("sllv")!= string::npos){
        create_sllv(test_case);
    }
    else if (size_t pos = test_case.find("slt_")!= string::npos){
        create_slt(test_case);
    }
    else if (size_t pos = test_case.find("slti_")!= string::npos){
        create_slti(test_case);
    }
    else if (size_t pos = test_case.find("sltiu")!= string::npos){
        create_sltiu(test_case);
    }
    else if (size_t pos = test_case.find("sltu")!= string::npos){
        create_sltu(test_case);
    }
    else{
        return 0;
    }

}
