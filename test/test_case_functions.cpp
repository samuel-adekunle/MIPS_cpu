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

using namespace std;

uint16_t wyhash16_x = rand(); 

uint32_t hash16(uint32_t input, uint32_t key) {
  uint32_t hash = input * key;
  return ((hash >> 16) ^ hash) & 0xFFFF;
}


uint16_t wyhash16() {
  wyhash16_x += 0xfc15;
  return hash16(wyhash16_x, 0x2ab);
}
uint16_t rand_16(const uint16_t s) {
    uint16_t x = wyhash16();
    uint32_t m = (uint32_t)x * (uint32_t)s;
    uint16_t l = (uint16_t)m;
    if (l < s) {
        uint16_t t = -s % s;
        while (l < t) {
            x = wyhash16();
            m = (uint32_t)x * (uint32_t)s;
            l = (uint16_t)m;
        }
    }
    return m >> 16;
}
template< typename T >
std::string int_to_hex( T i)
{
  std::stringstream stream;
  stream << "#0x" 
         << std::setfill ('0') << std::setw(sizeof(T)*2) 
         << std::hex << i;
  return stream.str();
}
void create_addiu(string afile){
    ofstream infile; 
    int min = -32768;
    int max = 32767;
    wyhash16_x = rand();
    int num1 = rand_16(0xffff);
    int num2 = rand_16(0xffff);
    int ans = num1+num2;
    infile.open(afile); 
    infile<<"desc random addiu"<<endl;
    infile<<"addiu $2, $2, "+to_string(num1)<<endl;
    infile<<"addiu $2, $2, "+to_string(num2)<<endl;
    infile<<"jr $0"<<endl;
    infile<<int_to_hex(ans);
    infile.close();
}

int main(int argc, char *argv[]){
    string test_case = argv[1];
    if (size_t pos = test_case.find("addiu")!= string::npos){
        create_addiu(test_case);

    }
}
