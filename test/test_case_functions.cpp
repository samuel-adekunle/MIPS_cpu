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
void create_addiu(string afile){
    ofstream infile; 
    int min = -32768;
    int max = 32767;
    srand (time(NULL));
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

int main(int argc, char *argv[]){
    string test_case = argv[1];
    if (size_t pos = test_case.find("addiu")!= string::npos){
        create_addiu(test_case);
    }
    else if (size_t pos = test_case.find("addu")!= string::npos){
        create_addu(test_case);
    }
}
