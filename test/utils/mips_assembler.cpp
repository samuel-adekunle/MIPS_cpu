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

string registerCode( string &r){
    r.erase(remove(r.begin(), r.end(), ','), r.end());
    if(r == "$0" || r == "$zero")
        return "00000";
    if(r == "$1" || r == "$at")
        return "00001";
    if(r == "$2" || r == "$v0")
        return "00010";
    if(r == "$3" || r == "$v1")
        return "00011";
    if(r == "$4" || r == "$a0")
        return "00100";
    if(r == "$5" || r == "$a1")
        return "00101";
    if(r == "$6" || r == "$a2")
        return "00110";
    if(r == "$7" || r == "$a3")
        return "00111";
    if(r == "$8" || r == "$t0")
        return "01000";
    if(r == "$9" || r == "$t1")
        return "01001";
    if(r == "$10" || r == "$t2")
        return "01010";
    if(r == "$11" || r == "$t3")
        return "01011";
    if(r == "$12" || r == "$t4")
        return "01100";
    if(r == "$13" || r == "$t5")
        return "01101";
    if(r == "$14" || r == "$t6")
        return "01110";
    if(r == "$15" || r == "$t7")
        return "01111";

    if(r == "$16" || r == "$s0")
        return "10000";
    if(r == "$17" || r == "$s1")
        return "10001";
    if(r == "$18" || r == "$s2")
        return "10010";
    if(r == "$19" || r == "$s3")
        return "10011";
    if(r == "$20" || r == "$s4")
        return "10100";
    if(r == "$21" || r == "$s5")
        return "10101";
    if(r == "$22" || r == "$s6")
        return "10110";
    if(r == "$23" || r == "$s7")
        return "10111";
    if(r == "$24" || r == "$t8")
        return "11000";
    if(r == "$25" || r == "$t9")
        return "11001";
    if(r == "$26" || r == "$k0")
        return "11010";
    if(r == "$27" || r == "$k1")
        return "11011";
    if(r == "$28" || r == "$gp")
        return "11100";
    if(r == "$29" || r == "$sp")
        return "11101";
    if(r == "$30" || r == "$fp")
        return "11110";
    else
        return "11111";
}




string I_TypeProcess(vector<string> &params){
    string opcode, Rs, Rt, imm;
    string temp;
    string imm_Rs;
    string op = params[0];
    // op rs rt imm
    if(op == "beq" || op == "bne"){
        Rs = registerCode(params[1]);
        Rt = registerCode(params[2]);
        //imm = signExtend(params[3]); //need some calculating here
        if(op == "beq")
            opcode = "000100";
        else if(op == "bne")
            opcode = "000101";
        else
            ;
    }
    //op rt rs imm
    else if(op == "addi" || op == "addiu" || op == "andi" || op == "ori" ||
            op == "xori" || op == "slti"  || op == "slti" || op == "sltiu"){
        Rt = registerCode(params[1]);
        Rs = registerCode(params[2]);
        int num = stoi(params[3]);
        if(op == "addi" || op == "slti" || op == "sltiu"|| op == "addiu"){
            bitset<16> y(num);
            imm = y.to_string<char,string::traits_type,string::allocator_type>();
        }else{ 
            //supposed to 0 extend
            bitset<16> y(num);
            imm = y.to_string<char,string::traits_type,string::allocator_type>();
        }

        if(op == "addi")
            opcode = "001000";
        else if(op == "addiu")
            opcode = "001001";
        else if(op == "andi")
            opcode = "001100";
        else if(op == "ori")
            opcode = "001101";
        else if(op == "xori")
            opcode = "001110";
        else if(op == "slti")
            opcode = "001010";
        else if(op == "sltiu")
            opcode = "001011";
        else
            ;
    }
     // op rt imm(rs)
    else if(op == "lw" || op == "sw" || op == "lb" || op == "lbu" || op == "lh" ||
            op == "lhu" || op == "sb" || op == "sb" || op == "sh"){
        Rt = registerCode(params[1]);
        //get the thing in the reg
        string reg = params[2];
        size_t spos = reg.find("(");
        size_t epos = reg.find(")");
        string reg_val = (reg).substr(spos+1, epos-spos-1);
        Rs = registerCode(reg_val);
        int imm_reg= stoi(reg.substr(0, spos));
        bitset<16> y(imm_reg);
        imm = y.to_string<char,string::traits_type,string::allocator_type>();

        if(op == "lw")
            opcode = "100011";
        else if(op == "sw")
            opcode = "101011";
        else if(op == "lb")
            opcode = "100000";
        else if(op == "lbu")
            opcode = "100100";
        else if(op == "lh")
            opcode = "100001";
        else if(op == "lhu")
            opcode = "100101";
        else if(op == "sb")
            opcode = "101000";
        else if(op == "sh")
            opcode = "101001";
        else
            ;
    }

    // op rt imm
    else if(op == "lui"){
        Rt = registerCode(params[1]);

        Rs = "00000";

        bitset<16> y(params[2]);
        imm = y.to_string<char,string::traits_type,string::allocator_type>();

        opcode = "001111";
    }

    // op rs imm
    else if(op == "blez" || op == "bltz" || op == "bgtz" || op == "bgez"){
        Rs = registerCode(params[1]);
        //get address for jump, add to counter
        bitset<16> y(params[2]);
        imm = y.to_string<char,string::traits_type,string::allocator_type>();

        if(op == "bgez"){
            opcode = "000001";
            Rt = "00001";
        }
        else if(op == "bgtz"){
            opcode = "000111";
            Rt = "00000";
        }
        else if(op == "blez"){
            opcode = "000110";
            Rt = "00000";
        }
        else if(op == "bltz"){
            opcode = "000001";
            Rt = "00000";
        }

        else
            ;
    }
    return(opcode+Rs+Rt+imm);
}

string J_TypeProcess(vector<string> &params){
    string op = params[0];
    string opcode, target;
    int temp;
    if(op == "j")
        opcode = "000010";
    else if(op == "jal")
        opcode = "000011";
    bitset<26> y(params[1]);
    target = y.to_string<char,string::traits_type,string::allocator_type>();
    return (opcode+target);

}
int main(int argc, const char * argv[]) {
    set<string>I_TYPE{"addiu","andi","beq","bgez","bgezal","bgtz","blez","bltz","bltzal",
    "bne","lb","lbu","lh","lhu","lui","lw","ori","sb","sh","slti","sltiu","sw","xori"};
    set<string>R_TYPE{"addu","and","div","divu","jr","mfhi","mthi","mflo","mtlo","mult","multu",
    "or","sll","sllv","slt","slti","sltiu","sltu","sra","srav","srl","srlv","subu","xor"};
    set<string>J_TYPE{"j", "jal", "jalr"};
    if (argv[1] == NULL) {
        printf("no file specified\n");
        return 0;
    }
    ifstream file(argv[1]);
    vector<string>lines;
    if (file.is_open()) {
        string line;
        while (std::getline(file, line)) {
            lines.push_back(line.c_str());
        }
    file.close();
    }
    cout << hex;    // Print everything in hex
    cout << setw(8); // Always print 8 digits
    cout << setfill('0'); // Pad with 0 digit

    for (int i = 0;i<lines.size();i++){
        string line = lines[i];
        if (line.find('.') == string::npos&&line.find(':') == string::npos){ //ignore the things with dots and location for now
            istringstream iss(line);//split by spaces
            vector<string> params((istream_iterator<string>(iss)),istream_iterator<string>());
            string binary_string;
            if (I_TYPE.find(params[0]) != I_TYPE.end()){
                cout<<I_TypeProcess(params)<<endl;
                //cout<<assemble_i(params)<<endl;
            }else if (R_TYPE.find(params[0]) != R_TYPE.end()){
                cout<<"R"<<endl;
            }else if (J_TYPE.find(params[0]) != J_TYPE.end()){
                cout<<J_TypeProcess(params)<<endl;
            }else{
                cout<<0x00000000<<endl; //no op
            }
        }
    }

    
};